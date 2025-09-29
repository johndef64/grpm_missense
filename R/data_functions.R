#' Extract residue function annotations
#'
#' @param data data.frame containing variant data
#' @return data.frame with residue function counts
#' @export
extract_residue_functions <- function(data) {
  data %>% 
    tidyr::separate(`Residue_function_(evidence)`,
             into=c("use","dum"), sep = "-", extra="merge") %>%
    dplyr::count(Protein_catalytic_activity, use, sort=TRUE)
}

#' Extract FoldX stability predictions
#'
#' @param data data.frame containing variant data
#' @return data.frame with FoldX ddG values
#' @export
extract_foldx_predictions <- function(data) {
  data %>%
    dplyr::select(`Foldx_prediction(foldxDdg;plddt)`) %>%
    tidyr::separate(`Foldx_prediction(foldxDdg;plddt)`,
             into = c("fx","plddt"), sep=";") %>%
    dplyr::select(fx) %>%
    dplyr::filter(fx != "N/A") %>%
    dplyr::mutate(fx = gsub("foldxDdg:","",fx)) %>%
    dplyr::mutate(fx = as.numeric(fx))
}

#' Extract disease associations from variants
#'
#' @param data data.frame containing variant data
#' @return data.frame with disease associations
#' @export
extract_disease_associations <- function(data) {
  data %>% 
    dplyr::select(dav = Diseases_associated_with_variant) %>%
    tidyr::separate_rows(dav, sep="\\|") %>%
    tidyr::separate(dav, into =c("one","dum"), sep = "-\\(", extra="merge") %>%
    dplyr::select(one) %>%
    dplyr::distinct()
}

#' Extract AlphaMissense pathogenicity scores
#'
#' @param data data.frame containing variant data
#' @return data.frame with AlphaMissense scores and classifications
#' @export
extract_alphamissense_scores <- function(data) {
  data %>%
    dplyr::select(am=`AlphaMissense_pathogenicity(class)`) %>%
    dplyr::filter(am != "N/A") %>%
    tidyr::separate(am, into = c("score","class"),sep ="\\(") %>%
    dplyr::mutate(score=as.numeric(score), class=gsub(")$","",class))  
}

#' Filter data for specific rsids
#'
#' @param protvar_data data.frame containing ProtVar data
#' @param rsid_list vector of RSIDs to filter
#' @return filtered data.frame
#' @export
filter_by_rsids <- function(protvar_data, rsid_list) {
  dplyr::filter(protvar_data, ID %in% rsid_list)
}

#' Create summary statistics table
#'
#' @param topic_data nested data.frame with topics and variant data
#' @return data.frame with summary statistics
#' @export
create_summary_table <- function(topic_data) {
  topic_data %>%
    dplyr::mutate(
      snp_count = purrr::map_int(value, nrow),
      missense_count = purrr::map_int(dfs, nrow),
      miss_gene_count = purrr::map_int(dfs, function(x) dplyr::n_distinct(x$Gene)),
      missense_snp_ratio = round(missense_count/snp_count, 2)
    ) %>%
    dplyr::select(-value, -dfs) 
}