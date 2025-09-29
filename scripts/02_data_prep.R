# ==============================================================================
# Data Preparation Script
# ==============================================================================
# This script handles data downloading, processing, and preparation for analysis.
# It preserves the original data processing logic while organizing it better.

# Check if setup script has been run
if (!exists("config")) {
  stop("Please run 01_setup.R first to initialize the project environment.")
}

cat("Starting data preparation...\n")

# ==============================================================================
# 1. Download and prepare core dataset
# ==============================================================================

# Define paths
data_raw_path <- file.path(project_root, config$paths$data_raw)
grpm_file_path <- file.path(data_raw_path, "nutrigenetic_dataset", config$data$grpm_file)

# Download dataset if not present
if (!file.exists(grpm_file_path)) {
  cat("Core dataset not found. Downloading from Zenodo...\n")
  
  # Download and extract
  url <- config$data$zenodo_url
  destfile <- file.path(data_raw_path, config$data$zenodo_filename)
  
  download.file(url, destfile, mode = "wb")
  unzip(destfile, exdir = data_raw_path)
  
  # Clean up zip file
  unlink(destfile)
  cat("Dataset downloaded and extracted successfully.\n")
} else {
  cat("Core dataset found. Skipping download.\n")
}

# ==============================================================================
# 2. Load and process GRPM data
# ==============================================================================

cat("Loading GRPM nutrigenomics data...\n")
GrpmNutrigenInt <- arrow::read_parquet(grpm_file_path)

# Get unique RSIDs
rsids <- unique(GrpmNutrigenInt$rsid)
cat("Found", length(rsids), "unique RSIDs in the dataset.\n")

# ==============================================================================
# 3. Variant annotation using BioMart
# ==============================================================================

# Check if annotations already exist
annotations_file <- file.path(project_root, config$paths$data_processed, "variant_annotations.parquet")

if (!file.exists(annotations_file)) {
  cat("Querying BioMart for variant annotations...\n")
  
  # Query BioMart (using original function logic)
  get_variant_annotations <- function(rsids) {
    ensembl <- biomaRt::useEnsembl(biomart = "snp", dataset = config$apis$biomart_dataset)
    biomaRt::getBM(
      attributes = c('refsnp_id', 'chr_name', 'chrom_start', 'consequence_type_tv', 'allele'),
      filters = 'snp_filter',
      values = rsids,
      mart = ensembl
    )
  }
  
  annotations <- get_variant_annotations(rsids)
  
  # Save annotations
  arrow::write_parquet(annotations, annotations_file)
  cat("Variant annotations saved.\n")
} else {
  cat("Loading existing variant annotations...\n")
  annotations <- arrow::read_parquet(annotations_file)
}

# ==============================================================================
# 4. Filter for missense variants
# ==============================================================================

cat("Filtering for missense variants...\n")
missense_only <- annotations %>% 
  dplyr::filter(consequence_type_tv == config$analysis$consequence_filter)

unique_refsnp_missense <- unique(missense_only$refsnp_id)
cat("Found", length(unique_refsnp_missense), "unique missense variants.\n")

# Save missense RSIDs for ProtVar upload
missense_file <- file.path(project_root, config$paths$data_processed, config$data$missense_rsids_file)
writeLines(unique_refsnp_missense, missense_file)

cat("Missense RSIDs saved to:", missense_file, "\n")

# ==============================================================================
# 5. Process ProtVar annotations (if available)
# ==============================================================================

# Check for ProtVar data in different locations
protvar_locations <- c(
  file.path(project_root, "data", paste0(config$data$protvar_base_name, "_PAPER.parquet")),  # Current location
  file.path(project_root, config$paths$data_external, paste0(config$data$protvar_base_name, ".csv")),
  file.path(project_root, config$paths$data_external, paste0(config$data$protvar_base_name, ".parquet"))
)

protvar_data <- NULL
protvar_found <- FALSE

for (location in protvar_locations) {
  if (file.exists(location)) {
    cat("Found ProtVar data at:", location, "\n")
    
    if (grepl("\\.csv$", location)) {
      protvar_data <- readr::read_csv(location, show_col_types = FALSE)
      # Save as parquet for better performance
      parquet_location <- gsub("\\.csv$", ".parquet", location)
      arrow::write_parquet(protvar_data, parquet_location)
    } else {
      protvar_data <- arrow::read_parquet(location)
    }
    
    protvar_found <- TRUE
    break
  }
}

if (!protvar_found) {
  cat("\n=== MANUAL STEP REQUIRED ===\n")
  cat("ProtVar annotations not found. Please follow these steps:\n")
  cat("1. Upload the file", missense_file, "to ProtVar (https://www.ebi.ac.uk/ProtVar/)\n")
  cat("2. Select 'Mapping with Annotations, including all annotations'\n")
  cat("3. Download the results\n")
  cat("4. Save as", paste0(config$data$protvar_base_name, ".csv"), "in", file.path(project_root, config$paths$data_external), "\n")
  cat("5. Re-run this script\n")
  cat("===========================\n")
} else {
  cat("ProtVar data loaded successfully.\n")
}

# ==============================================================================
# 6. Organize data by topics (if ProtVar data available)
# ==============================================================================

if (protvar_found) {
  cat("Organizing data by nutrigenomics topics...\n")
  
  # Split GRPM dataset by topics
  rsids_by_topic <- GrpmNutrigenInt %>%
    dplyr::select(topic, rsid) %>%
    split(.$topic)
  
  # Create nested structure similar to original
  did <- tibble::enframe(rsids_by_topic, name = "name", value = "value") %>%
    dplyr::mutate(dfs = purrr::map(value, function(x) {
      dplyr::filter(protvar_data, ID %in% x$rsid)
    }))
  
  # Save processed data structure
  processed_data_file <- file.path(project_root, config$paths$data_processed, "organized_data.rds")
  saveRDS(did, processed_data_file)
  
  cat("Data organized by topics and saved to:", processed_data_file, "\n")
}

cat("Data preparation completed successfully!\n")

# ==============================================================================
# Summary
# ==============================================================================

cat("\n=== DATA PREPARATION SUMMARY ===\n")
cat("Total RSIDs:", length(rsids), "\n")
cat("Missense variants:", length(unique_refsnp_missense), "\n")
if (protvar_found) {
  cat("ProtVar annotations: Available\n")
  cat("Topics in dataset:", length(unique(GrpmNutrigenInt$topic)), "\n")
} else {
  cat("ProtVar annotations: Manual upload required\n")
}
cat("================================\n")