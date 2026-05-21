# South India Crop Yield Explorer

Final project for **Data Analytics with R**.

This Shiny dashboard explores crop-yield records from 2004 to 2019 and includes a crop recommendation tool trained with a Random Forest model.

## Dashboard URL

https://marasilmaroanalytics.shinyapps.io/dataanalytics2/

## Problem Statement

The project asks:

How do crop yield, location, season, cultivated area, rainfall, humidity, and soil conditions relate to one another, and how can these patterns support basic crop-planning decisions?

## Main Features

1. Filter crop-yield records by year, location, crop, and season.
2. Compare total yield and area for selected records.
3. View current weather for selected locations through Open-Meteo.
4. Explore yield by location and season.
5. Compare crop share, soil type, and temperature relationships.
6. Review average yield trends by year.
7. Inspect correlations among area, rainfall, temperature, yield, and humidity.
8. Recommend crops from soil and climate inputs using a Random Forest model.

## Data Sources

1. Seasonal yield data: [`data_season.csv`](data_season.csv)
2. Crop recommendation data: https://www.kaggle.com/datasets/atharvaingle/crop-recommendation-dataset
3. Weather API: https://open-meteo.com/

## Data Quality Notes

The seasonal dataset contains some unrealistic temperature entries. The app treats temperature values below `-10C` or above `60C` as invalid for temperature-based charts and correlation analysis.

The crop recommendation model uses the published Kaggle dataset with these fields:

`N`, `P`, `K`, `temperature`, `humidity`, `ph`, `rainfall`, `label`

## Run Locally

```r
source("run.R")
```

## Validate

```r
source("validate.R")
source("data_quality_check.R")
```

## Train Model

```r
source("train_model.R")
```

This recreates `model_rf.RDS` from `Crop_recommendation.csv`.

## Deploy

Configure the shinyapps.io account first:

```r
rsconnect::setAccountInfo(
  name = "ACCOUNT_NAME",
  token = "TOKEN",
  secret = "SECRET"
)
```

Then publish the app:

```r
source("deploy_now.R")
```
