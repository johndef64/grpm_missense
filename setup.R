# ==============================================================================
# Simple Project Setup
# ==============================================================================
# This is a minimal setup script that just installs packages and loads functions
# Use this if you want to work interactively with the project functions

# Install packages if needed
cat("Checking and installing required packages...\n")
source("install_packages.R")

# Load required libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow) 
  library(biomaRt)
  library(httr)
  library(jsonlite)
  library(patchwork)
  library(yaml)
  library(here)
})

# Set project root
project_root <- here::here()

# Load project functions
source(file.path(project_root, "R", "api_functions.R"))
source(file.path(project_root, "R", "data_functions.R"))
source(file.path(project_root, "R", "plot_functions.R"))

# Load configuration
config <- yaml::read_yaml(file.path(project_root, "config", "config.yaml"))

cat("=====================================\n")
cat("Project setup completed!\n")
cat("- All packages loaded\n") 
cat("- All functions loaded\n")
cat("- Configuration loaded\n")
cat("=====================================\n")
cat("You can now use the project functions interactively.\n")
cat("Or run source('quick_run.R') for the complete pipeline.\n")