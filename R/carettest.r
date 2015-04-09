carettest <- function(train.x, train.y, test.x, test.y, model, grid, fitControl,...){
print('=========================================')
print(paste('          ', model,'      '))
print('=========================================')
print(paste('Starting',
            as.character(fitControl$number),
            'factor cross-validation'))
xvaltime = proc.time();
caretraw = train( train.x,
                  train.y, model,
                  preProc = c("scale"),
                  tuneGrid=grid,
                  trControl=fitControl,...)
xvaltime = proc.time() - xvaltime;
print('Finished cross-validation')
print(paste('Training',model))
trainFitControl = fitControl;
trainFitControl["method"] <- 'none'; # Keeps everything else the same...
traintime= proc.time();
rawtrain= train( train.x,
                 train.y,model,
                 preProc = c("scale"),
                 tuneGrid=caretraw$bestTune,
                 trControl=trainFitControl,...)
traintime= proc.time() - traintime;
print(paste('Testing',model))
testtime = proc.time();
pred = predict(rawtrain, newdata=scale(test.x))
testtime = proc.time() - testtime;
print('Done with testing')
errors = pred != test.y;
error = sum(errors)/length(errors);
print('Done calculating error')
print(caretraw$bestTune)
print(error)
print('-----------------------------------------')
return(list(caretraw=caretraw,
            classifier=rawtrain,
            predictions=pred,
            predError=errors,
            error=error,
            xvaltime=as.list(xvaltime)$elapsed,
            traintime=as.list(traintime)$elapsed,
            testtime=as.list(testtime)$elapsed))
}

    
