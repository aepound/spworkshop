source("load.r")

list.of.packages <- c(
                      "randomForest",
                      "rpart",
                      "e1071",
                      "RWeka",
                      "kernlab",
                      "nnet",
                      "gbm",
                      "pls",
                      "caret",
                      "matlab"
                      )

check_n_install_packages( list.of.packages )

#====================================================
fitControl = trainControl(method = "cv", number = 10)

#====================================================
# RF
#====================================================
# Package: randomForest
# Tuning parameter: mtry
# Mtry ranges from 1:number of variables
rfGrid = expand.grid(.mtry = 1:sqrt(length(train)));
rfFit = train( train.x, train.y,"rf", tuneGrid=rfGrid, trControl=fitControl)
fitRF = randomForest( train.x, as.factor(train.y), mtry=as.matrix(rfFit$bestTune))
pred.rf = predict(fitRF, newdata=test.x)
mse.rf= mean( (pred.rf - test.y)^2 )
rfFit$bestTune
mse.rf


