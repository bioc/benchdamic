% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/norm_DESeq2.R
\name{norm_DESeq2}
\alias{norm_DESeq2}
\title{norm_DESeq2}
\usage{
norm_DESeq2(
  object,
  assay_name = "counts",
  method = c("ratio", "poscounts", "iterate"),
  verbose = TRUE,
  ...
)
}
\arguments{
\item{object}{a phyloseq or TreeSummarizedExperiment object.}

\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{method}{Method for estimation: either \code{"ratio"},
\code{"poscounts"}, or \code{"iterate"}. \code{"ratio"} uses the standard
median ratio method introduced in DESeq. The size factor is the median ratio
of the sample over a "pseudosample": for each gene, the geometric mean of 
all samples. \code{"poscounts"} and \code{"iterate"} offer alternative
estimators, which can be used even when all features contain a sample with a
zero (a problem for the default method, as the geometric mean becomes zero,
and the ratio undefined). The \code{"poscounts"} estimator deals with
a feature with some zeros, by calculating a modified geometric mean by 
taking the n-th root of the product of the non-zero counts. This evolved out 
of use cases with Paul McMurdie's phyloseq package for metagenomic samples. 
The \code{"iterate"} estimator iterates between estimating the dispersion 
with a design of ~1, and finding a size factor vector by numerically 
optimizing the likelihood of the ~1 model.}

\item{verbose}{an optional logical value. If \code{TRUE}, information about
the steps of the algorithm is printed. Default \code{verbose = TRUE}.}

\item{...}{other parameters for DESeq2 
\code{\link[DESeq2]{estimateSizeFactors}} function.}
}
\value{
A new column containing the chosen DESeq2-based size factors is 
added to the \code{sample_data} slot of the phyloseq object or the 
\code{colData} slot of the TreeSummarizedExperiment object.
}
\description{
Calculate size factors from a phyloseq or TreeSummarizedExperiment object. 
Inherited from DESeq2 \code{\link[DESeq2]{estimateSizeFactors}} function.
}
\examples{
set.seed(1)
# Create a very simple phyloseq object
counts <- matrix(rnbinom(n = 60, size = 3, prob = 0.5), nrow = 10, ncol = 6)
metadata <- data.frame("Sample" = c("S1", "S2", "S3", "S4", "S5", "S6"),
                       "group" = as.factor(c("A", "A", "A", "B", "B", "B")))
ps <- phyloseq::phyloseq(phyloseq::otu_table(counts, taxa_are_rows = TRUE),
                         phyloseq::sample_data(metadata))

# Calculate the size factors
ps_NF <- norm_DESeq2(object = ps, method = "poscounts")
# The phyloseq object now contains the size factors:
sizeFacts <- phyloseq::sample_data(ps_NF)[, "NF.poscounts"]
head(sizeFacts)

# VERY IMPORTANT: DESeq2 uses size factors to normalize counts. 
# These factors are used internally by a regression model. To make DEseq2 
# size factors available for edgeR, we need to transform them into 
# normalization factors. This is possible by dividing the factors by the 
# library sizes and renormalizing. 
normSizeFacts = sizeFacts / colSums(phyloseq::otu_table(ps_stool_16S))
# Renormalize: multiply to 1
normFacts = normSizeFacts/exp(colMeans(log(normSizeFacts)))
}
\seealso{
\code{\link[DESeq2]{estimateSizeFactors}} for details.
\code{\link{setNormalizations}} and \code{\link{runNormalizations}} to 
fastly set and run normalizations.
}
