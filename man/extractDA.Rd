% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{extractDA}
\alias{extractDA}
\title{extractDA}
\usage{
extractDA(
  object,
  slot = "pValMat",
  colName = "adjP",
  type = "pvalue",
  direction = NULL,
  threshold_pvalue = 1,
  threshold_logfc = 0,
  top = NULL,
  verbose = FALSE
)
}
\arguments{
\item{object}{Output of differential abundance detection methods.
\code{pValMat}, \code{statInfo} matrices, and method's \code{name} must be
present (See vignette for detailed information).}

\item{slot}{A character vector with 1 or number-of-methods-times repeats of
the slot names where to extract values for each method
(default \code{slot = "pValMat"}).}

\item{colName}{A character vector with 1 or number-of-methods-times repeats
of the column name of the slot where to extract values for each method
(default \code{colName = "rawP"}).}

\item{type}{A character vector with 1 or number-of-methods-times repeats
of the value type of the column selected where to extract values for each
method. Two values are possible: \code{"pvalue"} or \code{"logfc"}
(default \code{type = "pvalue"}).}

\item{direction}{A character vector with 1 or number-of-methods-times repeats
of the \code{statInfo}'s column name containing information about the signs
of differential abundance (usually log fold changes) for each method
(default \code{direction = NULL}).}

\item{threshold_pvalue}{A single or a numeric vector of thresholds for
p-values. If present, features with p-values lower than
\code{threshold_pvalue} are considered differentially abundant. Set
\code{threshold_pvalue = 1} to not filter by p-values.}

\item{threshold_logfc}{A single or a numeric vector of thresholds for log
fold changes. If present, features with log fold change absolute values
higher than \code{threshold_logfc} are considered differentially abundant.
Set \code{threshold_logfc = 0} to not filter by log fold change values.}

\item{top}{If not null, the \code{top} number of features, ordered by
p-values or log fold change values, are considered as differentially
abundant (default \code{top = NULL}).}

\item{verbose}{Boolean to display the kind of extracted values
(default \code{verbose = FALSE}).}
}
\value{
A \code{data.frame} with several columns for each method:
\itemize{
    \item{\code{stat}}{ which contains the p-values or the absolute log fold
    change values;}
    \item{\code{direction}}{ which is present if \code{direction} was
    supplied, it contains the information about directionality of
    differential abundance (usually log fold changes);}
    \item{\code{DA}}{ which can contain several values according to
    thresholds and inputs. \code{"DA"} or \code{"non-DA"} if
    \code{direction = NULL}, \code{"UP Abundant"}, \code{"DOWN Abundant"}, or
    \code{"non-DA"} otherwise.}}
}
\description{
Inspect the list of p-values or/and log fold changes from the output of
differential abundance detection methods.
}
\examples{
data("ps_plaque_16S")
# Add scaling factors
my_norm <- setNormalizations(fun = c("norm_edgeR", "norm_CSS"),
    method = c("TMM", "CSS"))
ps_plaque_16S <- runNormalizations(normalization_list = my_norm,
    object = ps_plaque_16S)
# Perform DA analysis
my_methods <- set_limma(design = ~ 1 + HMP_BODY_SUBSITE, coef = 2,
    norm = c("TMM", "CSS"))
Plaque_16S_DA <- runDA(method_list = my_methods, object = ps_plaque_16S)
# Top 10 features (ordered by 'direction') are DA
DA_1 <- extractDA(
    object = Plaque_16S_DA, slot = "pValMat", colName = "adjP",
    type = "pvalue", direction = "logFC", threshold_pvalue = 1,
    threshold_logfc = 0, top = 10
)
# Features with p-value < 0.05 and |logFC| > 1 are DA
DA_2 <- extractDA(
    object = Plaque_16S_DA, slot = "pValMat", colName = "adjP",
    type = "pvalue", direction = "logFC", threshold_pvalue = 0.05,
    threshold_logfc = 1, top = NULL
)
}
\seealso{
\code{\link{getDA}}, \code{\link{extractStatistics}}
}
