# CropSense Dashboard — AI Agent Customization

## Project Overview
CropSense is an interactive R Shiny dashboard for analyzing India crop yield and production. The app provides data exploration, predictive recommendations, and factor correlation analysis for agricultural decision-making.

**Deployed at:** https://marasilmaroanalytics.shinyapps.io/dataanalytics2/

---

## ⚠️ Critical Issue: Factor Correlation Data Discrepancy

### Problem Statement
The "Factor Correlation" heatmap visualization (dashboard tab) **may display different correlation values** between the **local development version** and **deployed version**. This is caused by data source misalignment.

### Root Causes

#### 1. **Data Source Split** 
- **Local correlation calculation** (`server.r` lines 22–48) uses: `data_season.csv` (3,159 CSV lines, 3,158 data rows)
- **Main dashboard data** loads from: `data_season.csv` (also used for filters)
- **Large reference dataset**: `crop_production.csv` (246,092 rows) — NOT used for correlations

**Impact:** If `data_season.csv` differs between local and deployed environments, correlation values will diverge.

#### 2. **Column Naming Issues**
- The source CSV has a misspelled column: `yeilds` (missing 'l')
- Local code remaps it: `Yield = as.numeric(.data$yeilds)` → `Yield` 
- If this column is removed or renamed in a data refresh, correlations break

#### 3. **Pairwise Deletion Strategy**
- Correlation uses `use = 'pairwise.complete.obs'` (line 45 in server.r)
- This handles missing values by deleting incomplete rows pair-by-pair
- **If missing data patterns differ between versions**, correlation strength/direction changes
- Seasonal data also contains 58 blank `Soil type` cells; the app now trims and normalizes blank strings before analysis.

---

## 🔧 How to Debug & Fix Correlation Discrepancies

### Step 1: Verify Data Consistency
```r
# Check if data_season.csv is identical between environments
# Run this in R:
local_data <- read.csv('data_season.csv')
str(local_data)
summary(local_data)  # Check for NAs, ranges
nrow(local_data)  # Should be 3,159


```

### Step 2: Validate Correlation Calculation Logic
The current implementation in `server.r`:
```r
corr_source <- corr_source %>%
  transmute(
    Area = as.numeric(.data$Area),
    Rainfall = as.numeric(.data$Rainfall),
    Temperature = as.numeric(.data$Temperature),
    Yield = as.numeric(.data$yeilds),  # ⚠️ Misspelled source column
    Humidity = as.numeric(.data$Humidity)
  )
corr_mat <- cor(corr_source, use = 'pairwise.complete.obs')
```

**To check for NA counts:**
```r
# This shows how many rows are dropped due to missing values per factor pair
data_clean <- read.csv('data_season.csv', stringsAsFactors=FALSE)
# Check completeness of factors
sapply(data_clean[,c('Area','Rainfall','Temperature','yeilds','Humidity')], 
       function(x) sum(!is.na(x)))
```

### Step 3: Document Expected Baseline Values
Before redeploying, capture the "source of truth" correlations:
```r
# Save baseline correlations to a reference file
data_season <- read.csv('data_season.csv', stringsAsFactors=FALSE)
baseline_corr <- cor(
  data.frame(
    Area = as.numeric(data_season$Area),
    Rainfall = as.numeric(data_season$Rainfall),
    Temperature = as.numeric(data_season$Temperature),
    Yield = as.numeric(data_season$yeilds),
    Humidity = as.numeric(data_season$Humidity)
  ),
  use = 'pairwise.complete.obs'
)
saveRDS(baseline_corr, 'correlation_baseline.RDS')
```

### Step 4: Redeploy After Verification
```r
# Deploy only after confirming correlations match
rsconnect::deployApp('d:/DATAANALYTICS2')
```

---

## 📊 Data Architecture

### Key Files & Their Purpose

| File | Size | Purpose | Used For |
|------|------|---------|----------|
| `data_season.csv` | 3.2 KB | Climate + yield by location/season | Correlation viz, main filters, dashboard metrics |
| `crop_production.csv` | 2.4 MB | Historical crop production by state | *(Not currently used — planned for future map viz)* |
| `crop_yield.csv` | 9.8 MB | Large yield dataset | *(Reference data — not loaded in app)* |
| `Crop_recommendation.csv` | 21 KB | NPK, soil, weather for ML | Model training (`train_model.R`) |
| `agriculture_dataset.csv` | 1.5 KB | Small reference data | *(Exploratory use)* |

### Deployment Files
- **Deployed bundle:** `rsconnect/shinyapps.io/.../dataanalytics2.dcf`
- **Last deployment:** Bundle ID 12002511
- **Model file:** `model_rf.RDS` (trained Random Forest for crop recommendations)

---

## 🏗️ App Structure

### UI/UX (`ui.r`)
- **Layout:** `shinydashboard` with custom CSS (dark mode support)
- **Tabs:** Dashboard (3 stat cards + 4 visualizations) | Prediction | About
- **Sidebar:** Collapsible (hover/toggle) with emoji menu items
- **Styling:** CSS variables for theming (`--cs-green`, `--cs-sidebar`, etc.)

#### Stat Cards CSS Architecture (IMPORTANT)
The three stat cards on the Dashboard tab have different internal layouts controlled by specific CSS classes:

| Card | Container Class | Key Classes | Layout |
|------|---|---|---|
| **Total Yields** (left) | `stat-card split-stat-card` | `.split-stat-grid`, `.split-stat-box` | Flex grid with 2 columns (Yields + Area) |
| **Resource Usage** (center) | `stat-card resource-card` | `.resource-grid`, `.resource-item` | Flex layout with 3 columns (Pesticide/Fertilizer/Water) |
| **Weather** (right) | `stat-card weather-card` | `.weather-top` | Flex with 2-column internal layout |

**Critical CSS fix applied:** `.split-stat-card` originally had `display: block;` which broke flex centering. Removed to inherit parent flex display from `.stat-card`.

**When modifying stat card layout:**
- Parent `.stat-card` provides: `display: flex; flex-direction: column; justify-content: center; height: 110px;`
- Child containers should use: `display: flex;` or `display: grid;` for internal organization
- Never override parent with `display: block;` — it breaks vertical centering

### Server Logic (`server.r`)
- **Correlation viz** (lines 22–92): Heatmap from `data_season.csv`
- **Weather widget** (lines 111–181): Real-time API integration (Open-Meteo)
- **Data filtering** (lines 183–215): Year, location, crop, season selectors
- **YoY calculations** (lines 216–253): Year-over-year yield delta with sparkline
- **Stat cards** (lines 254–268): Sum of yields, area, pesticide/fertilizer/water estimates

### Key Dependencies
```r
library(shiny)
library(shinydashboard)  # Dashboard layout
library(plotly)          # Interactive visualizations
library(dplyr)           # Data wrangling
library(jsonlite)        # API responses (weather)
library(randomForest)    # ML predictions
```

---

## 🚀 Deployment Workflow

### To Deploy New Changes
1. Test locally: `shiny::runApp('d:/DATAANALYTICS2')`
2. Verify correlation values match baseline (see Step 3 above)
3. Run deployment script: `source('deploy_now.R')` or `source('deploy_shiny.R')`
4. Confirm deployment at: https://marasilmaroanalytics.shinyapps.io/dataanalytics2/

### Before Each Deployment
- **Check data files:** Ensure `data_season.csv` hasn't changed unexpectedly
- **Validate column names:** Confirm `yeilds` column exists (or update code if fixed)
- **Run tests:** `source('validate.R')` to check data quality

---

## � Common UI/CSS Layout Issues

### Issue: Stat Card Content Not Vertically Centered
**Symptoms:** Content appears at top of card instead of centered
**Root Cause:** Child container overriding parent flex display with `display: block;`
**Fix:** Check the CSS class chain. Parent `.stat-card` provides `display: flex; justify-content: center;`. Child classes (e.g., `.split-stat-card`) should NOT override with `display: block;`.

**Example (FIXED):**
```css
/* BEFORE (broken) */
.stat-card { display: flex; justify-content: center; }
.split-stat-card { display: block; }  /* ❌ BREAKS CENTERING */

/* AFTER (correct) */
.stat-card { display: flex; justify-content: center; }
.split-stat-card { }  /* ✓ Inherits parent flex */
.split-stat-grid { display: flex; gap: 12px; }  /* Child grid uses flex internally */
```

### Issue: Stat Card Content Has Different Height/Alignment
**Symptoms:** One stat card taller than another, content misaligned
**Root Cause:** Inconsistent `height`, `padding`, or missing `justify-content` on parent
**Check:** Ensure all stat-card variants have same height (110px) and same flex properties

### Issue: Dark Mode Text Not Visible
**Symptoms:** Text hard to read in dark mode
**Root Cause:** Color using fixed value instead of CSS variable (e.g., `color: #000;` instead of `color: var(--cs-text-main);`)
**Fix:** Always use `--cs-text-main`, `--cs-text-sub`, `--cs-green` variables. Dark mode automatically swaps them.

---

## 📝 Common Development Tasks

### Modifying Stat Card Layout
When editing stat cards in `ui.r` (lines ~730–770):
1. **Don't change container classes** — the CSS is carefully structured to maintain alignment
2. **To add a stat:** Create new `.split-stat-box` div with `span(class="stat-lbl", ...)` and `span(class="stat-val", ...)`
3. **To change spacing:** Edit `.split-stat-grid { gap: 12px; }` or `.resource-grid { gap: 18px; }`
4. **Always test locally** with `shiny::runApp()` before deploying

### Updating Correlation Visualization
- **File:** `server.r`, lines 22–92
- **To add/remove factors:** Edit `transmute()` section (line 32) and column order in `plot_ly()` args
- **To change color scale:** Modify `colorscale` list (lines 50–54, 73–76)

### Adding New Filters
- **UI:** Add `selectInput()` or `sliderInput()` to `ui.r`
- **Server:** Add corresponding `observe()` and `updateSelectInput()` in `server.r` lines 197–210
- **Filtering logic:** Update `filtered()` reactive (lines 212–219)

### Updating ML Model
1. Refresh training data: `train_model.R`
2. Run: `Rscript train_model.R` → generates `model_rf.RDS`
3. Commit and redeploy

---

## 🎯 AI Agent Working Guidelines

When working on this dashboard, always:

1. **Verify data consistency** between local and deployed environments before troubleshooting visualization issues
   - Compare `data_season.csv` row counts and column names
   - Save baseline correlation values after each data refresh (see correlation debugging section)

2. **Check CSS layout classes before assuming data bugs**
   - Many visual issues are CSS (flex/grid alignment) not data
   - Parent containers must use `display: flex;` for child content to center properly
   - Never override parent flex with `display: block;` on child containers

3. **Handle column naming mismatches** (e.g., `yeilds` vs. `Yield`)
   - The source CSV has misspelled `yeilds` column
   - Code remaps it with `as.numeric(.data$yeilds) → Yield`
   - If column is renamed in data refresh, correlations break immediately

4. **Test locally before deploying**
   - Use `shiny::runApp('d:/DATAANALYTICS2')`
   - Inspect browser console for JS/CSS errors
   - Verify stat card alignment and data freshness

5. **Review data quality checks**
   - Run `source('validate.R')` to check for NA patterns
   - Seasonal data contains 58 blank `Soil type` cells — these are handled by `clean_season_data()` function
   - Pairwise correlation deletion means NA patterns affect results

---

## 📖 Related Documentation
- [VIZ_DESIGN.md](VIZ_DESIGN.md) — Visualization specs and data mappings
- [SKILL.md](SKILL.md) — Story-driven dashboard workflow

