% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/boxplot.R
\name{boxplot_abundance}
\alias{boxplot_abundance}
\title{Abundance boxplot}
\usage{
boxplot_abundance(pseq, x, y, line = NULL, color = NULL, log10 = TRUE,
  title = NULL)
}
\arguments{
\item{pseq}{\code{\link{phyloseq-class}} object}

\item{x}{Metadata variable to map to the horizontal axis.}

\item{y}{OTU to map on the vertical axis}

\item{line}{The variable to map on lines}

\item{color}{The variable to map on colors}

\item{log10}{show y axis on log scale}

\item{title}{Optional title for the graphic.}
}
\value{
A \code{\link{ggplot}} plot object
}
\description{
Plot phyloseq abundances
}
\examples{
# 
}
\keyword{utilities}

