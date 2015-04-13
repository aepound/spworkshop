source("load.r")

list.of.packages <- c(
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
                      "MASS",
                      "doParallel"
                      )

check_n_install_packages( list.of.packages )

#===================================================
#  Try to use a parallel backend to the foreach loop.
#---------------------------------------------------
tt = try(registerDoParallel(cores=2))
#if (class(tt) == "try-error"){
#    cl = makeCluster(2)
#    tt = try(registerDoParallel(cl)
# }
#else {
#     print("I guess we'll be doing everything sequentially.")
# }

#tt = try(registerDoMC(2))
#if (class(tt) == "try-error"){
#    print("I guess we'll be doing everything sequentially.")
#}

#====================================================
fitControl = trainControl(method = "cv", number = 3)

#====================================================
# Source the tuning methods...
source('tuneMethods.r')


N = 1  ## Number of times to change up the random sample:

ErrTotal = NULL
TuneTotal = NULL
errCnt = 0;

for (miter in 1:N){


#====================================================
#  Running all the methods.
tt = try(source("allmethods.r"))

if (class(tt) == "try-error"){
  Errs = NULL
  tunes = NULL
  errCnt = errCnt+1;
}

ErrTotal = rbind(ErrTotal,Errs)
TuneTotal = rbind(TuneTotal,tunes)


ErrTotal = rbind(ErrTotal,Errs)
TuneTotal = rbind(TuneTotal,tunes)

save.image(file="fullResults.Rdata")

}























if(0){

#====================================================
# RF
#====================================================
# Package: randomForest
# Tuning parameter: mtry
# Mtry ranges from 1:number of variables
rf.grid = expand.grid(.mtry = 1:sqrt(ncol(train.x)));
print('Starting 10 factor cross-validation')
rf.xvaltime = proc.time();
# Do we really need to scale?  I understand that it's a normal thing done when using randomforest, but is it necessary?
rf.caretraw = train( train.x,
                     train.y,"rf",
                     preProc = c("scale"),
                     tuneGrid=rf.grid,
                     trControl=fitControl)
rf.xvaltime = proc.time() - rf.xvaltime;
print('Finished cross-validation')
print('Training RandomForest')
rf.traintime = proc.time();
rf.rawforest = randomForest( scale(train.x), train.y, mtry=as.matrix(rf.caretraw$bestTune))
rf.traintime = proc.time() - rf.traintime;
trainFitControl = trainControl(method='none',classProbs=FALSE);
t1 = proc.time();
rf.rawtrain = train( train.x,
                     train.y,"rf",
                     preProc = c("scale"),
                     tuneGrid=rf.caretraw$bestTune,
                     trControl=trainFitControl)
t1 = proc.time() - t1;
print('Testing RandomForest')
rf.testtime = proc.time();
rf.pred = predict(rf.rawtrain, newdata=scale(test.x))
rf.testtime = proc.time() - rf.testtime;
print('Done with testing')
rf.errors = rf.pred != test.y;
error.rf = sum(errors)/length(rf.errors);
print('Done calculating error')
print(rf.caretraw$bestTune)
print(error.rf)


#====================================================
# Naive Bayes
#====================================================
# Package: klaR
# Tuning parameter: fL, useKernel
# fL
# useKernel
#nb.grid = expand.grid();
#print('Starting 10 factor cross-validation')
#nb.xvaltime = proc.time();
# Do we really need to scale?  I understand that it's a normal thing done when using randomforest, but is it necessary?
#nb.caretraw = train( train.x,
#                     train.y,"rf",
#                     preProc = c("scale"),
#                     tuneGrid=nb.grid,
#                     trControl=fitControl)
#nb.xvaltime = proc.time() - nb.xvaltime;
#print('Finished cross-validation')
#print('Training RandomForest')
#nb.traintime = proc.time();
#nb.rawforest = randomForest( scale(train.x), train.y, mtry=as.matrix(nb.caretraw$bestTune))
#nb.traintime = proc.time() - nb.traintime;
#print('Testing RandomForest')
#nb.testtime = proc.time();
#nb.pred = predict(nb.rawforest, newdata=scale(test.x))
#nb.testtime = proc.time() - nb.testtime;
#print('Done with testing')
#nb.errors = nb.pred != test.y;
#error.nb = sum(errors)/length(nb.errors);
#print('Done calculating error')
#print(nb.caretraw$bestTune)
#print(error.nb)

} # IF (0)
