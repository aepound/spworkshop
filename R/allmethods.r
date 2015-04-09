Errs = list()
done = FALSE;
testing = TRUE;
datafile.name = "run1.Rdata"

##===================================
##  Recursive Partitioning
if (done){
rpart.grid = expand.grid(.cp = c(0.0005, 0.001,(seq(0.005,.35,.005))) )
rpart.args = list(cp=NULL)
rpart.form = formula( y ~ . )
rpart.out = tuneMethods("rpart","rpart",rpart.grid,
    fitControl,train.all,test.all,rpart.args,rpart.form)
print(rpart.out$tuned)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Random Forests
##----------------------------------
if (done){
if(testing){
  rf.grid = expand.grid(.mtry = 1:3)
}else{
  rf.grid = expand.grid(.mtry = 1:nvars)
}
rf.args = list(mtry=NULL)
rf.out = tuneMethods("randomForest","rf",rf.grid,
    fitControl,train.all,test.all,rf.args)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Neural Nets
##----------------------------------
if (done){
if(testing){
  nnet.grid = expand.grid(.decay=(0:1)/50000, .size=(1:2) )
}else{
  nnet.grid = expand.grid(.decay=(0:20)/100000,
                          .size=c(1:3*nlevels(test.y), seq(10,25,5),seq(30,200,10)))
}
nnet.args = list(decay=NULL,size=NULL,trace=FALSE)
nnet.form = formula( y ~ . )
nnet.out = tuneMethods("nnet","nnet",nnet.grid,
    fitControl,train.all,test.all,nnet.args,nnet.form)
print(paste(" "))
save.image(file=datafile.name)
}# IF done

##==================================
## naiveBayes
##----------------------------------
if (!done){
nBayes.grid = expand.grid(.fL = c(0,1),.usekernel=c(TRUE,FALSE))
nBayes.args = list(fL=NULL,usekernel=NULL,kernel='cosine')
nBayes.form = formula( y ~ . )
nBayes.out = tuneMethods("NaiveBayes","nb",nBayes.grid,
    fitControl,train.all,test.all,nBayes.args,nBayes.form,nBayes.form)
print(nBayes.out$tuned)
print(paste(" "))
save.image(file=datafile.name)

naiveBayes.grid = expand.grid(.fL = c(0,1),.usekernel=c(TRUE,FALSE))
naiveBayes.args = list(fL=NULL,usekernel=NULL,kernel='cosine')
naiveBayes.form = formula( y ~ . )
naiveBayes.out = tuneMethods("NaiveBayes",NULL,naiveBayes.grid,
    fitControl,train.all,test.all,naiveBayes.args,naiveBayes.form,naiveBayes.form)
print(naiveBayes.out$tuned)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Multiclass Logistic
##----------------------------------
if(done){
if(testing){
  mlog.grid = expand.grid(.decay=(0:2)/50000)
}else{
  mlog.grid = expand.grid(.decay=(0:20)/100000)
}
mlog.args = list(decay=NULL,trace=FALSE)
mlog.form = formula( y ~ . )
mlog.out = tuneMethods("multinom","multinom",mlog.grid,fitControl,train.all,test.all,mlog.args,mlog.form)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##==================================
## svmMulti
##----------------------------------
if(done){
svmMulti.grid = expand.grid(.C = c(seq(0.05,2,0.05)))
svmMulti.args = list(C = NULL, trace = FALSE, type="kbb-svc")
svmMulti.out = tuneMethods("ksvm",NULL,svmMulti.grid,
    fitControl,train.all,test.all,svmMulti.args)
print(svmMulti.out$tuned)
print(paste(" "))
save.image(file=datafile.name )
} # IF done

##==================================
## Aggregate the Errors together...
##----------------------------------
ErrNames = ls(pattern="[:alpha:]*.out")
tmpErr = lapply(ErrNames,get)
Errs = lapply(tmpErr,function(x) x$err)
tunep= lapply(tmpErr,function(x) x$tuned)
names(Errs) <- ErrNames
names(tunep) <-  ErrNames
Errs = do.call(c,Errs)
tunes= do.call(c,tunep)
