# SKILL: Build Story-Driven Data Dashboards (HarvestWatch Workflow)

## Overview
This skill documents the end-to-end workflow for building a **story-driven, interactive Shiny dashboard** that communicates complex data narratives to diverse audiences (farmers, policymakers, students). It's specifically tailored to the **HarvestWatch** dashboard (global crop yield & food security), but generalizes to any agriculture or food security data storytelling project.

**Key Principle:** Data dashboards are narrative tools first, analytics tools second. Every visualization should answer a specific question or move the story forward.

---

## Workflow Stages

### Stage 1: Planning & Story Framing (Pre-Build)
*Duration: 1-2 hours | Output: Dashboard outline, persona map, dataset spec*

#### Step 1.1: Define the Core Story
- **What problem does this dashboard solve?** (Example: "Which crops are thriving vs. declining? Why does food insecurity persist despite rising yield?")
- **Who is the primary audience?** (farmers, policymakers, researchers, general public)
- **What is the "aha moment"?** (The headline stat that anchors the narrative)
  - Example: "Global wheat yield has increased 3× since 1961 — but 733 million people still go hungry. Here's why."

#### Step 1.2: Validate the Dataset
- **Completeness:** Does it have geographic coverage (180+ countries)? Temporal depth (60+ years)?
- **Variables available:** Yield (kg/ha), production volume, harvested area, food supply per capita?
- **Data quality:** Are there gaps, outliers, or seasonal anomalies?
- **Public vs. proprietary:** (FAO data is public; validate licensing for use case)

**Decision Point:** Is the dataset rich enough to tell the story? If not, identify supplementary data sources.

#### Step 1.3: Map User Personas & Interaction Flows
- **Persona 1 (Farmer):** Quick insights on local yield trends, comparative analysis with neighbors
- **Persona 2 (Policymaker):** Regional food security metrics, production forecasts, risk zones
- **Persona 3 (Student/Public):** Guided story, global trends, interactive exploration
- **Key question:** Should the dashboard prioritize **guided narrative** or **free exploration**? (Recommended: hybrid — guided intro, then free exploration)

---

### Stage 2: Design Visualizations & Interaction (Architecture)
*Duration: 2-3 hours | Output: Wireframe/mockup, viz specs, interaction matrix*

#### Step 2.1: Select Core Visualizations
Each viz should answer ONE specific question and map to a narrative beat:

| Visualization | Question Answered | User Personas | Interaction |
|---|---|---|---|
| **Choropleth map** | Which countries have highest/lowest yield for a crop? | All | Filter by crop, year range |
| **Trend line** | How has global yield evolved for a crop over 60 years? | Policymakers, Students | Hover for year details, compare 2–3 crops |
| **Top 10 producers bar chart** | Which countries dominate production? | Policymakers | Animated by year, click to drill into country |
| **Scatter plot (yield vs. area)** | Are countries producing more with less land (efficiency)? | Farmers, Policymakers | Hover for country details, color by region |
| **Food supply heatmap** | Which regions face food security risk? | Policymakers | Filter by year, hover for per-capita details |
| **Crop comparison panel** | How do 2–3 crops compare side-by-side? | All | User-selected crops, overlaid trends |

**Decision Point:** Do all visualizations fit on one dashboard, or should they be split across tabs/pages? (Recommended: tab-based or scrollable single page for guided narrative, tabbed for exploratory modes)

#### Step 2.2: Define Interaction Patterns
- **Filters:** Crop type, year range, region, country
- **Brushing:** Selecting a year on the trend chart highlights that year on the map
- **Drill-down:** Click a country to see crop-level breakdown
- **Comparison:** Allow 2–3 simultaneous selections for side-by-side analysis
- **Storytelling toggle:** "Start guided tour" vs. "Explore freely"

#### Step 2.3: Design Information Architecture
```
Home/Headline
├── Guided Story Mode
│   ├── Intro (headline stat + context)
│   ├── Visualization 1 (choropleth + explanation)
│   ├── Visualization 2 (trend line + explanation)
│   ├── Visualization 3 (scatter + efficiency insight)
│   ├── Visualization 4 (heatmap + risk insight)
│   └── Call-to-action (explore further)
└── Explore Mode
    ├── Multi-dashboard with all visualizations
    ├── Full filter controls
    └── Custom comparison tools
```

---

### Stage 3: Implementation (Shiny Structure)
*Duration: 3-5 hours | Output: Working dashboard, responsive & performant*

#### Step 3.1: Set Up Shiny Structure
- **ui.r:** `shinydashboard` layout with sidebar + main body, guided/explore toggle, input controls
- **server.r:** Data loading, reactivity, visualization rendering, guided story logic
- **app.r:** Execution wrapper
- **Data folder:** CSV files organized by source (FAO, supplementary)

**Confirmed choice:** Using `shinydashboard` for clean panel layout with sidebar filters.

**UI Structure (shinydashboard):**
```r
dashboardPage(
  dashboardHeader(title = "HarvestWatch"),
  dashboardSidebar(
    # Toggle button
    actionButton("toggle_mode", "Toggle: Guided Story ↔ Free Explore"),
    # Filters (crop, year range, region)
    selectInput("crop_select", "Crop:", choices = crop_list),
    sliderInput("year_range", "Year Range:", min=1961, max=2023, value=c(2000,2023))
  ),
  dashboardBody(
    # Guided story content (conditional panel)
    conditionalPanel("input.toggle_mode % 2 == 0", {
      # Headline, intro text, sequential visualizations
    }),
    # Free explore content (conditional panel)
    conditionalPanel("input.toggle_mode % 2 == 1", {
      # All visualizations, full filters
      tabBox(
        tabPanel("Choropleth Map", plotOutput("map")),
        tabPanel("Yield Trend", plotOutput("trend")),
        tabPanel("Top Producers", plotOutput("bar_chart")),
        tabPanel("Efficiency", plotOutput("scatter")),
        tabPanel("Food Security", plotOutput("heatmap"))
      )
    })
  )
)
```

#### Step 3.2: Build Reactivity Chain
```
Inputs (filters) 
  ↓
Reactive data subset
  ↓
Render visualizations
  ↓
Update cross-viz brushing/linking
```

Example in server.r:
```r
filtered_data <- reactive({
  data %>% 
    filter(crop %in% input$crop_select) %>%
    filter(year >= input$year_range[1] & year <= input$year_range[2])
})

output$yield_map <- renderPlot({
  # Choropleth using filtered_data()
})
```

#### Step 3.3: Optimize Performance
- **Data loading:** Load all CSVs once at app startup (not per session) — FAO + supplementary data is small enough to keep fully in memory
- **Caching:** Use `shiny::reactive()` to avoid recomputing filtered datasets
- **Interactive visualizations:** Use `plotly` or `ggplotly()` for hover details and zooming; Leaflet for interactive maps
- **No server-side optimization needed** (data volume is <1M rows; standard R operations are fast)

**Performance target:** All filter changes should trigger re-renders in <500ms (easily achievable with this data size)

#### Step 3.4: Add Narrative Elements
- **Headline stat** (e.g., "Wheat yield up 3×, but…") rendered reactively based on selected crop
- **Explanatory text** next to each viz (e.g., "Why this chart matters")
- **Guided tour toggle** that highlights key insights
- **Attribution** (data source: FAO, analysis date, etc.)

---

### Stage 4: Quality Assurance & Iteration
*Duration: 1-2 hours | Output: Polished, tested dashboard*

#### Step 4.1: Functional Testing
- [ ] All filters work independently and in combination
- [ ] Cross-visualization linking (e.g., clicking map updates trend chart) works
- [ ] No console errors or warnings
- [ ] Performance is acceptable (no lag >500ms)
- [ ] Responsive design works on mobile/tablet

#### Step 4.2: Narrative Testing
- [ ] Does the guided story (start-to-finish) make sense to a non-technical user?
- [ ] Are headline stats accurate and compelling?
- [ ] Does each visualization answer its intended question clearly?
- [ ] Are explanatory texts jargon-free and actionable?

#### Step 4.3: Data Validation
- [ ] Spot-check 5–10 data points against source (FAO)
- [ ] Verify crop names and country names are consistent
- [ ] Check for missing data and handle gracefully (e.g., "Data not available for this crop/year")

#### Step 4.4: User Feedback (Optional)
- Share with 1–2 target users (farmer, policymaker, student)
- Ask: "What's the main takeaway?" and "What would make this more useful?"
- Adjust narrative and visualizations based on feedback

---

## Decision Tree

```
START: Build Story-Driven Dashboard
│
├─ Story defined + dataset validated?
│  ├─ No → Return to Stage 1.1–1.3
│  └─ Yes ↓
├─ Visualizations selected + interaction matrix complete?
│  ├─ No → Return to Stage 2.1–2.2
│  └─ Yes ↓
├─ Shiny structure built + reactivity chain working?
│  ├─ No → Debug in server.r, return to Stage 3.2
│  └─ Yes ↓
├─ All QA tests pass?
│  ├─ No → Fix bugs, return to appropriate stage
│  └─ Yes ↓
└─ Dashboard ready for sharing
```

---

## Quality Criteria (Success Metrics)

A story-driven dashboard is successful if:

1. **Clarity:** A 5-minute user interaction clearly communicates the core story
2. **Engagement:** Users explore beyond the guided narrative (free exploration is intuitive)
3. **Accuracy:** All data points are verifiable against source
4. **Performance:** Dashboard responds to all interactions in <500ms
5. **Accessibility:** Text is jargon-free; colors are colorblind-friendly
6. **Actionability:** Users can extract at least 3 insights without external prompts

---

## Example Prompts to Use This Skill

1. **"Design the HarvestWatch dashboard visualizations. Walk me through the core charts and interaction flows."**
   → Triggers Stage 2 (Design)

2. **"Build the ui.r structure for HarvestWatch with tabs for guided story and free exploration."**
   → Triggers Stage 3.1 (Shiny setup)

3. **"Write the reactive chain in server.r for filtering yield data by crop and year range."**
   → Triggers Stage 3.2 (Reactivity)

4. **"Test the HarvestWatch dashboard: Are all filters working? Does the headline stat update correctly?"**
   → Triggers Stage 4 (QA)

5. **"Rewrite the explanatory text next to the yield trend chart to be more compelling to a non-technical farmer."**
   → Triggers Stage 3.4 (Narrative refinement)

---

## Related Skills & Next Steps

- **agent-customization:** Use to refine this skill or create new dashboard-specific workflows
- **Shiny Dashboard Developer agent:** Invoke for complex visualization or UX design decisions

**Suggested next:** Create a companion SKILL.md for "Add Interactive Maps to Shiny Dashboards" (specific to choropleth + Leaflet implementation)

---

## Notes for Collaboration

- This skill assumes **R Shiny** as the dashboard framework (adaptable to Python Dash, Tableau, etc.)
- FAO dataset structure is assumed (can generalize to other agricultural data)
- "Guided story" mode is optional but recommended for public-facing dashboards
