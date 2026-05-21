library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  skin = "black",

  dashboardHeader(title = "", titleWidth = 0),

  dashboardSidebar(
    width = 250,
    sidebarMenu(id = "tabs", selected = "dashboard",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("bar-chart")),
      menuItem("Crop Recommendation", tabName = "prediction", icon = icon("leaf")),
      menuItem("Project Notes", tabName = "about", icon = icon("info-circle"))
    )
  ),

  dashboardBody(
    tags$head(
      tags$title("South India Crop Yield Explorer"),
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&family=Poppins:wght@400;500;600;700;800;900&display=swap"
      ),
      tags$style(HTML('
        @font-face {
          font-family: "Crows Ink";
          src: url("fonts/Crowsink-lxgl5.ttf") format("truetype");
          font-weight: 400;
          font-style: normal;
          font-display: swap;
        }

        .field-metric-value,
        .field-metric-value *,
        .field-metric-change,
        .field-metric-change *,
        .field-record-row,
        .field-record-row *,
        .field-temp,
        .field-temp *,
        .field-weather-details,
        .field-weather-details *,
        .field-dash-card-value,
        .field-dash-card-value *,
        .field-dash-stat-val,
        .field-dash-stat-val * {
          font-family: "Playfair Display", Georgia, serif !important;
        }

        :root {
          --field-deep: #062817;
          --field-mid: #0b351d;
          --field-green: #0f4f2d;
          --field-cream: #fff8e8;
          --field-rice: #d9a21f;
          --field-rice-light: #ffe37b;
          --field-border: rgba(255, 248, 232, 0.72);
          --cs-bg: #f1f6ec;
          --cs-card-bg: #fbfff7;
          --cs-text-main: #2b4027;
          --cs-text-sub: #627158;
          --cs-border: #bfd0aa;
          --topbar-height: 0px;
        }

        * { box-sizing: border-box; font-family: "Poppins", sans-serif !important; }
        html, body, .wrapper { margin: 0; padding: 0; overflow-x: hidden; background: var(--field-deep) !important; }
        body, .content-wrapper { color: var(--cs-text-main); background: var(--field-deep) !important; }

        .top-nav,
        .main-sidebar,
        .sidebar-backdrop,
        .main-header,
        .logo,
        header.main-header,
        .skin-black .main-header,
        .main-header .navbar {
          display: none !important;
          width: 0 !important;
          height: 0 !important;
          min-height: 0 !important;
          padding: 0 !important;
          margin: 0 !important;
          overflow: hidden !important;
        }

        .content-wrapper,
        body.sidebar-hovered .content-wrapper,
        body.sidebar-open .content-wrapper,
        .skin-black .content-wrapper {
          margin-left: 0 !important;
          margin-top: 0 !important;
          left: 0 !important;
          padding: 0 !important;
          min-height: 100vh !important;
        }
        .content-wrapper > section.content {
          min-height: 100vh !important;
          padding: 0 !important;
        }

        .fa,
        .fa-brands,
        .fa-classic,
        .fa-regular,
        .fa-sharp,
        .fa-solid,
        .fab,
        .far,
        .fas {
          font-family: "Font Awesome 6 Free" !important;
          font-style: normal;
          font-variant: normal;
          line-height: 1;
        }
        .fa-solid,
        .fas { font-weight: 900; }
        .fa-brands,
        .fab {
          font-family: "Font Awesome 6 Brands" !important;
          font-weight: 400;
        }

        .field-screen {
          position: relative;
          z-index: 1;
          min-height: 100vh;
          padding: clamp(18px, 2.4vw, 34px);
          color: var(--field-cream);
          background: #062817;
          overflow: hidden;
        }

        .field-screen::before {
          content: "";
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 100vh;
          z-index: 0;
          pointer-events: none;
          background:
            radial-gradient(circle at 88% 4%, rgba(244, 216, 115, 0.20), transparent 25%),
            radial-gradient(circle at 10% 0%, rgba(178, 203, 103, 0.15), transparent 28%),
            linear-gradient(to bottom,
              rgba(6, 40, 23, 0) 0%,
              rgba(6, 40, 23, 0.8) 28vw,
              #062817 40vw
            ),
            url("bg-field.png") no-repeat center top / 100% auto;
        }

        .field-shell {
          position: relative;
          z-index: 2;
          max-width: 1640px;
          margin: 0 auto;
          display: grid;
          grid-template-columns: minmax(240px, 0.9fr) minmax(430px, 1.45fr) minmax(260px, 0.95fr);
          grid-template-areas:
            ". badge ."
            "left hero right"
            "actions actions actions"
            "content content content";
          gap: clamp(18px, 2vw, 30px);
          align-items: stretch;
        }

        .field-badge {
          grid-area: badge;
          justify-self: center;
          display: inline-flex;
          align-items: center;
          gap: 10px;
          padding: 0;
          color: var(--field-cream);
          border: 0;
          background: transparent;
          box-shadow: none;
          font-family: Georgia, "Times New Roman", serif !important;
          font-size: clamp(22px, 2vw, 36px);
          font-weight: 400;
          letter-spacing: -0.02em;
        }
        .field-badge i { display: none; }

        .field-left {
          grid-area: left;
          display: grid;
          gap: clamp(18px, 2vw, 28px);
          align-content: center;
        }
        .field-right {
          grid-area: right;
          display: grid;
          gap: clamp(18px, 2vw, 28px);
          align-content: center;
        }

        .field-hero {
          grid-area: hero;
          position: relative;
          min-height: clamp(420px, 43vw, 570px);
          display: flex;
          align-items: center;
          justify-content: center;
          border: 0;
          background: transparent;
          box-shadow: none;
          overflow: visible;
        }
        .field-hero-copy {
          width: min(96%, 980px);
          margin: 0 auto;
          text-align: center;
        }
        .field-hero h1 {
          margin: 0;
          color: var(--field-cream);
          font-family: "Crows Ink", "Cooper Black", "Arial Rounded MT Bold", Georgia, "Times New Roman", serif !important;
          font-size: clamp(64px, 7.4vw, 128px);
          line-height: 0.98;
          letter-spacing: -0.055em;
          font-weight: 900;
          text-shadow: 0 10px 28px rgba(0, 0, 0, 0.28);
        }
        .field-hero .field-year {
          display: block;
          margin-top: clamp(4px, 0.8vw, 12px);
          color: var(--field-cream);
          font-family: "Playfair Display", Georgia, serif !important;
          font-size: clamp(40px, 4.5vw, 80px);
          line-height: 0.84;
          font-weight: 500;
          letter-spacing: -0.02em !important;
          text-shadow: 0 10px 28px rgba(0, 0, 0, 0.28);
        }
        .field-divider,
        .field-landscape { display: none; }
        .field-hero p {
          max-width: 920px;
          margin: clamp(12px, 1.5vw, 24px) auto 0;
          color: var(--field-cream);
          font-family: Georgia, "Times New Roman", serif !important;
          font-size: clamp(12px, 1.225vw, 22px);
          line-height: 1.28;
          letter-spacing: -0.02em;
          text-shadow: 0 8px 24px rgba(0, 0, 0, 0.28);
        }

        .field-card-desc {
          margin-top: clamp(8px, 1vw, 16px);
          color: rgba(255, 248, 232, 0.82);
          font-family: Georgia, serif !important;
          font-size: clamp(12px, 1vw, 15px);
          line-height: 1.45;
          text-align: center;
          padding: 0 10px;
        }

        .field-dash-metrics {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: clamp(12px, 1.5vw, 20px);
          margin-top: clamp(16px, 2vw, 24px);
        }

        .field-dash-card {
          position: relative;
          overflow: hidden;
          background: rgba(4, 28, 14, 0.42);
          border: 2px solid rgba(255, 248, 232, 0.6);
          border-radius: 20px;
          padding: 16px 20px;
          color: var(--field-cream);
          box-shadow: 0 10px 24px rgba(4, 23, 12, 0.15);
          display: flex;
          flex-direction: column;
          justify-content: center;
          min-height: 120px;
        }

        .field-dash-card-title,
        .field-dash-card-title * {
          margin: 0 0 6px 0;
          font-family: "Crows Ink", "Cooper Black", Georgia, serif !important;
          font-size: 13px;
          letter-spacing: 0.05em;
          text-transform: uppercase;
          color: #c0d367;
          opacity: 0.95;
          text-align: center;
        }

        .field-dash-card-value {
          font-size: clamp(22px, 2vw, 32px);
          font-weight: 500;
          line-height: 1.1;
          color: var(--field-cream);
        }

        .field-dash-stats-grid {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 6px;
          text-align: center;
        }

        .field-dash-stat-val {
          display: block;
          font-size: clamp(15px, 1.3vw, 20px);
          font-weight: 500;
          line-height: 1.1;
        }

        .field-dash-stat-lbl {
          display: block;
          margin-top: 3px;
          font-size: 10px;
          letter-spacing: 0.06em;
          text-transform: uppercase;
          color: rgba(255, 248, 232, 0.66);
        }

        .field-dash-weather {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 8px;
          align-items: center;
          text-align: center;
        }

        .field-dash-weather-main {
          color: var(--field-cream);
          font-size: clamp(18px, 1.7vw, 28px);
          font-weight: 500;
        }

        .field-dash-weather-meta {
          color: rgba(255, 248, 232, 0.78);
          font-size: 12px;
          line-height: 1.35;
        }

        .field-dash-card .delta-badge,
        .field-dash-card .delta-badge * {
          margin-top: 0 !important;
          color: var(--field-cream) !important;
          font-family: "Playfair Display", Georgia, serif !important;
          background: transparent !important;
          box-shadow: none !important;
        }
        .field-dash-card .trend-sparkline { display: none; }

        .field-card {
          position: relative;
          overflow: hidden;
          min-height: 200px;
          border-radius: 34px;
          background: rgba(2, 24, 11, 0.34);
          border: 4px solid var(--field-border);
          box-shadow: 0 22px 52px rgba(4, 23, 12, 0.34);
          color: var(--field-cream);
        }
        .field-card-head {
          min-height: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;
          padding: 28px 24px 0;
          color: var(--field-cream);
          background: transparent;
          box-shadow: none;
        }
        .field-card-head h2 {
          margin: 0;
          font-family: "Crows Ink", "Cooper Black", "Arial Rounded MT Bold", Georgia, "Times New Roman", serif !important;
          font-size: clamp(22px, 2vw, 34px);
          font-weight: 900;
          letter-spacing: 0.05em;
          text-align: center;
        }
        .field-card-head h2 .shiny-text-output {
          font-family: "Crows Ink", "Cooper Black", "Arial Rounded MT Bold", Georgia, "Times New Roman", serif !important;
        }
        .field-icon-bubble { display: none; }

        .field-metric-body {
          padding: 28px 30px 30px;
          text-align: center;
        }
        .field-metric-value {
          display: block;
          color: var(--field-cream);
          font-size: clamp(36px, 3vw, 56px);
          font-weight: 500;
          letter-spacing: -0.045em;
          line-height: 1;
        }
        .field-metric-change {
          margin-top: 18px;
          color: var(--field-cream);
          font-size: clamp(22px, 1.9vw, 34px);
          font-weight: 500;
        }
        .field-metric-change .delta-badge { color: var(--field-cream) !important; }
        .field-metric-change .trend-sparkline { display: none; }

        .field-records-body {
          padding: 24px 28px 28px;
          display: grid;
          gap: 8px;
          text-align: center;
        }
        .field-record-row {
          display: block;
          color: var(--field-cream);
          font-size: clamp(18px, 1.45vw, 27px);
        }
        .field-record-row i { display: none; }

        .field-weather-body {
          display: grid;
          grid-template-columns: 1fr;
        }
        .field-weather-icon-panel { display: none; }
        .field-weather-data {
          display: grid;
          grid-template-columns: minmax(120px, 44%) 1fr;
          align-items: center;
          gap: 14px;
          padding: 26px 22px 24px;
        }
        .field-temp {
          display: block;
          color: var(--field-cream);
          font-size: clamp(42px, 3.4vw, 62px);
          letter-spacing: -0.08em;
          line-height: 0.95;
          font-weight: 500;
        }
        .field-condition {
          display: block;
          margin-top: 8px;
          color: var(--field-cream);
          font-family: "Crows Ink", "Cooper Black", "Arial Rounded MT Bold", Georgia, "Times New Roman", serif !important;
          font-size: 18px;
          font-weight: 900;
        }
        .field-weather-details {
          display: grid;
          gap: 8px;
          color: var(--field-cream);
          font-size: clamp(14px, 1.05vw, 18px);
        }
        .field-weather-details i { display: none; }

        .field-action-row {
          grid-area: actions;
          display: grid;
          grid-template-columns: 1fr 1.25fr 1fr;
          gap: clamp(20px, 3vw, 46px);
          align-items: center;
          overflow: visible;
        }
        .field-action-card {
          position: relative;
          min-height: 112px;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 20px 26px;
          border-radius: 999px;
          color: var(--field-cream);
          border: 4px solid var(--field-border);
          box-shadow: 0 20px 42px rgba(4, 23, 12, 0.3);
          background: rgba(2, 24, 11, 0.36);
          text-decoration: none !important;
          transition: transform 0.32s ease, box-shadow 0.32s ease, background 0.32s ease, color 0.32s ease, border-color 0.32s ease;
        }
        .field-action-card:hover {
          transform: translateY(-3px);
          color: var(--field-cream);
          box-shadow: 0 26px 54px rgba(4, 23, 12, 0.44);
        }
        .field-action-card.is-active {
          color: #0a421f;
          background: linear-gradient(135deg, var(--field-rice-light), #dba52b 60%, #9f6812);
          border-color: rgba(255, 229, 102, 0.9);
          transform: scale(1.08);
          z-index: 3;
        }
        .field-action-icon,
        .field-arrow { display: none; }
        .field-action-title {
          margin: 0;
          color: inherit;
          font-family: "Crows Ink", "Cooper Black", "Arial Rounded MT Bold", Georgia, "Times New Roman", serif !important;
          font-size: clamp(22px, 2.25vw, 38px);
          line-height: 1.02;
          font-weight: 900;
          letter-spacing: 0.05em;
          text-transform: uppercase;
          text-align: center;
        }
        .field-action-card.is-active .field-action-title {
          font-size: clamp(30px, 2.9vw, 48px);
        }
        .field-action-card[data-section="dashboard"].is-active .field-action-title {
          font-size: clamp(42px, 4.6vw, 76px);
        }
        .field-action-card[data-section="prediction"].is-active .field-action-title {
          font-size: clamp(24px, 2.25vw, 36px);
        }
        .field-action-subtitle { display: none; }

        .field-content {
          grid-area: content;
          min-height: 360px;
        }
        .field-section-panel {
          animation: fieldSwap 0.42s ease both;
        }
        @keyframes fieldSwap {
          0% { opacity: 0; transform: translateY(18px) scale(0.985); }
          100% { opacity: 1; transform: translateY(0) scale(1); }
        }

        .field-filter-panel {
          display: grid;
          grid-template-columns: minmax(280px, 1.4fr) repeat(3, minmax(180px, 0.75fr));
          gap: 14px;
          align-items: end;
          padding: 18px;
          border-radius: 26px;
          background: rgba(255, 248, 232, 0.94);
          border: 2px solid rgba(244, 230, 184, 0.76);
          box-shadow: 0 22px 44px rgba(4, 23, 12, 0.25), inset 0 1px 0 rgba(255,255,255,0.42);
          position: relative;
          z-index: 1120;
        }
        .field-filter-panel .shiny-input-container,
        .field-filter-panel .form-group {
          width: 100% !important;
          margin-bottom: 0;
        }
        .field-filter-panel label {
          color: #15331f;
          font-size: 12px;
          text-transform: uppercase;
          letter-spacing: 0.08em;
          font-weight: 800;
        }

        .modern-card,
        .field-chart-card {
          overflow: hidden;
          border-radius: 28px;
          background: rgba(255, 248, 227, 0.97);
          border: 3px solid rgba(244, 230, 184, 0.78);
          box-shadow: 0 20px 42px rgba(4, 23, 12, 0.3), inset 0 1px 0 rgba(255,255,255,0.38);
          margin-bottom: 18px;
        }
        .card-header,
        .field-chart-head {
          display: flex;
          align-items: center;
          gap: 12px;
          min-height: 68px;
          padding: 16px 22px;
          color: var(--field-cream);
          background: linear-gradient(90deg, rgba(8, 61, 29, 0.98), rgba(15, 77, 37, 0.98));
          border-bottom: 1px solid rgba(255,255,255,0.12);
          font-weight: 850;
          font-size: 17px;
          flex-wrap: wrap;
        }
        .field-charts {
          display: grid;
          grid-template-columns: repeat(2, minmax(0, 1fr));
          gap: clamp(18px, 2vw, 28px);
        }
        .field-chart-card.wide { grid-column: 1 / -1; }
        .field-chart-controls {
          margin-left: auto;
          min-width: 220px;
        }
        .field-chart-controls .form-group,
        .field-chart-controls .shiny-input-container {
          margin-bottom: 0;
          width: 100% !important;
        }
        .field-chart-body { padding: 16px; }

        .prediction-hero {
          display: flex;
          align-items: center;
          gap: 18px;
          padding: 18px;
          background: linear-gradient(90deg, #f0fdfa, #f8fafc);
          border-radius: 8px;
        }

        .irs--shiny .irs-line {
          top: 24px;
          height: 10px;
          background: #e2dba5;
          border: 0;
          border-radius: 999px;
        }
        .irs--shiny .irs-bar {
          top: 24px;
          height: 10px;
          background: linear-gradient(90deg, #b9c85d, #406d4f);
          border: 0;
        }
        .irs--shiny .irs-handle {
          top: 18px;
          width: 22px;
          height: 22px;
          border: 2.4px solid #fffdf4;
          background: #406d4f;
          border-radius: 50%;
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
        }
        .irs--shiny .irs-grid-text { color: #66785b; font-size: 10px; }
        .irs--shiny .irs-grid-pol { background: rgba(102, 120, 91, 0.38); }
        .irs--shiny .irs-min,
        .irs--shiny .irs-max {
          color: #66785b;
          background: #ecf1df;
        }

        .js-plotly-plot .xtick text,
        .js-plotly-plot .ytick text,
        .js-plotly-plot .gtitle,
        .js-plotly-plot .legend text,
        .js-plotly-plot .annotation text,
        .js-plotly-plot .infolayer text,
        .js-plotly-plot .colorbar text,
        .js-plotly-plot .xtitle,
        .js-plotly-plot .ytitle,
        .js-plotly-plot .polar text {
          fill: #2b4027 !important;
          color: #2b4027 !important;
        }

        @media (max-width: 1220px) {
          .field-shell {
            grid-template-columns: 1fr;
            grid-template-areas:
              "badge"
              "hero"
              "left"
              "right"
              "actions"
              "content";
          }
          .field-left,
          .field-right {
            grid-template-columns: repeat(2, minmax(260px, 1fr));
          }
          .field-action-row {
            grid-template-columns: 1fr;
          }
        }
        @media (max-width: 850px) {
          .field-screen { padding: 14px; }
          .field-filter-panel,
          .field-left,
          .field-right,
          .field-charts,
          .field-dash-metrics {
            grid-template-columns: 1fr;
          }
          .field-dash-weather {
            grid-template-columns: 1fr;
          }
          .field-chart-card.wide { grid-column: auto; }
          .field-weather-data { grid-template-columns: 1fr; }
        }
        @media (max-width: 1220px) and (min-width: 851px) {
          .field-dash-metrics {
            grid-template-columns: repeat(2, 1fr);
          }
        }
      ')),
      tags$script(HTML("
        (function(){
          window.setFieldSection = function(sectionName, shouldScroll){
            sectionName = sectionName || 'dashboard';
            var shell = document.querySelector('.field-shell');
            if(shell){
              shell.classList.remove('field-section-dashboard', 'field-section-prediction', 'field-section-about');
              shell.classList.add('field-section-' + sectionName);
            }
            document.querySelectorAll('.field-action-card[data-section]').forEach(function(card){
              card.classList.toggle('is-active', card.dataset.section === sectionName);
            });
            if(window.Shiny){
              Shiny.setInputValue('field_section', sectionName, {priority: 'event'});
            }
            if(shouldScroll === true){
              var target = document.getElementById('field_content');
              if(target){ target.scrollIntoView({behavior: 'smooth', block: 'start'}); }
            }
          };

          function initFieldSection(){
            window.setFieldSection('dashboard', false);
          }

          if(document.readyState === 'loading'){
            document.addEventListener('DOMContentLoaded', initFieldSection);
          } else {
            initFieldSection();
          }
          document.addEventListener('shiny:connected', initFieldSection);
        })();
      "))
    ),

    div(class = "field-screen",
      tags$section(class = "field-shell",
        div(class = "field-badge",
          icon("seedling"),
          span("South India Crop Field Explorer")
        ),

        tags$aside(class = "field-left",
          tags$article(class = "field-card",
            div(class = "field-icon-bubble", icon("wheat-awn")),
            tags$header(class = "field-card-head",
              h2("Global Recorded Yield")
            ),
            div(class = "field-metric-body",
              span(class = "field-metric-value", "73.45M"),
              div(class = "field-card-desc", "Cumulative production recorded in South India districts.")
            )
          ),
          tags$article(class = "field-card",
            div(class = "field-icon-bubble", icon("map")),
            tags$header(class = "field-card-head",
              h2("Total Farmland")
            ),
            div(class = "field-metric-body",
              span(class = "field-metric-value", "29.46M ha"),
              div(class = "field-card-desc", "Total historical cultivated area monitored in this explorer.")
            )
          )
        ),

        tags$section(class = "field-hero",
          div(class = "field-hero-copy",
            h1(HTML('<span style="font-size: 1.3em; font-family: inherit !important;">C</span>rop <span style="font-size: 1.3em; font-family: inherit !important;">Y</span>ield <span style="font-size: 1.3em; font-family: inherit !important;">P</span>atterns'), span(class = "field-year", "2004-2019")),
            div(class = "field-divider", icon("seedling")),
            p("Compare recorded yield, cultivated area, season, crop, and weather-related factors across selected South India locations.")
          ),
          div(class = "field-landscape")
        ),

        tags$aside(class = "field-right",
          tags$article(class = "field-card",
            div(class = "field-icon-bubble", icon("file-lines")),
            tags$header(class = "field-card-head",
              h2("Verified Records")
            ),
            div(class = "field-metric-body",
              span(class = "field-metric-value", "3,158"),
              div(class = "field-card-desc", "Fully validated, high-fidelity seasonal crop data observations.")
            )
          ),
          tags$article(class = "field-card",
            div(class = "field-icon-bubble", icon("location-dot")),
            tags$header(class = "field-card-head",
              h2("Coverage Area")
            ),
            div(class = "field-metric-body",
              span(class = "field-metric-value", "11 Districts"),
              div(class = "field-card-desc", "Tracking primary agricultural centers across South India zones.")
            )
          )
        ),

        tags$nav(class = "field-action-row",
          tags$a(href = "#", class = "field-action-card",
            `data-section` = "prediction",
            onclick = "window.setFieldSection('prediction'); return false;",
            div(class = "field-action-icon", icon("leaf")),
            div(
              p(class = "field-action-title", "Crop", br(), "Recommendation"),
              p(class = "field-action-subtitle", "Model-backed suggestions based on soil nutrients and climate inputs.")
            ),
            span(class = "field-arrow", icon("arrow-right"))
          ),
          tags$a(href = "#", class = "field-action-card is-active",
            `data-section` = "dashboard",
            onclick = "window.setFieldSection('dashboard'); return false;",
            div(class = "field-action-icon", icon("chart-column")),
            div(
              p(class = "field-action-title", "Dashboard"),
              p(class = "field-action-subtitle", "Explore yield concentration, crop mix, yearly trends, and factor relationships.")
            ),
            span(class = "field-arrow", icon("arrow-right"))
          ),
          tags$a(href = "#", class = "field-action-card",
            `data-section` = "about",
            onclick = "window.setFieldSection('about'); return false;",
            div(class = "field-action-icon", icon("book-open")),
            div(
              p(class = "field-action-title", "Project", br(), "Notes"),
              p(class = "field-action-subtitle", "Review the problem statement, data sources, data quality notes, and project team.")
            ),
            span(class = "field-arrow", icon("arrow-right"))
          )
        ),

        div(id = "field_content", class = "field-content",
          conditionalPanel(
            condition = "!input.field_section || input.field_section == 'dashboard'",
            div(class = "field-section-panel",
              div(class = "field-filter-panel",
                div(class = "field-filter-year", sliderInput("year_filter", "Year", min = 2000, max = 2020, value = 2015, step = 1, sep = "")),
                div(selectInput("loc_filter", "Location", choices = "All")),
                div(selectInput("crop_filter", "Crop", choices = "All")),
                div(selectInput("season_filter", "Season", choices = "All"))
              ),
              div(class = "field-dash-metrics",
                div(class = "field-dash-card",
                  p(class = "field-dash-card-title", "Total Yield"),
                  div(style = "display: flex; align-items: baseline; gap: 8px; justify-content: center; flex-wrap: wrap;",
                    span(class = "field-dash-card-value", textOutput("sum_yields", inline = TRUE)),
                    uiOutput("yoy_badge")
                  )
                ),
                div(class = "field-dash-card",
                  p(class = "field-dash-card-title", "Total Area"),
                  div(style = "display: flex; align-items: baseline; justify-content: center;",
                    span(class = "field-dash-card-value", textOutput("sum_area", inline = TRUE))
                  )
                ),
                div(class = "field-dash-card",
                  p(class = "field-dash-card-title", "Filtered Stats"),
                  div(class = "field-dash-stats-grid",
                    div(
                      span(class = "field-dash-stat-val", textOutput("record_count", inline = TRUE)),
                      span(class = "field-dash-stat-lbl", "Records")
                    ),
                    div(
                      span(class = "field-dash-stat-val", textOutput("crop_count", inline = TRUE)),
                      span(class = "field-dash-stat-lbl", "Crops")
                    ),
                    div(
                      span(class = "field-dash-stat-val", textOutput("avg_yield", inline = TRUE)),
                      span(class = "field-dash-stat-lbl", "Avg Yield")
                    )
                  )
                ),
                div(class = "field-dash-card",
                  p(class = "field-dash-card-title", textOutput("weather_location", inline = TRUE)),
                  div(class = "field-dash-weather",
                    div(class = "field-dash-weather-main", textOutput("weather_temp", inline = TRUE)),
                    div(class = "field-dash-weather-meta",
                      div(textOutput("weather_desc", inline = TRUE)),
                      div(textOutput("weather_wind", inline = TRUE)),
                      div(textOutput("weather_humidity", inline = TRUE))
                    )
                  )
                )
              ),
              tags$section(id = "field_charts", class = "field-charts", style = "margin-top: clamp(18px, 2vw, 28px);",
                div(class = "field-chart-card",
                  div(class = "field-chart-head",
                    icon("map"),
                    span("Where Yield Is Concentrated"),
                    div(class = "field-chart-controls",
                      selectInput("combined_chart_select", NULL, choices = c("Yield by Location", "Yield by Season"), selected = "Yield by Location", width = "100%")
                    )
                  ),
                  div(class = "field-chart-body", plotlyOutput("combined_chart", height = "360px"))
                ),
                div(class = "field-chart-card",
                  div(class = "field-chart-head",
                    icon("bolt"),
                    span("Crop Mix and Growing Conditions"),
                    div(class = "field-chart-controls",
                      selectInput("efficiency_var_select", NULL, choices = c("Crop Share", "Yield by Soil Type", "Yield vs Temperature"), selected = "Crop Share", width = "100%")
                    )
                  ),
                  div(class = "field-chart-body", plotlyOutput("efficiency_scatter", height = "360px"))
                ),
                div(class = "field-chart-card wide",
                  div(class = "field-chart-head",
                    icon("chart-line"),
                    span("Average Yield Trend by Year")
                  ),
                  div(class = "field-chart-body", plotlyOutput("trend_plot", height = "380px"))
                ),
                div(class = "field-chart-card wide",
                  div(class = "field-chart-head",
                    icon("project-diagram"),
                    span("Correlation Between Crop Factors")
                  ),
                  div(class = "field-chart-body", plotlyOutput("stat_corr", height = "360px"))
                )
              )
            )
          ),

          conditionalPanel(
            condition = "input.field_section == 'prediction'",
            div(class = "field-section-panel",
              fluidRow(
                column(4,
                  div(class = "modern-card",
                    div(class = "card-header", icon("flask"), "Soil Nutrients & pH"),
                    div(style = "padding:12px;",
                      sliderInput("input_n", "Nitrogen (N)", min = 0, max = 150, value = 80, step = 1, width = "100%"),
                      tags$div(style = "display:flex; gap:10px; margin-top:6px;",
                        tags$span(style = "flex:1", sliderInput("input_p", "Phosphorus (P)", min = 0, max = 150, value = 40, step = 1, width = "100%")),
                        tags$span(style = "flex:1", sliderInput("input_k", "Potassium (K)", min = 0, max = 150, value = 40, step = 1, width = "100%"))
                      ),
                      sliderInput("input_ph", "Soil pH", min = 0, max = 14, value = 6.5, step = 0.01, width = "100%")
                    )
                  ),
                  div(class = "modern-card",
                    div(class = "card-header", icon("thermometer-half"), "Climate Conditions & Weather"),
                    div(style = "padding:12px;",
                      sliderInput("input_temp", "Temperature (°C)", min = -10, max = 50, value = 25, step = 0.1, width = "100%"),
                      sliderInput("input_hum", "Humidity (%)", min = 0, max = 100, value = 80, step = 0.1, width = "100%"),
                      sliderInput("input_rain", "Rainfall (mm)", min = 0, max = 500, value = 200, step = 0.1, width = "100%")
                    )
                  )
                ),
                column(8,
                  div(class = "modern-card",
                    tags$div(class = "prediction-hero",
                      div(style = "width:120px; height:120px; background:linear-gradient(135deg, #10b981, #059669); border-radius:12px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:56px;", textOutput("pred_crop_image")),
                      div(style = "flex:1;",
                        div(style = "font-size:12px; color:var(--cs-text-sub); font-weight:600; text-transform:uppercase;", "Primary Recommendation"),
                        div(style = "font-size:40px; font-weight:800; margin-top:6px;", textOutput("pred_crop")),
                        div(style = "display:flex; gap:10px; align-items:center; flex-wrap:wrap;",
                          div(style = "background:#0f172a; color:#fff; padding:8px 12px; border-radius:8px; font-weight:700;", "Confidence: ", textOutput("pred_confidence", inline = TRUE)),
                          div(style = "background:#eef2ff; padding:8px 12px; border-radius:8px; color:#0f172a;", textOutput("pred_info_rain", inline = TRUE)),
                          div(style = "background:#fff7ed; padding:8px 12px; border-radius:8px; color:#b45309;", textOutput("pred_info_temp", inline = TRUE))
                        )
                      )
                    )
                  ),
                  div(class = "modern-card",
                    div(class = "card-header", icon("list"), "Top Alternatives"),
                    div(style = "padding:12px;", plotlyOutput("pred_alternatives", height = "280px"))
                  ),
                  div(class = "modern-card",
                    div(class = "card-header", icon("chart-area"), "Input Profile Compared With a Reference Pattern"),
                    div(style = "padding:12px;",
                      plotlyOutput("pred_radar", height = "300px"),
                      div(style = "font-size:12px; line-height:1.5; color:var(--cs-text-sub); margin-top:8px;",
                        textOutput("pred_insights")
                      )
                    )
                  )
                )
              )
            )
          ),

          conditionalPanel(
            condition = "input.field_section == 'about'",
            div(class = "field-section-panel",
              div(style = "margin-bottom: 28px; text-align: center;",
                h1("About the Project", style = "font-size: clamp(34px, 4vw, 56px); font-weight: 900; margin: 0 0 12px 0; color: #fff8e8;"),
                p("A Data Analytics with R dashboard for crop-yield exploration and crop suitability prediction.", style = "font-size: 16px; color: #f8edcf; margin: 0;")
              ),
              fluidRow(
                column(12,
                  div(class = "modern-card",
                    div(class = "card-header", icon("info-circle"), "Problem Statement"),
                    div(style = "padding: 20px;",
                      p("This project asks a practical question: how do crop yield, location, season, cultivated area, rainfall, humidity, and soil conditions relate to one another, and how can those patterns support basic crop-planning decisions?",
                        style = "font-size: 15px; line-height: 1.6; color: var(--cs-text-main); margin-bottom: 12px;"),
                      p("The dashboard has two parts. The first part explores crop-yield records from 2004 to 2019 using filters and interactive charts. The second part uses a Random Forest model to recommend a crop from soil nutrients, pH, rainfall, temperature, and humidity inputs.",
                        style = "font-size: 15px; line-height: 1.6; color: var(--cs-text-main);")
                    )
                  )
                )
              ),
              fluidRow(
                column(12,
                  div(class = "modern-card",
                    div(class = "card-header", icon("database"), "Data Sources and Notes"),
                    div(style = "padding: 20px;",
                      fluidRow(
                        column(4,
                          div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #10b981;",
                            h4("Seasonal Yield File", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                            p("The dashboard uses data_season.csv for year, location, crop, season, area, yield, rainfall, humidity, irrigation, and soil type.", style = "margin: 0 0 8px 0; font-size: 14px; color: var(--cs-text-sub);"),
                            tags$a("View CSV in project repository", href = "https://github.com/ixlvyadz/FINAL_DATAANALYTICS/blob/main/data_season.csv", target = "_blank", rel = "noopener noreferrer", style = "font-size:13px; font-weight:600; color:#2563eb;")
                          )
                        ),
                        column(4,
                          div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #06b6d4;",
                            h4("Crop Recommendation Dataset", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                            p("The prediction section uses the published Kaggle crop recommendation dataset with N, P, K, temperature, humidity, pH, rainfall, and crop label fields.", style = "margin: 0 0 8px 0; font-size: 14px; color: var(--cs-text-sub);"),
                            tags$a("Open Kaggle dataset", href = "https://www.kaggle.com/datasets/atharvaingle/crop-recommendation-dataset", target = "_blank", rel = "noopener noreferrer", style = "font-size:13px; font-weight:600; color:#2563eb;")
                          )
                        ),
                        column(4,
                          div(style = "padding: 12px; background: var(--cs-bg); border-radius: 8px; border-left: 4px solid #f59e0b;",
                            h4("Weather Data", style = "margin: 0 0 8px 0; color: var(--cs-text-main);"),
                            p("The weather card calls Open-Meteo for current temperature, humidity, wind speed, and weather condition based on the selected location.", style = "margin: 0 0 8px 0; font-size: 14px; color: var(--cs-text-sub);"),
                            tags$a("Open-Meteo documentation", href = "https://open-meteo.com/", target = "_blank", rel = "noopener noreferrer", style = "font-size:13px; font-weight:600; color:#2563eb;")
                          )
                        )
                      ),
                      div(style = "margin-top: 14px; padding: 12px; border-radius: 8px; background: rgba(245, 158, 11, 0.12); color: var(--cs-text-main); font-size: 13px; line-height: 1.5;",
                        strong("Data quality note: "),
                        "Some temperature entries in the seasonal file are outside realistic agricultural ranges. Values below -10°C or above 60°C are excluded from temperature-based charts and correlation analysis so they do not distort the interpretation."
                      )
                    )
                  )
                )
              ),
              fluidRow(
                column(6,
                  div(class = "modern-card",
                    div(style = "padding: 24px; display: flex; flex-direction: column; align-items: center; text-align: center;",
                      div(style = "width: 100px; height: 100px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 30px; font-weight:800; margin-bottom: 16px;", "EM"),
                      h4("Elvie May Mara", style = "margin: 0 0 8px 0; font-size: 20px; font-weight: 700; color: var(--cs-text-main);"),
                      p("Dashboard Development and Data Visualization", style = "margin: 0 0 8px 0; color: var(--cs-text-sub); font-size: 14px;"),
                      p("Built the Shiny interface, filters, visual summaries, and project explanation for the final dashboard.", style = "margin: 0; color: var(--cs-text-sub); font-size: 13px; line-height: 1.5;")
                    )
                  )
                ),
                column(6,
                  div(class = "modern-card",
                    div(style = "padding: 24px; display: flex; flex-direction: column; align-items: center; text-align: center;",
                      div(style = "width: 100px; height: 100px; background: linear-gradient(135deg, #06b6d4, #0891b2); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 30px; font-weight:800; margin-bottom: 16px;", "BS"),
                      h4("Baberose Silmaro", style = "margin: 0 0 8px 0; font-size: 20px; font-weight: 700; color: var(--cs-text-main);"),
                      p("Model Training and Data Preparation", style = "margin: 0 0 8px 0; color: var(--cs-text-sub); font-size: 14px;"),
                      p("Prepared the crop recommendation workflow and Random Forest model used in the prediction section.", style = "margin: 0; color: var(--cs-text-sub); font-size: 13px; line-height: 1.5;")
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)
