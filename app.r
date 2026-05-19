library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)

source("ui.r")
source("server.r")

shinyApp(ui = ui, server = server)

