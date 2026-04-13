# global.R – Shared data, libraries, and model logic
install.packages(c("shiny", "shinydashboard", "plotly"), repos="https://cloud.r-project.org/")
library(shiny)
library(shinydashboard)
library(plotly)

# ── Load CSV dataset (single source of truth) ───────────────────────────────
csv_path <- "Crop_recommendation.csv"

if (!file.exists(csv_path)) {
  stop(paste0("Dataset not found at: ", normalizePath(csv_path, winslash = "/", mustWork = FALSE)))
} 

crop_data <- read.csv(csv_path, stringsAsFactors = FALSE)

required_cols <- c("N", "P", "K", "temperature", "humidity", "ph", "rainfall", "label")
missing_cols <- setdiff(required_cols, names(crop_data))
if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

crop_data <- crop_data[!is.na(crop_data$label) & nchar(trimws(crop_data$label)) > 0, ]
crop_data$label <- trimws(tolower(crop_data$label))

# ── Build crop profiles from CSV means (all crops) ──────────────────────────
crop_profiles <- lapply(split(crop_data, crop_data$label), function(df) {
  list(
    N = mean(df$N, na.rm = TRUE),
    P = mean(df$P, na.rm = TRUE),
    K = mean(df$K, na.rm = TRUE),
    temp = mean(df$temperature, na.rm = TRUE),
    hum = mean(df$humidity, na.rm = TRUE),
    ph = mean(df$ph, na.rm = TRUE),
    rain = mean(df$rainfall, na.rm = TRUE)
  )
})

message("Loaded ", nrow(crop_data), " rows and ", length(crop_profiles), " unique crops from CSV.")

# ── Feature importance (keep your current static values) ────────────────────
feature_importance <- data.frame(
  feature    = c("Rainfall", "Nitrogen", "Phosphorus", "Potassium", "Temperature", "Humidity", "pH"),
  importance = c(0.35, 0.25, 0.15, 0.10, 0.08, 0.05, 0.02),
  stringsAsFactors = FALSE
)

# ── Crop-specific feature importance (crop vs. rest effect size) ────────────
importance_features <- c("rainfall", "N", "P", "K", "temperature", "humidity", "ph")
importance_labels <- c(
  rainfall = "Rainfall",
  N = "Nitrogen",
  P = "Phosphorus",
  K = "Potassium",
  temperature = "Temperature",
  humidity = "Humidity",
  ph = "pH"
)

crop_feature_importance <- lapply(names(crop_profiles), function(crop) {
  in_crop <- crop_data[crop_data$label == crop, , drop = FALSE]
  out_crop <- crop_data[crop_data$label != crop, , drop = FALSE]

  in_mean <- sapply(importance_features, function(f) mean(in_crop[[f]], na.rm = TRUE))
  out_mean <- sapply(importance_features, function(f) mean(out_crop[[f]], na.rm = TRUE))
  all_sd <- sapply(importance_features, function(f) sd(crop_data[[f]], na.rm = TRUE))

  all_sd[is.na(all_sd) | all_sd == 0] <- 1
  scores <- abs(in_mean - out_mean) / all_sd

  if (sum(scores) == 0 || anyNA(scores)) {
    scores <- rep(1 / length(importance_features), length(importance_features))
  } else {
    scores <- scores / sum(scores)
  }

  data.frame(
    feature = unname(importance_labels[importance_features]),
    importance = as.numeric(scores),
    stringsAsFactors = FALSE
  )
})
names(crop_feature_importance) <- names(crop_profiles)

# ── Prediction function (required by server.r) ──────────────────────────────
predict_crop <- function(N, P, K, temp, hum, ph, rain) {
  weights <- list(N = 1, P = 1, K = 1, temp = 0.7, hum = 0.7, ph = 1, rain = 1)
  inputs  <- list(N = N, P = P, K = K, temp = temp, hum = hum, ph = ph, rain = rain)

  scores <- lapply(names(crop_profiles), function(crop) {
    profile <- crop_profiles[[crop]]
    dist <- sum(sapply(names(weights), function(k) {
      weights[[k]] * (inputs[[k]] - profile[[k]])^2
    }))
    list(crop = crop, dist = dist)
  })

  scores <- scores[order(sapply(scores, `[[`, "dist"))]
  top3 <- scores[seq_len(min(3, length(scores)))]

  inv <- sapply(top3, function(s) 1 / (1 + s$dist))
  probs <- inv / sum(inv)

  list(
    recommended = top3[[1]]$crop,
    confidence  = probs[1],
    top3 = data.frame(
      crop = sapply(top3, `[[`, "crop"),
      prob = probs,
      stringsAsFactors = FALSE
    )
  )
}

# Load UI and server definitions from split files and launch the app.
ui <- source("ui.r", local = TRUE)$value
server <- source("server.r", local = TRUE)$value

shinyApp(ui = ui, server = server)
