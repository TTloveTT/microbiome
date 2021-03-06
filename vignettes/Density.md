### Abundance histograms

Different sample sets have different population distributions in
microbial abundance. It is also important to consider whether to use
absolute or logarithmic abundances.


Visualize population densities for specific taxonomic group:


```r
library(microbiome)
library(phyloseq)

# Example data from
# http://www.nature.com/ncomms/2014/140708/ncomms5344/full/ncomms5344.html
data("atlas1006")
x <- atlas1006

# Pick the subset of RBB-preprocessed samples from time point 0
x <- subset_samples(x, time == 0 & DNA_extraction_method == "r")

# Visualize population densities for specific taxa
plot_density(x, "Prevotella melaninogenica et rel.")
```

![plot of chunk hist](figure/hist-1.png)


Same with log10 abundances:


```r
plot_density(x, "Prevotella melaninogenica et rel.", log10 = TRUE)
```

![plot of chunk hist2](figure/hist2-1.png)


Same with log10 relative abundances:


```r
# Convert to relative abundances
x <- transform_sample_counts(x, function (x) {100 * x/sum(x)})

# Visualize
tax <- "Prevotella melaninogenica et rel."
plot_density(x, tax, log10 = TRUE) + ggtitle(paste(tax, "(Rel. Ab. %)"))
```

![plot of chunk hist3](figure/hist3-1.png)

