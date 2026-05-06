# VIZ DESIGN: India Crop Yield & Production Dashboard
# 6 Interactive Visualizations — Data Mapping & Interaction Specs

---

## VISUALIZATION 1: State Production Choropleth Map
**Chart Type:** Leaflet Interactive Map (Choropleth)
**Story:** "Which states dominate crop production in India?"

### Data Mapping
```
Latitude/Longitude: India state boundaries (from spatial data)
Color intensity: Total Production (tonnes) for selected crop
Year filter: User selects year (slider: 1997–2015)
Crop filter: User selects crop (dropdown: 124 crops)
Season filter: User selects season (Kharif/Rabi/Summer/etc. or "All")
```

### Output
- States colored by production volume (green=high, light=low)
- Hover tooltip shows: State name, Production (tonnes), Area (ha), Calculated Yield
- Click state → highlight in other visualizations

### Filters in Sidebar
- `input$map_year`: Slider (1997–2015)
- `input$map_crop`: Select (all 124 crops, default="Rice")
- `input$map_season`: Select (All / Kharif / Rabi / Summer / Autumn / Winter)

### Server Logic
```r
map_data <- reactive({
  crop_prod %>%
    filter(Crop_Year == input$map_year) %>%
    filter(Crop == input$map_crop) %>%
    {if(input$map_season != "All") filter(., Season == input$map_season) else .} %>%
    group_by(State_Name) %>%
    summarise(
      Production = sum(Production, na.rm=TRUE),
      Area = sum(Area, na.rm=TRUE),
      Yield = Production / Area
    )
})

output$state_map <- renderLeaflet({
  # Join map_data to spatial state boundaries
  # Color by Production using colorNumeric palette
})
```

---

## VISUALIZATION 2: Crop Trend Lines (20-Year Evolution)
**Chart Type:** ggplot2 line chart (via plotly)
**Story:** "How has crop yield evolved over 18 years?"

### Data Mapping
```
X-axis: Year (1997–2015)
Y-axis: Yield (tonnes/hectare) [calculated: Production/Area]
Lines: Up to 3 crops (user-selectable)
Color: Different color per crop
Facets: Optional — separate by state or season
```

### Output
- Smooth trend lines for selected crops
- Hover shows: Year, Crop, Yield, State (if filtered)
- Dashed reference line = national average
- Shaded confidence bands optional

### Filters
- `input$trend_crops`: Multi-select (pick 2–3 crops)
- `input$trend_state`: Select (specific state or "All India")
- `input$trend_season`: Select (Kharif/Rabi/All)

### Server Logic
```r
trend_data <- reactive({
  crop_prod %>%
    filter(Crop %in% input$trend_crops) %>%
    {if(input$trend_state != "All") filter(., State_Name == input$trend_state) else .} %>%
    {if(input$trend_season != "All") filter(., Season == input$trend_season) else .} %>%
    group_by(Crop_Year, Crop) %>%
    summarise(
      Yield = sum(Production, na.rm=TRUE) / sum(Area, na.rm=TRUE),
      Production = sum(Production, na.rm=TRUE)
    )
})

output$trend_plot <- renderPlotly({
  ggplot(trend_data(), aes(x=Crop_Year, y=Yield, color=Crop)) +
    geom_line(size=1.2) +
    geom_point() +
    labs(title="20-Year Crop Yield Trends", x="Year", y="Yield (tonnes/hectare)") +
    theme_minimal()
})
```

---

## VISUALIZATION 3: Top 10 States by Production (Bar Chart)
**Chart Type:** Horizontal bar chart (animated by year)
**Story:** "Which states are production leaders, and how has this ranking changed?"

### Data Mapping
```
X-axis: Total Production (tonnes)
Y-axis: State name (top 10)
Bar color: Gradient (highest=dark, lowest=light)
Animation: Year slider updates bars with smooth transition
```

### Output
- Top 10 states ranked by production for selected crop
- Hover shows: State name, Production (tonnes), % of total
- Animation updates when year slider changes

### Filters
- `input$top10_year`: Slider (1997–2015) — animated
- `input$top10_crop`: Select (e.g., "Rice")
- `input$top10_season`: Select (Kharif/Rabi/All)

### Server Logic
```r
top10_data <- reactive({
  crop_prod %>%
    filter(Crop_Year == input$top10_year) %>%
    filter(Crop == input$top10_crop) %>%
    {if(input$top10_season != "All") filter(., Season == input$top10_season) else .} %>%
    group_by(State_Name) %>%
    summarise(Production = sum(Production, na.rm=TRUE)) %>%
    arrange(desc(Production)) %>%
    slice(1:10) %>%
    mutate(State_Name = reorder(State_Name, Production))
})

output$top10_bar <- renderPlotly({
  ggplot(top10_data(), aes(x=Production, y=State_Name, fill=Production)) +
    geom_col() +
    scale_fill_gradient(low="lightblue", high="darkblue") +
    labs(title=paste("Top 10 States —", input$top10_crop), x="Production (tonnes)", y="") +
    theme_minimal()
})
```

---

## VISUALIZATION 4: Efficiency Scatter Plot (Yield vs. Area)
**Chart Type:** Scatter plot (ggplot2 + plotly)
**Story:** "Are states producing more with less land? (Efficiency insight)"

### Data Mapping
```
X-axis: Harvested Area (hectares) [log scale for readability]
Y-axis: Yield (tonnes/hectare)
Points: Each state (or district)
Size: Production volume (larger = more production)
Color: State/Region
```

### Output
- Bubble scatter: Upper-left quadrant = efficient (high yield, small area)
- Lower-right = extensive (large area, lower yield)
- Hover shows: State, Crop, Area, Yield, Production, Year
- Quadrant reference lines (avg. area & avg. yield)

### Filters
- `input$scatter_year`: Slider (1997–2015)
- `input$scatter_crop`: Select (e.g., "Wheat")
- `input$scatter_season`: Select (Kharif/Rabi/All)

### Server Logic
```r
scatter_data <- reactive({
  crop_prod %>%
    filter(Crop_Year == input$scatter_year) %>%
    filter(Crop == input$scatter_crop) %>%
    {if(input$scatter_season != "All") filter(., Season == input$scatter_season) else .} %>%
    group_by(State_Name) %>%
    summarise(
      Area = sum(Area, na.rm=TRUE),
      Production = sum(Production, na.rm=TRUE),
      Yield = Production / Area
    ) %>%
    filter(Area > 0 & Yield > 0)
})

output$efficiency_scatter <- renderPlotly({
  ggplot(scatter_data(), aes(x=Area, y=Yield, size=Production, color=State_Name)) +
    geom_point(alpha=0.6) +
    scale_x_log10() +
    labs(title="Yield vs. Area Efficiency", 
         x="Area (hectares, log scale)", 
         y="Yield (tonnes/hectare)") +
    theme_minimal() +
    theme(legend.position="none")
})
```

---

## VISUALIZATION 5: Seasonal Production Breakdown (Stacked Bar)
**Chart Type:** Stacked bar chart
**Story:** "Which seasons dominate production? (Kharif vs. Rabi patterns)"

### Data Mapping
```
X-axis: State (top 10 producing states)
Y-axis: Production (tonnes)
Stacked segments: Season (Kharif, Rabi, Summer, Autumn, Winter, Whole Year)
Color: Different color per season
```

### Output
- Stacked bars showing seasonal contribution to total state production
- Hover shows: State, Season, Production, % of total
- Clear visual of whether state is Kharif-dependent or diversified

### Filters
- `input$seasonal_year`: Slider (1997–2015)
- `input$seasonal_crop`: Select (e.g., "All crops" or specific crop)

### Server Logic
```r
seasonal_data <- reactive({
  crop_prod %>%
    filter(Crop_Year == input$seasonal_year) %>%
    {if(input$seasonal_crop != "All") filter(., Crop == input$seasonal_crop) else .} %>%
    group_by(State_Name, Season) %>%
    summarise(Production = sum(Production, na.rm=TRUE)) %>%
    arrange(desc(Production)) %>%
    # Get top 10 states
    filter(State_Name %in% 
      (crop_prod %>% 
        filter(Crop_Year == input$seasonal_year) %>%
        group_by(State_Name) %>%
        summarise(Total = sum(Production, na.rm=TRUE)) %>%
        arrange(desc(Total)) %>%
        pull(State_Name) %>%
        head(10)))
})

output$seasonal_stack <- renderPlotly({
  ggplot(seasonal_data(), aes(x=reorder(State_Name, Production), 
                               y=Production, fill=Season)) +
    geom_col(position="stack") +
    coord_flip() +
    labs(title="Seasonal Production Mix (Top 10 States)", x="", y="Production (tonnes)") +
    theme_minimal()
})
```

---

## VISUALIZATION 6: Crop Diversity Heatmap (State × Crop Grid)
**Chart Type:** Heatmap (plotly or ggplot2 + geom_tile)
**Story:** "Which states specialize in which crops? (Diversity pattern)"

### Data Mapping
```
X-axis: Crop (top 20 crops by national production)
Y-axis: State (all 33 states)
Cell color: Yield (tonnes/hectare) [red=high, white=low]
Year filter: User selects year
```

### Output
- Heatmap shows state × crop specialization
- Red cells = states excelling at that crop
- White cells = crop not grown / low yield
- Reveals crop clusters (e.g., rice in South/East, wheat in North)

### Filters
- `input$heatmap_year`: Slider (1997–2015)
- `input$heatmap_season`: Select (Kharif/Rabi/All)

### Server Logic
```r
heatmap_data <- reactive({
  # Top 20 crops by national production
  top_crops <- crop_prod %>%
    filter(Crop_Year == input$heatmap_year) %>%
    group_by(Crop) %>%
    summarise(Total = sum(Production, na.rm=TRUE)) %>%
    arrange(desc(Total)) %>%
    pull(Crop) %>%
    head(20)
  
  crop_prod %>%
    filter(Crop_Year == input$heatmap_year) %>%
    filter(Crop %in% top_crops) %>%
    {if(input$heatmap_season != "All") filter(., Season == input$heatmap_season) else .} %>%
    group_by(State_Name, Crop) %>%
    summarise(Yield = sum(Production, na.rm=TRUE) / sum(Area, na.rm=TRUE)) %>%
    replace_na(list(Yield = 0))
})

output$heatmap <- renderPlotly({
  ggplot(heatmap_data(), aes(x=Crop, y=State_Name, fill=Yield)) +
    geom_tile() +
    scale_fill_gradient(low="white", high="darkred") +
    labs(title="State × Crop Yield Heatmap", x="", y="") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle=45, hjust=1))
})
```

---

## CROSS-VISUALIZATION INTERACTION MATRIX

| From → To | Interaction Type | Details |
|---|---|---|
| Map (click state) | Highlight Trend, Scatter, Heatmap | Filter other viz by selected state |
| Trend (hover year) | Highlight in Map, Top 10 | Show that year's data in other viz |
| Top 10 (click state) | Filter Map, Scatter, Heatmap | Drill into that state across viz |
| Seasonal (hover season) | Filter all viz | Show only that season's data |
| Heatmap (click cell) | Filter Trend, Scatter | Show data for State × Crop combo |

---

## SUMMARY TABLE

| Viz # | Name | Chart Type | Primary Story | Key Filters |
|---|---|---|---|---|
| 1 | State Choropleth | Leaflet Map | Which states lead production? | Year, Crop, Season |
| 2 | Trend Lines | Line Chart | How has yield evolved? | Crops (multi), State, Season |
| 3 | Top 10 Producers | Bar Chart (animated) | State rankings by production? | Year, Crop, Season |
| 4 | Efficiency Scatter | Bubble Scatter | High yield with less land? | Year, Crop, Season |
| 5 | Seasonal Breakdown | Stacked Bar | Kharif vs. Rabi dominance? | Year, Crop |
| 6 | Crop Diversity Heatmap | Heatmap | State-crop specialization? | Year, Season |

---

## IMPLEMENTATION NOTES

### Libraries Needed
```r
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(leaflet)
library(dplyr)
library(tidyr)
```

### Data Preparation (in server.r startup)
```r
# Load and preprocess
crop_prod <- read.csv('crop_production.csv', stringsAsFactors = FALSE) %>%
  mutate(
    State_Name = trimws(State_Name),
    Crop = trimws(Crop),
    Season = trimws(Season),
    Yield = Production / Area
  ) %>%
  filter(Area > 0, Production >= 0)  # Remove invalid rows
```

### Reactive Pattern
All visualizations follow this pattern:
```r
# 1. Create reactive dataset based on filters
viz_data <- reactive({
  crop_prod %>%
    filter(Crop_Year == input$year_slider) %>%
    filter(Crop %in% input$crop_select) %>%
    # ... more filters
})

# 2. Render visualization
output$viz_id <- renderPlotly({
  ggplot(viz_data(), ...) + ...
})
```

---

## GUIDED STORY FLOW (for Toggle Mode)

**"Guided Tour" Mode** (sequential narrative):
1. Intro: "India produces 1.2B tonnes annually across 33 states and 124 crops"
2. Show **State Choropleth** → "Rice dominates, concentrated in Eastern states"
3. Show **Trend Lines** → "Wheat yields doubled since 1997"
4. Show **Efficiency Scatter** → "Punjab achieves highest wheat yields efficiently"
5. Show **Seasonal Breakdown** → "Kharif (monsoon crop) drives 60% of production"
6. Show **Heatmap** → "South specializes in rice; North in wheat"
7. Call-to-action: "Now explore freely!"

**Free Explore Mode**: All 6 viz visible, user controls filters freely

