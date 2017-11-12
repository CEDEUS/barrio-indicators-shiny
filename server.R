# Loading required libraries

library(shinydashboard)
library(leaflet)
library(dplyr)
library(spdplyr)
library(RColorBrewer)
library(viridis)
library(reshape2)

# Disabling trace

options(shiny.trace=F)

# Adding Jan Vydra's fix encoding function from https://stackoverflow.com/questions/34024654/reading-rdata-file-with-different-encoding

fix.encoding <- function(df, originalEncoding = "UTF-8") {
  numCols <- ncol(df)
  df <- data.frame(df)
  for (col in 1:numCols)
  {
    if(class(df[, col]) == "character"){
      Encoding(df[, col]) <- originalEncoding
    }
    
    if(class(df[, col]) == "factor"){
      Encoding(levels(df[, col])) <- originalEncoding
    }
  }
  return(as_data_frame(df))
}


# Loading shapes

barrios_m <- readRDS("Data/barrios_merged.RDS")
barrios_p <- readRDS("Data/barrios_pil.RDS")

manzbarr <- readRDS("Data/Manzanasbarriospiloto.RDS")

# Loading databases

empl <- readRDS("Data/empleabilidadmismacomuna.RDS")
matr <- readRDS("Data/materialidad.RDS")
mujt <- readRDS("Data/mujerestrabajando.RDS")
acte <- readRDS("Data/accesotecnologia.RDS")
aav <- readRDS("Data/aav.RDS")
acc <- readRDS("Data/accesibility_score_final.RDS")
acc2 <- readRDS("Data/accesibility_score_final_15.RDS")
acntr <- readRDS("Data/anoconstruccion.RDS")

#Fix encoding

barrios_m@data <- fix.encoding(barrios_m@data)
barrios_p@data <- fix.encoding(barrios_p@data)

manzbarr <- fix.encoding(manzbarr)

empl <- fix.encoding(empl)
matr <- fix.encoding(matr)
mujt <- fix.encoding(mujt)
acte <- fix.encoding(acte)
aav <- fix.encoding(aav)
acc <- fix.encoding(acc)
acc2 <- fix.encoding(acc2)
acntr <- fix.encoding(acntr)

# Shiny starts here

function(input, output, session) {

# Adding data to dropdown's

  output$Ciudad <- renderUI({
    ciudadesList <- unique(barrios_p@data$CIUDAD)
    selectInput("CiudadSelection", "Ciudad", choices = ciudadesList, selected = ciudadesList[1])
  })
  
  output$Barrio <- renderUI({
    req(input$CiudadSelection)
    filtered <- filter(barrios_p@data, CIUDAD == input$CiudadSelection)
    routeNums <- filtered$BARRIO
    selectInput("BarrioSelection", "Barrio", choices = routeNums, selected = routeNums[1])
  })
  
  output$Variable <- renderUI({
    options <- c("% Viviendas de buena calidad","% Mujeres trabajando","% Empleados en la misma comuna","% Acceso a tecnologias de la información","Cercanía a Areas Verdes","Caminabilidad a servicios urbanos - 10 min - 1.25 m/s","Caminabilidad a servicios urbanos - 15 min - 1.38 m/s","Mediana de años de construcción")
    selectInput("VarU", "Variable", choices = options, selected = options[1])
  })

# Setting up an observer
  
  observeEvent({c(input$VarU,input$BarrioSelection)},{

    req(input$VarU)
    req(input$BarrioSelection)
    
    VarList <- data.frame(var=c("% Viviendas de buena calidad","% Mujeres trabajando","% Empleados en la misma comuna","% Acceso a tecnologias de la información","Cercanía a Areas Verdes","Caminabilidad a servicios urbanos - 10 min - 1.25 m/s","Caminabilidad a servicios urbanos - 15 min - 1.38 m/s","Mediana de años de construcción"),db=c("matr","mujt","empl","acte","aav","acc","acc2","acntr"),legend=c(1,1,1,1,2,1,1,3))
    
    db <- eval(as.name(as.character(VarList[match(input$VarU,VarList$var),]$db)))
    
    # Getting data
    
    if(suppressWarnings(nrow(db[db$d==input$BarrioSelection,]))>0){
      data <- db[db$d==input$BarrioSelection,] %>% mutate(MANZENT=ID_W)
    } else {
      data <- db %>% mutate(MANZENT=ID_W)
    }

    # Doing merges
    
    shape <<- sp::merge(barrios_m,data,by="MANZENT") # Dirrrrrty
    shape_barr <- base::merge(manzbarr,data,by="MANZENT")
    
    # Calculating the mean and the variance for units

    meanbarrio <- round(mean(subset(shape,BARRIO == input$BarrioSelection)$value,na.rm=T),2)
    meansmall <- round(mean(subset(shape_barr,BARRIO == input$BarrioSelection)$value,na.rm=T),2)
    
    variancebarrio <- round(sd(subset(shape,BARRIO == input$BarrioSelection)$value,na.rm=T),2)
    variancesmall <- round(sd(subset(shape_barr,BARRIO == input$BarrioSelection)$value,na.rm=T),2)
    
    unitscounterbarrio <- length(subset(shape,BARRIO == input$BarrioSelection)$value)
    unitscountersmall <- length(subset(shape_barr,BARRIO == input$BarrioSelection)$value)
    
    # Displaying the values

    output$unitsBox <- renderValueBox({
      valueBox(
        paste(unitscountersmall,"/",unitscounterbarrio,sep=" "), "Unidades (Barrio/Buffer)",
        color = "purple"
      )})
    
    output$meanBox <- renderValueBox({
      valueBox(
        paste(meansmall,"/",meanbarrio,sep=" "), "Promedio (Barrio/Buffer)",
        color = "purple"
      )})
    
    output$varianceBox <- renderValueBox({
      valueBox(
        paste(variancesmall,"/",variancebarrio,sep=" "), "Desviación Estándar (Barrio/Buffer)",
        color = "purple"
      )})
    
    # Map here custom from mapbox!

    output$vizmap <- renderLeaflet({
      
      leaflet(filter(shape,BARRIO == input$BarrioSelection)) %>% 
        addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/robsalasco/cizaf21t600762rmu7spm9p06/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9ic2FsYXNjbyIsImEiOiJjaWcxbzh1bjAxMHhodXdsdnczZ28xOHc1In0.WkFivOlHKIMwx30ssZorBw",attribution = 'Mapa por <a href="http://www.mapbox.com/">Mapbox</a> | Aplicación por <a href="mailto:rosalasATuc.cl">Roberto Salas</a>') 
    })

    VarList <- data.frame(var=c("% Viviendas de buena calidad","% Mujeres trabajando","% Empleados en la misma comuna","% Acceso a tecnologias de la información","Cercanía a Areas Verdes","Caminabilidad a servicios urbanos - 10 min - 1.25 m/s","Caminabilidad a servicios urbanos - 15 min - 1.38 m/s","Mediana de años de construcción"),db=c("matr","mujt","empl","acte","aav","acc","acc2","acntr"),legend=c(1,1,1,1,2,1,1,3))
    state_popup <- paste0(round(subset(shape,BARRIO == input$BarrioSelection)$value,2),sep="")

    # Loading palettes again (maybe I have to remove it)
    
    palette <- colorBin(viridis_pal()(11), 
                        bins = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100), na.color = "#FFFFFF00")
    
    palette.contru <- colorBin(viridis_pal()(11), 
                                bins = c(0, 1920.0, 1940.0,1950.0, 1960.0, 1970.0, 1980.0, 1990.0, 2000.0, 2010.0, 2020.0),na.color = "#FFFFFF00")
    
    # Subset

    datamap <- filter(shape,BARRIO == input$BarrioSelection)

    # Proxy to update on the fly because we are using different units of measure

    proxy <- leafletProxy("vizmap",data=datamap)
    proxy %>% clearControls()
    if (VarList[match(input$VarU,VarList$var),]$legend == 1)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>%
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette(value),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette, values = ~value,
                                  title = "",
                                  labFormat = labelFormat(suffix = "%"),
                                  opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    } 
    else if (VarList[match(input$VarU,VarList$var),]$legend == 2)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>% 
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette(value),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", colors = viridis_pal()(2), values = ~value,
                         title = "",
                         labels= c("No","Si"),
                         opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    } 
    else if (VarList[match(input$VarU,VarList$var),]$legend == 3)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>%
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette.contru(value),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette.contru, values = ~value,
                         title = "",
                         opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    } 
  })
  
  # Credits

  output$Texto <- renderUI({
    HTML(paste("<p style='text-align:center'><a href='http://www.cedeus.cl'><img src='http://www.cedeus.cl/wp-content/themes/cedeus/img/logo.png' height='52'></a></p>"))
  })
  
  
  
  
}