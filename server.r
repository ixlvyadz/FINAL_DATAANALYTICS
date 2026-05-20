library(shiny)
library(plotly)
library(dplyr)
library(jsonlite)
library(randomForest)

utils::globalVariables(c(
  'Location', 'Crops', 'yeilds', 'Temperature', 'Year', 'State', 'Crop', 'Season',
  'Yield', 'Area', 'Val', 'AvgY', 'PrevYear', 'Delta', 'prob', 'N', 'P', 'K',
  'temperature', 'humidity', 'ph', 'rainfall', 'price', 'Humidity', 'Rainfall',
  'Temperature', 'State_Name', 'Prod', 'Temp', 'DeltaLabel', 'Crop_Year'
))

clean_season_data <- function(path) {
  read.csv(path, stringsAsFactors = FALSE, na.strings = c('', 'NA'), check.names = FALSE) %>%
    mutate(across(where(is.character), ~ trimws(.x))) %>%
    mutate(across(where(is.character), ~ na_if(.x, '')))
}

theme_dark_plot <- function(p) {
  plotly::layout(
    p,
    paper_bgcolor = 'rgba(0,0,0,0)',
    plot_bgcolor = 'rgba(0,0,0,0)',
    font = list(color = '#eff7bf')
  )
}


# Load ML model if present
model_rf <- NULL
if (file.exists('model_rf.RDS')) {
  try({ model_rf <- readRDS('model_rf.RDS') }, silent = TRUE)
}

server <- function(input, output, session) {
  output$stat_corr <- renderPlotly({
    corr_source <- tryCatch({
      clean_season_data('data_season.csv')
    }, error = function(e) NULL)

    if (is.null(corr_source)) {
      return(plot_ly() %>% layout(
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)',
        xaxis = list(visible = FALSE),
        yaxis = list(visible = FALSE),
        annotations = list(list(
          text = 'Correlation data unavailable',
          x = 0.5, y = 0.5, xref = 'paper', yref = 'paper',
          showarrow = FALSE,
          font = list(color = '#66785b', size = 14)
        ))
      ) %>% config(displayModeBar = FALSE))
    }

    corr_fields <- c('Area', 'Rainfall', 'Temperature', 'yeilds', 'Humidity')

    corr_source <- corr_source %>%
      filter(if_all(all_of(corr_fields), ~ !is.na(.x))) %>%
      transmute(
        Area = as.numeric(.data$Area),
        Rainfall = as.numeric(.data$Rainfall),
        Temperature = as.numeric(.data$Temperature),
        Yield = as.numeric(.data$yeilds),
        Humidity = as.numeric(.data$Humidity)
      )

    corr_mat <- cor(corr_source, use = 'pairwise.complete.obs')
    # Compute per-pair correlation, p-value, and sample count
    compute_corr_stats <- function(df) {
      m <- as.matrix(df)
      vars <- colnames(m)
      nvar <- length(vars)
      r_mat <- matrix(NA_real_, nvar, nvar, dimnames = list(vars, vars))
      p_mat <- matrix(NA_real_, nvar, nvar, dimnames = list(vars, vars))
      n_mat <- matrix(0L, nvar, nvar, dimnames = list(vars, vars))
      for (i in seq_len(nvar)) {
        for (j in seq_len(nvar)) {
          xi <- m[, i]; xj <- m[, j]
          ok <- stats::complete.cases(xi, xj)
          n_mat[i, j] <- sum(ok)
          if (n_mat[i, j] < 3) next
          ct <- tryCatch(cor.test(xi[ok], xj[ok], method = 'pearson'), error = function(e) NULL)
          if (!is.null(ct)) {
            r_mat[i, j] <- as.numeric(ct$estimate)
            p_mat[i, j] <- as.numeric(ct$p.value)
          }
        }
      }
      list(r = r_mat, p = p_mat, n = n_mat)
    }

    corr_stats <- compute_corr_stats(corr_source)
    corr_mat <- corr_stats$r
    p_mat <- corr_stats$p
    n_mat <- corr_stats$n

    corr_df <- as.data.frame(as.table(corr_mat), stringsAsFactors = FALSE)
    names(corr_df) <- c('Factor_X', 'Factor_Y', 'Correlation')
    # attach p-value and sample count for hover/annotation
    p_df <- as.data.frame(as.table(p_mat), stringsAsFactors = FALSE)
    names(p_df) <- c('Factor_X', 'Factor_Y', 'P')
    n_df <- as.data.frame(as.table(n_mat), stringsAsFactors = FALSE)
    names(n_df) <- c('Factor_X', 'Factor_Y', 'N')
    corr_df$P <- p_df$P
    corr_df$N <- n_df$N
    factor_levels <- colnames(corr_mat)
    corr_df$Factor_X <- factor(corr_df$Factor_X, levels = factor_levels)
    corr_df$Factor_Y <- factor(corr_df$Factor_Y, levels = rev(factor_levels))

    corr_df$HoverText <- paste0('n=', corr_df$N, '<br>p=', sprintf('%.3g', corr_df$P))

    corr_plot <- plotly::plot_ly(
      data = corr_df,
      x = ~Factor_X,
      y = ~Factor_Y,
      z = ~Correlation,
      text = ~HoverText,
      type = 'heatmap',
      zmin = -1,
      zmax = 1,
      colorscale = list(
        c(0, '#d73027'),
        c(0.5, '#fff7b0'),
        c(1, '#1a9850')
      ),
      colorbar = list(title = 'r', titleside = 'right', tickvals = c(-1, 0, 1), ticktext = c('-1','0','1'), thickness = 16),
      hovertemplate = paste0(
        '<b>%{x} vs %{y}</b><br>',
        'Correlation: %{z:.2f}<br>',
        '%{text}<extra></extra>'
      )
    )

    corr_plot <- plotly::layout(
      corr_plot,
      margin = list(l = 38, r = 18, t = 10, b = 26),
      paper_bgcolor = 'rgba(0,0,0,0)',
      plot_bgcolor = 'rgba(0,0,0,0)',
      xaxis = list(
        title = '',
        side = 'bottom',
        tickangle = 0,
        tickfont = list(size = 11, color = '#26402f'),
        showgrid = FALSE,
        zeroline = FALSE,
        titlefont = list(size = 12, color = '#26402f')
      ),
      yaxis = list(
        title = '',
        tickfont = list(size = 11, color = '#26402f'),
        showgrid = FALSE,
        zeroline = FALSE,
        autorange = 'reversed'
      )
    )

    plotly::config(corr_plot, displayModeBar = FALSE, responsive = TRUE)
  })
  weather_code_label <- function(code) {
    switch(as.character(code),
      "0" = "Clear sky",
      "1" = "Mainly clear",
      "2" = "Partly cloudy",
      "3" = "Overcast",
      "45" = "Fog",
      "48" = "Depositing rime fog",
      "51" = "Light drizzle",
      "53" = "Drizzle",
      "55" = "Dense drizzle",
      "61" = "Slight rain",
      "63" = "Rain",
      "65" = "Heavy rain",
      "71" = "Slight snow",
      "73" = "Snow",
      "75" = "Heavy snow",
      "80" = "Rain showers",
      "81" = "Heavy showers",
      "82" = "Violent showers",
      "95" = "Thunderstorm",
      "96" = "Thunderstorm with hail",
      "99" = "Thunderstorm with hail",
      "Unknown weather"
    )
  }

  weather_icon <- function(code, is_day) {
    if (is.na(code)) return("⛅")
    if (code == 0) return(if (isTRUE(is_day == 1)) "☀️" else "🌙")
    if (code %in% c(1, 2, 3)) return("⛅")
    if (code %in% c(45, 48)) return("🌫️")
    if (code %in% c(51, 53, 55, 61, 63, 65, 80, 81, 82)) return("🌧️")
    if (code %in% c(71, 73, 75)) return("❄️")
    if (code %in% c(95, 96, 99)) return("⛈️")
    "⛅"
  }

  # Location to coordinates mapping
  location_coords <- list(
    "New Delhi" = list(lat = 28.6139, lon = 77.2090),
    "Mumbai" = list(lat = 19.0760, lon = 72.8777),
    "Bangalore" = list(lat = 12.9716, lon = 77.5946),
    "Chennai" = list(lat = 13.0827, lon = 80.2707),
    "Kolkata" = list(lat = 22.5726, lon = 88.3639),
    "Hyderabad" = list(lat = 17.3850, lon = 78.4867),
    "Delhi" = list(lat = 28.6139, lon = 77.2090),
    "Pune" = list(lat = 18.5204, lon = 73.8567),
    "All" = list(lat = 28.6139, lon = 77.2090)
  )
  
  weather_data <- reactive({
    invalidateLater(10 * 60 * 1000, session)
    tryCatch({
      selected_loc <- input$loc_filter %||% "All"
      coords <- location_coords[[selected_loc]] %||% location_coords[["All"]]
      url <- paste0(
        "https://api.open-meteo.com/v1/forecast?latitude=", coords$lat, "&longitude=", coords$lon, 
        "&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m,is_day&timezone=auto"
      )
      jsonlite::fromJSON(url)
    }, error = function(e) {
      NULL
    })
  })
  
  # Load Dataset and normalize column names
  data_clean <- read.csv('data_season.csv', stringsAsFactors = FALSE) %>%
    rename(State = Location, Crop = Crops, Yield = yeilds, Temp = Temperature) %>%
    rename_with(~ gsub(" ", "_", .x))
  
  # Initialize Filters
  observe({
    updateSelectInput(session, "loc_filter", choices = c("All", sort(unique(data_clean$State))))
    updateSelectInput(session, "crop_filter", choices = c("All", sort(unique(data_clean$Crop))))
    updateSelectInput(session, "season_filter", choices = c("All", sort(unique(data_clean$Season))))
    
    yrs <- sort(unique(data_clean$Year))
    updateSliderInput(session, "year_filter", min = min(yrs), max = max(yrs), value = max(yrs))
  })

  # Reactive Filtered Data
  filtered <- reactive({
    d <- data_clean %>% filter(Year == input$year_filter)
    if(input$loc_filter != "All") d <- d %>% filter(State == input$loc_filter)
    if(input$crop_filter != "All") d <- d %>% filter(Crop == input$crop_filter)
    if(input$season_filter != "All") d <- d %>% filter(Season == input$season_filter)
    d
  })
  
  # LINKED BRUSHING: Track selected state from charts
  selected_state <- reactiveVal(NULL)
  
  # Calculate year-over-year deltas
  calculate_delta <- function(current_val, previous_val) {
    if (is.na(current_val) || is.na(previous_val) || previous_val == 0) return(NA)
    ((current_val - previous_val) / previous_val) * 100
  }
  
  # Get benchmark (national average) for current filters
  get_benchmark <- reactive({
    d <- data_clean %>% filter(Year == input$year_filter)
    if(input$crop_filter != "All") d <- d %>% filter(Crop == input$crop_filter)
    mean(d$Yield, na.rm = TRUE)
  })

  # Summary Outputs with Deltas
  output$sum_yields <- renderText({
    total_yield <- suppressWarnings(sum(as.numeric(filtered()$Yield), na.rm = TRUE))
    format(round(total_yield, 0), big.mark = ",", scientific = FALSE, trim = TRUE)
  })
    output$yoy_badge <- renderUI({
    current_year <- input$year_filter
    previous_year <- current_year - 1
    
    # Current year yield
    current_filtered <- data_clean %>% filter(Year == current_year)
    if(input$loc_filter != "All") current_filtered <- current_filtered %>% filter(State == input$loc_filter)
    if(input$crop_filter != "All") current_filtered <- current_filtered %>% filter(Crop == input$crop_filter)
    if(input$season_filter != "All") current_filtered <- current_filtered %>% filter(Season == input$season_filter)
    current_yield <- sum(as.numeric(current_filtered$Yield), na.rm = TRUE)
    
    # Previous year yield
    previous_filtered <- data_clean %>% filter(Year == previous_year)
    if(input$loc_filter != "All") previous_filtered <- previous_filtered %>% filter(State == input$loc_filter)
    if(input$crop_filter != "All") previous_filtered <- previous_filtered %>% filter(Crop == input$crop_filter)
    if(input$season_filter != "All") previous_filtered <- previous_filtered %>% filter(Season == input$season_filter)
    previous_yield <- sum(as.numeric(previous_filtered$Yield), na.rm = TRUE)
    
    # Calculate YoY percentage
    yoy_pct <- calculate_delta(current_yield, previous_yield)
    
    if (is.na(yoy_pct) || nrow(previous_filtered) == 0) {
      return(div(style = "font-size: 10px; color: var(--cs-text-sub); margin-top: 3px;", "—"))
    }
    
    badge_class <- if (yoy_pct >= 0) "delta-positive" else "delta-negative"
    arrow <- if (yoy_pct >= 0) "↑" else "↓"
    
    # Create SVG sparkline for positive/negative trend
    if (yoy_pct >= 0) {
      # Upward trend line
      sparkline <- HTML('<svg class="trend-sparkline" viewBox="0 0 32 16" width="32" height="16" style="margin-left: 4px; vertical-align: middle;">
        <path class="trend-line trend-up" d="M 2 14 Q 8 10 14 8 Q 20 6 30 2" />
      </svg>')
    } else {
      # Downward trend line
      sparkline <- HTML('<svg class="trend-sparkline" viewBox="0 0 32 16" width="32" height="16" style="margin-left: 4px; vertical-align: middle;">
        <path class="trend-line trend-down" d="M 2 2 Q 8 6 14 8 Q 20 10 30 14" />
      </svg>')
    }
    
    div(
      class = "delta-badge",
      style = "margin-top: 4px; display: inline-flex; align-items: center;",
      class = badge_class,
      HTML(paste0(arrow, " ", round(abs(yoy_pct), 1), "% YoY")),
      sparkline
    )
  })
    output$sum_area  <- renderText({ format(round(sum(filtered()$Area), 0), big.mark=",") })
  output$pest_val  <- renderText({ paste0(round(sum(filtered()$Area)*0.04, 0), "L") })
  output$fert_val  <- renderText({ paste0(round(sum(filtered()$Area)*0.11, 0), "kg") })
  output$water_val <- renderText({ paste0(round(sum(filtered()$Area)*0.75, 0), "m³") })

  output$weather_location <- renderText({
    selected <- input$loc_filter
    if (is.null(selected) || selected == "All") "New Delhi" else selected
  })

  output$weather_temp <- renderText({
    w <- weather_data()
    if (is.null(w) || is.null(w$current$temperature_2m)) return("--°C")
    paste0(round(w$current$temperature_2m), "°C")
  })

  output$weather_desc <- renderText({
    w <- weather_data()
    if (is.null(w) || is.null(w$current$weather_code)) return("Weather unavailable")
    weather_code_label(w$current$weather_code)
  })

  output$weather_icon <- renderText({
    w <- weather_data()
    if (is.null(w) || is.null(w$current$weather_code)) return("⛅")
    weather_icon(w$current$weather_code, w$current$is_day)
  })

  output$weather_wind <- renderText({
    w <- weather_data()
    if (is.null(w) || is.null(w$current$wind_speed_10m)) return("Wind: --")
    paste0("Wind: ", round(w$current$wind_speed_10m), " km/h")
  })

  output$weather_humidity <- renderText({
    w <- weather_data()
    if (is.null(w) || is.null(w$current$relative_humidity_2m)) return("Humidity: --")
    paste0("Humidity: ", round(w$current$relative_humidity_2m), "%")
  })

  # Prediction reactive/result holder
  pred_result <- reactiveVal(list(crop = "--", conf = NA))

  # Crop emoji/image mapping
  crop_emoji <- function(crop_name) {
    emojis <- list(
      "rice" = "🌾",
      "maize" = "🌽",
      "wheat" = "🌾",
      "chickpea" = "🫘",
      "kidneybeans" = "🫘",
      "pigeonpeas" = "🫘",
      "mothbeans" = "🫘",
      "mungbean" = "🫘",
      "blackgram" = "🫘",
      "lentil" = "🫘",
      "pomegranate" = "🍎",
      "banana" = "🍌",
      "mango" = "🥭",
      "grapes" = "🍇",
      "watermelon" = "🍈",
      "papaya" = "🧡",
      "orange" = "🍊",
      "apple" = "🍎",
      "coconut" = "🥥",
      "cotton" = "🤎",
      "sugarcane" = "🌾",
      "tobacco" = "🚬"
    )
    emoji <- emojis[[tolower(as.character(crop_name))]]
    if (is.null(emoji) || is.na(emoji)) {
      "🌱"
    } else {
      emoji
    }
  }

  output$pred_crop_image <- renderText({ crop_emoji(pred_result()$crop) })

  observe({
    # Build input row for model
    req(input$input_n, input$input_p, input$input_k, input$input_temp, input$input_hum, input$input_ph, input$input_rain)
    if (is.null(model_rf)) {
      pred_result(list(crop = "Model not available", conf = NA))
      return()
    }

    newrow <- data.frame(
      N = as.numeric(input$input_n),
      P = as.numeric(input$input_p),
      K = as.numeric(input$input_k),
      temperature = as.numeric(input$input_temp),
      humidity = as.numeric(input$input_hum),
      ph = as.numeric(input$input_ph),
      rainfall = as.numeric(input$input_rain)
    )

    # Ensure columns order matches model training
    preds_prob <- tryCatch({ predict(model_rf, newdata = newrow, type = "prob") }, error = function(e) NULL)
    preds_class <- tryCatch({ predict(model_rf, newdata = newrow) }, error = function(e) NULL)

    if (!is.null(preds_prob) && is.matrix(preds_prob)) {
      top_idx <- which.max(preds_prob[1, ])
      top_label <- colnames(preds_prob)[top_idx]
      top_conf  <- preds_prob[1, top_idx]
      pred_result(list(crop = as.character(top_label), conf = top_conf))
    } else if (!is.null(preds_class)) {
      pred_result(list(crop = as.character(preds_class[1]), conf = NA))
    } else {
      pred_result(list(crop = "Prediction error", conf = NA))
    }
  })

  output$pred_crop <- renderText({
    crop_name <- as.character(pred_result()$crop)
    if (crop_name %in% c("--", "Model not available", "Prediction error")) {
      crop_name
    } else {
      tools::toTitleCase(crop_name)
    }
  })
  output$pred_confidence <- renderText({
    conf <- pred_result()$conf
    if (is.na(conf)) return("--")
    paste0(round(conf * 100, 1), "%")
  })

  # Small info badges for hero card (echo inputs)
  output$pred_info_rain <- renderText({ paste0(input$input_rain, "mm Rainfall") })
  output$pred_info_temp <- renderText({ paste0(round(input$input_temp), "°C Temp") })
  # Reactive probabilities for current inputs (used for alternatives chart)
  prob_reactive <- reactive({
    req(input$input_n, input$input_p, input$input_k, input$input_temp, input$input_hum, input$input_ph, input$input_rain)
    if (is.null(model_rf)) return(NULL)
    newrow <- data.frame(
      N = as.numeric(input$input_n),
      P = as.numeric(input$input_p),
      K = as.numeric(input$input_k),
      temperature = as.numeric(input$input_temp),
      humidity = as.numeric(input$input_hum),
      ph = as.numeric(input$input_ph),
      rainfall = as.numeric(input$input_rain)
    )
    probs <- tryCatch({ predict(model_rf, newdata = newrow, type = "prob") }, error = function(e) NULL)
    probs
  })

  output$pred_alternatives <- renderPlotly({
    probs <- prob_reactive()
    if (is.null(probs)) {
      return(theme_dark_plot(plot_ly()) %>% layout(xaxis=list(visible=FALSE), yaxis=list(visible=FALSE)))
    }
    dfp <- data.frame(crop = colnames(probs), prob = as.numeric(probs[1, ]))
    dfp <- dfp %>% arrange(desc(prob)) %>% head(5)
    dfp$crop <- tools::toTitleCase(as.character(dfp$crop))
    dfp$crop <- factor(dfp$crop, levels = rev(dfp$crop))
    plot_ly(
      dfp,
      x = ~prob,
      y = ~crop,
      type = 'bar',
      orientation = 'h',
      text = ~paste0(round(prob * 100, 1), '%'),
      textposition = 'auto',
      marker = list(color = '#10b981')
    ) %>%
      layout(xaxis = list(title = 'Probability', range = c(0, 1)), yaxis = list(title = ''), margin = list(l=90)) %>%
      theme_dark_plot()
  })

  # Contextual insight text (simple summary)
  output$pred_insights <- renderText({
    sprintf("Given N=%.0f, P=%.0f, K=%.0f, Temp=%.1f°C, Humidity=%.1f%%, pH=%.2f, Rain=%.1fmm. Recommendation based on the trained model.",
            input$input_n, input$input_p, input$input_k, input$input_temp, input$input_hum, input$input_ph, input$input_rain)
  })

  output$pred_radar <- renderPlotly({
    req(input$input_n, input$input_p, input$input_k, input$input_temp, input$input_hum, input$input_ph, input$input_rain)
    # normalize values to 0-1 for display
    vals <- c(input$input_n/150, input$input_p/150, input$input_k/150, input$input_temp/50, input$input_hum/100, input$input_ph/14, input$input_rain/500)
    ideal <- c(0.6, 0.6, 0.6, 0.5, 0.7, 0.5, 0.4)
    cats <- c('N','P','K','Temp','Hum','pH','Rain')
    plot_ly(type = 'scatterpolar', r = ideal, theta = cats, fill = 'toself', name = 'Ideal Profile') %>%
      add_trace(r = vals, theta = cats, fill = 'toself', name = 'Your Soil') %>%
      layout(
        polar = list(radialaxis = list(visible = TRUE, range = c(0,1), tickfont = list(color = '#eff7bf'))),
        showlegend = TRUE,
        legend = list(font = list(color = '#eff7bf'))
      ) %>%
      theme_dark_plot()
  })



  # Graph Outputs
  output$state_map <- renderPlotly({
    res <- filtered() %>% group_by(State) %>% summarise(Val = sum(Yield)) %>% arrange(desc(Val))
    plot_ly(res, x = ~Val, y = ~reorder(State, Val), type = 'bar', orientation = 'h', marker = list(color = '#10b981')) %>%
      layout(xaxis = list(title = "Total Yield"), yaxis = list(title = ""), margin = list(l=100), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })

  # Combined chart: switch between Production by Location and Seasonal Distribution
  output$combined_chart <- renderPlotly({
    req(filtered())
    sel <- input$combined_chart_select
    if(is.null(sel)) sel <- "Production by Location"
    if(sel == "Production by Location"){
      res <- filtered() %>% group_by(State) %>% summarise(Val = sum(Yield), .groups = 'drop') %>% arrange(desc(Val))
      bench <- get_benchmark()
      # Pre-format the delta as a string to avoid Plotly hovertemplate errors
      res$DeltaPct <- paste0(format(round((res$Val - bench) / bench * 100, 1), nsmall = 1), "%")
      
      plot_ly(
        source = "combined_chart",
        res, 
        x = ~Val, 
        y = ~reorder(State, Val), 
        type = 'bar', 
        orientation = 'h',
        marker = list(color = '#10b981', line = list(color = 'rgba(255,255,255,0.3)', width = 2)),
        hovertemplate = paste0(
          '<b>%{y}</b><br>',
          'Total Yield: %{x:,.0f}<br>',
          'vs National Avg: %{customdata}<extra></extra>'
        ),
        customdata = ~DeltaPct
      ) %>%
        add_segments(x = bench, xend = bench, y = -0.5, yend = nrow(res) + 0.5,
                     line = list(color = 'rgba(100, 116, 139, 0.5)', width = 2, dash = 'dash'),
                     name = 'National Avg',
                     hovertemplate = 'National Average: %{x:,.0f}<extra></extra>',
                     showlegend = TRUE) %>%
        layout(
          xaxis = list(title = "Total Yield"),
          yaxis = list(title = ""),
          margin = list(l=100),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)',
          hovermode = 'closest'
        )
    } else {
      res <- filtered() %>% group_by(State, Season) %>% summarise(Val = sum(Yield), .groups = 'drop') %>% head(20)
      plot_ly(
        source = "combined_chart_seasonal",
        res, 
        x = ~State, 
        y = ~Val, 
        color = ~Season, 
        type = 'bar',
        hovertemplate = '<b>%{x}</b> - %{fullData.name}<br>Yield: %{y:,.0f}<extra></extra>'
      ) %>%
        layout(
          barmode = 'stack',
          xaxis = list(title = ""),
          yaxis = list(title = "Yield"),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)'
        )
    }
  })

  output$trend_plot <- renderPlotly({
    res <- data_clean %>% 
      group_by(Year) %>% 
      summarise(AvgY = mean(Yield, na.rm = TRUE), .groups = 'drop') %>%
      arrange(Year) %>%
      mutate(
        PrevYear = lag(AvgY),
        Delta = if_else(is.na(PrevYear) | PrevYear == 0, NA_real_, round(((AvgY - PrevYear) / PrevYear) * 100, 1)),
        DeltaLabel = if_else(is.na(Delta), "--", paste0(format(Delta, nsmall=1), "%"))
      )
    
    max_yield_year <- res$Year[which.max(res$AvgY)]
    max_yield_val <- max(res$AvgY, na.rm = TRUE)
    
    plot_ly(
      source = "trend_plot",
      res, 
      x = ~Year, 
      y = ~AvgY, 
      type = 'scatter', 
      mode = 'lines+markers',
      line = list(color = '#3b82f6', width = 3),
      marker = list(size = 8, color = '#3b82f6', line = list(color = 'white', width = 2)),
      hovertemplate = paste0(
        '<b>Year: %{x}</b><br>',
        'Avg Yield: %{y:,.0f}<br>',
        'YoY Change: <b>%{customdata}</b><extra></extra>'
      ),
      customdata = ~DeltaLabel
    ) %>%
      add_annotations(
        x = max_yield_year,
        y = max_yield_val,
        text = "Record",
        showarrow = TRUE,
        arrowhead = 2,
        arrowcolor = '#10b981',
        ax = 40,
        ay = -40,
        bgcolor = '#dcfce7',
        bordercolor = '#10b981',
        borderwidth = 1,
        font = list(color = '#166534', size = 12, family = 'Poppins')
      ) %>%
      layout(
        yaxis = list(title = "Avg Yield"),
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)',
        hovermode = 'x unified'
      )
  })

  output$top10_bar <- renderPlotly({
    res <- filtered() %>% group_by(State) %>% summarise(Val = sum(Yield)) %>% arrange(desc(Val)) %>% head(10)
    plot_ly(res, x = ~reorder(State, -Val), y = ~Val, type = 'bar', marker = list(color = '#f59e0b')) %>%
      layout(xaxis = list(title = ""), yaxis = list(title = "Yield"), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })

  output$efficiency_scatter <- renderPlotly({
    req(filtered())
    sel <- input$efficiency_var_select
    d <- filtered()
    if(is.null(sel)) sel <- "Soil Type"

    if(sel == "Crop Distribution"){
      # Pie chart of crop distribution with rich tooltips
      crop_dist <- d %>% group_by(Crop) %>% summarise(Val = sum(Yield, na.rm = TRUE), Count = n(), .groups = 'drop') %>% arrange(desc(Val))
      total_yield <- sum(crop_dist$Val)
      crop_dist$Pct <- round(crop_dist$Val / total_yield * 100, 1)
      
      plot_ly(
        source = "pie_chart",
        crop_dist,
        labels = ~Crop,
        values = ~Val,
        type = 'pie',
        marker = list(colors = c('#10b981', '#06b6d4', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#f97316')),
        hovertemplate = '<b>%{label}</b><br>Yield: %{value:,.0f}<br>Share: %{customdata}%<extra></extra>',
        customdata = ~Pct
      ) %>%
        layout(
          title = list(text = "Crop Distribution by Total Yield"),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)'
        )
    } else if(sel == "Soil Type"){
      soil_vals <- d[["Soil_type"]]
      yield_vals <- d[["Yield"]]
      crop_names <- d[["Crop"]]
      
      plot_ly(
        x = soil_vals,
        y = yield_vals,
        text = crop_names,
        type = 'box',
        boxpoints = 'all',
        jitter = 0.3,
        pointpos = -1.8,
        marker = list(color = '#10b981', opacity = 0.7, line = list(color = '#059669', width = 1)),
        hovertemplate = '<b>Soil Type: %{x}</b><br>Yield: %{y:,.0f}<br>Crop: %{text}<extra></extra>'
      ) %>%
        layout(
          xaxis = list(title = "Soil Type"),
          yaxis = list(title = "Yield"),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)'
        )
    } else if(sel == "Temperature"){
      plot_ly(
        d,
        x = ~Temp,
        y = ~Yield,
        text = ~Crop,
        type = 'scatter',
        mode = 'markers',
        marker = list(size = 8, opacity = 0.7, color = '#8b5cf6', line = list(color = '#6d28d9', width = 1)),
        hovertemplate = '<b>%{text}</b><br>Temperature: %{x}°C<br>Yield: %{y:,.0f}<extra></extra>'
      ) %>%
        layout(
          xaxis = list(title = "Temperature (°C)"),
          yaxis = list(title = "Yield"),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)'
        )
    } else {
      var_col <- switch(sel, "Soil Type" = "Soil_type", "Season" = "Season", "Irrigation" = "Irrigation")
      vals <- d[[var_col]]
      crop_names <- d[["Crop"]]
      
      plot_ly(
        x = vals,
        y = d$Yield,
        text = crop_names,
        type = 'box',
        boxpoints = 'all',
        jitter = 0.3,
        pointpos = -1.8,
        marker = list(color = '#8b5cf6', opacity = 0.7, line = list(color = '#6d28d9', width = 1)),
        hovertemplate = '<b>%{x}</b><br>Yield: %{y:,.0f}<br>Crop: %{text}<extra></extra>'
      ) %>%
        layout(
          xaxis = list(title = sel),
          yaxis = list(title = "Yield"),
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)'
        )
    }
  })

  output$seasonal_stack <- renderPlotly({
    res <- filtered() %>% group_by(State, Season) %>% summarise(Val = sum(Yield)) %>% head(20)
    plot_ly(res, x = ~State, y = ~Val, color = ~Season, type = 'bar') %>%
      layout(barmode = 'stack', xaxis = list(title = ""), yaxis = list(title = "Yield"), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')
  })

}