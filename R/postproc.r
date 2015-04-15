
##==================================
## Aggregate the Errors together...
##----------------------------------
ErrNames = ls(pattern="[:alpha:]*.out")
tmpErr = lapply(ErrNames,get)
Errs = lapply(tmpErr,function(x) x$err)
tunep= lapply(tmpErr,function(x) x$tuned)
nnames=lapply(tmpErr,function(x) x$name)
names(Errs) <- nnames
names(tunep) <-  nnames
Errs = do.call(c,Errs)
tunes= do.call(c,tunep)
