cat("\n========================================\n")
cat("DATA QUALITY REPORT\n")
cat("========================================\n\n")

season_data <- read.csv("data_season.csv", stringsAsFactors = FALSE, check.names = FALSE)
recommendation_data <- read.csv("Crop_recommendation.csv", stringsAsFactors = FALSE)

cat("1. SEASONAL YIELD DATA (data_season.csv)\n")
cat("------------------------------------------\n")
cat(sprintf("Rows: %d\n", nrow(season_data)))
cat(sprintf("Columns: %s\n", paste(names(season_data), collapse = ", ")))
cat(sprintf("Year range: %d - %d\n", min(season_data$Year, na.rm = TRUE), max(season_data$Year, na.rm = TRUE)))
cat(sprintf("Locations: %d\n", length(unique(season_data$Location))))
cat(sprintf("Crops: %d\n", length(unique(season_data$Crops))))
cat(sprintf("Seasons: %s\n", paste(sort(unique(season_data$Season)), collapse = ", ")))

soil_missing <- sum(is.na(season_data[["Soil type"]]) | trimws(season_data[["Soil type"]]) == "")
temp_invalid <- sum(season_data$Temperature < -10 | season_data$Temperature > 60, na.rm = TRUE)

cat(sprintf("Missing soil type values: %d\n", soil_missing))
cat(sprintf("Temperature values outside -10C to 60C: %d\n", temp_invalid))
cat("\nNumeric summaries:\n")
print(summary(season_data[, c("Area", "Rainfall", "Temperature", "yeilds", "Humidity", "price")]))

cat("\n2. CROP RECOMMENDATION DATA (Crop_recommendation.csv)\n")
cat("------------------------------------------------------\n")
cat(sprintf("Rows: %d\n", nrow(recommendation_data)))
cat(sprintf("Columns: %s\n", paste(names(recommendation_data), collapse = ", ")))
cat(sprintf("Crop labels: %d\n", length(unique(recommendation_data$label))))
cat(sprintf("Labels: %s\n", paste(sort(unique(recommendation_data$label)), collapse = ", ")))
cat("\nNumeric summaries:\n")
print(summary(recommendation_data[, c("N", "P", "K", "temperature", "humidity", "ph", "rainfall")]))

cat("\n3. MODEL FILE\n")
cat("-------------\n")
if (file.exists("model_rf.RDS")) {
  model <- readRDS("model_rf.RDS")
  cat(sprintf("Model class: %s\n", paste(class(model), collapse = ", ")))
  if ("randomForest" %in% class(model)) {
    cat(sprintf("Trees: %d\n", model$ntree))
    cat(sprintf("Classes: %d\n", length(model$classes)))
    cat(sprintf("OOB error: %.4f\n", tail(model$err.rate[, "OOB"], 1)))
  }
} else {
  cat("model_rf.RDS not found\n")
}

cat("\nNotes:\n")
cat("- Temperature values outside -10C to 60C are treated as invalid in the app's temperature and correlation views.\n")
cat("- The recommendation dataset is the published Kaggle Crop Recommendation Dataset.\n")
cat("- The seasonal file is used for dashboard exploration and is linked from the project repository.\n")

cat("\n========================================\n")
