# ui.R – Modern HTML-based Dashboard with Custom CSS

shinyUI(
  tagList(
    # Include the custom CSS stylesheet
    tags$head(
      tags$meta(charset = "UTF-8"),
      tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0"),
      tags$title("Precision Farming: Intelligent Crop Advisor"),
      
      # Font Awesome for icons
      tags$link(
        rel = "stylesheet",
        href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      ),
      
      # Custom CSS embedded
      tags$style(HTML("
        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
          font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
          background-color: #e5e7eb;
        }

        .app-root {
          display: flex;
          min-height: 100vh;
          padding-top: 3.4rem;
          padding-left: 76px;
          transition: padding-left 0.32s ease;
        }

        .app-root.sidebar-open {
          padding-left: 220px;
        }

        .mobile-topbar {
          display: flex;
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          height: 3.4rem;
          align-items: center;
          gap: 0;
          padding: 0;
          background: #0b1635;
          color: #fff;
          z-index: 1200;
          box-shadow: 0 6px 20px rgba(15, 23, 42, 0.22);
        }

        .mobile-topbar-title {
          font-size: 0.98rem;
          font-weight: 700;
          letter-spacing: 0.02em;
          opacity: 0;
          max-width: 0;
          overflow: hidden;
          white-space: nowrap;
          transform: translateX(-6px);
          transition: opacity 0.2s ease, max-width 0.25s ease, transform 0.2s ease;
          padding-left: 1rem;
        }

        .theme-toggle {
          margin-left: auto;
          margin-right: calc((76px - 2.4rem) / 2);
          border: none;
          background: rgba(255, 255, 255, 0.12);
          color: #fff;
          width: 2.4rem;
          height: 2.4rem;
          border-radius: 0.5rem;
          cursor: pointer;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          transition: background-color 0.2s ease, transform 0.2s ease;
        }

        .theme-toggle:hover {
          background: rgba(255, 255, 255, 0.2);
          transform: translateY(-1px);
        }

        .theme-toggle i {
          font-size: 1rem;
        }

        .app-root.sidebar-open .mobile-topbar-title,
        .app-root.sidebar-hover .mobile-topbar-title {
          opacity: 1;
          max-width: 10rem;
          transform: translateX(0);
        }

        .sidebar {
          position: fixed;
          top: 3.4rem;
          left: 0;
          bottom: 0;
          width: 76px;
          background: #0b1635;
          color: #e5e7eb;
          padding: 1rem 0.5rem;
          z-index: 1100;
          overflow: hidden;
          transition: width 0.32s cubic-bezier(0.2, 0.8, 0.2, 1), box-shadow 0.32s ease;
          will-change: width;
        }

        .app-root.sidebar-open .sidebar {
          width: 220px;
          box-shadow: 10px 0 28px rgba(2, 6, 23, 0.18);
        }

        .sidebar:hover,
        .sidebar:focus-within {
          width: 220px;
          box-shadow: 10px 0 28px rgba(2, 6, 23, 0.16);
        }

        .menu-toggle {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          border: none;
          background: transparent;
          color: #fff;
          width: 76px;
          height: 100%;
          border-radius: 0;
          cursor: pointer;
          margin-bottom: 0;
          padding: 0;
        }

        .menu-toggle i {
          font-size: 1.15rem;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          width: 1.2rem;
          height: 1.2rem;
          line-height: 1;
        }

        .nav-link {
          display: grid;
          grid-template-columns: 1.5rem 0fr;
          align-items: center;
          justify-items: start;
          width: 100%;
          justify-content: flex-start;
          text-align: left;
          column-gap: 0;
          padding: 0.6rem 0.65rem 0.6rem 1.125rem;
          border-radius: 0.5rem;
          margin-bottom: 0.25rem;
          color: #cbd5f5;
          text-decoration: none;
          font-size: 0.9rem;
          transition: background-color 0.2s ease, color 0.2s ease, grid-template-columns 0.3s ease, column-gap 0.3s ease;
          cursor: pointer;
          border: none;
          background: transparent;
        }

        .nav-link i {
          justify-self: center;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          width: 1.2rem;
          height: 1.2rem;
          line-height: 1;
          font-size: 0.95rem;
          color: #93c5fd;
          transition: color 0.2s ease, transform 0.2s ease;
        }

        .nav-text {
          max-width: 0;
          opacity: 0;
          text-align: left;
          justify-self: start;
          overflow: hidden;
          white-space: nowrap;
          transform: translateX(-6px);
          transition: max-width 0.3s ease 0.04s, opacity 0.18s ease 0.08s, transform 0.2s ease 0.08s, margin-left 0.2s ease;
        }

        .sidebar:hover .nav-link,
        .sidebar:focus-within .nav-link,
        .app-root.sidebar-open .nav-link {
          grid-template-columns: 1.5rem minmax(0, 1fr);
          column-gap: 0.55rem;
        }

        .sidebar:hover .nav-text,
        .sidebar:focus-within .nav-text,
        .app-root.sidebar-open .nav-text {
          max-width: 12rem;
          opacity: 1;
          transform: translateX(0);
        }

        .nav-link:hover {
          background: #1e3a8a;
          color: #ffffff;
        }

        .nav-link:hover i {
          color: #ffffff;
        }

        .nav-link.active {
          background: #1d4ed8;
          color: #fff;
        }

        .nav-link.active i {
          color: #fff;
        }

        body.dark-mode {
          background-color: #0f172a;
        }

        body.dark-mode .mobile-topbar {
          background: #020617;
          box-shadow: 0 6px 20px rgba(2, 6, 23, 0.45);
        }

        body.dark-mode .theme-toggle {
          background: rgba(255, 255, 255, 0.08);
        }

        body.dark-mode .sidebar {
          background: #020617;
          color: #e2e8f0;
        }

        body.dark-mode .nav-link {
          color: #cbd5e1;
        }

        body.dark-mode .nav-link i {
          color: #60a5fa;
        }

        body.dark-mode .nav-link:hover {
          background: #1e293b;
        }

        body.dark-mode .nav-link.active {
          background: #2563eb;
        }

        body.dark-mode .main {
          background: #0f172a;
        }

        body.dark-mode .card {
          background: #111827;
          box-shadow: 0 6px 20px rgba(2, 6, 23, 0.35);
        }

        body.dark-mode .col-span-4 > .card {
          background: linear-gradient(180deg, #0f172a 0%, #111827 100%);
          border: 1px solid #4f7bf3;
          box-shadow: 0 12px 28px rgba(2, 6, 23, 0.5);
        }

        body.dark-mode .section-title,
        body.dark-mode .topbar-title,
        body.dark-mode .recommended-name,
        body.dark-mode .flex-between,
        body.dark-mode .card,
        body.dark-mode p,
        body.dark-mode label,
        body.dark-mode .text-muted {
          color: #e5e7eb;
        }

        body.dark-mode .text-muted {
          color: #94a3b8;
        }

        body.dark-mode .chip {
          background: #1f2937;
          color: #e5e7eb;
        }

        body.dark-mode .btn-primary {
          background: #10b981;
        }

        body.dark-mode .btn-primary:hover {
          background: #059669;
        }

        body.dark-mode .slider-row input[type='range'] {
          accent-color: #60a5fa;
        }

        .main {
          flex: 1;
          padding: 2.5rem 1.5rem;
          background: #f3f4f6;
          overflow-y: auto;
        }

        .topbar-title {
          font-size: 1.3rem;
          font-weight: 600;
          margin-bottom: 0.75rem;
        }

        .page {
          display: none;
        }
        
        .page.visible {
          display: block;
        }

        .grid {
          display: grid;
          gap: 1.5rem;
        }
        
        .grid-cols-12 {
          grid-template-columns: repeat(12, minmax(0, 1fr));
        }
        
        .col-span-4 {
          grid-column: span 4 / span 4;
        }
        
        .col-span-6 {
          grid-column: span 6 / span 6;
        }
        
        .col-span-8 {
          grid-column: span 8 / span 8;
        }
        
        .col-span-12 {
          grid-column: span 12 / span 12;
        }

        .output-layout {
          margin-bottom: 1.5rem;
        }

        .output-layout .output-recommend {
          grid-column: 1 / -1;
        }

        .output-layout .output-top3 {
          width: 100%;
        }

        .output-layout .output-importance {
          width: 100%;
        }

        .card {
          background: #fff;
          border-radius: 0.75rem;
          padding: 1rem 1.25rem;
          box-shadow: 0 6px 20px rgba(15, 23, 42, 0.1);
          margin-bottom: 0.75rem;
        }

        .output-recommend .card {
          padding-top: 0.68rem;
          padding-bottom: 0.68rem;
        }
        
        .col-span-4 > .card {
          background: linear-gradient(180deg, #0f172a 0%, #111827 100%);
          box-shadow: 0 12px 28px rgba(2, 6, 23, 0.5);
          color: #e5e7eb;
        }

        .col-span-4 > .card .section-title,
        .col-span-4 > .card .slider-row label,
        .col-span-4 > .card .text-muted {
          color: #e5e7eb;
        }

        .section-title {
          font-size: 0.95rem;
          font-weight: 600;
          margin-bottom: 1rem;
        }

        .slider-row {
          margin-bottom: 1.25rem;
        }
        
        .slider-row label {
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-size: 0.875rem;
          margin-bottom: 0rem;
          line-height: 0.5;
        }

        .slider-row label span {
          font-weight: 400;
          font-size: 0.875rem;
        }

        .slider-row .shiny-input-container {
          margin-bottom: 0;
          width: 100%;
        }

        .slider-row .shiny-input-container > label:empty {
          display: none;
        }

        .slider-row .irs--shiny {
          height: 44px;
          font-family: inherit;
        }

        .slider-row .irs--shiny.irs-with-grid {
          height: 44px;
        }

        .slider-row .irs--shiny .irs-line,
        .slider-row .irs--shiny .irs-bar {
          top: 16px;
          height: 8px;
          border-radius: 999px;
        }

        .slider-row .irs--shiny .irs-line {
          background: rgba(148, 163, 184, 0.35);
          border: none;
        }

        .slider-row .irs--shiny .irs-bar {
          background: #0ea5e9;
          border: none;
        }

        .slider-row .irs--shiny .irs-handle {
          top: 10px;
          width: 18px;
          height: 18px;
          border: none;
          background: #0ea5e9;
          box-shadow: none;
        }

        .slider-row .irs--shiny .irs-grid {
          top: 30px;
        }

        .slider-row .irs--shiny .irs-grid-text {
          color: #e5e7eb;
          font-size: 0.7rem;
        }

        .slider-row .irs--shiny .irs-single,
        .slider-row .irs--shiny .irs-min,
        .slider-row .irs--shiny .irs-max {
          display: none;
        }

        .slider-row input[type='range'] {
          width: 100%;
          accent-color: #1d4ed8;
        }

        .btn-primary {
          width: 100%;
          padding: 0.6rem;
          margin-top: 0.6rem;
          border-radius: 999px;
          border: none;
          background: #10b981;
          color: #fff;
          font-weight: 600;
          cursor: pointer;
          font-size: 0.9rem;
        }
        
        .btn-primary:hover {
          background: #059669;
        }

        .text-muted {
          font-size: 0.8rem;
          color: #6b7280;
        }

        .flex-between {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        
        .recommended-name {
          font-size: 2.45rem;
          font-weight: 800;
          text-transform: uppercase;
          line-height: 1;
          letter-spacing: 0.02em;
        }
        
        .big-emoji {
          font-size: 3rem;
        }

        .recommend-layout {
          display: grid;
          grid-template-columns: 78px minmax(0, 1fr) minmax(160px, 210px);
          align-items: center;
          gap: 0.55rem;
        }

        .recommend-icon {
          font-size: 4.5rem;
          line-height: 1;
        }

        .recommend-title {
          font-size: 0.96rem;
          font-weight: 600;
          color: #334155;
          margin-bottom: 0.2rem;
        }

        .recommend-content .recommended-name {
          margin-bottom: 0.25rem;
        }

        .recommend-content {
          min-width: 0;
        }

        .recommend-content #recommended-text {
          margin: 0;
          font-size: 0.88rem;
          line-height: 1.35;
          color: #475569;
          overflow-wrap: anywhere;
        }

        .recommend-probability {
          align-self: stretch;
          display: flex;
          flex-direction: column;
          justify-content: center;
          padding: 0 0.1rem;
        }

        .probability-title {
          text-align: center;
          margin-bottom: 0.01rem;
          font-size: 0.8rem;
          color: #334155;
          font-weight: 600;
        }

        .gauge-wrap {
          position: relative;
          width: min(176px, 100%);
          margin: -0.03rem auto 0;
        }

        .gauge-wrap #gauge-chart {
          width: 100% !important;
          height: auto !important;
          display: block;
        }

        .probability-meta {
          margin-top: 0;
        }

        .probability-value {
          text-align: center;
          font-size: 0.78rem;
          color: #475569;
          margin-bottom: 0.14rem;
        }

        #gauge-value {
          color: #1d4ed8;
          font-weight: 700;
        }

        .probability-legend {
          display: flex;
          justify-content: center;
          gap: 0.55rem;
          font-size: 0.67rem;
          color: #334155;
          margin-bottom: 0.1rem;
        }

        .legend-item {
          display: inline-flex;
          align-items: center;
          gap: 0.2rem;
        }

        .legend-swatch {
          width: 0.58rem;
          height: 0.58rem;
          border-radius: 999px;
        }

        .legend-confidence {
          background: #1d4ed8;
        }

        .legend-remaining {
          background: #e5e7eb;
          border: 1px solid #cbd5e1;
        }

        .output-recommend .chips {
          display: none;
        }
        
        .chips {
          margin-top: 0.3rem;
        }
        
        .chip {
          display: inline-block;
          padding: 0.15rem 0.5rem;
          border-radius: 999px;
          font-size: 0.7rem;
          background: #e5e7eb;
          margin-right: 0.25rem;
        }

        @media (max-width: 768px) {
          .col-span-4,
          .col-span-6,
          .col-span-8,
          .col-span-12 {
            grid-column: span 12 / span 12;
          }

          .output-layout .output-recommend,
          .output-layout .output-top3,
          .output-layout .output-importance {
            grid-column: span 12 / span 12;
          }

          .recommend-layout {
            grid-template-columns: 1fr;
            gap: 0.75rem;
          }
        }
      "))
    ),

    # Main app container
    div(
      class = "app-root",
      id = "app-root",
      
      # Top bar
      div(
        class = "mobile-topbar",
        tags$button(
          class = "menu-toggle",
          id = "menu-toggle",
          tags$i(class = "fas fa-bars")
        ),
        div(
          class = "mobile-topbar-title",
          "CropSense"
        ),
        tags$button(
          class = "theme-toggle",
          id = "dark-mode-btn",
          tags$i(class = "fas fa-moon")
        )
      ),

      # Sidebar
      tags$nav(
        class = "sidebar",
        id = "sidebar",
        tags$button(
          class = "nav-link active",
          id = "nav-dashboard",
          "data-page" = "dashboard",
          tags$i(class = "fas fa-gauge"),
          span(class = "nav-text", "Dashboard")
        ),
        tags$button(
          class = "nav-link",
          id = "nav-prediction",
          "data-page" = "prediction",
          tags$i(class = "fas fa-chart-line"),
          span(class = "nav-text", "Prediction")
        ),
        tags$button(
          class = "nav-link",
          id = "nav-settings",
          "data-page" = "settings",
          tags$i(class = "fas fa-sliders"),
          span(class = "nav-text", "Settings")
        ),
        tags$button(
          class = "nav-link",
          id = "nav-info",
          "data-page" = "info",
          tags$i(class = "fas fa-circle-info"),
          span(class = "nav-text", "Info")
        )
      ),

      # Main content
      tags$main(
        class = "main",
        
        # Dashboard page
        div(
          class = "page visible",
          id = "page-dashboard",
          
          # Grid layout
          div(
            class = "grid grid-cols-12",
            
            # Left column: Inputs
            div(
              class = "col-span-4",
              div(
                class = "card",
                div(class = "section-title", "Soil & Climate Inputs"),
                
                # Sliders
                div(
                  class = "slider-row",
                  tags$label("Nitrogen (N)", tags$span("80", id = "n-val")),
                  sliderInput("N", "", min = 0, max = 150, value = 80, step = 1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("Phosphorus (P)", tags$span("40", id = "p-val")),
                  sliderInput("P", "", min = 0, max = 150, value = 40, step = 1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("Potassium (K)", tags$span("40", id = "k-val")),
                  sliderInput("K", "", min = 0, max = 150, value = 40, step = 1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("Temperature (°C)", tags$span("22", id = "temp-val")),
                  sliderInput("temp", "", min = 0, max = 40, value = 22, step = 1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("Humidity (%)", tags$span("80", id = "hum-val")),
                  sliderInput("hum", "", min = 20, max = 100, value = 80, step = 1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("pH", tags$span("6.5", id = "ph-val")),
                  sliderInput("ph", "", min = 3, max = 9, value = 6.5, step = 0.1, width = "100%")
                ),
                div(
                  class = "slider-row",
                  tags$label("Rainfall (mm)", tags$span("200", id = "rain-val")),
                  sliderInput("rain", "", min = 0, max = 300, value = 200, step = 1, width = "100%")
                ),
                
                actionButton("recommend_btn", "Recommend Crop", class = "btn-primary"),
                p(class = "text-muted", "Adjust sliders to see how recommendation and charts change.")
              )
            ),

            # Right column: Outputs
            div(
              class = "col-span-8",
              
              # Recommendation card
              div(
                class = "output-layout output-recommend",
                div(
                  class = "card",
                  div(
                    class = "recommend-layout",
                    div(class = "recommend-icon", "🌾"),
                    div(
                      class = "recommend-content",
                      div(class = "recommend-title", "Your Recommended Crop:"),
                      div(class = "recommended-name", id = "recommended-crop", textOutput("recommended_crop")),
                      p(id = "recommended-text", "Based on advanced analysis of successful harvests.")
                    ),
                    div(
                      class = "recommend-probability",
                      div(class = "probability-title", "Probability"),
                      div(
                        class = "gauge-wrap",
                        plotlyOutput("gauge_chart", width = "100%", height = "150px")
                      ),
                      div(class = "probability-value", 
                          span(id = "gauge-value", "62.2"),
                          "% confidence"
                      )
                    )
                  )
                )
              ),
              
              # Top 3 and Feature Importance
              div(
                class = "output-layout",
                style = "display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;",
                div(
                  class = "output-top3",
                  div(
                    class = "card",
                    div(class = "section-title", "Top 3 Alternatives"),
                    plotlyOutput("top3_chart", height = "250px")
                  )
                ),
                div(
                  class = "output-importance",
                  div(
                    class = "card",
                    div(class = "section-title", "Feature Importance"),
                    plotlyOutput("importance_chart", height = "250px")
                  )
                )
              ),
              
              # Radar chart
              div(
                class = "output-layout",
                div(
                  class = "card col-span-12",
                  div(class = "section-title", id = "radar-title", "Soil Profile vs Ideal Profile (Rice)"),
                  plotlyOutput("radar_chart", height = "300px")
                )
              ),
              
              # Distribution chart
              div(
                class = "output-layout",
                div(
                  class = "card col-span-12",
                  div(class = "section-title", "Dataset Crop Distribution"),
                  textOutput("dataset_summary"),
                  plotlyOutput("dist_chart", height = "240px")
                )
              )
            )
          )
        ),

        # Prediction page
        div(
          class = "page",
          id = "page-prediction",
          div(class = "card", 
            div(class = "section-title", "Prediction"),
            p("Prediction page coming soon...")
          )
        ),

        # Settings page
        div(
          class = "page",
          id = "page-settings",
          div(class = "card",
            div(class = "section-title", "Settings"),
            p("Settings coming soon...")
          )
        ),

        # Info page
        div(
          class = "page",
          id = "page-info",
          div(class = "card",
            div(class = "section-title", "About & Info"),
            p("This dashboard uses the Kaggle Crop Recommendation dataset (N, P, K, temperature, humidity, pH, rainfall, crop label). The CSV is read from data/Crop_recommendation.csv and used to build the crop distribution chart and basic statistics.")
          )
        )
      )
    ),

    # JavaScript for interactivity
    tags$script(HTML("
      // Initialize on document ready
      $(document).ready(function() {
        // Sidebar toggle
        $('#menu-toggle').on('click', function() {
          $('#app-root').toggleClass('sidebar-open');
        });

        // Show topbar title while hovering over sidebar
        $('#sidebar').on('mouseenter', function() {
          $('#app-root').addClass('sidebar-hover');
        });

        $('#sidebar').on('mouseleave', function() {
          $('#app-root').removeClass('sidebar-hover');
        });

        // Dark mode toggle
        $('#dark-mode-btn').on('click', function() {
          $('body').toggleClass('dark-mode');
          var isDark = $('body').hasClass('dark-mode');
          var icon = isDark ? 'fa-sun' : 'fa-moon';
          $('#dark-mode-btn i').removeClass('fa-moon fa-sun').addClass(icon);
        });

        // Page navigation
        $('.nav-link').on('click', function() {
          var page = $(this).data('page');
          
          // Update active nav link
          $('.nav-link').removeClass('active');
          $(this).addClass('active');
          
          // Show page
          $('.page').removeClass('visible');
          $('#page-' + page).addClass('visible');
        });

        // Update slider value displays
        $('#N').on('input', function() {
          $('#n-val').text(this.value);
        });

        $('#P').on('input', function() {
          $('#p-val').text(this.value);
        });

        $('#K').on('input', function() {
          $('#k-val').text(this.value);
        });

        $('#temp').on('input', function() {
          $('#temp-val').text(this.value);
        });

        $('#hum').on('input', function() {
          $('#hum-val').text(this.value);
        });

        $('#ph').on('input', function() {
          $('#ph-val').text(this.value);
        });

        $('#rain').on('input', function() {
          $('#rain-val').text(this.value);
        });

      });
    "))
  )
)
