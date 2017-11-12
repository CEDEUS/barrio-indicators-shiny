# Loading required libs

library(shinydashboard)
library(leaflet)

# Header

header <- dashboardHeader(
  title = "Barrios Sustentables ᵃˡᵖʰᵃ", titleWidth = 300
)

# Body

body <- dashboardBody(
  fluidRow(
    column(12, div(style = "height:25px", "")),
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("vizmap", height = 696)
           )
    ),
    column(width = 3,
           box(width = NULL, color="purple",
               uiOutput("Barrio"),
               uiOutput("Variable")
           ),
           valueBoxOutput(width = NULL, "unitsBox"),
           valueBoxOutput(width = NULL, "meanBox"),
           valueBoxOutput(width = NULL, "varianceBox"),
           box(width = NULL, color="purple", uiOutput("Texto"))
    )
  )
)

dashboardPage(
  skin = "purple",
  header,
  dashboardSidebar(disable = TRUE),
  body
)