Errs = list()
done = FALSE;
testing = FALSE;
nvars=ncol(train.x)
##==================================
##  Algorithms to run:
##----------------------------------
algs = list()
algs = c(algs, "lda")
#algs = c(algs, "qda")   
algs = c(algs, "rpart")
algs = c(algs, "rf")
#algs = c(algs, "nnet")  ## Still errors
algs = c(algs, "nb")
algs = c(algs, "rpart")
#algs = c(algs, "mlog")  ## Still errors
algs = c(algs, "svm")

print("==================================")
print(" Algorithms to be tested:         ")
trash =  lapply(algs,print);
print("----------------------------------")
print(" ")

##===================================
##  Linear Discriminant Analysis
##----------------------------------
if("lda" %in% algs){
lda.grid = NULL
lda.args = list()
lda.form = formula( y ~ . )
lda.out = tuneMethods("lda","lda",lda.grid,
    fitControl,train.all,test.all,lda.args,lda.form,lda.form)
lda.out$name = "LDA"
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Quadratic Discriminant Analysis
##----------------------------------
if("qda" %in% algs){
qda.grid = NULL
qda.args = list()
qda.form = formula( y ~ . )
qda.out = tuneMethods("qda","qda",qda.grid,
    fitControl,train.all,test.all,qda.args,qda.form,qda.form)
qda.out$name = "QDA"
print(paste(" "))
save.image(file=datafile.name)
} # IF done



##===================================
##  Recursive Partitioning
##----------------------------------
if ("rpart" %in% algs){
rpart.grid = expand.grid(.cp = c(0.0005, 0.001,(seq(0.005,.35,.005))) )
rpart.args = list(cp=NULL)
rpart.form = formula( y ~ . )
rpart.out = tuneMethods("rpart","rpart",rpart.grid,
    fitControl,train.all,test.all,rpart.args,rpart.form)
rpart.out$name = "CART"
#print(rpart.out$tuned)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Random Forests
##----------------------------------
if ("rf" %in% algs){
if(testing){
  rf.grid = expand.grid(.mtry = 1:3)
}else{
  rf.grid = expand.grid(.mtry = seq(1,nvars,by=15))
}
rf.args = list(mtry=NULL)
rf.out = tuneMethods("randomForest","rf",rf.grid,
    fitControl,train.all,test.all,rf.args)
rf.out$name = "RandomForest"
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Neural Nets
##----------------------------------
## This still errors...  4/13/15
if ("nnet" %in% algs){
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
nnet.out$name = "Neural Net"
print(paste(" "))
save.image(file=datafile.name)
}# IF done

##==================================
## naiveBayes
##----------------------------------
if ("nb" %in% algs){
nBayes.grid = expand.grid(.fL = c(0,1),.usekernel=c(TRUE,FALSE))
nBayes.args = list(fL=NULL,usekernel=NULL,kernel='cosine')
nBayes.form = formula( y ~ . )
nBayes.out = tuneMethods("NaiveBayes","nb",nBayes.grid,
    fitControl,train.all,test.all,nBayes.args,nBayes.form,nBayes.form)
nBayes.out$name = "Naive Bayes"
#print(nBayes.out$tuned)
print(paste(" "))
save.image(file=datafile.name)

naiveBayes.grid = expand.grid(.fL = c(0,1),.usekernel=c(TRUE,FALSE))
naiveBayes.args = list(fL=NULL,usekernel=NULL,kernel='cosine')
naiveBayes.form = formula( y ~ . )
naiveBayes.out = tuneMethods("NaiveBayes",NULL,naiveBayes.grid,
    fitControl,train.all,test.all,naiveBayes.args,naiveBayes.form,naiveBayes.form)
naiveBayes.out$name = "Naive Bayes"
#print(naiveBayes.out$tuned)
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##===================================
##  Multiclass Logistic
##----------------------------------
## This still errors...  4/13/15
if("mlog" %in% algs){
if(testing){
  mlog.grid = expand.grid(.decay=(0:2)/50000)
}else{
  mlog.grid = expand.grid(.decay=(0:20)/100000)
}
mlog.args = list(decay=NULL,trace=FALSE)
mlog.form = formula( y ~ . )
mlog.out = tuneMethods("multinom","multinom",mlog.grid,fitControl,train.all,test.all,mlog.args,mlog.form)
mlog.out$name = "Multi-class Logistic"
print(paste(" "))
save.image(file=datafile.name)
} # IF done

##==================================
## svmMulti
##----------------------------------
if("svm" %in% algs){
svmMulti.grid = expand.grid(.C = c(seq(0.05,2,0.05)))
svmMulti.args = list(C = NULL, trace = FALSE, type="kbb-svc")
svmMulti.out = tuneMethods("ksvm",NULL,svmMulti.grid,
    fitControl,train.all,test.all,svmMulti.args)
svmMulti.out$name = "Multi-class SVM"
#print(svmMulti.out$tuned)
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
names(Errs) <- ErrNames$name
names(tunep) <-  ErrNames$name
Errs = do.call(c,Errs)
tunes= do.call(c,tunep)
