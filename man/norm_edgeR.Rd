% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/norm_edgeR.R
\name{norm_edgeR}
\alias{norm_edgeR}
\title{norm_edgeR}
\usage{
norm_edgeR(
  object,
  assay_name = "counts",
  method = c("TMM", "TMMwsp", "RLE", "upperquartile", "posupperquartile", "none"),
  refColumn = NULL,
  logratioTrim = 0.3,
  sumTrim = 0.05,
  doWeighting = TRUE,
  Acutoff = -1e+10,
  p = 0.75,
  verbose = TRUE,
  ...
)
}
\arguments{
\item{object}{a phyloseq or TreeSummarizedExperiment object.}

\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{method}{normalization method to be used. Choose between \code{TMM},
\code{TMMwsp}, \code{RLE}, \code{upperquartile}, \code{posupperquartile} or
\code{none}.}

\item{refColumn}{column to use as reference for \code{method="TMM"}. Can be a column number or a numeric vector of length \code{nrow(object)}.}

\item{logratioTrim}{the fraction (0 to 0.5) of observations to be trimmed from each tail of the distribution of log-ratios (M-values) before computing the mean. Used by \code{method="TMM"} for each pair of samples.}

\item{sumTrim}{the fraction (0 to 0.5) of observations to be trimmed from each tail of the distribution of A-values before computing the mean. Used by \code{method="TMM"} for each pair of samples.}

\item{doWeighting}{logical, whether to use (asymptotic binomial precision) weights when computing the mean M-values. Used by \code{method="TMM"} for each pair of samples.}

\item{Acutoff}{minimum cutoff applied to A-values. Count pairs with lower A-values are ignored. Used by \code{method="TMM"} for each pair of samples.}

\item{p}{numeric value between 0 and 1 specifying which quantile of the counts should be used by \code{method="upperquartile"}.}

\item{verbose}{an optional logical value. If \code{TRUE}, information about
the steps of the algorithm is printed. Default \code{verbose = TRUE}.}

\item{...}{other arguments are not currently used.}
}
\value{
A new column containing the chosen edgeR-based normalization factors 
is added to the \code{sample_data} slot of the phyloseq object or the 
\code{colData} slot of the TreeSummarizedExperiment object.
}
\description{
Calculate normalization factors from a phyloseq or TreeSummarizedExperiment
object. Inherited from edgeR \code{\link{calcNormFactors}} function.
}
\examples{
set.seed(1)
# Create a very simple phyloseq object
counts <- matrix(rnbinom(n = 60, size = 3, prob = 0.5), nrow = 10, ncol = 6)
metadata <- data.frame("Sample" = c("S1", "S2", "S3", "S4", "S5", "S6"),
                       "group" = as.factor(c("A", "A", "A", "B", "B", "B")))
ps <- phyloseq::phyloseq(phyloseq::otu_table(counts, taxa_are_rows = TRUE),
                         phyloseq::sample_data(metadata))

# Calculate the normalization factors
ps_NF <- norm_edgeR(object = ps, method = "TMM")

# The phyloseq object now contains the normalization factors:
normFacts <- phyloseq::sample_data(ps_NF)[, "NF.TMM"]
head(normFacts)

# VERY IMPORTANT: edgeR uses normalization factors to normalize library sizes
# not counts. They are used internally by a regression model. To make edgeR 
# normalization factors available for other methods, such as DESeq2 or other 
# DA methods based on scaling or size factors, we need to transform them into
# size factors. This is possible by multiplying the factors for the library 
# sizes and renormalizing. 
normLibSize = normFacts * colSums(phyloseq::otu_table(ps_stool_16S))
# Renormalize: multiply to 1
sizeFacts = normLibSize/exp(colMeans(log(normLibSize)))
}
\seealso{
\code{\link[edgeR]{calcNormFactors}} for details.

\code{\link{setNormalizations}} and \code{\link{runNormalizations}}
to fastly set and run normalizations.
}
