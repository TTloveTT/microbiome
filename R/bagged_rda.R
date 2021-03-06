#' @title Bagged RDA
#' @description Bagged (or Bootstrap Aggregated) RDA feature selection
#' @param x a matrix, samples on columns, variables (bacteria) on rows. 
#'        Or a \code{\link{phyloseq-class}} object
#' @param y vector with names(y)=rownames(X). 
#'            Or name of phyloseq sample data variable name.
#' @param sig.thresh signal p-value threshold, default 0.1
#' @param nboot Number of bootstrap iterations
#' @param verbose verbose
#' @return List with items:
#'   \itemize{
#'     \item{loadings}{bagged loadings}
#'     \item{scores}{bagged scores}
#'     \item{significance}{significances of X variables}
#'     \item{group.centers}{group centers on latent space}
#'     \item{bootstrapped}{bootstrapped loadings}
#'     \item{data}{data set with non-significant components dropped out}
#'   }
#' @examples \dontrun{
#'   library(microbiome)
#'   data(peerj32)
#'   x <- t(peerj32$microbes)
#'   y <- factor(peerj32$meta$time); names(y) <- rownames(peerj32$meta)
#'   res <- bagged_rda(x, y, sig.thresh=0.05, nboot=100)
#'   plot_bagged_rda(res, y)
#'  }
#' @export
#' @details Bagging ie. Bootstrap aggregation is expected to improve the stability of the results. The results over several modeling runs with different boostrap samples of the data are averaged to produce the final summary,
#' @references See citation("microbiome") 
#' @author Jarkko Salojarvi \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities
bagged_rda <- function(x, y, sig.thresh = 0.1, nboot = 1000, verbose = T){

  if (class(x) == "phyloseq") {
    # Pick OTU matrix and the indicated annotation field
    y <- factor(sample_data(x)[[y]])
    names(y) <- sample_data(x)$sample
    x <- otu_table(x)@.Data
  }

  stop.run=F
  class.split=split(names(y),y)
  dropped=vector("character",nrow(x))
  x.all=x
  mean.err=rep(1,nrow(x))
  while(stop.run==F){
    boot=replicate(nboot,unlist(sapply(class.split,function(x) sample(x,length(x),replace=T))),simplify=F)
    Bag.res=Bagged.RDA(x,y,boot=boot)
    min.prob=Bag.res$significance[[1]]
    if (length(levels(y))>2){
      for (i in 1:nrow(x))
         min.prob[i]=min(sapply(Bag.res$significance,function(x) x[i]))
    }
    mean.err[nrow(x)]=Bag.res$error
    dropped[nrow(x)]=rownames(x)[which.max(min.prob)]
    if (verbose) {message(c(nrow(x), Bag.res$error))}
    if (nrow(x)>max(length(class.split),2))
      x=x[-which.max(min.prob),]
    else
      stop.run=T
  }
  dropped[1:length(class.split)]=rownames(x)[order(min.prob)[1:length(class.split)]]
  best.res=which.min(mean.err)

  Bag.res=Bagged.RDA(x.all[dropped[1:best.res],],y,boot=boot)
  Bag.res$data=x.all[dropped[1:best.res],]
  Bag.res$Err.selection=mean.err
  Bag.res$dropped=dropped

  plot(mean.err,xlab="x dimension")
  points(best.res,mean.err[best.res],col="red")

  list(bagged.rda = Bag.res, variable = y)

}

