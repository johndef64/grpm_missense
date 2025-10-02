# Nutrigenomics Protein Variant Analysis

[![R](https://img.shields.io/badge/R-4.0.0-blue.svg)](https://www.r-project.org/) [![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT) [![Data Source](https://img.shields.io/badge/Data%20Source-Zenodo-blue.svg)](https://doi.org/10.5281/zenodo.14052302) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14052302.svg)](https://doi.org/10.5281/zenodo.14052302)


## Overview

This project analyzes protein variants in nutrigenomics contexts, focusing on missense variants and their functional consequences. The analysis includes variant annotation, functional family classification, and pathogenicity prediction.

## Project Structure

```
├── README.md                      # This file
├── DESCRIPTION                    # Project metadata
├── NAMESPACE                      # R package namespace
├── LICENSE                        # Project license
├── quick_run.R                    # Complete analysis pipeline
├── run_analysis.R                 # Alternative analysis runner
├── setup.R                        # Setup script
├── config/
│   └── config.yaml                # Configuration parameters
├── data/
│   ├── ProtVar_GrpmNutrigInt_...  # Main dataset
│   ├── raw/                       # Raw data files
│   ├── processed/                 # Processed data files
│   └── external/                  # External reference data
├── R/                             # Package functions
│   ├── api_functions.R            # API query functions
│   ├── data_functions.R           # Data manipulation functions
│   └── plot_functions.R           # Visualization functions
├── scripts/                       # Analysis scripts
│   ├── 01_setup.R                 # Environment setup
│   ├── 02_data_prep.R             # Data preparation
│   ├── 03_analysis.R              # Main analysis
│   └── 04_figures.R               # Figure generation
├── output/
│   ├── figures/                   # Generated figures
│   ├── tables/                    # Generated tables
│   └── reports/                   # Analysis reports
├── tests/
│   └── test_functions.R           # Unit tests
└── docs/                          # Documentation
```

## Requirements

- R (>= 4.0.0)
- Required packages (see DESCRIPTION file)

## Installation

1. Clone or download this repository
2. Open R/RStudio in the project directory
3. Run the analysis - packages will be installed automatically:

```r
source("setup.R")
```

## Usage

### Complete Analysis

```r
source("run_analysis.R")
```

### Step-by-Step Analysis

```r
source("scripts/01_setup.R")       # Install packages & setup environment
source("scripts/02_data_prep.R")   # Download and prepare datasets  
source("scripts/03_analysis.R")    # Perform variant annotation and analysis
source("scripts/04_figures.R")     # Generate figures and tables
```

## Data Sources

- **GRPM Nutrigenomics Dataset**: Available from Zenodo ([DOI: 10.5281/zenodo.14052302](https://doi.org/10.5281/zenodo.14052302))
- **Variant Annotations**: ProtVar ([https://www.ebi.ac.uk/ProtVar/](https://www.ebi.ac.uk/ProtVar/))
- **Functional Families**: Pharos API ([https://pharos-api.ncats.io/](https://pharos-api.ncats.io/))

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

MIT License. See the LICENSE file for details.

## Citation

If you use this code or data in your research, please cite our publication:

> De Filippis, G.M.; Monticelli, M.; Hay Mele, B.; Calabrò, V. Missense Variants in Nutrition-Related Genes: A Computational Study. Int. J. Mol. Sci. **2025**, 26, 9619. https://doi.org/10.3390/ijms26199619

## Contact

For any inquiries, please contact:
- Giovanni M. De Filippis - [giovannimaria.defilippis@unina.it](mailto:giovannimaria.defilippis@unina.it)
- Bruno Hay Mele - [bruno.haymele@unina.it](mailto:bruno.haymele@unina.it)
