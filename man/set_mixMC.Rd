% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DA_mixMC.R
\name{set_mixMC}
\alias{set_mixMC}
\title{set_mixMC}
\usage{
set_mixMC(
  assay_name = "counts",
  pseudo_count = 1,
  contrast = NULL,
  ID_variable = NULL,
  expand = TRUE
)
}
\arguments{
\item{assay_name}{the name of the assay to extract from the 
TreeSummarizedExperiment object (default \code{assayName = "counts"}). Not 
used if the input object is a phyloseq.}

\item{pseudo_count}{a positive numeric value for the pseudo-count to be 
added. Default is 1.}

\item{contrast}{character vector with exactly, three elements: a string 
indicating the name of factor whose levels are the conditions to be 
compared, the name of the level of interest, and the name of the other 
level.}

\item{ID_variable}{a character string indicating the name of the variable 
name corresponding to the repeated measures units (e.g., the subject ID).}

\item{expand}{logical, if TRUE create all combinations of input parameters
(default \code{expand = TRUE}).}
}
\value{
A named list contaning the set of parameters for \code{DA_mixMC}
method.
}
\description{
Set the parameters for mixMC sPLS-DA.
}
\examples{
# Set some basic combinations of parameters for mixMC
base_mixMC <- set_mixMC(pseudo_count = 1, contrast = c("group", "B", "A"))
many_mixMC <- set_mixMC(pseudo_count = c(0.1, 0.5, 1), 
    contrast = c("group", "B", "A"))
}
\seealso{
\code{\link{DA_mixMC}}
}
