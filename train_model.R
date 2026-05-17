# train_model.R
options(repos = c(CRAN = "https://cloud.r-project.org"))
if(!require(randomForest)) install.packages("randomForest", repos=options()$repos)
library(randomForest)

set.seed(123)
cat('Loading data...\n')
df <- read.csv('Crop_recommendation.csv', stringsAsFactors = FALSE)

expected <- c('N','P','K','temperature','humidity','ph','rainfall','label')
if(!all(expected %in% names(df))) stop('Missing expected columns: ', paste(setdiff(expected, names(df)), collapse=', '))
df <- df[, expected]
df <- na.omit(df)
df$label <- as.factor(df$label)

idx <- sample(seq_len(nrow(df)), size = floor(0.8 * nrow(df)))
train <- df[idx,]
test  <- df[-idx,]

cat('Training Random Forest...\n')
model <- randomForest(label ~ ., data = train, ntree = 200)

cat('Predicting on test set...\n')
pred <- predict(model, newdata = test)
acc  <- mean(pred == test$label)
cat(sprintf('Test accuracy: %.4f\n', acc))
print(table(pred, test$label))

saveRDS(model, 'model_rf.RDS')
cat('Saved model_rf.RDS\n')

invisible(NULL)
