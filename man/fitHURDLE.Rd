% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fitDistribution.R
\name{fitHURDLE}
\alias{fitHURDLE}
\title{fitHURDLE}
\usage{
fitHURDLE(object, assay_name = "counts", scale = "default", verbose = TRUE)
}
\arguments{
\item{object}{a phyloseq object, a TreeSummarizedExperiment object, or a 
matrix of counts.}

\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{scale}{Character vector, either \code{median} or \code{default} to
choose between the median of the library size or one million to scale raw
counts.}

\item{verbose}{an optional logical value. If \code{TRUE} information on the
steps of the algorithm is printed. Default \code{verbose = TRUE}.}
}
\value{
A data frame containing the continuity corrected logarithms of the
average fitted values for each row of the matrix of counts in the \code{Y}
column, and the estimated probability to observe a zero in the \code{Y0}
column.
}
\description{
Fit a truncated gaussian hurdle model for each taxon of the count data. The
hurdle model estimation procedure is performed by MAST \code{\link{zlm}}
function without assuming the presence of any group in the samples (design
matrix equal to a column of ones.)
}
\examples{
# Generate some random counts
counts = matrix(rnbinom(n = 600, size = 3, prob = 0.5), nrow = 100, ncol = 6)

# Fit model on the counts matrix
HURDLE <- fitHURDLE(counts, scale = "median")
head(HURDLE)
}
