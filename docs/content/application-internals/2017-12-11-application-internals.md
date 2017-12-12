---
title: Application Internals
author: ''
date: '2017-12-11'
slug: application-internals
categories: []
tags: []
menu: 'main'
weight: 50
---

## Directory structure

The application have a data directory what contains for every indicator a RDS file. I have some special files too ```Manzanasbarriospiloto.RDS```, ```barrios_merged.RDS``` and ```barrios_pil.RDS``` what are gonna be explained in the next section. The ```ui.R``` and the ```server.R``` files are the core of this application, the first is related, as the name says, the user interface and the second contains all the functions to make everything dynamic.

```
rsalas@basicubuntu1404forr:/srv/shiny-server/barriossust$ tree
.
├── Data
│   ├── aav.RDS
│   ├── accesibility_score_final_15.RDS
│   ├── accesibility_score_final.RDS
│   ├── accesotecnologia.RDS
│   ├── anoconstruccion_max.RDS
│   ├── anoconstruccion_min.RDS
│   ├── anoconstruccion.RDS
│   ├── barrios_merged.RDS
│   ├── barrios_pil.RDS
│   ├── empleabilidadmismacomuna.RDS
│   ├── Manzanasbarriospiloto.RDS
│   ├── materialidad.RDS
│   ├── mujerestrabajando.RDS
│   ├── numerodepersonas.RDS
│   ├── valuesii.RDS
│   └── vehiculos.RDS
├── description.md
├── helpers.R
├── server.R
├── Shiny_Indicadores.Rproj
└── ui.R

1 directory, 21 files
```

## Special data files

They are special because contains the polygons of the barrios. In the next table I'll explain this better.

| Database                  | Contains                                                             |
|---------------------------|----------------------------------------------------------------------|
| Manzanasbarriospiloto.RDS | All the census manzanas related to the barrio itself and their codes |
| barrios_pil.RDS           | The barrio polygon                                                   |
| barrios_merged.RDS        | The buffer around the barrio polygons with the census manzanas       |

## Indicators

Currently I have 12 indicators builded and running on the visualization.

|    | Large name                                            | Codename  | Path                                 |
|----|-------------------------------------------------------|-----------|--------------------------------------|
| 1  | % Empleados en la misma comuna                        | empl      | Data/empleabilidadmismacomuna.RDS    |
| 2  | % Viviendas de buena calidad                          | matr      | Data/materialidad.RDS                |
| 3  | % Mujeres trabajando                                  | mujt      | Data/mujerestrabajando.RDS           |
| 4  | % Acceso a tecnologias de la información              | acte      | Data/accesotecnologia.RDS            |
| 5  | Cercanía a Areas Verdes                               | aav       | Data/aav.RDS                         |
| 6  | Caminabilidad a servicios urbanos - 10 min - 1.25 m/s | acc       | Data/accesibility_score_final.RDS    |
| 7  | Caminabilidad a servicios urbanos - 15 min - 1.38 m/s | acc2      | Data/accesibility_score_final_15.RDS |
| 8  | Mediana de años de construcción (Año mínimo)          | acntrmin  | Data/anoconstruccion_min.RDS         |
| 9  | Mediana de años de construcción (Año máximo)          | acntrmax  | Data/anoconstruccion_max.RDS         |
| 10 | Presencia de vehiculos                                | vehiculos | Data/vehiculos.RDS                   |
| 11 | Avaluo                                                | avaluo    | Data/valuesii.RDS                    |
| 12 | Personas                                              | personas  | Data/numerodepersonas.RDS            |
