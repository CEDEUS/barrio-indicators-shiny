
# barrio-indicators-shiny

[![license](https://img.shields.io/github/license/CEDEUS/barrio-indicators-shiny.svg)]()
[![license](https://img.shields.io/github/languages/top/CEDEUS/barrio-indicators-shiny.svg)]()

Platform to visualize data from barrios

# Screenshot

![shot](/images/shot1.png)


## Currently using data from:

- Census 2012
- Walkscore
- SII

## Technologies:

- R
- Shiny
- Tidyverse
- Leaflet
- Mapbox

## Barrios in database:

| ID                         | BARRIO                                        | CIUDAD                      | COMUNA        |
|----------------------------|-----------------------------------------------|-----------------------------|---------------|
| 1                          | Barrio Amanecer                               | Temuco - Padre Las Casas    | Temuco        |
| 2                          | Barrio Estación                               | Temuco - Padre Las Casas    | Temuco        |
| 3                          | Camilo Henriquez                              | Gran Concepción             | Concepción    |
| 4                          | Fundo El Carmen                               | Temuco                      | Temuco        |
| 5                          | Lomas de San Sebastian                        | Gran Concepción             | Concepción    |
| 6                          | Villa Los Fundadores                          | Valdivia                    | Valdivia      |
| 7                          | Parque Krahmer                                | Valdivia                    | Valdivia      |
| 8                          | Sector Regional                               | Valdivia                    | Valdivia      |
| 9                          | Barrio Brasil                                 | Gran Santiago               | Santiago      |
| 10                         | Villa Codelco                                 | Copiapó                     | Copiapó       |
| 11                         | Tierra Viva Oriente                           | Copiapó                     | Copiapó       |
| 12                         | El Llano                                      | Gran Coquimbo               | Coquimbo      |
| 13                         | Villa Vista Hermosa                           | Gran Coquimbo               | La Serena     |
| 14                         | Barrio San Miguel                             | Gran Santiago               | San Miguel    |
| 15                         | Barrio Las Lilas                              | Gran Santiago               | Providencia   |
| 16                         | Barrio Jardin del Este                        | Gran Santiago               | Vitacura      |
| 17                         | Barrio Plaza de Maipú                         | Gran Santiago               | Maipú         |
| 18                         | Barrios Bajos                                 | Valdivia                    | Valdivia      |
| 19                         | Guayacán                                      | Gran Coquimbo               | Coquimbo      |
| 20                         | Villa Esperanza                               | Copiapó                     | Copiapó       |
| 21                         | El Faro Parte Alta                            | Gran Coquimbo               | Coquimbo      |
| 22                         | Juan XXIII                                    | Gran Coquimbo               | La Serena     |
| 23                         | Chorrillos                                    | Gran Santiago               | Independencia |
| 24                         | Brasilia                                      | Gran Santiago               | San Miguel    |
| 25                         | El Mariscal                                   | Gran Santiago               | Puente Alto   |
| 26                         | U.V. 35 José María Caro                       | Gran Santiago               | Lo Espejo     |
| 27                         | Pucará de Lasana                              | Gran Santiago               | Quilicura     |
| 28                         | Juan González Huerta                          | Gran Concepción             | Talcahuano    |
| 29                         | Cerro Verde Alto                              | Gran Concepción             | Penco         |
| 30                         | Leonera 2                                     | Gran Concepción             | Chiguayante   |
| 31                         | Padre Hurtado (CCSS)                          | Temuco - Padre Las Casas    | Temuco        |
| 32                         | Las Quilas                                    | Temuco - Padre Las Casas    | Temuco        |

## ¿How data inside databases is organized?

```
> head(readRDS("accesibility_score_final_15.RDS"))
           ID_W value               d
1 9112041001032    36 Barrio Amanecer
2 9101171003040    75 Barrio Amanecer
3 9101171003002    52 Barrio Amanecer
4 9101171001001    54 Barrio Amanecer
5 9101171003028    65 Barrio Amanecer
6 9101171002002    80 Barrio Amanecer

```

| COLUMN | DESCRIPTION                    |
|--------|--------------------------------|
| ID_W   | Census code related to manzana |
| value  | Score of the indicator         |
| d      | Barrio's name                  |

## Hey! In your code you have a hidden data.frame to specify the legend and codenames of databases!

Yes I have one and I'm using it because I'm lazy to externalize the data.frame. In a future version and when the amount of indicators change I'll add a external dataset to add custom parameters.

## What's the procedure to add a new variable?

- First you have to set up a database using the specifications above
- Then edit the hidden data.frames and choose a view (at the moment I have 3)

## What's the procedure to add a new barrios?

- First you have to download the shapes and load everything in R
- Add your current barrios file, and run the scripts in add_new_barrios folder

## Roadmap

TODO

| ID | DESCRIPTION                                             | ESTIMATED      |
|----|---------------------------------------------------------|----------------|
| 1  | Add initial year in the year of construction indicator  | DONE           |
| 2  | Add last year in the year of construction indicator     | DONE           |
| 3  | Add avaluo fiscal indicator                             | DONE           |
| 4  | Fix bugs on the platform                                | DONE           |
| 5  | Add indicator of cars by housing                        | DONE           |
| 6  | Count houses in every manzana                           | DONE           |
| 7  | Add dropdown to select location                         | DONE           |


