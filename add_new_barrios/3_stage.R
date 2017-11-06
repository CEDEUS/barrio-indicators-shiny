library(tidyverse)
library(rgdal)
library(rgeos)
library(sp)
library(maptools)
library(spdplyr)

# Reading last shapes

barrios_p<-read_rds("barrios_pil.RDS")
barrios_m<-read_rds("barrios_merged.RDS")

# Intersection

manzbarr <- over(barrios_p,barrios_m,returnList=TRUE)

# Joining

manzbarr <- do.call(rbind, manzbarr)

manzbarr<-left_join(barrios_p@data,manzbarr,by=c("BARRIO"))

# Writing census manzanas inside barrio polygon 

write_rds(manzbarr,"Manzanasbarriospiloto.RDS")

# Writing test shapefiles

writeOGR(barrios_p,"test", "piloto", driver="ESRI Shapefile")
writeOGR(barrios,"barrios", "piloto", driver="ESRI Shapefile")
