library(shiny)
library(plotly)
library(dplyr)

server <- function(input, output, session) {
  
  # Load new dataset and map columns
  raw_data <- reactive({
    df <- read.csv('data_season.csv', stringsAsFactors = FALSE)
    df %>% rename(
      Crop_Year = Year,
      State_Name = Location,
      Crop = Crops,
      Yield = yeilds
    ) %>%
    mutate(Production = Yield * Area) # Derived production metric
  })
  
  # Update Filters
  observe({
    updateSelectInput(session, "loc_select", choices = c("All", sort(unique(raw_data()$State_Name))))
    updateSelectInput(session, "season_select", choices = c("All", sort(unique(raw_data()$Season))))
    
    yrs <- sort(unique(raw_data()$Crop_Year))
    updateSliderInput(session, "year_slider", min = min(yrs), max = max(yrs), value = max(yrs))
  })

  # Filtered Data for calculations
  filtered_df <- reactive({
    df <- raw_data() %>% filter(Crop_Year == input$year_slider)
    if(input$loc_select != "All") df <- df %>% filter(State_Name == input$loc_select)
    if(input$season_select != "All") df <- df %>% filter(Season == input$season_select)
    df
  })

  # --- SUMMARY CARD OUTPUTS ---
  output$crop_count <- renderText({ length(unique(filtered_df()$Crop)) })
  output$area_total <- renderText({ format(round(sum(filtered_df()$Area, na.rm=T), 0), big.mark=",") })
  
  # Resource logic: Simulated based on Area and Rainfall
  output$pest_val  <- renderText({ format(round(sum(filtered_df()$Area) * 0.42, 1), big.mark=",") })
  output$fert_val  <- renderText({ format(round(sum(filtered_df()$Area) * 1.15, 0), big.mark=",") })
  output$water_val <- renderText({ 
    val <- sum(filtered_df()$Area) * 0.85 
    if(val > 1000) paste0(round(val/1000, 1), "k") else round(val, 0)
  })

  # --- CHARTS ---
  output$yield_bar <- renderPlotly({
    data <- filtered_df() %>% group_by(Crop) %>% summarise(m_yield = mean(Yield)) %>% arrange(desc(m_yield))
    plot_ly(data, x = ~reorder(Crop, -m_yield), y = ~m_yield, type = "bar", marker = list(color = "#10b981")) %>%
      layout(xaxis = list(title = ""), yaxis = list(title = "Avg Yield"), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })

  output$trend_line <- renderPlotly({
    data <- raw_data() %>% group_by(Crop_Year) %>% summarise(Total_Prod = sum(Production))
    plot_ly(data, x = ~Crop_Year, y = ~Total_Prod, type = 'scatter', mode = 'lines+markers', line = list(color = "#3b82f6", width = 3)) %>%
      layout(xaxis = list(title = "Year"), yaxis = list(title = "Production"), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })

  output$geo_heat <- renderPlotly({
    data <- filtered_df() %>% group_by(State_Name, Crop) %>% summarise(Yield = mean(Yield))
    plot_ly(data, x = ~Crop, y = ~State_Name, z = ~Yield, type = "heatmap", colorscale = "YlGnBu") %>%
      layout(xaxis = list(title = ""), yaxis = list(title = ""), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })
}