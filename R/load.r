
# Clear out the workspace:
rm( list = ls() )
# A function to install any packages not found.
check_n_install_packages <- function(x){
  for( i in x ){
    #  require returns TRUE invisibly if it was able to load package
    if( ! require( i , character.only = TRUE ) ){
      #  If package was not able to be loaded then re-install
      install.packages( i , dependencies = TRUE )
      #  Load package after installing
      require( i , character.only = TRUE )
    }
  }
}

# List out the needd packages:
list.of.packages <- c("R.matlab","randomForest",
                      "rpart", "e1071",
                      "RWeka","kernlab",
                      "nnet","gbm",
                      "pls","caret",
                      "matlab"
                      )
# , "doMC"


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
train.x <- train.x[-inTraining$Fold1,]
train.y <- train.y[-inTraining$Fold1]
