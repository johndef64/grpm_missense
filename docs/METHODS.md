# Documentation for the Nutrigenomics Protein Analysis Project

## Overview

This document provides detailed information about the analysis methods, data sources, and computational approaches used in this study.

## Data Sources

### 1. GRPM Nutrigenomics Dataset
- **Source**: Zenodo repository (DOI: 10.5281/zenodo.14052302)
- **Description**: Comprehensive dataset of genetic variants associated with nutrigenomics traits
- **Format**: Parquet file containing RSIDs organized by topic
- **Size**: Variable number of variants per topic

### 2. Variant Annotations
- **Source**: Ensembl BioMart SNP database
- **API**: BioMart web service
- **Attributes Retrieved**:
  - Reference SNP ID (refsnp_id)
  - Chromosome name (chr_name)
  - Chromosomal start position (chrom_start)
  - Consequence type (consequence_type_tv)
  - Allele information (allele)

### 3. ProtVar Annotations
- **Source**: EBI ProtVar (https://www.ebi.ac.uk/ProtVar/)
- **Description**: Protein variant effect predictions
- **Processing**: Manual upload of missense variant RSIDs
- **Annotations Include**:
  - FoldX stability predictions
  - AlphaMissense pathogenicity scores
  - Residue function annotations
  - Disease associations

### 4. Functional Family Classifications
- **Source**: Pharos API (https://pharos-api.ncats.io/)
- **Description**: Target Development Level (TDL) and functional family classifications
- **Query Method**: GraphQL API for gene symbols

## Analysis Methods

### 1. Variant Filtering
- **Filter Criterion**: Consequence type = "missense_variant"
- **Rationale**: Focus on variants likely to affect protein function
- **Implementation**: dplyr::filter() on BioMart annotations

### 2. Stability Prediction Analysis (FoldX)
- **Method**: FoldX ddG values from ProtVar
- **Binning Strategy**: 
  - Highly destabilizing: ddG < -4
  - Moderately destabilizing: -4 ≤ ddG < -2
  - Slightly destabilizing: -2 ≤ ddG < 0
  - Slightly stabilizing: 0 ≤ ddG < 2
  - Moderately stabilizing: 2 ≤ ddG < 4
  - Highly stabilizing: ddG ≥ 4
- **Visualization**: Stacked bar plots showing proportion per topic

### 3. Pathogenicity Prediction Analysis (AlphaMissense)
- **Method**: AlphaMissense scores and classifications
- **Categories**:
  - BENIGN: Low pathogenicity (score < 0.34)
  - AMBIGUOUS: Uncertain pathogenicity (0.34 ≤ score < 0.564)
  - PATHOGENIC: High pathogenicity (score ≥ 0.564)
- **Visualization**: Stacked bar plots with color coding

### 4. Functional Family Analysis
- **Method**: Pharos Target Development Level classifications
- **Categories**: Various functional families plus "Other" for unclassified
- **API Queries**: Batch processing with error handling
- **Visualization**: Stacked bar plots showing family distribution

### 5. Statistical Summary
- **Metrics Calculated**:
  - Total SNP count per topic
  - Missense variant count per topic
  - Unique gene count with missense variants
  - Missense/total SNP ratio per topic

## Computational Environment

### Required R Packages
- **Data Manipulation**: tidyverse (dplyr, tidyr, purrr, etc.)
- **Data I/O**: arrow, readr
- **Biological Data**: biomaRt
- **API Communication**: httr, jsonlite
- **Visualization**: ggplot2, patchwork
- **Configuration**: yaml, here

### Performance Considerations
- **Caching**: Analysis results cached as RDS files
- **Parallel Processing**: API queries can be parallelized
- **Memory Usage**: Parquet format for efficient data storage
- **Reproducibility**: Fixed random seeds where applicable

## File Structure

### Input Files
- `grpm_nutrigen_int.parquet`: Main genetic variant dataset
- `ProtVar_*.csv`: Protein variant annotations (manual upload)
- `config.yaml`: Analysis parameters and settings

### Output Files
- `Table_1.csv`: Summary statistics by topic
- `Figure_2.svg/png`: Multi-panel visualization
- `analysis_results.rds`: Complete analysis results
- `organized_data.rds`: Processed input data structure

### Intermediate Files
- `variant_annotations.parquet`: BioMart query results
- `nutrigenint_refsnp_missense.txt`: RSIDs for ProtVar upload
- `temp/analysis_cache/*.rds`: Cached analysis components

## Quality Control

### Data Validation
- **Missing Data Handling**: "N/A" values filtered out consistently
- **Data Type Verification**: Numeric conversions validated
- **API Response Validation**: NULL responses handled gracefully

### Reproducibility Measures
- **Version Control**: All code and configuration tracked
- **Dependency Management**: Package versions specified in DESCRIPTION
- **Configuration Management**: Parameters externalized to YAML
- **Documentation**: Comprehensive inline comments and documentation

## Limitations and Considerations

### Technical Limitations
- **API Rate Limits**: Pharos queries may be rate-limited
- **Manual Steps**: ProtVar upload cannot be automated
- **Network Dependencies**: Requires internet for data download and API queries

### Biological Limitations
- **Prediction Accuracy**: FoldX and AlphaMissense are computational predictions
- **Functional Annotation**: Pharos classifications may be incomplete
- **Variant Context**: Analysis doesn't consider variant combinations or epistasis

