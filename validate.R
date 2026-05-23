required_files <- c(
  "app.r",
  "ui.r",
  "server.r",
  "data_season.csv",
  "Crop_recommendation.csv",
  "model_rf.RDS"
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing required files: ", paste(missing_files, collapse = ", "))
}

invisible(parse(file = "app.r"))
invisible(parse(file = "ui.r"))
invisible(parse(file = "server.r"))

suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(plotly)
  library(dplyr)
  library(jsonlite)
  library(randomForest)
  library(httr2)
  library(commonmark)
})

source("ui.r")
source("server.r")

if (!inherits(ui, "shiny.tag")) {
  stop("ui.r did not create a valid Shiny UI object")
}

if (!is.function(server)) {
  stop("server.r did not create a valid Shiny server function")
}

season_data <- read.csv("data_season.csv", stringsAsFactors = FALSE, check.names = FALSE)
recommendation_data <- read.csv("Crop_recommendation.csv", stringsAsFactors = FALSE)

season_required <- c("Year", "Location", "Area", "Rainfall", "Temperature", "Soil type", "Irrigation", "yeilds", "Humidity", "Crops", "price", "Season")
recommendation_required <- c("N", "P", "K", "temperature", "humidity", "ph", "rainfall", "label")

if (!all(season_required %in% names(season_data))) {
  stop("data_season.csv is missing: ", paste(setdiff(season_required, names(season_data)), collapse = ", "))
}

if (!all(recommendation_required %in% names(recommendation_data))) {
  stop("Crop_recommendation.csv is missing: ", paste(setdiff(recommendation_required, names(recommendation_data)), collapse = ", "))
}

cat("Validation passed\n")
cat("Seasonal records:", nrow(season_data), "\n")
cat("Recommendation records:", nrow(recommendation_data), "\n")
cat("Recommendation labels:", length(unique(recommendation_data$label)), "\n")
