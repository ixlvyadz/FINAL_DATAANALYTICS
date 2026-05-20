tryCatch({
  parse(file = "ui.r")
  cat("OK\n")
}, error = function(e) {
  cat("ERR: ", conditionMessage(e), "\n")
})
