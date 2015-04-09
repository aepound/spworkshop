source('carettest.r')

#====================================================
# nb
#====================================================
# Package: klaR
# Tuning parameters: fL, useKernel
# fL
# useKernel
fitControl = trainControl(method = "cv", number = 3)
grid = expand.grid(.fL = c(0, .01, .1, .5), .usekernel=FALSE)
gbm <- carettest(train.x, train.y, test.x, test.y, "nb", grid, fitControl)
