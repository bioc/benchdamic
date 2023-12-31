% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{get_counts_metadata}
\alias{get_counts_metadata}
\title{get_counts_metadata}
\usage{
get_counts_metadata(
  object,
  assay_name = "counts",
  min_counts = 0,
  min_samples = 0
)
}
\arguments{
\item{object}{a phyloseq or TreeSummarizedExperiment object.}

\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{min_counts}{Parameter to filter taxa. Set this number to keep features 
with more than \code{min_counts} counts in more than \code{min_samples} 
samples (default \code{min_counts = 0}).}

\item{min_samples}{Parameter to filter taxa. Set this number to keep 
features with a \code{min_counts} counts in more than \code{min_samples} 
samples (default \code{min_samples = 0}).}
}
\value{
a \code{list} of results:
\itemize{
    \item{\code{counts}}{the \code{otu_table} slot or \code{assayName} assay 
    of the phyloseq or TreeSummarizedExperiment object;}
    \item{\code{metadata}}{the \code{sample_data} or \code{colData} slot of
    the phyloseq or TreeSummarizedExperiment object;}
    \item{\code{is_phyloseq}}{a boolean equal to \code{TRUE} if the input is 
    a phyloseq object.}}
}
\description{
Check whether the input object is a phyloseq or a 
TreeSummarizedExperiment, then extract the requested data slots.
}
\examples{
set.seed(1)
# Create a very simple phyloseq object
counts <- matrix(rnbinom(n = 60, size = 3, prob = 0.5), nrow = 10, ncol = 6)
metadata <- data.frame("Sample" = c("S1", "S2", "S3", "S4", "S5", "S6"),
                       "group" = as.factor(c("A", "A", "A", "B", "B", "B")))
ps <- phyloseq::phyloseq(phyloseq::otu_table(counts, taxa_are_rows = TRUE),
                         phyloseq::sample_data(metadata))
get_counts_metadata(ps)

# Or with a TreeSummarizedExperiment
tse <- TreeSummarizedExperiment::TreeSummarizedExperiment(
    assays = list("counts" = counts), colData = metadata)
get_counts_metadata(tse)
}
