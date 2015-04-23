if (!exists('matout.dir')){
    matout.dir <- './matout'
}

dltrainfiles = dir(path=matout.dir,pattern=glob2rx("traindl*"))
dltestfiles = dir(path=matout.dir,pattern=glob2rx("testdl*"))

train = read.table(paste(matout.dir,'/',dltrainfiles[1],sep=''),header = FALSE)
test  = read.table(paste(matout.dir,'/',dltestfiles[1] ,sep=''),header = FALSE)

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
