% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotEnrichment.R
\name{plotMutualFindings}
\alias{plotMutualFindings}
\title{plotMutualFindings}
\usage{
plotMutualFindings(enrichment, enrichmentCol, levels_to_plot, n_methods = 1)
}
\arguments{
\item{enrichment}{enrichment object produced by \link{createEnrichment}
function.}

\item{enrichmentCol}{name of the column containing information for enrichment
analysis.}

\item{levels_to_plot}{A character vector containing the levels of the
enrichment variable to plot.}

\item{n_methods}{minimum number of method that mutually find the features.}
}
\value{
a \code{ggplot2} object.
}
\description{
Plot and filter the features which are considered differentially
abundant, simultaneously, by a specified number of methods.
}
\examples{
data("ps_plaque_16S")
data("microbial_metabolism")

# Extract genera from the phyloseq tax_table slot
genera <- phyloseq::tax_table(ps_plaque_16S)[, "GENUS"]
# Genera as rownames of microbial_metabolism data.frame
rownames(microbial_metabolism) <- microbial_metabolism$Genus
# Match OTUs to their metabolism
priorInfo <- data.frame(genera,
    "Type" =  microbial_metabolism[genera, "Type"])
# Unmatched genera becomes "Unknown"
unknown_metabolism <- is.na(priorInfo$Type)
priorInfo[unknown_metabolism, "Type"] <- "Unknown"
priorInfo$Type <- factor(priorInfo$Type)
# Add a more informative names column
priorInfo[, "newNames"] <- paste0(rownames(priorInfo), priorInfo[, "GENUS"])

# Add some normalization/scaling factors to the phyloseq object
my_norm <- setNormalizations(fun = c("norm_edgeR", "norm_CSS"),
   method = c("TMM", "CSS"))
ps_plaque_16S <- runNormalizations(normalization_list = my_norm,
    object = ps_plaque_16S)

# Initialize some limma based methods
my_limma <- set_limma(design = ~ 1 + RSID + HMP_BODY_SUBSITE,
    coef = "HMP_BODY_SUBSITESupragingival Plaque",
    norm = c("TMM", "CSS"))

# Make sure the subject ID variable is a factor
phyloseq::sample_data(ps_plaque_16S)[, "RSID"] <- as.factor(
    phyloseq::sample_data(ps_plaque_16S)[["RSID"]])

# Perform DA analysis
Plaque_16S_DA <- runDA(method_list = my_limma, object = ps_plaque_16S)

# Enrichment analysis
enrichment <- createEnrichment(object = Plaque_16S_DA,
    priorKnowledge = priorInfo, enrichmentCol = "Type", namesCol = "GENUS",
    slot = "pValMat", colName = "adjP", type = "pvalue", direction = "logFC",
    threshold_pvalue = 0.1, threshold_logfc = 1, top = 10, verbose = TRUE)

# Contingency tables
plotContingency(enrichment = enrichment, method = "limma.TMM")
# Barplots
plotEnrichment(enrichment, enrichmentCol = "Type")
# Mutual findings
plotMutualFindings(
    enrichment = enrichment, enrichmentCol = "Type",
    n_methods = 1
)
}
\seealso{
\code{\link{createEnrichment}}, \code{\link{plotEnrichment}}, and
\code{\link{plotContingency}}.
}
