# server.R – Reactive logic and chart rendering

function(input, output, session) {

  # ── Reactive prediction (fires on button click OR on initial load) ─────────
  pred <- eventReactive(
    input$recommend_btn,
    {
      predict_crop(
        N    = input$N,
        P    = input$P,
        K    = input$K,
        temp = input$temp,
        hum  = input$hum,
        ph   = input$ph,
        rain = input$rain
      )
    },
    ignoreNULL = FALSE
  )

  # Shared dataset loaded in app.R
  csv_data <- reactive({
    crop_data
  })

  # ── Recommended crop card ─────────────────────────────────────────────────
  output$recommended_crop <- renderText({
    toupper(pred()$recommended)
  })

  # ── Gauge chart ────────────────────────────────────────────────────────────
  output$gauge_chart <- renderPlotly({
    conf <- round(pred()$confidence * 100, 1)

    plot_ly(
      type  = "indicator",
      mode  = "gauge+number",
      value = conf,
      number = list(suffix = "%", font = list(size = 28, color = "#1f2937", family = "Arial")),
      gauge = list(
        axis  = list(range = list(0, 100), tickfont = list(size = 12)),
        bar   = list(color = "#2563eb", thickness = 0.15),
        steps = list(
          list(range = c(0,  50),  color = "#fecaca"),
          list(range = c(50, 75),  color = "#fcd34d"),
          list(range = c(75, 100), color = "#86efac")
        ),
        threshold = list(
          line = list(color = "red", width = 2),
          thickness = 0.75,
          value = 90
        )
      ),
      title = list(text = "<b>Probability</b>", font = list(size = 16, color = "#374151", family = "Arial"))
    ) %>%
      layout(
        margin = list(l = 30, r = 30, t = 50, b = 20),
        font = list(family = "Arial", color = "#1f2937"),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ) %>%
      config(displayModeBar = FALSE, responsive = TRUE)
  })

  # ── Top-3 bar chart ────────────────────────────────────────────────────────
  output$top3_chart <- renderPlotly({
    df <- pred()$top3
    df$prob_pct <- round(df$prob * 100, 1)

    plot_ly(
      data   = df,
      x      = ~toupper(crop),
      y      = ~prob_pct,
      type   = "bar",
      marker = list(color = "#2563eb", line = list(color = "rgba(0,0,0,0)")),
      hovertemplate = "<b>%{x}</b><br>Probability: %{y}%<extra></extra>"
    ) %>%
      layout(
        xaxis = list(
          title = "",
          tickfont = list(size = 11, color = "#374151"),
          showgrid = FALSE,
          zeroline = FALSE
        ),
        yaxis = list(
          title = "Probability (%)",
          titlefont = list(size = 12, color = "#374151"),
          tickfont = list(size = 10, color = "#6b7280"),
          showgrid = TRUE,
          gridwidth = 1,
          gridcolor = "rgba(0,0,0,0.05)"
        ),
        showlegend = FALSE,
        margin = list(l = 50, r = 20, t = 20, b = 40),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        font = list(family = "Arial", color = "#1f2937")
      ) %>%
      config(displayModeBar = FALSE, responsive = TRUE)
  })

  # ── Feature importance chart ───────────────────────────────────────────────
  output$importance_chart <- renderPlotly({
    plot_ly(
      data   = feature_importance,
      x      = ~factor(feature, levels = feature),
      y      = ~importance,
      type   = "bar",
      marker = list(color = "#10b981", line = list(color = "rgba(0,0,0,0)")),
      hovertemplate = "<b>%{x}</b><br>Importance: %{y:.3f}<extra></extra>"
    ) %>%
      layout(
        xaxis = list(
          title = "",
          tickfont = list(size = 11, color = "#374151"),
          showgrid = FALSE,
          zeroline = FALSE
        ),
        yaxis = list(
          title = "Importance",
          titlefont = list(size = 12, color = "#374151"),
          tickfont = list(size = 10, color = "#6b7280"),
          showgrid = TRUE,
          gridwidth = 1,
          gridcolor = "rgba(0,0,0,0.05)"
        ),
        showlegend = FALSE,
        margin = list(l = 50, r = 20, t = 20, b = 40),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        font = list(family = "Arial", color = "#1f2937")
      ) %>%
      config(displayModeBar = FALSE, responsive = TRUE)
  })

  # ── Radar chart title ──────────────────────────────────────────────────────
  output$radar_title <- renderUI({
    paste0("Soil Profile vs Ideal Profile (",
           tools::toTitleCase(pred()$recommended), ")")
  })

  # ── Radar chart ────────────────────────────────────────────────────────────
  output$radar_chart <- renderPlotly({
    p     <- pred()
    ideal <- crop_profiles[[p$recommended]]

    categories <- c("N", "P", "K", "Temp", "Humidity", "pH", "Rainfall", "N")  # close polygon
    user_vals  <- c(input$N, input$P, input$K, input$temp,
                    input$hum, input$ph, input$rain, input$N)
    ideal_vals <- c(ideal$N, ideal$P, ideal$K, ideal$temp,
                    ideal$hum, ideal$ph, ideal$rain, ideal$N)

    plot_ly(type = "scatterpolar", mode = "lines", fill = "toself") %>%
      add_trace(
        r         = user_vals,
        theta     = categories,
        name      = "Your Soil",
        fillcolor = "rgba(37, 99, 235, 0.2)",
        line      = list(color = "#2563eb", width = 2),
        hovertemplate = "<b>%{theta}</b><br>Value: %{r}<extra></extra>"
      ) %>%
      add_trace(
        r         = ideal_vals,
        theta     = categories,
        name      = "Ideal Profile",
        fillcolor = "rgba(16, 185, 129, 0.2)",
        line      = list(color = "#10b981", width = 2),
        hovertemplate = "<b>%{theta}</b><br>Value: %{r}<extra></extra>"
      ) %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = TRUE,
            range = c(0, 150),
            tickfont = list(size = 10, color = "#6b7280"),
            gridcolor = "rgba(0,0,0,0.08)"
          ),
          angularaxis = list(
            tickfont = list(size = 11, color = "#374151")
          ),
          bgcolor = "rgba(0,0,0,0)"
        ),
        showlegend = TRUE,
        legend = list(
          x = 1.05,
          y = 1,
          font = list(size = 12, color = "#374151")
        ),
        margin = list(l = 50, r = 100, t = 20, b = 50),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        font = list(family = "Arial", color = "#1f2937")
      ) %>%
      config(displayModeBar = FALSE, responsive = TRUE)
  })

  # ── Dataset distribution ───────────────────────────────────────────────────

  output$dataset_summary <- renderText({
    df <- csv_data()
    if (is.null(df)) return("Failed to load dataset.")
    paste0(nrow(df), " samples \u2022 ",
           length(unique(df$label)), " unique crops (showing top 6).")
  })

  output$dist_chart <- renderPlotly({
    df <- csv_data()
    if (is.null(df)) {
      return(plot_ly() %>%
               layout(title = "Failed to load dataset") %>%
               config(displayModeBar = FALSE))
    }

    counts <- sort(table(df$label), decreasing = TRUE)
    top6   <- data.frame(
      crop  = names(counts)[seq_len(min(6, length(counts)))],
      count = as.integer(counts)[seq_len(min(6, length(counts)))],
      stringsAsFactors = FALSE
    )

    plot_ly(
      data   = top6,
      x      = ~factor(crop, levels = crop),
      y      = ~count,
      type   = "bar",
      marker = list(color = "#2563eb", line = list(color = "rgba(0,0,0,0)")),
      hovertemplate = "<b>%{x}</b><br>Samples: %{y}<extra></extra>"
    ) %>%
      layout(
        xaxis = list(
          title = "",
          tickfont = list(size = 11, color = "#374151"),
          showgrid = FALSE,
          zeroline = FALSE
        ),
        yaxis = list(
          title = "Samples",
          titlefont = list(size = 12, color = "#374151"),
          tickfont = list(size = 10, color = "#6b7280"),
          showgrid = TRUE,
          gridwidth = 1,
          gridcolor = "rgba(0,0,0,0.05)"
        ),
        showlegend = FALSE,
        margin = list(l = 50, r = 20, t = 20, b = 40),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        font = list(family = "Arial", color = "#1f2937")
      ) %>%
      config(displayModeBar = FALSE, responsive = TRUE)
  })
}
