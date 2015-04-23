tuneMethods = function(method,abbrev,search.params,tune.params,train.data,test.data,meth.args = list(),model.formula = NULL, caret.formula=NULL){
  ## method        : The function name of the method to be tested
  ## abbrev        : The name caret knows the method by, or NULL if not known by Caret.
  ## search.params : This is the search space for the tuning parameters. (from expand.grid)
  ## tune.params   : This is the list of parameters for caret (from trainControl)
  ## train.data$x<>: This is the training data (predictors)
  ## train.data$y  : This is the training responses.
  ## test.data$x<> : This is the test set to calculate the predicted values.
  ## test.data$y   : This is the test set response.
  ## meth.args     : A list of model parameters w/ NULLs for the tuning parameters.
  ## model.formula : A formula class object for the model fitting interface
  ## caret.formula : A formula class object for the caret tuning interface
  
  classLevels <- levels(train.data$y)
  if(!is.null(abbrev) && length(classLevels) > 2
     && (abbrev %in% c("gbm", "glmboost", "ada", "gamboost",
                       "blackboost", "penalized", "glm",
                       "earth", "nodeHarvest", "glmrob", "plr",
                       "GAMens", "rocc", "logforest", "logreg",
                       "gam", "gamLoess", "gamSpline", "bstTree",
                       "bstLs", "bstSm"))){
    
    stop(paste("Model: ",method,": is only implemented for two class problems, so far."))
    ## I actually don't remember if this statement is accurate or not...
    ## But I just don't want to deal with it right now....
    ## I can come back to fix it up later...
    
    
    ## Implement the ECOC or the 1 vs All thing for the algorithms that
    ## don't natively handle multiclass problems.
    ## ECOCcaret = function(method, abbrev, search.params,
    ##                      tune.params, train.data,
    ##                      meth.args, caret.formula)
#    print(paste("=====","   Tuning: ",method))
#    this.model = ECOCcaret(method, abbrev, search.params,
#                           tune.params, train.data, test.data,
#                           meth.args, model.formula, caret.formula)
#    print(paste("=====","   Predicting..."))
#    out.test = predict(this.model, newdata = test.data[,-1])
#
#    err = mean(out.test != test.y)  ## Misclassification error.
#    print(paste("=====","   Error = ",formatC(err,digits=4,width=6,format="f",flag=0)))
#
    ## save: error, model, predictions on the test set.
#    output = list(err=err,model=this.model,pred=out.test) 
#    
  }else{
    ## Then we have either native multiclass support through caret,
    ## or a binary classification problem...
     

    print(paste("=====","   Tuning: ",method))
    if ( !is.null(abbrev) ){ 
      ## Make sure that the caret library is loaded...
      require(caret)
      ## train.data[-1,] is the training data, already pre-processed.
      ## train.data$y    is the response (It should already be a factor vector if classifying).

      ## send2caret = function(method, abbrev, search.params,
      ##                       tune.params, train.data,
      ##                       meth.args, caret.formula)
      tuned.params = send2caret(method, abbrev, search.params,
                                tune.params, train.data,
                                meth.args, caret.formula) 
    } else {
      ## Then => (abbrev == NULL) => We can't use Caret to tune this...
      
      ##  TODO: **** figure out what I need to do here to do my own parameter search...
      ##
      ##  ...  I want to use this for some algorithms that caret doesn't tune:
      ##  ...  > kernlab ksvm with a custom kernel
      ##  ...  > kernlab ksvm with a different type: spoc-svc, and kbb-svc
      ##  ***** TODO

      ## myTuningAlg = function(method, abbrev, search.params,
      ##                        tune.params, train.data,
      ##                        meth.args, caret.method)
      junk = capture.output(
      tuned.params <- myTuningAlg(method, abbrev, search.params,
                                 tune.params, train.data,
                                 meth.args, caret.formula)
      )
    }
    
    ##----------------------------------------------
    ##   Build the model with all the data:
    ##----------------------------------------------
    ## buildCall = function(meth.args, search.params, tuned.params, train.data, model.formula)

    meth.args = buildCall(meth.args, search.params, tuned.params, train.data, model.formula);
##  browser()    

    ## Evaluate the call:    
    print(paste("=====","   Training..."))
    #browser()
    junk = capture.output( this.model <- do.call(method,meth.args) )

    ##--------------------------------------------
    ## Check the prediction error:
    ##--------------------------------------------
    ## A couple of fixes for a few different methods:
    print(paste("=====","   Predicting..."))
    ##  TODO: **** This should be wrapped into a tryCatch statement: *****
#    browser()
    if (!is.null(abbrev) && abbrev %in% c("rpart","knn","nnet")){
      out.test = predict(this.model, newdata=test.data[,-1],type="class")
    }else{
      out.test = predict(this.model, newdata=test.data[,-1])
    }
    if (!is.null(abbrev) && abbrev %in% c("nb","lda","nb") ||
        !is.null(method) && method %in% c("NaiveBayes")   ){
      out.test = out.test$class
    }
    if (!is.null(abbrev) && abbrev %in% c("nnet")){
      out.test = factor(as.character(out.test),levels=levels(test.data$y)) 
    }
    
    ## Return the error back out:
    err = mean(out.test != test.data$y)  ## Misclassification error.
    print(paste("=====","   Error = ",formatC(err,digits=4,width=6,format="f",flag=0)))
    ## save: error, model, predictions on the test set, and tuned params.
    output = list(err=err,model=this.model,pred=out.test,tuned = tuned.params); 
    
  } ## End of: IF multiclass and trying to use a binary classifier...

  return(output)
} ## End of function: tuneMethods()


##==================================================
##  Send to Caret
##--------------------------------------------------
## This function sends all the necessary information 
## to Caret and then passes back the tuned parameters
## in a  matrix.
send2caret = function(method, abbrev, search.params, tune.params, train.data, meth.args, caret.formula){
#  browser()
  if (!is.null(caret.formula)){
    ## Using the caret fornula interface:
    if ("verbose" %in% names(meth.args)){
      ## Include the verbose flag to cut down on the output:
      cfit = train( form=caret.formula,data=train.data,method=abbrev,
                    tuneGrid=search.params, trControl=tune.params,
                    verbose=meth.args$verbose)
    }else{
      if ("trace" %in% names(meth.args) && method %in% c("nnet","multinom") ){
        ## Include the trace flag to cut down on the output:
        cfit = train( form=caret.formula, data=train.data, method=abbrev,
                      tuneGrid=search.params, trControl=tune.params,
                      trace=meth.args$trace)
      }else{
        cfit = train( form=caret.formula, data=train.data, method=abbrev,
                      tuneGrid=search.params, trControl=tune.params)
      }
    }
        
  }else{
    ## NOT using the caret formula interface:
    if ("verbose" %in% names(meth.args)){
      ## Include the verbose flag to cut down on the output:
      cfit = train( as.matrix(train.data[,-1]), train.data$y,method=abbrev,
                    tuneGrid=search.params, trControl=tune.params,
                    verbose=meth.args$verbose)
    }else{
      if ("trace" %in% names(meth.args) && method %in% c("nnet","multinom") ){
        ## Include the trace flag to cut down on the output:
        cfit = train( as.matrix(train.data[,-1]), train.data$y,method=abbrev,
                      tuneGrid=search.params, trControl=tune.params,
                      trace=meth.args$trace)
      }else{
        cfit = train( as.matrix(train.data[,-1]), train.data$y,method=abbrev,
                      tuneGrid=search.params, trControl=tune.params)
      }
    }      
  }
  # Return value: The best tuning parameter...
  tuned.params=as.matrix(cfit$bestTune)
} ## End of send2caret function...


##==================================================
##  Perform the tuning by K-fold CV
##--------------------------------------------------
## This function tests over all the parameters passed in
## and tests to see which on produces the K-fold CV'd
## best prediction error for the method passed in.
##
## This function is for methods that Caret doesn't handle,
## or for options that Caret does allow for tuning over.
myTuningAlg = function(method, abbrev, search.params, tune.params, train.data, meth.args, caret.formula){
  
  ## I'm only going to deal w/ CV...
  stopifnot(tune.params$method %in% c("cv","repeatedcv")) 


  sz = dim(train.data[,-1])
  sz.params = dim(search.params)
    
  nfold = tune.params$number
  nreps = tune.params$repeats

#  browser()
  
  cv.results = vector("double", nreps)
  param.results = vector("double",sz.params[1])
  one.vec = vector("double",1)
  
  i.pred = vector("integer",sz[1])
  ##------------------------------------
  ## This sets up a list with the names
  ## of the parameters that we are going to vary.
  if( is.list(meth.args) && length(meth.args)){ ## Basically: if it's NOT an empty list...
    .name.meth.args = paste(".",names(meth.args),sep="")  ## Prepend a period.
  }else{
    .name.meth.args = NULL
  }
  ## Now we can compare the name of the tuning parameters with this list
  ## of names to be able to assign the parameters that we are testing. 

  ##*********************************************************************************************
  ## Someday it might be nice to put parallelization in here, but right now, I don't know how.
  ## Also, some of the methods already take advantage of parallelization
  ## (But maybe this is only in the caret package, and not in the method itself...)
  ##*********************************************************************************************
  for (p in 1:sz.params[1]){                       ## Iterate over the parameters to be tested...
    i.meth.args = meth.args;
    cv.results = vapply(cv.results,function(x){0},one.vec) ## Zero out the CV results vector.
    

    ## TODO: Clean this up and figure out what we need to be doing......
    if ( is.data.frame(search.params) ){
      ## Then this is most likely from expand.grid()
      for (ii in colnames(search.params)){            ## Assign the parameters
        i.meth.args[.name.meth.args == ii] = search.params[p,ii]
      }
    }else{ ## If there are no parameters: 
      i.meth.args=list()   ## Make an empty list to add on the other needed args..
    }

    
    for (i in 1:nreps){ ## Iterate over the # of repeats
      ifold = sample( rep(1:nfold,length=sz[1]) )
      
      ## Zero out the predicted classes.
      i.pred = factor(vapply(i.pred,function(x){NA},one.vec),levels(train.data$y)) 
      for (j in 1:nfold){                         ## Iterate over the K-folds for CV

        itrain = (1:sz[1])[j != ifold]
        itest  = (1:sz[1])[j == ifold]

        ## buildCall = function(meth.args, search.params, tuned.params, train.data, model.formula)         
        ii.meth.args = buildCall(i.meth.args, search.params = NULL,
                                tuned.params = NULL,
                                train.data[itrain,], model.formula=caret.formula)
        #browser()
        ## Do the training...
        cfit = do.call(method,ii.meth.args)

        ## Now we need to produce the predictions on the held-back K-fold
        if (method %in% c('NaiveBayes', 'lda') ){
            preds = predict(cfit,newdata=train.data[itest,-1]);
            i.pred[itest] = preds$class;
        }
        else{
            i.pred[itest] = predict(cfit,newdata=train.data[itest,-1]);
        }
      }
      #browser()
      ## Calculate the error for this K-fold CV:
      cv.results[i] = mean(i.pred != train.data$y)

    }
    ## Calculate the mean across the repeats:
    param.results[p] = mean(cv.results)
  }

  ## Now select the parameters with the lowest error:
  tuned.params = as.matrix( search.params[ (which(param.results == min(param.results)))[1] , ] )
  colnames(tuned.params) <- names(search.params);
  ##  browser()
  return(tuned.params)
}## End of function: myTuningAlg()

##==================================================
##  Build the call 
##--------------------------------------------------
## This function builds a list with the arguments
## needed to be able to call the training function.
buildCall = function(meth.args, search.params, tuned.params, train.data, model.formula=NULL){ 
  ## Build the call:
  ## browser()
  ## Substitute in the tuned parameters:
  if (!is.null(search.params) && is.list(meth.args)){
    ## (ie NOT empty grid)   AND    (is a list)
    for (i in colnames(tuned.params)){
      #browser()
      if (substr(i,1,1) == '.'){ ## If the names start with a period, match that...
        match.ind = paste(".",names(meth.args),sep="") == i
      }else {                    ## Otherwise, just match the names...
        match.ind = names(meth.args) == i
      }
      meth.args[match.ind] = tuned.params[,i]
      ##        ^^ Pick out the col with name i     ^^
    }
  }else {
    if (is.null(search.params) && is.list(meth.args)){
      ## Then meth.args is probably extra arguments
      ## not having to do with the training.
    }else {
      if (length(meth.args)){           # if it's not a list, then
                                        # make it an empty list:
        meth.args=list()
      }
    }
  }
  ## Add in the training data: (or the formula and data)   
  if (!is.null(model.formula)){
    ## Check to see if the formula is already there...
    #browser()
    ## Using the formula interface:
    stopifnot(is.formula(model.formula))   ## It IS a formula....

    ## Check to see if the formula is in the first position:
    formula.position = 'formula' %in% names(meth.args)
    if (formula.position[1]){
      no.reverse = TRUE
    } else{
      no.reverse = FALSE
    }
    meth.args$data = train.data;           ## Load up the full training data.
    meth.args$formula = model.formula;     ## Add in the formula.
  }else{
    ## Using the matrix interface.
    ## Check to see if "x" is in the first position:
    formula.position = 'x' %in% names(meth.args)
    if (formula.position[1]){
      no.reverse = TRUE
    } else{
      no.reverse = FALSE
    }
    meth.args$y=train.data$y;
    meth.args$x=as.matrix(train.data[,-1]);
  }
  if (!no.reverse) {
    meth.args = rev(meth.args)  ## Reverse the arguments, so that x (or formula) is first.
  }
  
} ## End function: buildCall()
