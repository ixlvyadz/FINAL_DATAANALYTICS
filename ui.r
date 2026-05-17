library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  skin = "black",

  dashboardHeader(title = "", titleWidth = 0),

  dashboardSidebar(
    width = 250,
    sidebarMenu(id = "tabs",
      menuItem(HTML('<span class="menu-emoji">📊</span><span class="menu-label-text">Dashboard</span>'), tabName = "dashboard"),
      menuItem(HTML('<span class="menu-emoji">📈</span><span class="menu-label-text">Prediction</span>'), tabName = "prediction"),
      menuItem(HTML('<span class="menu-emoji">ℹ</span><span class="menu-label-text">About</span>'), tabName = "about")
    ),
    div(class = "sidebar-bottom-controls",
      div(class = "sidebar-bottom-item", id = "collapse_btn",
        span("☰", class = "menu-emoji"),
        span("Toggle Menu", class = "ctrl-text")
      )
    )
  ),

  dashboardBody(
    tags$head(
      tags$title("CropSense"),
      tags$link(rel = "stylesheet", type = "text/css",
                href = "https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap"),
      tags$style(HTML('
        :root {
          --cs-bg: #f5f5f5;
          --cs-card-bg: #ffffff;
          --cs-green: #406d4f;
          --cs-sidebar: #406d4f;
          --cs-text-main: #26402f;
          --cs-text-sub: #66785b;
          --cs-border: #d8d1a0;
          --topbar-height: 64px;
          --sidebar-collapsed: 70px;
          --content-gutter: 0px;
          --sidebar-width: 250px;
        }
        .dark-mode {
          --cs-bg: #0d170f;
          --cs-sidebar: #102018;
          --cs-card-bg: #1a2b21;
          --cs-text-main: #eff7bf;
          --cs-text-sub: #b9c8ad;
          --cs-border: #315140;
        }

        * { box-sizing: border-box; font-family: "Poppins", sans-serif !important; }
        body, .content-wrapper { background: var(--cs-bg); color: var(--cs-text-main); }
        html, body, .wrapper { margin: 0; padding: 0; }
        .wrapper { overflow: visible; }

        /* Keep the header anchored at the viewport top and paint it in the same green context.
           This removes the thin dark strip seen above the header during sidebar state changes. */
        .top-nav,
        body.sidebar-open .top-nav {
          top: 0 !important;
          background: rgba(64, 109, 79, 0.78) !important;
        }
        .main-header, .logo { display: none !important; }
        .content-wrapper {
          margin-top: var(--topbar-height) !important;
          /* match deployed: content starts after collapsed rail with no extra gutter */
          margin-left: var(--sidebar-collapsed) !important;
          padding-left: 0 !important;
          left: auto !important;
          transition: margin-left 0.25s ease, padding-left 0.25s ease;
          position: static;
          z-index: 800;
        }
        .main-sidebar:hover ~ .content-wrapper {
          margin-left: var(--sidebar-width) !important;
          padding-left: 0 !important;
          left: auto !important;
        }

        .content-wrapper > section.content {
          padding: 0 !important;
          min-height: 250px;
        }

        .main-sidebar {
          width: var(--sidebar-collapsed) !important;
          position: fixed !important;
          left: 0;
          top: var(--topbar-height);
          height: calc(100vh - var(--topbar-height));
          overflow-y: auto;
          overflow-x: hidden;
          background: var(--cs-sidebar) !important;
          border-right: 1px solid rgba(51, 82, 65, 0.95);
          transition: width 0.25s ease;
          z-index: 100; /* lower stacking so pushed content can appear above */
        }
        .main-sidebar:hover {
          width: var(--sidebar-width) !important;
        }

        .sidebar-menu { padding-top: 0; margin-top: 0; }
        .sidebar-menu > li > a {
          display: flex;
          align-items: center;
          gap: 4px;
          color: #eff7bf !important;
          margin: 6px 10px;
          padding: 12px 12px !important;
          border-radius: 12px;
          font-size: 14px;
        }
        .sidebar-menu > li > a:hover { background: rgba(239, 247, 191, 0.18) !important; color: #fff8d8 !important; }
        .sidebar-menu > li.active > a { background: rgba(184, 201, 90, 0.28) !important; color: #fff8d8 !important; font-weight: 600; }
        .sidebar-menu > li > a i { min-width: 26px; text-align: center; font-size: 18px; }
        .menu-emoji { display: inline-block; width: 26px; text-align: center; font-size: 18px; line-height: 1; }
        .menu-label-text, .ctrl-text {
          opacity: 0;
          transform: translateX(-6px);
          transition: opacity 0.18s ease, transform 0.18s ease;
          white-space: nowrap;
        }
        .main-sidebar:hover .menu-label-text,
        .main-sidebar:hover .ctrl-text { opacity: 1; transform: translateX(0); margin-left: 10px; }

        .sidebar-bottom-controls {
          position: absolute;
          left: 0;
          right: 0;
          bottom: 20px;
          padding-top: 16px;
          border-top: 1px solid rgba(239, 247, 191, 0.12);
        }
        .sidebar-bottom-item {
          display: flex;
          align-items: center;
          padding: 12px 23px;
          color: #eff7bf;
          cursor: pointer;
          user-select: none;
        }
        .sidebar-bottom-item:hover { color: #fff8d8; }

        .top-nav {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          z-index: 1200;
          display: flex;
          align-items: center;
          justify-content: space-between;
          height: var(--topbar-height);
          padding: 12px 16px 12px 12px;
          background: rgba(64, 109, 79, 0.78);
          color: #eff7bf;
          border-bottom: 1px solid rgba(51, 82, 65, 0.9);
          backdrop-filter: blur(12px);
        }
        .top-nav .brand { display: flex; align-items: center; gap: 10px; cursor: pointer; user-select: none; }
        .topbar-leaf-icon { display: inline-block; font-size: 20px; line-height: 1; color: #eff7bf; }
        .topbar-logo-text { font-size: 14px; font-weight: 700; letter-spacing: 0.2px; }
        .top-nav button#sidebar_toggle_top,
        .top-nav button#dark_toggle_top,
        .top-nav button#glossary_toggle {
          background: rgba(239, 247, 191, 0.12);
          border: 1px solid rgba(239, 247, 191, 0.22);
          color: #eff7bf;
          padding: 8px 10px;
          border-radius: 8px;
          font-size: 16px;
          min-width: 38px;
          height: 38px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
        }
        .top-nav button#sidebar_toggle_top { display: none; }
        .sidebar-backdrop {
          display: none;
          position: fixed;
          top: var(--topbar-height);
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(15, 23, 42, 0.26);
          z-index: 1240;
          opacity: 0;
          pointer-events: none;
          transition: opacity 0.2s ease;
        }
        .sidebar-open .sidebar-backdrop {
          opacity: 1;
          pointer-events: auto;
        }

        .modern-card {
          background: var(--cs-card-bg);
          border-radius: 12px;
          border: 1px solid var(--cs-border);
          margin-bottom: 18px;
          box-shadow: 0 8px 22px rgba(64, 109, 79, 0.08);
          overflow: hidden;
        }
        .card-header {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 16px 20px;
          border-bottom: 1px solid var(--cs-border);
          font-weight: 600;
          color: var(--cs-text-main);
          flex-wrap: wrap;
        }
        .card-header-controls { margin-left: auto; display: flex; gap: 8px; align-items: center; }
        .card-header-controls .shiny-input-container { margin-bottom: 0; }

        .panel-controls {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 24px;
          margin-bottom: 16px;
          flex-wrap: nowrap;
        }
        .panel-title { min-width: 0; flex: 1 1 320px; }
        .panel-filters-wrap { flex: 0 1 720px; margin-left: auto; }
        .panel-filters {
          display: flex;
          gap: 12px;
          align-items: end;
          justify-content: flex-end;
          width: 100%;
          margin-top: 0;
          flex-wrap: nowrap;
        }
        .panel-filter-item .shiny-input-container,
        .panel-filter-item .form-group {
          width: 100% !important;
          min-width: 0;
          margin-bottom: 0;
        }
        .panel-filter-item-year {
          width: min(280px, 100%);
          min-width: 0;
          flex: 1.35 1 0;
        }
        .panel-filter-item {
          width: 170px;
          min-width: 0;
          flex: 1 1 0;
        }

        /* Match deployed slider theme globally (ion.rangeSlider used by Shiny sliderInput). */
        .irs--shiny .irs-line {
          top: 24px;
          height: 10px;
          background: #e2dba5;
          border: 0;
          border-radius: 999px;
          box-shadow: inset 0 1px 2px rgba(15, 23, 42, 0.08);
        }
        .irs--shiny .irs-bar {
          top: 24px;
          height: 10px;
          background: linear-gradient(90deg, #b9c85d, #406d4f);
          border: 0;
          border-radius: 8px 0 0 8px;
          box-shadow: 0 6px 14px rgba(22, 163, 74, 0.28);
        }
        .irs--shiny .irs-handle {
          top: 18px;
          width: 22px;
          height: 22px;
          border: 2.4px solid #fffdf4;
          background: #406d4f;
          border-radius: 50%;
          box-shadow: 0 8px 18px rgba(64, 109, 79, 0.28);
        }
        .irs--shiny .irs-handle.state_hover,
        .irs--shiny .irs-handle:hover {
          background: #3a6347;
        }
        .irs--shiny .irs-single,
        .irs--shiny .irs-from,
        .irs--shiny .irs-to {
          top: -6px;
          padding: 3px 8px;
          font-size: 11px;
          font-weight: 600;
          color: #ffffff;
          text-shadow: none;
          background: #406d4f;
          border-radius: 999px;
          box-shadow: 0 8px 20px rgba(17, 24, 39, 0.18);
        }
        .irs--shiny .irs-grid-text {
          color: #66785b;
          font-size: 10px;
        }
        .irs--shiny .irs-grid-pol {
          background: rgba(102, 120, 91, 0.38);
        }
        .irs--shiny .irs-min,
        .irs--shiny .irs-max {
          color: #66785b;
          background: #ecf1df;
        }

        .stat-card { background: var(--cs-card-bg); border-radius: 12px; padding: 14px; border: 1px solid var(--cs-border); height: 110px; color: var(--cs-text-main); box-shadow: 0 6px 18px rgba(64,109,79,0.10); }
        .resource-card { height: 110px; padding: 14px 14px 12px; display: flex; flex-direction: column; justify-content: flex-start; gap: 2px; }
        .resource-grid { display: flex; justify-content: space-between; gap: 12px; margin-top: 0; }
        .resource-item { flex: 1; min-width: 0; text-align: center; }
        .resource-label { display: block; font-size: 10px; line-height: 1.2; color: var(--cs-text-main); opacity: 0.9; }
        .stat-val { font-size: 20px; font-weight: 700; display: block; line-height: 1.1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .resource-stat { font-size: 18px; font-weight: 700; display: block; line-height: 1.1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .stat-lbl { font-size: 11px; text-transform: uppercase; color: var(--cs-text-main); font-weight: 600; margin: 0; }
        .split-stat-card { display: block; }
        .split-stat-grid { display: flex; gap: 12px; align-items: flex-start; }
        .split-stat-box { flex: 1; text-align: left; min-width: 0; display: flex; flex-direction: column; gap: 4px; }

        .weather-card { display: flex; flex-direction: column; gap: 4px; padding: 14px; height: 110px; }
        .weather-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
        .weather-temp { font-size: 28px; font-weight: 700; line-height: 1; }
        .weather-desc { font-size: 13px; }
        .weather-meta { display: flex; gap: 14px; font-size: 11px; }
        .weather-icon { font-size: 34px; line-height: 1; }

        .graph-card {
          overflow: hidden;
          background: transparent;
          border: 1px solid rgba(64, 109, 79, 0.16);
          border-radius: 18px;
          box-shadow: 0 16px 36px rgba(15, 23, 42, 0.08), 0 2px 8px rgba(64, 109, 79, 0.06);
        }
        .graph-card .card-header {
          padding: 14px 18px;
          border-bottom: 1px solid rgba(64, 109, 79, 0.1);
        }
        .graph-body { padding: 14px; }

        .eff-tooltip {
          background: linear-gradient(180deg, rgba(17,24,39,0.96), rgba(17,24,39,0.88));
          color: #f8fafc;
          padding: 12px 14px;
          border-radius: 10px;
          box-shadow: 0 10px 28px rgba(2,6,23,0.6);
          font-size: 13px;
          line-height: 1.5;
          display: none;
          pointer-events: auto;
          min-width: 240px;
          word-wrap: break-word;
        }
        .eff-tooltip::after {
          content: "";
          position: absolute;
          bottom: -6px;
          right: 14px;
          border-width: 6px;
          border-style: solid;
          border-color: rgba(17,24,39,0.88) transparent transparent transparent;
        }

        .glossary-side-panel {
          position: fixed;
          top: var(--topbar-height);
          right: 0;
          width: 320px;
          height: calc(100vh - var(--topbar-height));
          background: var(--cs-card-bg);
          border-left: 1px solid var(--cs-border);
          box-shadow: -8px 0 28px rgba(2, 6, 23, 0.14);
          transform: translateX(100%);
          transition: transform 0.25s ease;
          z-index: 1250;
          display: flex;
          flex-direction: column;
        }
        .glossary-side-panel.open { transform: translateX(0); }
        .glossary-panel-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 14px 16px;
          border-bottom: 1px solid var(--cs-border);
          color: var(--cs-text-main);
        }
        .glossary-panel-content {
          padding: 12px;
          overflow-y: auto;
          flex: 1;
        }
        .glossary-item {
          border-bottom: 1px solid rgba(100,116,139,0.12);
          margin-bottom: 4px;
        }
        .glossary-term {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 12px 8px;
          cursor: pointer;
          user-select: none;
        }
        .glossary-arrow { font-size: 11px; color: #94a3b8; }
        .glossary-definition {
          display: none;
          padding: 12px 16px;
          border-left: 3px solid #10b981;
          font-size: 12px;
          color: var(--cs-text-sub);
          line-height: 1.4;
          background: rgba(16, 185, 129, 0.08);
        }

        @media (max-width: 768px) {
          header.main-header,
          .main-header,
          .skin-black .main-header,
          .main-header .navbar,
          .sidebar-open .skin-black .main-header,
          .sidebar-open .main-header,
          .sidebar-open .main-header .navbar {
            display: none !important;
            height: 0 !important;
            min-height: 0 !important;
          }
          .top-nav { padding: 10px 12px; }
          .main-sidebar {
            width: 220px !important;
            left: -220px;
            transform: none;
            box-shadow: 4px 0 20px rgba(0, 0, 0, 0.18);
            transition: left 0.25s ease;
          }
          .sidebar-open .main-sidebar { left: 0; z-index: 1250; }
          .content-wrapper, .main-sidebar:hover + .content-wrapper, .sidebar-open .content-wrapper {
            margin-left: 0 !important;
            padding-left: 0 !important;
            left: 0 !important;
          }
          .sidebar-backdrop { display: block; }
          .sidebar-open .sidebar-backdrop { opacity: 1; pointer-events: auto; }
          .skin-black.sidebar-open .main-sidebar { padding-top: 0 !important; top: 50px !important; }
          .skin-black.sidebar-open .content-wrapper { padding-top: var(--topbar-height) !important; margin-top: var(--topbar-height) !important; }
          .panel-controls { flex-direction: column; gap: 12px; align-items: stretch; }
          .panel-title,
          .panel-filters-wrap { width: 100%; flex: 1 1 auto; margin-left: 0; }
          .panel-filters { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; justify-content: stretch; }
          .panel-filter-item-year { grid-column: 1 / -1; width: 100%; }
          .card-header-controls { margin-left: 0 !important; width: 100%; flex-wrap: wrap; }
          .card-header-controls .shiny-input-container,
          .card-header-controls .form-group { width: 100% !important; min-width: 0; margin-bottom: 0; }
          .eff-tooltip { left: 10px; right: 10px; min-width: 0; max-width: none; }
          .summary-cards .stat-card,
          .summary-cards .resource-card,
          .summary-cards .weather-card { min-height: 96px; padding: 12px; height: auto; }
          .summary-cards .split-stat-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
          .summary-cards .resource-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; }
          .summary-cards .resource-label { font-size: 9px; }
          .summary-cards .weather-icon { font-size: 30px; }
        }

        @media (max-width: 576px) {
          .panel-filters { grid-template-columns: 1fr; gap: 8px; }
          .panel-filter-item-year { grid-column: auto; }
          .topbar-logo-text { font-size: 12px; }
          .glossary-side-panel { width: 100%; transform: translateX(100%); }
        }
      '))),

    div(class = "top-nav",
      div(class = "brand",
        span("🌿", class = "topbar-leaf-icon"),
        span("CropSense", class = "topbar-logo-text")
      ),
      div(),
      div(style = "display:flex; align-items:center; gap:12px;",
        tags$button(id = "dark_toggle_top", type = "button", class = "btn btn-default", HTML('☾')),
        tags$button(id = "glossary_toggle", type = "button", class = "btn btn-default", HTML('📖'), title = "Show Glossary")
      )
    ),

    div(class = "sidebar-backdrop", id = "sidebar_backdrop"),

    div(id = "glossary_panel", class = "glossary-side-panel",
      div(class = "glossary-panel-header",
        span("📖 Data Glossary", style = "flex:1; font-size:15px; font-weight:600;"),
        tags$button(id = "glossary_panel_close", type = "button", class = "btn btn-sm btn-default", HTML('✕'), style = "padding:4px 8px; font-size:12px;")
      ),
      div(class = "glossary-panel-content",
        div(class = "glossary-item", `data-term` = "yoy",
          div(class = "glossary-term",
            span("📈 YoY Change", style = "font-weight: 600; color: #3b82f6;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Year-over-Year percentage change comparing current year to previous year with same filters applied.")
        ),
        div(class = "glossary-item", `data-term` = "delta",
          div(class = "glossary-term",
            span("Δ Delta", style = "font-weight: 600; color: #22c55e;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Change value shown as percentage. Green (📈) indicates increase, Red (📉) indicates decrease.")
        ),
        div(class = "glossary-item", `data-term` = "benchmark",
          div(class = "glossary-term",
            span("📊 Benchmark", style = "font-weight: 600; color: #a855f7;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Dashed line showing national average (mean yield). Used to compare individual location performance.")
        ),
        div(class = "glossary-item", `data-term` = "yield",
          div(class = "glossary-term",
            span("🌾 Yield", style = "font-weight: 600; color: #f97316;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Agricultural output measured in crop production volume. Higher yield indicates better productivity.")
        ),
        div(class = "glossary-item", `data-term` = "record",
          div(class = "glossary-term",
            span("🏆 Record", style = "font-weight: 600; color: #10b981;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Highest value in the dataset, marked with annotation on trend charts for easy identification.")
        ),
        div(class = "glossary-item", `data-term` = "efficiency",
          div(class = "glossary-term",
            span("⚡ Efficiency", style = "font-weight: 600; color: #0ea5e9;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Productivity ratio showing crop output relative to soil type, temperature, or other factors.")
        ),
        div(class = "glossary-item", `data-term` = "season",
          div(class = "glossary-term",
            span("🌱 Season", style = "font-weight: 600; color: #f9b442;"),
            span("▶", class = "glossary-arrow")
          ),
          div(class = "glossary-definition", "Growing period classification (Kharif, Rabi, Summer) affecting crop selection and yield patterns.")
        )
      )
    ),

    conditionalPanel(
      condition = "input.tabs == 'dashboard'",
      div(style = "padding: 25px;",
        div(class = "panel-controls",
          div(class = "panel-title",
            h2("Crop Analytics", style = "margin:0; font-weight:700; color:var(--cs-text-main);") ,
            tags$p("Analyze crop yield and area by year, location, season, and crop type", style = "margin:0; font-size:12px; color:var(--cs-text-sub);")
          ),
          div(class = "panel-filters-wrap",
            div(class = "panel-filters",
              div(class = "panel-filter-item panel-filter-item-year", sliderInput("year_filter", "Year", min = 2000, max = 2020, value = 2015, step = 1, sep = "")),
              div(class = "panel-filter-item", selectInput("loc_filter", "Location", choices = "All")),
              div(class = "panel-filter-item", selectInput("crop_filter", "Crop", choices = "All")),
              div(class = "panel-filter-item", selectInput("season_filter", "Season", choices = "All"))
            )
          )
        ),
        br(),
        fluidRow(class = "summary-cards",
          column(4,
            div(class = "stat-card split-stat-card",
              div(class = "split-stat-grid",
                div(class = "split-stat-box",
                  span(class = "stat-lbl", "Total Yields"),
                  span(class = "stat-val", textOutput("sum_yields"))
                ),
                div(class = "split-stat-box",
                  span(class = "stat-lbl", "Total Area (ha)"),
                  span(class = "stat-val", textOutput("sum_area"))
                )
              )
            )
          ),
          column(4,
            div(class = "stat-card resource-card",
              span(class = "stat-lbl", "Resource Usage (Est.)"),
              div(class = "resource-grid",
                div(class = "resource-item", span(class = "resource-stat", textOutput("pest_val", inline = TRUE)), span(class = "resource-label", "Pesticide")),
                div(class = "resource-item", span(class = "resource-stat", textOutput("fert_val", inline = TRUE)), span(class = "resource-label", "Fertilizer")),
                div(class = "resource-item", span(class = "resource-stat", textOutput("water_val", inline = TRUE)), span(class = "resource-label", "Water"))
              )
            )
          ),
          column(4,
            div(class = "stat-card weather-card",
              div(class = "weather-top",
                div(
                  div(style = "margin-top:0px;", span(textOutput("weather_location"), style = "font-size:13px; font-weight:600;")),
                  div(class = "weather-temp", textOutput("weather_temp")),
                  div(class = "weather-desc", textOutput("weather_desc"))
                ),
                div(class = "weather-icon", textOutput("weather_icon"))
              ),
              div(class = "weather-meta",
                div(textOutput("weather_wind")),
                div(textOutput("weather_humidity"))
              )
            )
          )
        ),
        br(),
        fluidRow(
          column(6,
            div(class = "modern-card graph-card",
              div(class = "card-header", icon("map"), "Production / Seasonal",
                div(class = "card-header-controls",
                  selectInput("combined_chart_select", NULL, choices = c("Production by Location", "Seasonal Distribution"), selected = "Production by Location", width = "220px")
                )
              ),
              div(class = "graph-body", plotlyOutput("combined_chart", height = "350px"))
            )
          ),
          column(6,
            div(id = "efficiency-card", class = "modern-card graph-card", style = "position:relative;",
              div(class = "card-header", icon("bolt"), "Efficiency Analysis",
                div(class = "card-header-controls",
                  selectInput("efficiency_var_select", NULL, choices = c("Crop Distribution", "Soil Type", "Temperature"), selected = "Crop Distribution", width = "220px")
                )
              ),
              div(id = "eff_tooltip", class = "eff-tooltip", style = "display:none; position:absolute; bottom:60px; right:12px; max-width:320px; z-index:2000;",
                  HTML('<div style="display:flex; gap:8px; align-items:flex-start;"><div id="eff_tooltip_content" style="flex:1"></div><button id="eff_tooltip_close" class="btn btn-xs btn-default" style="background:transparent; border:none; color:#cbd5e1; font-size:14px;">✕</button></div>')
              ),
              actionButton("eff_help_btn", "?", class = "btn btn-default btn-sm", style = "position:absolute; bottom:12px; right:12px; padding:6px 8px; font-weight:700; z-index:1999;"),
              div(class = "graph-body", plotlyOutput("efficiency_scatter", height = "350px"))
            )
          )
        ),
        fluidRow(
          column(12,
            div(class = "modern-card graph-card",
              div(class = "card-header", icon("chart-line"), "Yield Trends"),
              div(class = "graph-body", plotlyOutput("trend_plot", height = "400px"))
            )
          )
        ),
        fluidRow(
          column(12,
            div(class = "modern-card graph-card",
              div(class = "card-header", icon("project-diagram"), "Factor Correlation"),
              div(class = "graph-body", plotlyOutput("stat_corr", height = "360px"))
            )
          )
        )
      )
    ),

    conditionalPanel(
      condition = "input.tabs == 'prediction'",
      div(style = "padding: 20px;",
        fluidRow(
          column(4,
            div(class = "modern-card",
              div(class = "card-header", icon("flask"), "Soil Nutrients (NPK) & pH"),
              div(style = "padding:12px;",
                sliderInput("input_n", "Nitrogen (N)", min = 0, max = 150, value = 80, step = 1, width = '100%'),
                tags$div(style = 'display:flex; gap:10px; margin-top:6px;',
                         tags$span(style = 'flex:1', sliderInput("input_p", "Phosphorus (P)", min = 0, max = 150, value = 40, step = 1, width = '100%')),
                         tags$span(style = 'flex:1', sliderInput("input_k", "Potassium (K)", min = 0, max = 150, value = 40, step = 1, width = '100%'))
                ),
                sliderInput("input_ph", "Soil pH", min = 0, max = 14, value = 6.5, step = 0.01, width = '100%')
              )
            ),
            br(),
            div(class = "modern-card",
              div(class = "card-header", icon("thermometer-half"), "Climate Conditions"),
              div(style = "padding:12px;",
                sliderInput("input_temp", "Temperature (°C)", min = -10, max = 50, value = 25, step = 0.1, width = '100%'),
                sliderInput("input_hum", "Humidity (%)", min = 0, max = 100, value = 80, step = 0.1, width = '100%'),
                sliderInput("input_rain", "Rainfall (mm)", min = 0, max = 500, value = 200, step = 0.1, width = '100%')
              )
            ),
            br(),
            actionButton("predict_btn", "Get Crop Recommendation", class = "btn btn-success", style = "width:100%; padding:12px; font-weight:700; font-size:16px; border-radius:8px; background:#10b981; border:none; color:#fff;")
          ),
          column(8,
            div(class = "modern-card",
              tags$div(class = 'prediction-hero', style = 'display:flex; align-items:center; gap:18px; padding:18px; background:linear-gradient(90deg, #f0fdfa, #f8fafc); border-radius:8px;',
                       div(style = 'width:120px; height:120px; background:linear-gradient(135deg, #10b981, #059669); border-radius:12px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:56px;', textOutput('pred_crop_image')),
                       div(style = 'flex:1;',
                           div(style = 'font-size:12px; color:var(--cs-text-sub); font-weight:600; text-transform:uppercase;', 'Primary Recommendation'),
                           div(style = 'font-size:40px; font-weight:800; margin-top:6px;', textOutput('pred_crop')),
                           div(style = 'display:flex; gap:10px; align-items:center;',
                               div(style = 'background:#0f172a; color:#fff; padding:8px 12px; border-radius:8px; font-weight:700;', 'Confidence: ', textOutput('pred_confidence', inline = TRUE)),
                               div(style = 'background:#eef2ff; padding:8px 12px; border-radius:8px; color:#0f172a;', textOutput('pred_info_rain', inline = TRUE)),
                               div(style = 'background:#fff7ed; padding:8px 12px; border-radius:8px; color:#b45309;', textOutput('pred_info_temp', inline = TRUE))
                           )
                       )
              )
            ),
            br(),
            div(class = 'modern-card',
              div(class = 'card-header', icon('list'), 'Top Alternatives'),
              div(style = 'padding:12px;', plotlyOutput('pred_alternatives', height = '280px'))
            ),
            br(),
            fluidRow(
              column(6,
                div(class = 'modern-card',
                  div(class = 'card-header', icon('chart-area'), 'Soil Profile vs Ideal Requirements'),
                  div(style = 'padding:12px;', plotlyOutput('pred_radar', height = '300px'))
                )
              )
            )
          )
        )
      )
    ),

    conditionalPanel(
      condition = "input.tabs == 'about'",
      div(style = "padding: 40px;",
        div(style = "margin-bottom: 40px; text-align: center;",
          h1("About CropSense", style = "font-size: 48px; font-weight: 800; margin: 0 0 12px 0; color: var(--cs-text-main);"),
          p("Intelligent Crop Recommendation System Using Machine Learning", style = "font-size: 16px; color: var(--cs-text-sub); margin: 0;")
        ),
        fluidRow(
          column(12,
            div(class = "modern-card",
              div(class = "card-header", icon("info-circle"), "About This Dashboard"),
              div(style = "padding: 20px;",
                p("CropSense is an intelligent web-based dashboard designed to help farmers and agricultural professionals make data-driven decisions about crop selection and management. Our platform combines historical agricultural data with machine learning to provide personalized crop recommendations based on soil conditions, climate, and nutrient levels.",
                  style = "font-size: 15px; line-height: 1.6; color: var(--cs-text-main); margin-bottom: 12px;"),
                p("The dashboard provides comprehensive analytics including production trends, seasonal distribution analysis, efficiency metrics, and real-time weather data integration. The prediction engine uses a Random Forest model trained on diverse crop data to recommend the most suitable crops for specific environmental conditions.",
                  style = "font-size: 15px; line-height: 1.6; color: var(--cs-text-main);")
              )
            )
          )
        ),
        br(),
        fluidRow(
          column(12,
            div(class = "modern-card",
              div(class = "card-header", icon("database"), "Dataset Information"),
              div(style = "padding: 20px;",
                fluidRow(
                  column(4,
                    div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #10b981;",
                      h4("Crop Production Data", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                      p("Historical crop yield and production records by location, year, season, and soil type.", style = "margin: 0; font-size: 14px; color: var(--cs-text-sub);")
                    )
                  ),
                  column(4,
                    div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #06b6d4;",
                      h4("Crop Recommendation Data", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                      p("Machine learning training dataset with soil nutrients (N, P, K), temperature, humidity, pH, and rainfall mapped to optimal crop labels.", style = "margin: 0; font-size: 14px; color: var(--cs-text-sub);")
                    )
                  ),
                  column(4,
                    div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #f59e0b;",
                      h4("Weather Data", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                      p("Real-time and historical weather data including temperature, humidity, wind speed, and rainfall patterns for regional analysis.", style = "margin: 0; font-size: 14px; color: var(--cs-text-sub);")
                    )
                  )
                )
              )
            )
          )
        ),
        br(),
        div(style = "margin-bottom: 12px;",
          h3("Development Team", style = "font-size: 24px; font-weight: 700; color: var(--cs-text-main); margin: 0 0 20px 0;")
        ),
        fluidRow(
          column(6,
            div(class = "modern-card",
              div(style = "padding: 24px; display: flex; flex-direction: column; align-items: center; text-align: center;",
                div(style = "width: 100px; height: 100px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; margin-bottom: 16px;", "👩‍💻"),
                h4("Elvie May Mara", style = "margin: 0 0 8px 0; font-size: 20px; font-weight: 700; color: var(--cs-text-main);"),
                p("Full-Stack Developer", style = "margin: 0 0 8px 0; color: var(--cs-text-sub); font-size: 14px;"),
                p("Specialized in R Shiny development, data visualization, and interactive dashboard design.", style = "margin: 0; color: var(--cs-text-sub); font-size: 13px; line-height: 1.5;")
              )
            )
          ),
          column(6,
            div(class = "modern-card",
              div(style = "padding: 24px; display: flex; flex-direction: column; align-items: center; text-align: center;",
                div(style = "width: 100px; height: 100px; background: linear-gradient(135deg, #06b6d4, #0891b2); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; margin-bottom: 16px;", "👨‍💻"),
                h4("Baberose Silmaro", style = "margin: 0 0 8px 0; font-size: 20px; font-weight: 700; color: var(--cs-text-main);"),
                p("Machine Learning Engineer", style = "margin: 0 0 8px 0; color: var(--cs-text-sub); font-size: 14px;"),
                p("Specialized in predictive modeling, data processing, and agricultural data science applications.", style = "margin: 0; color: var(--cs-text-sub); font-size: 13px; line-height: 1.5;")
              )
            )
          )
        ),
        br(),
        div(style = "text-align: center; padding: 20px; border-top: 1px solid var(--cs-border); margin-top: 20px;",
          p("CropSense © 2026 | Leveraging Data Science for Sustainable Agriculture", style = "color: var(--cs-text-sub); font-size: 13px; margin: 0;")
        )
      )
    )
  )
)
