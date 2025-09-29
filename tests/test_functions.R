# Tests for Nutrigenomics Protein Analysis Functions

# Set up test environment
library(testthat)
library(dplyr)
library(tibble)

# Source functions to test
if (file.exists("R/api_functions.R")) {
  source("R/api_functions.R")
}

if (file.exists("R/data_functions.R")) {
  source("R/data_functions.R")
}

# ==============================================================================
# Test API Functions
# ==============================================================================

test_that("query_pharos_api returns correct structure", {
  skip_if_offline()
  skip_on_cran()
  
  result <- query_pharos_api("TP53")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(ncol(result), 2)
  expect_true("sym" %in% names(result))
  expect_true("family" %in% names(result))
})

test_that("query_pharos_api handles invalid symbols", {
  skip_if_offline()
  skip_on_cran()
  
  result <- query_pharos_api("INVALID_GENE_SYMBOL_12345")
  
  expect_s3_class(result, "tbl_df")
  expect_equal(result$sym, "INVALID_GENE_SYMBOL_12345")
  expect_true(is.na(result$family))
})

# ==============================================================================
# Test Data Functions
# ==============================================================================

test_that("extract_foldx_predictions processes data correctly", {
  # Create test data
  test_data <- tibble(
    `Foldx_prediction(foldxDdg;plddt)` = c(
      "foldxDdg:1.5;plddt:80",
      "foldxDdg:-2.3;plddt:75",
      "N/A",
      "foldxDdg:0.8;plddt:90"
    )
  )
  
  result <- extract_foldx_predictions(test_data)
  
  expect_equal(nrow(result), 3)  # N/A should be filtered out
  expect_true(all(is.numeric(result$fx)))
  expect_equal(result$fx, c(1.5, -2.3, 0.8))
})

test_that("extract_alphamissense_scores processes data correctly", {
  # Create test data
  test_data <- tibble(
    `AlphaMissense_pathogenicity(class)` = c(
      "0.85(PATHOGENIC)",
      "0.15(BENIGN)",
      "N/A",
      "0.45(AMBIGUOUS)"
    )
  )
  
  result <- extract_alphamissense_scores(test_data)
  
  expect_equal(nrow(result), 3)  # N/A should be filtered out
  expect_true(all(is.numeric(result$score)))
  expect_equal(result$score, c(0.85, 0.15, 0.45))
  expect_equal(result$class, c("PATHOGENIC", "BENIGN", "AMBIGUOUS"))
})

# ==============================================================================
# Integration Tests
# ==============================================================================

test_that("end-to-end workflow components work together", {
  # Test that the main workflow functions can be chained together
  # This is a basic integration test
  
  # Mock data structure similar to what would be created
  mock_data <- tibble(
    name = c("topic1", "topic2"),
    value = list(
      tibble(rsid = c("rs1", "rs2")),
      tibble(rsid = c("rs3", "rs4"))
    ),
    dfs = list(
      tibble(
        Gene = c("GENE1", "GENE2"),
        `Foldx_prediction(foldxDdg;plddt)` = c("foldxDdg:1.0;plddt:80", "foldxDdg:-1.0;plddt:75"),
        `AlphaMissense_pathogenicity(class)` = c("0.8(PATHOGENIC)", "0.2(BENIGN)")
      ),
      tibble(
        Gene = c("GENE3"),
        `Foldx_prediction(foldxDdg;plddt)` = c("foldxDdg:0.5;plddt:85"),
        `AlphaMissense_pathogenicity(class)` = c("0.4(AMBIGUOUS)")
      )
    )
  )
  
  # Test summary table creation
  summary_result <- create_summary_table(mock_data)
  
  expect_equal(nrow(summary_result), 2)
  expect_true("snp_count" %in% names(summary_result))
  expect_true("missense_count" %in% names(summary_result))
  expect_true("miss_gene_count" %in% names(summary_result))
  expect_true("missense_snp_ratio" %in% names(summary_result))
})