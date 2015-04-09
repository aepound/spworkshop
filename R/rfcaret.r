source('carettest.r')

#====================================================
# RF
#====================================================
# Package: randomForest
# Tuning parameter: mtry
# Mtry ranges from 1:number of variables
fitControl = trainControl(method = "cv", number = 3)
grid = expand.grid(.mtry = 1:sqrt(ncol(train.x)));
rf <- carettest(train.x, train.y, test.x, test.y, "rf", grid, fitControl)

