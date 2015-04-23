
# Clear out the workspace:
#rm( list = ls() )

# List out the needed packages:
list.of.packages <- c("R.matlab",
                      "randomForest",
                      "rpart",
                      "e1071",
                      "RWeka",
                      "kernlab",
                      "klaR",
                      "nnet",
                      "gbm",
                      "plyr",
                      "pls",
                      "caret",
                      "matlab",
                      "MASS")

# A function to install any packages not found.
source('check_n_install_packages.r')

#  Then try/install packages:
check_n_install_packages( list.of.packages )

# registerDoMC(2)
set.seed(123456)

train = read.table("../matout/train",header = FALSE)
test  = read.table("../matout/test" ,header = FALSE)

train.x <- train[,-length(train)]            # Training data
train.y <- as.factor(train[, length(train)]) # Training classes

test.x  <- test[,-length(test)]              # Testing data
test.y  <- as.factor(test[, length(test)])   # Testing classes


# Let's cut it down while we are testing out the code...
inTraining <- createFolds(train.y, k=9, list=TRUE,returnTrain=TRUE)
if (testing){
  train.x <- train.x[-inTraining$Fold1,]
  train.y <- train.y[-inTraining$Fold1]
}
  
#====================================================
train.all = data.frame(y=train.y,x=scale(train.x))
test.all  = data.frame(y=test.y, x=scale(test.x ))
