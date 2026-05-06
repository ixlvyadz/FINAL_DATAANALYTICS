# Data Quality Check for India Crop Dashboard
# This script validates the datasets before building the Shiny app

library(dplyr)
library(tidyr)

cat("\n========================================\n")
cat("DATA QUALITY REPORT\n")
cat("========================================\n\n")

# Load crop_production.csv
cat("1. CROP PRODUCTION DATA (crop_production.csv)\n")
cat("------------------------------------------\n")
crop_prod <- read.csv('crop_production.csv', stringsAsFactors = FALSE)

cat(sprintf("Total rows: %d\n", nrow(crop_prod)))
cat(sprintf("Columns: %s\n", paste(names(crop_prod), collapse = ", ")))

# State coverage
states <- unique(trimws(crop_prod$State_Name))
cat(sprintf("\nUnique States: %d\n", length(states)))
cat(sprintf("States: %s\n", paste(head(states, 10), collapse = ", "), "...\n"))

# Crop coverage
crops <- unique(trimws(crop_prod$Crop))
cat(sprintf("\nUnique Crops: %d\n", length(crops)))
cat(sprintf("Sample crops: %s\n", paste(head(crops, 10), collapse = ", ")))

# Year range
years <- range(crop_prod$Crop_Year)
cat(sprintf("\nYear Range: %d - %d\n", years[1], years[2]))

# Season breakdown
seasons <- unique(trimws(crop_prod$Season))
cat(sprintf("\nSeasons: %s\n", paste(seasons, collapse = ", ")))

# Data completeness
cat(sprintf("\nMissing Values:\n"))
cat(sprintf("  State_Name: %d\n", sum(is.na(crop_prod$State_Name))))
cat(sprintf("  Crop: %d\n", sum(is.na(crop_prod$Crop))))
cat(sprintf("  Area: %d\n", sum(is.na(crop_prod$Area))))
cat(sprintf("  Production: %d\n", sum(is.na(crop_prod$Production))))

# Area and Production stats
cat(sprintf("\nArea (hectares) - Summary:\n"))
print(summary(crop_prod$Area))

cat(sprintf("\nProduction (tonnes) - Summary:\n"))
print(summary(crop_prod$Production))

# Calculate yield
cat(sprintf("\n\nCalculated Yield (Production / Area):\n"))
crop_prod$Yield <- crop_prod$Production / crop_prod$Area
cat(sprintf("  Min: %.2f tonnes/hectare\n", min(crop_prod$Yield, na.rm=TRUE)))
cat(sprintf("  Max: %.2f tonnes/hectare\n", max(crop_prod$Yield, na.rm=TRUE)))
cat(sprintf("  Mean: %.2f tonnes/hectare\n", mean(crop_prod$Yield, na.rm=TRUE)))

# Sample data
cat("\n\nSample rows (first 5):\n")
print(head(crop_prod[, c("State_Name", "Crop_Year", "Crop", "Area", "Production")], 5))

cat("\n\n2. SEASONAL DATA (data_season.csv)\n")
cat("------------------------------------------\n")
data_season <- read.csv('data_season.csv', stringsAsFactors = FALSE)

cat(sprintf("Total rows: %d\n", nrow(data_season)))
cat(sprintf("Columns: %s\n", paste(names(data_season), collapse = ", ")))

locations <- unique(data_season$Location)
cat(sprintf("\nUnique Locations: %d\n", length(locations)))
cat(sprintf("Locations: %s\n", paste(head(locations, 10), collapse = ", ")))

cat(sprintf("\nYear Range: %d - %d\n", min(data_season$Year), max(data_season$Year)))

cat("\n\n3. CROP YIELD DATA (crop_yield.csv)\n")
cat("------------------------------------------\n")
crop_yield <- read.csv('crop_yield.csv', stringsAsFactors = FALSE)

cat(sprintf("Total rows: %d\n", nrow(crop_yield)))
cat(sprintf("Columns: %s\n", paste(names(crop_yield), collapse = ", ")))

regions <- unique(crop_yield$Region)
cat(sprintf("\nUnique Regions: %d\n", length(regions)))
cat(sprintf("Regions: %s\n", paste(regions, collapse = ", ")))

yield_crops <- unique(crop_yield$Crop)
cat(sprintf("\nUnique Crops: %d\n", length(yield_crops)))
cat(sprintf("Crops: %s\n", paste(head(yield_crops, 10), collapse = ", ")))

cat("\n\n4. DATA INTEGRATION ASSESSMENT\n")
cat("------------------------------------------\n")

# Check overlap between crop_production and crop_yield crops
overlap_crops <- intersect(tolower(crops), tolower(yield_crops))
cat(sprintf("Crop overlap between datasets: %d crops\n", length(overlap_crops)))
cat(sprintf("Samples: %s\n", paste(head(overlap_crops, 5), collapse = ", ")))

# Check if we can calculate yields
cat(sprintf("\n✓ Can calculate Yield from crop_production: YES (Production / Area)\n"))
cat(sprintf("✓ Can link data_season to crop_production: PARTIAL (need location/state mapping)\n"))
cat(sprintf("✓ Can link crop_yield: PARTIAL (different regions/structure)\n"))

cat("\n\nRECOMMENDATIONS FOR DASHBOARD:\n")
cat("========================================\n")
cat("1. PRIMARY SOURCE: crop_production.csv (most complete, state-level)\n")
cat("2. USE CALCULATED YIELD: Production / Area from crop_production\n")
cat("3. ENHANCEMENT: Merge data_season for climate factors (if location mapping available)\n")
cat("4. STATE COVERAGE: All major Indian states available\n")
cat("5. TEMPORAL: 20+ years of data for trend analysis\n")
cat("6. PRODUCTION MIX: Can analyze seasonal split (Kharif/Rabi)\n")

cat("\n========================================\n")
