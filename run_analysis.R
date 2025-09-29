# ==============================================================================
# Main Analysis Pipeline
# ==============================================================================
# This script runs the complete analysis pipeline for the Nutrigenomics 
# Protein Variant Analysis project.
#
# Usage: source("run_analysis.R")
#
# The pipeline consists of four main steps:
# 1. Project setup and configuration
# 2. Data preparation and downloading
# 3. Main analysis (variant annotation and functional analysis)
# 4. Figure generation and output creation

cat("=====================================\n")
cat("Nutrigenomics Protein Analysis Pipeline\n")
cat("=====================================\n")

# Record start time
start_time <- Sys.time()

# ==============================================================================
# Step 1: Project Setup
# ==============================================================================

cat("\n[Step 1/4] Setting up project environment...\n")
source("scripts/01_setup.R")

# ==============================================================================
# Step 2: Data Preparation  
# ==============================================================================

cat("\n[Step 2/4] Preparing data...\n")
source("scripts/02_data_prep.R")

# Check if manual ProtVar step is needed
if (!exists("protvar_found") || !protvar_found) {
  cat("\n*** PIPELINE PAUSED ***\n")
  cat("Manual step required for ProtVar annotations.\n")
  cat("Please complete the ProtVar upload as instructed above,\n")
  cat("then re-run this script to continue.\n")
  cat("***********************\n")
  stop("Manual intervention required.")
}

# ==============================================================================
# Step 3: Main Analysis
# ==============================================================================

cat("\n[Step 3/4] Running main analysis...\n")
source("scripts/03_analysis.R")

# ==============================================================================
# Step 4: Figure Generation
# ==============================================================================

cat("\n[Step 4/4] Generating figures...\n")
source("scripts/04_figures.R")

# ==============================================================================
# Pipeline Summary
# ==============================================================================

end_time <- Sys.time()
total_time <- difftime(end_time, start_time, units = "mins")

cat("\n=====================================\n")
cat("ANALYSIS PIPELINE COMPLETED\n")
cat("=====================================\n")
cat("Total runtime:", round(as.numeric(total_time), 2), "minutes\n")
cat("Start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("End time:  ", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")

# Summary of outputs
outputs_summary <- data.frame(
  File = c(
    "Table_1.csv",
    "Figure_2.svg",
    "Figure_2.png",
    "analysis_results.rds",
    "organized_data.rds"
  ),
  Location = c(
    "output/tables/",
    "output/figures/svg/",
    "output/figures/png/",
    "data/processed/",
    "data/processed/"
  ),
  Description = c(
    "Summary statistics by topic",
    "Main figure (vector format)",
    "Main figure (raster format)", 
    "Complete analysis results",
    "Organized input data"
  )
)

cat("\nKey outputs generated:\n")
print(outputs_summary, row.names = FALSE)

cat("\n=====================================\n")
cat("Analysis completed successfully!\n")
cat("All outputs are ready for manuscript preparation.\n")
cat("=====================================\n")