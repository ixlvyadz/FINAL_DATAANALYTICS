library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(title = "", titleWidth = 0),
  
  dashboardSidebar(
    width = 250,
    div(class = "sidebar-logo-bar",
        tags$i(class = "fas fa-leaf", style = "color: #16a34a; font-size: 24px;"),
        span("CropSense", style = "color: #ffffff; font-weight: 700; font-size: 20px; margin-left: 10px;")
    ),
    
    sidebarMenu(id = "tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-bar")),
      menuItem("Prediction", tabName = "prediction", icon = icon("chart-line")),
      menuItem("Settings", tabName = "settings", icon = icon("cog")),
      menuItem("Info", tabName = "info", icon = icon("info-circle"))
    ),
    
    div(class = "sidebar-bottom-controls",
        div(class = "sidebar-bottom-item", id = "dark_toggle",
            tags$i(class = "fas fa-moon"),
            span("Dark Mode")
        ),
        div(class = "sidebar-bottom-item", id = "collapse_toggle",
            tags$i(class = "fas fa-compress-alt"),
            span("Collapse")
        )
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", 
                href = "https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"),
      tags$style(HTML('
        :root {
          --cs-bg: #f8fafc;
          --cs-sidebar: #1a2332;
          --cs-card-bg: #ffffff;
          --cs-text-main: #1e293b;
          --cs-text-sub: #64748b;
          --cs-green: #10b981;
          --cs-blue: #3b82f6;
          --cs-border: #e2e8f0;
        }

        .dark-mode {
          --cs-bg: #0f172a;
          --cs-sidebar: #020617;
          --cs-card-bg: #1e293b;
          --cs-text-main: #f1f5f9;
          --cs-text-sub: #94a3b8;
          --cs-border: #334155;
        }

        * { font-family: "Poppins", sans-serif !important; }
        body, .content-wrapper { background-color: var(--cs-bg); color: var(--cs-text-main); transition: 0.3s; }
        .main-sidebar { background-color: var(--cs-sidebar) !important; border: none; }
        .sidebar-logo-bar { display: flex; height: 70px; align-items: center; padding: 0 20px; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .sidebar-menu > li > a { color: #cbd5e1 !important; margin: 5px 12px; border-radius: 8px; }
        .sidebar-menu > li.active > a { background-color: var(--cs-green) !important; color: white !important; }
        
        .top-nav {
          display: flex; align-items: center; justify-content: space-between;
          background-color: var(--cs-card-bg); padding: 0 30px; height: 80px;
          border-bottom: 1px solid var(--cs-border); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        
        .stat-card {
          background-color: var(--cs-card-bg); border-radius: 16px; padding: 20px;
          border: 1px solid var(--cs-border); height: 140px; display: flex; flex-direction: column; justify-content: center;
        }
        .stat-label { color: var(--cs-text-sub); font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-value { font-size: 26px; font-weight: 700; color: var(--cs-text-main); margin: 4px 0; }
        
        /* Resource Card Layout */
        .resource-row { display: flex; justify-content: space-between; margin-top: 10px; border-top: 1px solid var(--cs-border); padding-top: 10px; }
        .resource-box { text-align: center; flex: 1; }
        .res-val { font-weight: 700; font-size: 14px; display: block; }
        .res-lbl { font-size: 10px; color: var(--cs-text-sub); }

        .modern-card { background-color: var(--cs-card-bg); border-radius: 16px; border: 1px solid var(--cs-border); margin-bottom: 24px; }
        .card-header { padding: 16px 20px; border-bottom: 1px solid var(--cs-border); font-weight: 600; }
        
        .main-header, .logo { display: none !important; }
        .content-wrapper { margin-left: 250px !important; padding: 0 !important; }
        .filter-item { width: 160px; }
      '))
    ),
    
    tags$script(HTML("
      $(document).on('click', '#dark_toggle', function() { $('body').toggleClass('dark-mode'); });
    ")),

    # Header / Filters
    div(class = "top-nav",
        div(h2("Agricultural Insights", style="margin:0; font-weight:700;"), tags$p("Live data from data_season.csv", style="margin:0; color:var(--cs-text-sub); font-size:12px;")),
        div(style="display:flex; gap:15px; align-items:center;",
            div(class="filter-item", sliderInput("year_slider", NULL, 2000, 2020, 2015, step=1, sep="")),
            div(class="filter-item", selectInput("loc_select", NULL, choices = "All")),
            div(class="filter-item", selectInput("season_select", NULL, choices = "All"))
        )
    ),

    div(style = "padding: 30px;",
        # TOP SUMMARY CARDS
        fluidRow(
          column(4, div(class = "stat-card", 
                       div(class="stat-label", "Total Number of Crops"),
                       div(class="stat-value", textOutput("crop_count")),
                       div(style="color:var(--cs-green); font-size:12px;", icon("check-circle"), " Diversity Index Optimized")
          )),
          column(4, div(class = "stat-card", 
                       div(class="stat-label", "Total Farm Area"),
                       div(class="stat-value", textOutput("area_total")),
                       div(style="color:var(--cs-blue); font-size:12px;", icon("map-marked-alt"), " Hectares under cultivation")
          )),
          column(4, div(class = "stat-card", 
                       div(class="stat-label", "Resource Consumption"),
                       div(class="resource-row",
                           div(class="resource-box", span(class="res-val", textOutput("pest_val")), span(class="res-lbl", "Pesticide (L)")),
                           div(class="resource-box", span(class="res-val", textOutput("fert_val")), span(class="res-lbl", "Fertilizer (kg)")),
                           div(class="resource-box", span(class="res-val", textOutput("water_val")), span(class="res-lbl", "Water (m³)"))
                       )
          ))
        ),
        br(),
        
        # MAIN CHARTS
        fluidRow(
          column(6, div(class = "modern-card", div(class="card-header", "Yield by Crop"), div(style="padding:15px", plotlyOutput("yield_bar", height="350px")))),
          column(6, div(class = "modern-card", div(class="card-header", "Production Trends"), div(style="padding:15px", plotlyOutput("trend_line", height="350px"))))
        ),
        fluidRow(
          column(12, div(class = "modern-card", div(class="card-header", "Regional Performance Matrix"), div(style="padding:15px", plotlyOutput("geo_heat", height="400px"))))
        )
    )
  )
)