# ==============================================================================
# Analysis Script
# ==============================================================================
# This script performs the main analysis including variant effect prediction,
# functional annotation, and statistical summaries.

# Check if setup and data prep have been run
if (!exists("config")) {
  stop("Please run 01_setup.R first to initialize the project environment.")
}

cat("Starting main analysis...\n")

# ==============================================================================
# Load processed data
# ==============================================================================

processed_data_file <- file.path(project_root, config$paths$data_processed, "organized_data.rds")

if (!file.exists(processed_data_file)) {
  stop("Processed data not found. Please run 02_data_prep.R first.")
}

did <- readRDS(processed_data_file)
cat("Loaded organized data with", nrow(did), "topics.\n")

# ==============================================================================
# Define analysis functions (preserved from original)
# ==============================================================================

# Function for extracting catalytic activity to residues
extract_residue_functions <- function(x) {
  x %>% 
    tidyr::separate(`Residue_function_(evidence)`,
             into=c("use","dum"), sep = "-", extra="merge") %>%
    dplyr::count(Protein_catalytic_activity, use, sort=TRUE)
}

# Function for extracting the foldX value (stability prediction)
extract_foldx_predictions <- function(x) {
  x %>%
    dplyr::select(`Foldx_prediction(foldxDdg;plddt)`) %>%
    tidyr::separate(`Foldx_prediction(foldxDdg;plddt)`,
             into = c("fx","plddt"), sep=";") %>%
    dplyr::select(fx) %>%
    dplyr::filter(fx != "N/A") %>%
    dplyr::mutate(fx = gsub("foldxDdg:","",fx)) %>%
    dplyr::mutate(fx = as.numeric(fx))
}

# Function for extracting disease associations
extract_disease_associations <- function(x) {
  x %>% 
    dplyr::select(dav = Diseases_associated_with_variant) %>%
    tidyr::separate_rows(dav, sep="\\|") %>%
    tidyr::separate(dav, into =c("one","dum"), sep = "-\\(", extra="merge") %>%
    dplyr::select(one) %>%
    dplyr::distinct()
}

# Function for extracting AlphaMissense scores
extract_alphamissense_scores <- function(x) {
  x %>%
    dplyr::select(am=`AlphaMissense_pathogenicity(class)`) %>%
    dplyr::filter(am != "N/A") %>%
    tidyr::separate(am, into = c("score","class"),sep ="\\(") %>%
    dplyr::mutate(score=as.numeric(score), class=gsub(")$","",class))  
}

# Function for querying Pharos API
query_pharos_api <- function(sym) {
  query <- list(query = sprintf('query { target(q:{sym:"%s"}) { fam sym } }', sym))
  
  res <- httr::POST(
    url = config$apis$pharos_graphql,
    body = query,
    encode = "json"
  )
  
  data <- httr::content(res, as = "parsed", simplifyVector = TRUE)$data$target
  
  if (is.null(data)) return(tibble::tibble(sym = sym, family = NA_character_))
  
  tibble::tibble(
    sym    = data$sym,
    family = data$fam
  )
}

# Function for batch Pharos queries
batch_query_pharos <- function(x) {
  x %>%
    dplyr::select(Gene) %>%
    dplyr::distinct() %>%
    dplyr::mutate(api_response = purrr::map(Gene, query_pharos_api)) %>%
    tidyr::unnest(api_response)
}

# ==============================================================================
# Perform analyses
# ==============================================================================

cat("Performing variant effect analyses...\n")

# Check if analysis results already exist
analysis_results_dir <- file.path(project_root, config$paths$temp_data, "analysis_cache")
if (!dir.exists(analysis_results_dir)) {
  dir.create(analysis_results_dir, recursive = TRUE)
}

# Residue function analysis
residue_file <- file.path(analysis_results_dir, "residue_analysis.rds")
if (!file.exists(residue_file)) {
  cat("Analyzing residue functions...\n")
  residue_analysis <- did %>%
    dplyr::mutate(residue_data = purrr::map(dfs, extract_residue_functions))
  saveRDS(residue_analysis, residue_file)
} else {
  residue_analysis <- readRDS(residue_file)
}

# FoldX analysis
foldx_file <- file.path(analysis_results_dir, "foldx_analysis.rds")
if (!file.exists(foldx_file)) {
  cat("Analyzing FoldX predictions...\n")
  foldx_analysis <- did %>%
    dplyr::mutate(fix = purrr::map(dfs, extract_foldx_predictions))
  saveRDS(foldx_analysis, foldx_file)
} else {
  foldx_analysis <- readRDS(foldx_file)
}

# Disease association analysis
disease_file <- file.path(analysis_results_dir, "disease_analysis.rds")
if (!file.exists(disease_file)) {
  cat("Analyzing disease associations...\n")
  disease_analysis <- did %>%
    dplyr::mutate(disease_data = purrr::map(dfs, extract_disease_associations))
  saveRDS(disease_analysis, disease_file)
} else {
  disease_analysis <- readRDS(disease_file)
}

# AlphaMissense analysis
alphamissense_file <- file.path(analysis_results_dir, "alphamissense_analysis.rds")
if (!file.exists(alphamissense_file)) {
  cat("Analyzing AlphaMissense predictions...\n")
  alphamissense_analysis <- did %>%
    dplyr::mutate(am = purrr::map(dfs, extract_alphamissense_scores))
  saveRDS(alphamissense_analysis, alphamissense_file)
} else {
  alphamissense_analysis <- readRDS(alphamissense_file)
}

# Pharos functional family analysis
pharos_file <- file.path(analysis_results_dir, "pharos_analysis.rds")
if (!file.exists(pharos_file)) {
  cat("Querying Pharos for functional families...\n")
  pharos_analysis <- did %>%
    dplyr::mutate(fam = purrr::map(dfs, batch_query_pharos))
  saveRDS(pharos_analysis, pharos_file)
} else {
  pharos_analysis <- readRDS(pharos_file)
}

# ==============================================================================
# Create summary table (Table 1)
# ==============================================================================

cat("Creating summary statistics table...\n")

tab1 <- did %>%
  dplyr::mutate(
    snp_count = purrr::map_int(value, nrow),
    missense_count = purrr::map_int(dfs, nrow),
    miss_gene_count = purrr::map_int(dfs, function(x) dplyr::n_distinct(x$Gene)),
    missense_snp_ratio = round(missense_count/snp_count, 2)
  ) %>%
  dplyr::select(-value, -dfs)

# Save Table 1
table1_file <- file.path(project_root, config$paths$output_tables, "Table_1.csv")
readr::write_csv(tab1, table1_file)

cat("Table 1 saved to:", table1_file, "\n")

# ==============================================================================
# Save analysis results for plotting
# ==============================================================================

# Combine all analysis results
analysis_results <- list(
  residue = residue_analysis,
  foldx = foldx_analysis,
  disease = disease_analysis,
  alphamissense = alphamissense_analysis,
  pharos = pharos_analysis,
  summary = tab1
)

analysis_results_file <- file.path(project_root, config$paths$data_processed, "analysis_results.rds")
saveRDS(analysis_results, analysis_results_file)

cat("Analysis results saved to:", analysis_results_file, "\n")

# ==============================================================================
# Analysis Summary
# ==============================================================================

cat("\n=== ANALYSIS SUMMARY ===\n")
cat("Topics analyzed:", nrow(tab1), "\n")
cat("Total SNPs:", sum(tab1$snp_count), "\n")
cat("Total missense variants:", sum(tab1$missense_count), "\n")
cat("Total genes with missense variants:", sum(tab1$miss_gene_count), "\n")
cat("Average missense ratio:", round(mean(tab1$missense_snp_ratio), 3), "\n")

# Display topic-wise summary
cat("\nTopic-wise summary:\n")
print(tab1)

cat("========================\n")
cat("Analysis completed successfully!\n")