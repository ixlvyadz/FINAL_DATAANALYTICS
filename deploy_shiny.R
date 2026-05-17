options(repos = c(CRAN = 'https://cran.r-project.org'))
if (!requireNamespace('rsconnect', quietly = TRUE)) install.packages('rsconnect')
# Ensure account is set in RStudio previously; deploy
rsconnect::deployApp('d:/DATAANALYTICS2')
