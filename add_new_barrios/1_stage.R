library(tidyverse)
library(rgdal)
library(rgeos)
library(sp)
library(maptools)

# You have to use the orig barrios file

barrios_p <- read_rds("orig/barrios_pil.RDS")

# Setting up the projection

crs <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0")

# Loading the barrios (this is an example)

br <- readOGR("nuevos_barrios_shp/barrioamanecer.shp", "barrioamanecer")
cd <- readOGR("nuevos_barrios_shp/barrioestacion.shp", "barrioestacion")
vo <- readOGR("nuevos_barrios_shp/camilohenriquez.shp", "camilohenriquez")
el <- readOGR("nuevos_barrios_shp/fundoelcarmen.shp", "fundoelcarmen")

# Join everything

nbarrios <- rbind(br,cd,vo,el)

# Adding data to the shape

nbarrios@data <- read_delim("Id	BARRIO	CIUDAD	COMUNA
0	Barrio Amanecer	Temuco	Temuco
0	Barrio Estación	Temuco	Temuco
0	Camilo Henriquez	Gran Concepción	Concepción
0	Fundo El Carmen	Temuco	Temuco
",delim="\t")

# Setting up the projection

nbarrios <- spTransform(nbarrios, crs)

# Join with the prexistent barrios 

barrios_p <- rbind(nbarrios,barrios_p)

# Adding data frame

barrios_p@data <- as.data.frame(barrios_p@data)

# Setting up the projection

barrios_p <- spTransform(barrios_p,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0"))

# Writing file with the barrio shapes

write_rds(barrios_p,"barrios_pil.RDS")

rm(list=ls())
