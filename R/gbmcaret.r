source('carettest.r')

#====================================================
# gbm
#====================================================
# Package: gbm
# Tuning parameters: interaction.depth, n.trees, shrinkage
# This will be a bit more involved, because it has 3 tuning
# parameters.
fitControl = trainControl(method = "cv", number = 3)
grid = expand.grid(.interaction.depth = 1:5, .n.trees = c(10, 50, 100, 200, 500,1000, 2000, 5000), .shrinkage = c(.01, .1, .5))
gbm <- carettest(train.x, train.y, test.x, test.y, "gbm", grid, fitControl,distribution='gaussian',verbose=FALSE)


