#' @title DA_ANCOM
#'
#' @importFrom ANCOMBC ancom ancombc
#' @importFrom SummarizedExperiment assays
#' @importFrom phyloseq otu_table sample_data phyloseq taxa_are_rows
#' @export
#' @description
#' Fast run for ANCOM and ANCOM-BC differential abundance detection methods.
#'
#' @inheritParams DA_edgeR
#' @param formula Used when \code{BC = TRUE}, the character string expresses 
#' how the microbial absolute abundances for each taxon depend on the variables 
#' in metadata.
#' @param adj_formula Used when \code{BC = FALSE}. Character string 
#' representing the formula for covariate adjustment. Default is NULL.
#' @param rand_formula Used when \code{BC = FALSE}. Character string 
#' representing the formula for random effects. For details, see ?nlme::lme. 
#' Default is NULL.
#' @param lme_control Used when \code{BC = FALSE} A list specifying control 
#' values for lme fit. For details, see ?nlme::lmeControl. Default is NULL.
#' @param contrast character vector with exactly, three elements: a string 
#' indicating the name of factor whose levels are the conditions to be 
#' compared, the name of the level of interest, and the name of the other 
#' level. 
#' @param BC boolean for ANCOM method to use. If TRUE the bias correction 
#' (ANCOM-BC) is computed (default \code{BC = TRUE}). When \code{BC = FALSE} 
#' computational time may increase and p-values are not computed.
#' @inheritParams ANCOMBC::ancombc
#'
#' @return A list object containing the matrix of p-values `pValMat`,
#' a matrix of summary statistics for each tag `statInfo`, and a suggested 
#' `name` of the final object considering the parameters passed to the 
#' function. ANCOM (BC = FALSE) does not produce p-values but W statistics. 
#' Hence, `pValMat` matrix is filled with \code{1 - W / (nfeatures - 1)} values 
#' which are not p-values. To find DA features a threshold on this statistic 
#' can be used (liberal < 0.4, < 0.3, < 0.2, < 0.1 conservative).
#'
#' @seealso \code{\link[ANCOMBC]{ancombc}} for analysis of microbiome 
#' compositions with bias correction or without it 
#' \code{\link[ANCOMBC]{ancom}}.
#'
#' @examples
#' set.seed(1)
#' # Create a very simple phyloseq object
#' counts <- matrix(rnbinom(n = 60, size = 3, prob = 0.5), nrow = 10, ncol = 6)
#' metadata <- data.frame("Sample" = c("S1", "S2", "S3", "S4", "S5", "S6"),
#'                        "group" = as.factor(c("A", "A", "A", "B", "B", "B")))
#' ps <- phyloseq::phyloseq(phyloseq::otu_table(counts, taxa_are_rows = TRUE),
#'                          phyloseq::sample_data(metadata))
#' # Differential abundance
#' DA_ANCOM(object = ps, pseudo_count = FALSE, formula = "group", contrast =
#'    c("group", "B", "A"), verbose = FALSE)

DA_ANCOM <- function(object, assay_name = "counts", pseudo_count = FALSE, 
    formula = NULL, adj_formula = NULL, rand_formula = NULL, 
    lme_control = NULL, contrast = NULL, p_adj_method = "BH", 
    struc_zero = FALSE, BC = TRUE, verbose = TRUE){
    counts_and_metadata <- get_counts_metadata(object, assay_name = assay_name)
    counts <- counts_and_metadata[[1]]
    metadata <- counts_and_metadata[[2]]
    is_phyloseq <- counts_and_metadata[[3]]
    # Name building
    name <- "ANCOM"
    method <- "DA_ANCOM"
    # add 1 if any zero counts
    if (any(counts == 0) & pseudo_count){
        message("Adding a pseudo count... \n")
        counts <- counts + 1
        name <- paste(name, ".pseudo", sep = "")
    }
    # Check the assay
    if (!is_phyloseq){
        if(verbose)
            message("Using the ", assay_name, " assay.")
        name <- paste(name, ".", assay_name, sep = "")
    } 
    # If ANCOM_BC is used
    if(BC){
        name <- paste(name, ".", "BC", sep = "")
        # Check if the formula is a character
        if (!is.character(formula)) {
            stop(method, "\n", 
                 "Please specify 'formula' as a character object.")
        }
    } # If BC is FALSE there is no need to check formulas, they are optional
    if(!is.character(contrast) | length(contrast) != 3)
        stop(method, "\n", 
             "contrast: please supply a character vector with exactly", 
             " three elements: the name of a variable used in",  
             " 'design', the name of the level of interest, and the", 
             " name of the reference level.")
    if(is.element(contrast[1], colnames(metadata))){
        if(!is.factor(metadata[, contrast[1]])){
            if(verbose){
                message("Converting variable ", contrast[1], " to factor.")
            }
            metadata[, contrast[1]] <- as.factor(metadata[, contrast[1]])
        }
        if(!is.element(contrast[2], levels(metadata[, contrast[1]])) | 
           !is.element(contrast[3], levels(metadata[, contrast[1]]))){
            stop(method, "\n", 
                 "contrast: ", contrast[2], " and/or ", contrast[3], 
                 " are not levels of ", contrast[1], " variable.")
        }
        if(verbose){
            message("Setting ", contrast[3], " the reference level for ", 
                    contrast[1], " variable.")
        }
        metadata[, contrast[1]] <- stats::relevel(metadata[, contrast[1]], 
            ref = contrast[3])
    }
    phyloseq_obj <- phyloseq::phyloseq(
        otu_table = phyloseq::otu_table(counts, taxa_are_rows = TRUE),
        sample_data = phyloseq::sample_data(as.data.frame(metadata))
    )
    if(struc_zero){ # Add struc_zero to the name
        name <- paste(name, ".", "struc_zero", sep = "")
    }
    # If the sample size is large enough, set neg_lb to TRUE 
    neg_lb <- ifelse(min(table(metadata[, contrast[1]])) > 30, TRUE, FALSE)
    if(verbose){
        if(BC){
            res <- ancombc(phyloseq = phyloseq_obj, formula = formula, 
                p_adj_method = p_adj_method, prv_cut = 0, lib_cut = 0, 
                group = contrast[1], struc_zero = struc_zero, neg_lb = neg_lb)
        } else {
            res <- ancom(phyloseq = phyloseq_obj, adj_formula = adj_formula, 
                rand_formula = rand_formula, lme_control = lme_control,
                p_adj_method = p_adj_method, prv_cut = 0, lib_cut = 0, 
                main_var = contrast[1], struc_zero = struc_zero, 
                neg_lb = neg_lb)
        }
    } else {
        if(BC){
            res <- suppressWarnings(ancombc(
                phyloseq = phyloseq_obj, formula = formula, 
                p_adj_method = p_adj_method, prv_cut = 0, lib_cut = 0, 
                group = contrast[1], struc_zero = struc_zero, neg_lb = neg_lb))
        } else {
            res <- suppressWarnings(
                ancom(phyloseq = phyloseq_obj, adj_formula = adj_formula, 
                    rand_formula = rand_formula, lme_control = lme_control,
                    p_adj_method = p_adj_method, prv_cut = 0, lib_cut = 0, 
                    main_var = contrast[1], struc_zero = struc_zero, 
                    neg_lb = neg_lb))
        }
    }
    statInfo <- as.data.frame(res[["res"]])
    colnames(statInfo) <- names(res[["res"]])
    if(BC){
        pValMat <- statInfo[,c("p_val", "q_val")]
    } else {
        pValMat <- 1 - (statInfo[, c("W", "W")] / (nrow(statInfo) - 1))
    }
    colnames(pValMat) <- c("rawP", "adjP")
    rownames(statInfo) <- rownames(pValMat) <- rownames(counts)
    return(list("pValMat" = pValMat, "statInfo" = statInfo, "name" = name))
}# END - function: DA_ANCOM

#' @title set_ANCOM
#'
#' @export
#' @description
#' Set the parameters for ANCOM differential abundance detection method.
#'
#' @inheritParams DA_ANCOM
#' @param expand logical, if TRUE create all combinations of input parameters
#' (default \code{expand = TRUE}).
#'
#' @return A named list containing the set of parameters for \code{DA_ANCOM}
#' method.
#'
#' @seealso \code{\link{DA_ANCOM}}
#'
#' @examples
#' # Set some basic combinations of parameters for ANCOM with bias correction
#' base_ANCOMBC <- set_ANCOM(pseudo_count = FALSE, formula = "group", 
#' contrast = c("group", "B", "A"), BC = TRUE, expand = FALSE)
#' many_ANCOMs <- set_ANCOM(pseudo_count = c(TRUE, FALSE), formula = "group",
#'    contrast = c("group", "B", "A"), struc_zero = c(TRUE, FALSE),
#'    BC = c(TRUE, FALSE))
set_ANCOM <- function(assay_name = "counts", pseudo_count = FALSE, 
    formula = NULL, adj_formula = NULL, rand_formula = NULL, 
    lme_control = NULL, contrast = NULL, p_adj_method = "BH", 
    struc_zero = FALSE, BC = TRUE, expand = TRUE) {
    method <- "DA_ANCOM"
    if (is.null(assay_name)) {
        stop(method, "\n", "'assay_name' is required (default = 'counts').")
    }
    if (!is.logical(pseudo_count) | !is.logical(struc_zero) | 
        !is.logical(BC)) {
        stop(method, "\n", 
            "'pseudo_count', 'struc_zero', and 'BC' must be logical.")
    }
    if(!is.null(formula)){
        if (!is.character(formula)){
            stop(method, "\n", "'formula' should be a character.")
        }
    }
    if(!is.null(adj_formula)){
        if (!is.character(adj_formula)){
            stop(method, "\n", "'adj_formula' should be a character.")
        }
    }
    if(!is.null(rand_formula)){
        if (!is.character(rand_formula)){
            stop(method, "\n", "'rand_formula' should be a character.")
        }
    }
    if (is.null(contrast)) {
        stop(method, "\n", "'contrast' must be specified.")
    }
    if (!is.character(contrast) & length(contrast) != 3){
        stop(method, "\n", 
             "contrast: please supply a character vector with exactly", 
             " three elements: a string indicating the name of factor whose",
             " levels are the conditions to be compared,",  
             " the name of the level of interest, and the", 
             " name of the other level.")
    }
    if (expand) {
        parameters <- expand.grid(method = method, assay_name = assay_name, 
            pseudo_count = pseudo_count, p_adj_method = p_adj_method, 
            struc_zero = struc_zero, BC = BC, stringsAsFactors = FALSE)
    } else {
        message("Some parameters may be duplicated to fill the matrix.")
        parameters <- data.frame(method = method, assay_name = assay_name, 
            pseudo_count = pseudo_count, p_adj_method = p_adj_method, 
            struc_zero = struc_zero, BC = BC)
    }
    # data.frame to list
    out <- plyr::dlply(.data = parameters, .variables = colnames(parameters))
    out <- lapply(X = out, FUN = function(x){
        if(x[["BC"]]){
            x <- append(x = x, values = list("formula" = formula, 
                "contrast" = contrast), after = 3)
        } else {
            x <- append(x = x, values = list("adj_formula" = adj_formula, 
                "rand_formula" = rand_formula, "lme_control" = lme_control,
                "contrast" = contrast), after = 3)
        }
    })
    names(out) <- paste0(method, ".", seq_along(out))
    return(out)
}