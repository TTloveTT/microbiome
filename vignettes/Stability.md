# Microbiome stability analysis

Get example data - HITChip Atlas of 130 genus-like taxa across 1006 healthy western adults from [Lahti et al. Nat. Comm. 5:4344, 2014](http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html). A subset of 76 subjects have also short time series available for temporal stability analysis:


```r
library(microbiome)
data("atlas1006")
pseq <- atlas1006

# Let us keep only prevalent taxa
# (HITChip signal >3 in >20 percent of the samples)
pseq <- filter_prevalent(pseq, detection.threshold = 10^3, prevalence.threshold = 0.2)
```



## Quantify intermediate stability 

It has been reported that certain microbial groups exhibit bi-stable
abundance distributions with distinct peaks at low and high
abundances, and an instable intermediate abundance range. Instability
at the intermediate abundance range is hence one indicator of
bi-stability. [Lahti et
al. 2014](http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html))
use straightforward correlation analysis to quantify how the distance
from the intermediate abundance region (50% quantile) is associated
with the observed shifts between consecutive time points. This can be
calculated with:


```r
intermediate.stability <- intermediate_stability(pseq, output = "scores")
```


## Quantify bimodality 

Bimodality of the abundance distribution provides another (indirect)
indicator of bistability, although other explanations such as sampling
biases etc. should be controlled. Multiple bimodality scores are
available.

Let is stick to cross-sectional analysis of bimodality and include
only the samples from the zero time point:


```r
pseq0 <- subset_samples(pseq, time == 0 & DNA_extraction_method == "r")
```


Multimodality score using [potential analysis with
bootstrap](http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html)



```r
bimodality.pb <- bimodality(pseq0, method = "potential_bootstrap")
```

Sarle's bimodality coefficient (see help(coefficient_of_bimodality)):


```r
bimodality.sarle <- bimodality(pseq0, method = "Sarle.finite.sample")
```


DIP test for multimodality (from the [diptest](https://cran.r-project.org/web/packages/diptest/index.html) package):


```r
bimodality.dip <- bimodality(pseq0, method = "dip")
```


Visualize population densities 


```r
# Pick the most and least bimodal taxa as examples
bimodality <- bimodality.pb
unimodal <- names(which.min(bimodality))
bimodal  <- names(which.max(bimodality))

# Visualize population frequencies
library(ggplot2)
theme_set(theme_bw(20))
p1 <- plot_density(pseq, variable = unimodal, log10 = TRUE) 
p2 <- plot_density(pseq, variable = bimodal,  log10 = TRUE) 
library(gridExtra)
library(ggplot2)
grid.arrange(p1, p2, nrow = 1)
```

![plot of chunk stability2](figure/stability2-1.png)


## Comparing bimodality and intermediate stability

The analysis suggests that bimodal population distribution across individuals is often associated with instable intermediate abundances within individuals. The specific bi-stable groups in the upper left corner were suggested to constitute bistable tipping elements of the human intestinal microbiota in [Lahti et al. Nat. Comm. 5:4344, 2014](http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html):


```r
taxa <- taxa_names(pseq0)
df <- data.frame(group = taxa,
                 intermediate.stability = intermediate.stability[taxa],
		 bimodality = bimodality.pb[taxa])
theme_set(theme_bw(20))
p <- ggplot(df, aes(x = intermediate.stability, y = bimodality, label = group))
p <- p + geom_text(size = 3)
p
```

![plot of chunk bimodalitybistability](figure/bimodalitybistability-1.png)

## Detecting a tipping point

Identify potential minima in cross-section population data as
tipping point candidates. 


```r
# Pick example data
library(phyloseq)
library(microbiome)
data("atlas1006")
pseq <- atlas1006
pseq <- subset_samples(pseq, DNA_extraction_method == "r")
pseq <- transform_phyloseq(pseq, "relative.abundance")

# Dialister log10 relative abundance
x <- log10(get_sample(pseq, "Dialister"))

# Potential analysis to identify potential minima
library(earlywarnings)
res <- livpotential_ews(x)

# Identify the potential minimum location as a tipping point candidate 
tipping.point <- 10^res$min.points

print(tipping.point)
```

```
## [1] 0.2491531
```

## Variation lineplot and Bimodality hotplot

Pick subset of the [HITChip Atlas data set](http://doi.org/10.5061/dryad.pk75d) and plot the subject abundance variation lineplot (**Variation lineplot**) and **Bimodality hotplot** for a given taxon as in [Lahti et al. 2014](http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html). The bi-stable Dialister has bimodal population distribution and reduced temporal stability within subjects at intermediate abundances.


```r
# Variation line plot:
# Indicates the abundance variation range
# for subjects with multiple time points
pv <- plot_variation(pseq, "Dialister", tipping.point = tipping.point, xlim = c(0.01, 100))
print(pv)

# Bimodality hotplot:
# Only consider a unique sample from each subject
# baseline time point for density plot
pseq.baseline <- subset_samples(pseq, time == 0)
ph <- plot_bimodal(pseq.baseline, "Dialister", tipping.point = tipping.point)
print(ph)
```

<img src="figure/stability-variationplot-1.png" title="plot of chunk stability-variationplot" alt="plot of chunk stability-variationplot" width="430px" /><img src="figure/stability-variationplot-2.png" title="plot of chunk stability-variationplot" alt="plot of chunk stability-variationplot" width="430px" />




### Version information


```r
sessionInfo()
```

```
## R version 3.2.2 (2015-08-14)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Ubuntu 15.10
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] grid      parallel  stats     graphics  grDevices utils     datasets 
## [8] methods   base     
## 
## other attached packages:
##  [1] earlywarnings_1.1.22 tseries_0.10-34      tgp_2.4-11          
##  [4] moments_0.14         gridExtra_2.0.0      FD_1.0-12           
##  [7] geometry_0.3-6       magic_1.5-6          abind_1.4-3         
## [10] ape_3.4              ade4_1.7-3           RSQLite_1.0.0       
## [13] DBI_0.3.1            vegan_2.3-3          lattice_0.20-33     
## [16] permute_0.8-4        intergraph_2.0-2     sna_2.3-2           
## [19] network_1.13.0       ggnet_0.1.0          GGally_1.0.1        
## [22] knitcitations_1.0.7  knitr_1.12           devtools_1.9.1      
## [25] limma_3.26.5         sorvi_0.7.35         ggplot2_2.0.0       
## [28] tidyr_0.3.1          dplyr_0.4.3          MASS_7.3-45         
## [31] netresponse_1.21.14  reshape2_1.4.1       mclust_5.1          
## [34] minet_3.28.0         Rgraphviz_2.14.0     graph_1.48.0        
## [37] phyloseq_1.14.0      microbiome_0.99.73   RPA_1.26.0          
## [40] affy_1.48.0          Biobase_2.30.0       BiocGenerics_0.16.1 
## 
## loaded via a namespace (and not attached):
##  [1] colorspace_1.2-6      rjson_0.2.15          dynamicTreeCut_1.62  
##  [4] som_0.3-5             qvalue_2.2.2          XVector_0.10.0       
##  [7] affyio_1.40.0         AnnotationDbi_1.32.3  mvtnorm_1.0-3        
## [10] lubridate_1.5.0       RefManageR_0.10.5     xml2_0.1.2           
## [13] codetools_0.2-14      splines_3.2.2         doParallel_1.0.10    
## [16] impute_1.44.0         spam_1.3-0            Formula_1.2-1        
## [19] WGCNA_1.49            cluster_2.0.3         GO.db_3.2.2          
## [22] Kendall_2.2           oai_0.1.0             httr_1.0.0           
## [25] assertthat_0.1        Matrix_1.2-3          lazyeval_0.1.10      
## [28] formatR_1.2.1         acepack_1.3-3.3       tools_3.2.2          
## [31] igraph_1.0.1          rdryad_0.2.0          gtable_0.1.2         
## [34] maps_3.0.2            Rcpp_0.12.3           Biostrings_2.38.3    
## [37] RJSONIO_1.3-0         multtest_2.26.0       biom_0.3.12          
## [40] preprocessCore_1.32.0 nlme_3.1-122          iterators_1.0.8      
## [43] lmtest_0.9-34         fastcluster_1.1.16    stringr_1.0.0        
## [46] XML_3.98-1.3          zlibbioc_1.16.0       zoo_1.7-12           
## [49] scales_0.3.0          BiocInstaller_1.20.1  solr_0.1.6           
## [52] RColorBrewer_1.1-2    fields_8.3-6          curl_0.9.5           
## [55] memoise_0.2.1         rpart_4.1-10          latticeExtra_0.6-26  
## [58] reshape_0.8.5         stringi_1.0-1         maptree_1.4-7        
## [61] highr_0.5.1           S4Vectors_0.8.7       foreach_1.4.3        
## [64] nortest_1.0-4         boot_1.3-17           bibtex_0.4.0         
## [67] chron_2.3-47          bitops_1.0-6          matrixStats_0.50.1   
## [70] dmt_0.8.20            evaluate_0.8          labeling_0.3         
## [73] plyr_1.8.3            magrittr_1.5          R6_2.1.2             
## [76] IRanges_2.4.6         Hmisc_3.17-1          foreign_0.8-66       
## [79] mgcv_1.8-10           nnet_7.3-11           survival_2.38-3      
## [82] RCurl_1.95-4.7        KernSmooth_2.23-15    data.table_1.9.6     
## [85] digest_0.6.9          diptest_0.75-7        stats4_3.2.2         
## [88] munsell_0.4.2         quadprog_1.5-5
```

