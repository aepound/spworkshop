
##==================================
## Aggregate the Errors together...
##----------------------------------
ls()
ErrNames = ls(pattern=glob2rx("*.out"))
tmpErr = lapply(ErrNames,get)
Errs = lapply(tmpErr,function(x) x$err)
tunep= lapply(tmpErr,function(x) x$tuned)
nnames=lapply(tmpErr,function(x) x$name)
rm(tmpErr) # delete the temp variable...
names(Errs) <- nnames
names(tunep) <-  nnames
Errs = do.call(c,Errs)
tunes= do.call(c,tunep)

# Let's remove one of the Naive bayes... (there's 2)

first.nb = which(names(Errs) == "Naive Bayes")
if (sum(first.nb) >= 2){
  first.nb = min(first.nb)
  Errs = Errs[-first.nb]
  tunes= tunes[-first.nb]
}
