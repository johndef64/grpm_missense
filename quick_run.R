# ==============================================================================
# Quick Run - Complete Analysis Pipeline
# ==============================================================================

cat("=====================================\n")
cat("Nutrigenomics Protein Analysis\n") 
cat("=====================================\n")

# Run analysis pipeline
source("scripts/01_setup.R")
source("scripts/02_data_prep.R")
source("scripts/03_analysis.R")
source("scripts/04_figures.R")

cat("=====================================\n")
cat("Analysis completed!\n")
cat("=====================================\n")