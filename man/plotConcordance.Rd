% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotConcordance.R
\name{plotConcordance}
\alias{plotConcordance}
\title{plotConcordance}
\usage{
plotConcordance(concordance, threshold = NULL, cols = NULL)
}
\arguments{
\item{concordance}{A long format \code{data.frame} produced by
\code{\link{createConcordance}} function.}

\item{threshold}{The threshold for rank (x-axis upper limit if all methods
have a higher number of computed statistics).}

\item{cols}{A named vector containing the color hex codes.}
}
\value{
A 2 elements list of \code{ggplot2} class objects:
\itemize{
    \item{\code{concordanceDendrogram}}{ which contains the
    vertically directioned dendrogram for the methods involved in the
    concordance analysis;}
    \item{\code{concordanceHeatmap}}{ which contains the heatmap of between
    and within method concordances.}}
}
\description{
Produce a list of graphical outputs summarizing the between and
within method concordance.
}
\examples{
data(ps_plaque_16S)

# Balanced design
my_splits <- createSplits(
    object = ps_plaque_16S, varName = "HMP_BODY_SUBSITE", balanced = TRUE,
    paired = "RSID", N = 10 # N = 100 suggested
)

# Make sure the subject ID variable is a factor
phyloseq::sample_data(ps_plaque_16S)[, "RSID"] <- as.factor(
    phyloseq::sample_data(ps_plaque_16S)[["RSID"]])

# Initialize some limma based methods
my_limma <- set_limma(design = ~ RSID + HMP_BODY_SUBSITE, 
    coef = "HMP_BODY_SUBSITESupragingival Plaque",
    norm = c("TMM", "CSS"))

# Set the normalization methods according to the DA methods
my_norm <- setNormalizations(fun = c("norm_edgeR", "norm_CSS"),
    method = c("TMM", "CSS"))

# Run methods on split datasets
results <- runSplits(split_list = my_splits, method_list = my_limma,
    normalization_list = my_norm, object = ps_plaque_16S)

# Concordance for p-values
concordance_pvalues <- createConcordance(
    object = results, slot = "pValMat", colName = "rawP", type = "pvalue"
)

# plot concordances from rank 1 to 50.
plotConcordance(
    concordance = concordance_pvalues,
    threshold = 50
)
}
\seealso{
\code{\link{createConcordance}}
}
