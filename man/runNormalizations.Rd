% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runNormalizations.R
\name{runNormalizations}
\alias{runNormalizations}
\title{runNormalizations}
\usage{
runNormalizations(
  normalization_list,
  object,
  assay_name = "counts",
  verbose = TRUE
)
}
\arguments{
\item{normalization_list}{a list object containing the normalization methods
and their parameters.}

\item{object}{a phyloseq or TreeSummarizedExperiment object.}

\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{verbose}{an optional logical value. If \code{TRUE}, information about
the steps of the algorithm is printed. Default \code{verbose = TRUE}.}
}
\value{
A phyloseq object containing the normalization/scaling factors.
}
\description{
Add normalization/scaling factors to a phyloseq object
}
\examples{
set.seed(1)
# Create a very simple phyloseq object
counts <- matrix(rnbinom(n = 60, size = 3, prob = 0.5), nrow = 10, ncol = 6)
metadata <- data.frame("Sample" = c("S1", "S2", "S3", "S4", "S5", "S6"),
                       "group" = as.factor(c("A", "A", "A", "B", "B", "B")))
ps <- phyloseq::phyloseq(phyloseq::otu_table(counts, taxa_are_rows = TRUE),
                         phyloseq::sample_data(metadata))

# Set some simple normalizations
my_normalizations <- setNormalizations()

# Add them to the phyloseq object
ps <- runNormalizations(normalization_list = my_normalizations, object = ps)
}
\seealso{
\code{\link{setNormalizations}}
}
