---
title: How the app works
author: ''
date: '2017-12-11'
slug: how-the-application-works
categories: []
tags: []
menu: 'main'
weight: 60
---

## 1 - Loading databases

The first section of the app before the initialization of the server load the databases

```
#Loading required databases

barrios_m <- readRDS("Data/barrios_merged.RDS")
barrios_p <- readRDS("Data/barrios_pil.RDS")

manzbarr <- readRDS("Data/Manzanasbarriospiloto.RDS")

empl <- readRDS("Data/empleabilidadmismacomuna.RDS")
matr <- readRDS("Data/materialidad.RDS")
mujt <- readRDS("Data/mujerestrabajando.RDS")
acte <- readRDS("Data/accesotecnologia.RDS")
aav <- readRDS("Data/aav.RDS")
acc <- readRDS("Data/accesibility_score_final.RDS")
acc2 <- readRDS("Data/accesibility_score_final_15.RDS")
acntrmin <- readRDS("Data/anoconstruccion_min.RDS")
acntrmax <- readRDS("Data/anoconstruccion_max.RDS")
vehiculos <- readRDS("Data/vehiculos.RDS")
avaluo <- readRDS("Data/valuesii.RDS")
personas <- readRDS("Data/numerodepersonas.RDS")
```

## 2 - Fixing encoding

Then the encoding is fixed using an small function

```
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
acntrmin <- fix.encoding(acntrmin)
acntrmax <- fix.encoding(acntrmax)
personas <- fix.encoding(personas)
```

## 3 - Inside the Shiny app, creating UI elements

The second part of the app starts inside the shiny function before ```function(input, output, session) { ... }``` creating some UI elements called dropdowns to change the city, barrio and selected variable.

```
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
    options <- c("% Viviendas de buena calidad",
                 "% Mujeres trabajando",
                 "% Empleados en la misma comuna",
                 "% Acceso a tecnologias de la información",
                 "Cercanía a Areas Verdes","Caminabilidad a servicios urbanos - 10 min - 1.25 m/s",
                 "Caminabilidad a servicios urbanos - 15 min - 1.38 m/s",
                 "Mediana de años de construcción (Año mínimo)",
                 "Mediana de años de construcción (Año máximo)",
                 "Presencia de vehiculos",
                 "Avaluo",
                 "Personas"
                 )
    selectInput("VarU", "Variable", choices = options, selected = options[1])
  })
  
```

## 4 - Creating the observer

The element called _observeEvent_  ```observeEvent({c(input$VarU,input$BarrioSelection)},{ ... })``` continuously checks for the values of the dropdowns  _input$VarU_ and _input$BarrioSelection_ so if a change on them ocurrs the value is updated on the entire app. The trick to prevent early loading of the values is the function _req()_ what waits for the values _because one depends of another_.

```
    req(input$VarU)
    req(input$BarrioSelection)
```

## 5 - The hidden data.frame

This small database asigns the _big name_ of every indicator with their correspondent database and specify a legend type.

```
    VarList <- data.frame(var=c("% Viviendas de buena calidad",
                                "% Mujeres trabajando",
                                "% Empleados en la misma comuna",
                                "% Acceso a tecnologias de la información",
                                "Cercanía a Areas Verdes",
                                "Caminabilidad a servicios urbanos - 10 min - 1.25 m/s",
                                "Caminabilidad a servicios urbanos - 15 min - 1.38 m/s",
                                "Mediana de años de construcción (Año mínimo)",
                                "Mediana de años de construcción (Año máximo)",
                                "Presencia de vehiculos",
                                "Avaluo",
                                "Personas"),
                          db=c("matr","mujt","empl","acte","aav","acc","acc2","acntrmin","acntrmax","vehiculos","avaluo","personas"),
                          legend=c(1,1,1,1,2,1,1,3,3,1,4,5))
```

## 6 - Database loading and starting the calculations

The _db_ variable dynamically get the correct database based on the dropdown selection and loads it. The following conditional fuction discriminate between variables with barrios and manzana and variables only with their manzanas values using their number of rows. Once we have everything on board two joins are created one for the barrios manzanas and another for the entire buffer. Then the calculations of the means, variance and units for the barrio and the buffer are calculated and exposed in the UI using small boxes called _valueBox_

```
    db <- eval(as.name(as.character(VarList[match(input$VarU,VarList$var),]$db)))
    
    if(suppressWarnings(nrow(db[db$d==input$BarrioSelection,]))>0){
      data <- db[db$d==input$BarrioSelection,] %>% mutate(MANZENT=ID_W)
    } else {
      data <- db %>% mutate(MANZENT=ID_W)
    }
    
    shape <<- sp::merge(barrios_m,data,by="MANZENT")
    shape_barr <- base::merge(manzbarr,data,by="MANZENT")
    
    meanbarrio <- round(mean(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm=T),2)
    meansmall <- round(mean(subset(shape_barr,BARRIO == input$BarrioSelection)$listo,na.rm=T),2)
    
    variancebarrio <- round(sd(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm=T),2)
    variancesmall <- round(sd(subset(shape_barr,BARRIO == input$BarrioSelection)$listo,na.rm=T),2)
    
    unitscounterbarrio <- length(subset(shape,BARRIO == input$BarrioSelection)$listo)
    unitscountersmall <- length(subset(shape_barr,BARRIO == input$BarrioSelection)$listo)
    
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
```

## 7 - The map

Inside ```renderLeaflet({ ... })``` the map is created. First, Leaflet gets a polygon subsetted by the barrio selected then add tiles from Mapbox and then a attribution creating the base map. Second, a popup is created to get every value of the manzana units on click over them. Third, four color palettes based on viridis are created to reflect the values of the correspondent indicator.  Fourth, the _datamap_ variable is created to store the current barrio selected, then a proxy updates the values of the map without reloading conditionally by the legend value, so we can have different elements by indicator.

```
      leaflet(filter(shape,BARRIO == input$BarrioSelection)) %>% 
        addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/robsalasco/cizaf21t600762rmu7spm9p06/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9ic2FsYXNjbyIsImEiOiJjaWcxbzh1bjAxMHhodXdsdnczZ28xOHc1In0.WkFivOlHKIMwx30ssZorBw",attribution = 'Mapa por <a href="http://www.mapbox.com/">Mapbox</a> | Aplicación por <a href="mailto:rosalas@uc.cl">Roberto Salas</a>') 
    })
    
    state_popup <- paste0(round(subset(shape,BARRIO == input$BarrioSelection)$listo,2),sep="")
    
    palette <- colorBin(viridis_pal()(11), 
                        bins = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100), na.color = "#FFFFFF00")
    
    palette.contru <- colorBin(viridis_pal()(11), 
                                bins = c(0, 1920.0, 1940.0,1950.0, 1960.0, 1970.0, 1980.0, 1990.0, 2000.0, 2010.0, 2020.0),na.color = "#FFFFFF00")
    palette.avaluo <- colorBin(viridis_pal()(11), 
                               bins = cbreaks(c(min(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm = T), max(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm = T)), pretty_breaks(9))$breaks, na.color = "#FFFFFF00")
    
    palette.personas <- colorBin(viridis_pal()(11), 
                               bins = cbreaks(c(min(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm = T), max(subset(shape,BARRIO == input$BarrioSelection)$listo,na.rm = T)), pretty_breaks(9))$breaks, na.color = "#FFFFFF00")
    
    
    datamap <- filter(shape,BARRIO == input$BarrioSelection)
    proxy <- leafletProxy("busmap",data=datamap)
    proxy %>% clearControls()
    if (VarList[match(input$VarU,VarList$var),]$legend == 1)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>%
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette(listo),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette, values = ~listo,
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
                    fillColor = ~palette(listo),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", colors = viridis_pal()(2), values = ~listo,
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
                    fillColor = ~palette.contru(listo),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette.contru, values = ~listo,
                         title = "",
                         opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    }
    else if (VarList[match(input$VarU,VarList$var),]$legend == 4)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>%
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette.avaluo(listo),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette.avaluo, values = ~listo,
                                                                                                                         title = "",
                                                                                                                         opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    }
    else if (VarList[match(input$VarU,VarList$var),]$legend == 5)
    {proxy %>% fitBounds(lng1 = bbox(datamap)[[3]],lat1 = bbox(datamap)[[4]], lng2 = bbox(datamap)[[1]],lat2 = bbox(datamap)[[2]]) %>%
        addPolygons(weight = 0.5,
                    color = '#444444',
                    fillOpacity = 1,
                    fillColor = ~palette.personas(listo),
                    popup = state_popup,stroke = TRUE, group = "Variable") %>% 
        addPolygons(data = barrios_p %>% filter(BARRIO == input$BarrioSelection),
                    weight = 4, color = 'red', fillOpacity = 0, fillColor = '#000000', group = "Poligono") %>% addLegend("bottomright", pal = palette.personas, values = ~listo,
                                                                                                                         title = "",
                                                                                                                         opacity = 1) %>% 
        addLayersControl(overlayGroups = c("Variable", "Poligono"),
                         options = layersControlOptions(collapsed = T))
    }
```




