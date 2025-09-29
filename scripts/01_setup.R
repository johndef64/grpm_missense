# ==============================================================================
# Project Setup and Configuration
# ==============================================================================

# Install packages if not available
required_packages <- c("arrow", "biomaRt", "httr", "jsonlite", "tidyverse", 
                      "patchwork", "yaml", "here")

# Install CRAN packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) {
  install.packages(new_packages, dependencies = TRUE)
}

# Install biomaRt from Bioconductor if needed
if(!requireNamespace("biomaRt", quietly = TRUE)) {
  if(!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("biomaRt", update = FALSE)
}

# Load required libraries
suppressPackageStartupMessages({
  library(arrow)
  library(biomaRt)
  library(httr)
  library(jsonlite)
  library(tidyverse)
  library(patchwork)
  library(yaml)
  library(here)
})

# Set up project root directory
project_root <- here::here()

# Load configuration
config <- yaml::read_yaml(file.path(project_root, "config", "config.yaml"))

# Create directory structure if it doesn't exist
dirs_to_create <- c(
  file.path(project_root, config$paths$data_raw),
  file.path(project_root, config$paths$data_processed),
  file.path(project_root, config$paths$data_external),
  file.path(project_root, config$paths$output_figures),
  file.path(project_root, config$paths$output_tables),
  file.path(project_root, config$paths$output_reports),
  file.path(project_root, config$paths$temp_data)
)

for (dir in dirs_to_create) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    message("Created directory: ", dir)
  }
}

# Source custom functions
source(file.path(project_root, "R", "api_functions.R"))
source(file.path(project_root, "R", "data_functions.R"))
source(file.path(project_root, "R", "plot_functions.R"))

# Display project information
cat("=====================================\n")
cat("Nutrigenomics Protein Analysis Setup\n")
cat("=====================================\n")
cat("Project root:", project_root, "\n")
cat("R version:", R.version.string, "\n")
cat("Configuration loaded successfully\n")
cat("Functions loaded successfully\n")
cat("=====================================\n")

# Set options for better output
options(
  stringsAsFactors = FALSE,
  readr.num_columns = 0,
  pillar.min_title_chars = 15
)