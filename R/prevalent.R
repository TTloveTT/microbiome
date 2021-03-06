#' @title Prevalent taxa
#' @description List prevalent groups.
#' @param x A matrix or a x \code{\link{phyloseq}} object
#' @param detection.threshold Detection threshold for absence/presence.
#' @param prevalence.threshold Detection threshold for prevalence, provided as percentages [0, 100]
#' @details For phyloseq object, lists taxa that are more prevalent with the given detection
#'          threshold. For matrix, lists columns that satisfy these criteria.
#' @return Vector of prevalent taxa names
#' @references 
#'   A Salonen et al. The adult intestinal core microbiota is determined by 
#'   analysis depth and health status. Clinical Microbiology and Infection 
#'   18(S4):16 20, 2012. 
#'   To cite the microbiome R package, see citation('microbiome') 
#' @author Contact: Leo Lahti \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities
#' @export
#' @examples
#'   #peerj32 <- download_microbiome("peerj32")
#'   #prevalent_taxa(peerj32$data$microbes, 10^1.8 + 100, 0.2) # matrix
#'   #prevalent_taxa(peerj32$physeq, 100, 0.2) # phyloseq object
prevalent_taxa <- function (x, detection.threshold, prevalence.threshold) {

  if (class(x) == "phyloseq") {
    # Convert into OTU matrix
    otu <- otu_table(x)@.Data    
    if (taxa_are_rows(x)) {
      otu <- t(otu)
    }
  } 

  sort(names(which(prevalence(otu, detection.threshold) > prevalence.threshold)))

}


