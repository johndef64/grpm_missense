# Nutrigenomics Protein Variant Analysis

## Overview

This project analyzes protein variants in nutrigenomics contexts, focusing on missense variants and their functional consequences. The analysis includes variant annotation, functional family classification, and pathogenicity prediction.

## Project Structure

```
├── README.md                    # This file
├── DESCRIPTION                  # Project metadata
├── quick_run.R                  # Complete analysis pipeline
├── config/
│   └── config.yaml             # Configuration parameters
├── data/
│   └── raw/                    # Raw data files
│   └── processed/              # Processed data files
│   └── external/               # External reference data
├── src/                        # Source code
│   ├── data_acquisition.R      # Data download and preparation
│   ├── data_processing.R       # Data cleaning and processing
│   ├── analysis.R              # Main analysis functions
│   └── visualization.R         # Plotting functions
├── R/                          # Package functions
│   ├── api_functions.R         # API query functions
│   ├── data_functions.R        # Data manipulation functions
│   └── plot_functions.R        # Visualization functions
├── scripts/                    # Analysis scripts
│   ├── 01_setup.R              # Environment setup
│   ├── 02_data_prep.R          # Data preparation
│   ├── 03_analysis.R           # Main analysis
│   └── 04_figures.R            # Figure generation
├── output/
│   ├── figures/                # Generated figures
│   ├── tables/                 # Generated tables
│   └── reports/                # Analysis reports
├── tests/                      # Unit tests
├── docs/                       # Documentation
└── original_code/              # Preserved original code
```

## Requirements

- R (>= 4.0.0)
- Required packages (see DESCRIPTION file)

## Installation

1. Clone or download this repository
2. Open R/RStudio in the project directory
3. Run the analysis - packages will be installed automatically:

```r
source("quick_run.R")
```

## Usage

### Complete Analysis

```r
source("quick_run.R")
```

### Step-by-Step Analysis

```r
source("scripts/01_setup.R")       # Install packages & setup environment
source("scripts/02_data_prep.R")   # Download and prepare datasets  
source("scripts/03_analysis.R")    # Perform variant annotation and analysis
source("scripts/04_figures.R")     # Generate figures and tables
```

## Data Sources

- **GRPM Nutrigenomics Dataset**: Available from Zenodo (DOI: 10.5281/zenodo.14052302)
- **Variant Annotations**: ProtVar (https://www.ebi.ac.uk/ProtVar/)
- **Functional Families**: Pharos API (https://pharos-api.ncats.io/)

## Outputs

- **Table 1**: Summary statistics by topic (`output/tables/Table_1.csv`)
- **Figure 2**: Multi-panel visualization (`output/figures/Figure_2.svg`)

## Manual Steps Required

Some steps require manual intervention:

1. Upload `data/processed/nutrigenint_refsnp_missense.txt` to ProtVar
2. Download annotations with "Mapping with Annotations, including all annotations"
3. Save results as `ProtVar_GrpmNutrigInt_MissenseAnnotations.csv` in `data/external/`

## Contributing

Please ensure all code follows the established structure and includes appropriate documentation.

## License

[Specify license here]

## Citation

[Add citation information here]

## Contact

[Add contact information here]