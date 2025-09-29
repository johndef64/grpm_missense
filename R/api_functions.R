#' Query Pharos API for protein functional family information
#'
#' @param sym Character. Gene symbol to query
#' @return tibble with sym and family columns
#' @export
#' @examples
#' \dontrun{
#' query_pharos_api("TP53")
#' }
query_pharos_api <- function(sym) {
  query <- list(query = sprintf('query { target(q:{sym:"%s"}) { fam sym } }',
                                sym)
  )
  
  res <- httr::POST(
    url = "https://pharos-api.ncats.io/graphql",
    body = query,
    encode = "json"
  )
  
  data <- httr::content(res, as = "parsed", simplifyVector = TRUE)$data$target
  
  if (is.null(data))  return(tibble::tibble(sym = sym, family = NA_character_))
  
  tibble::tibble(
    sym    = data$sym,
    family = data$fam
  )
}

#' Get variant annotations from BioMart
#'
#' @param rsids Character vector of RSIDs to query
#' @return data.frame with variant annotations
#' @export
get_variant_annotations <- function(rsids) {
  ensembl <- biomaRt::useEnsembl(biomart = "snp", dataset = "hsapiens_snp")
  biomaRt::getBM(
    attributes = c('refsnp_id', 'chr_name', 'chrom_start', 'consequence_type_tv', 'allele'),
    filters = 'snp_filter',
    values = rsids,
    mart = ensembl
  )
}

#' Batch query Pharos API for multiple gene symbols
#'
#' @param gene_df data.frame containing Gene column
#' @return data.frame with gene symbols and families
#' @export
batch_query_pharos <- function(gene_df) {
  gene_df %>%
    dplyr::select(Gene) %>%
    dplyr::distinct() %>%
    dplyr::mutate(api_response = purrr::map(Gene, query_pharos_api)) %>%
    tidyr::unnest(api_response)
}