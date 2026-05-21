options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("rsconnect", quietly = TRUE)) {
  install.packages("rsconnect")
}

if (nrow(rsconnect::accounts()) == 0) {
  stop(
    "No rsconnect account is configured. Run rsconnect::setAccountInfo() ",
    "with the shinyapps.io token and secret, then rerun this script.",
    call. = FALSE
  )
}

rsconnect::deployApp(appDir = getwd(), appName = "dataanalytics2")
