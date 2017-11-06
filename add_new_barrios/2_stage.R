library(tidyverse)
library(rgdal)
library(rgeos)
library(sp)
library(maptools)
library(spdplyr)

#Loading barrios shape

barrios_p<-read_rds("barrios_pil.RDS")

# Ciudades Cedeus

sa <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_13.gdb/","MANZANA")
sd <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_14.gdb/","MANZANA")
fg <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_4.gdb/","MANZANA")
ff <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_3.gdb/","MANZANA")
kr <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_9.gdb/","MANZANA")
pq <- readOGR("Mapa Manzanas sin CODSII (geometría buena) - Cartografia Precenso 2011 - Público/Carto_Region_8.gdb/","MANZANA")

# Joining shapes

barrios_m <- rbind(sa,sd,fg,ff,kr,pq)

# Establishing projection

crs <- CRS("+init=epsg:32719") # Projeccion

barrios_p <- spTransform(barrios_p, crs) 
barrios_m <- spTransform(barrios_m, crs)

# Creating buffer

buffer <- gBuffer(barrios_p, width=1000, byid=TRUE,capStyle="FLAT")

# Cutting

buffer <- over(buffer,barrios_m,returnList=TRUE)

barrios_list <- as.list(barrios_p@data$BARRIO)

barrios <- mapply(function(x) barrios_m[as.numeric(rownames(x)),], buffer)
barrios <- mapply(cbind, barrios, barrios_list, SIMPLIFY=F)
barrios <- lapply(barrios, setNames, c("CUT", "AREA_C", "MANZENT", "DISTRITO", "ZONA", "MANZANA", "SHAPE_Length", "SHAPE_Area", "BARRIO"))
barrios <- do.call(rbind, barrios)

# Setting up the projection

barrios <- spTransform(barrios,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0"))

# Writing barrio's buffer with census manzanas

write_rds(barrios,"barrios_merged.RDS")

