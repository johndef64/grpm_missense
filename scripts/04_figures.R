# ==============================================================================
# Figure Generation Script
# ==============================================================================
# This script creates all figures and visualizations for the project.

# Check if setup and analysis have been run
if (!exists("config")) {
  stop("Please run 01_setup.R first to initialize the project environment.")
}

cat("Starting figure generation...\n")

# ==============================================================================
# Load analysis results
# ==============================================================================

analysis_results_file <- file.path(project_root, config$paths$data_processed, "analysis_results.rds")

if (!file.exists(analysis_results_file)) {
  stop("Analysis results not found. Please run 03_analysis.R first.")
}

analysis_results <- readRDS(analysis_results_file)

# Extract individual analysis components
foldx_analysis <- analysis_results$foldx
alphamissense_analysis <- analysis_results$alphamissense
pharos_analysis <- analysis_results$pharos

cat("Analysis results loaded successfully.\n")

# ==============================================================================
# Define plotting functions (preserved from original)
# ==============================================================================

# Custom save function
save_figure <- function(plot, filename, width = 14, height = 6, scale = 2, 
                       units = "cm", dpi = 300) {
  ggplot2::ggsave(
    plot = plot,
    filename = filename, 
    width = width, 
    height = height,
    units = units, 
    dpi = dpi, 
    scale = scale
  )
}

# ==============================================================================
# Create individual plots
# ==============================================================================

cat("Creating FoldX stability prediction plot...\n")

# FoldX plot (binned stability predictions)
fx_plot <- foldx_analysis %>%
  dplyr::select(name, fix) %>%
  tidyr::unnest(fix) %>%
  dplyr::mutate(bin = cut(fx, breaks = config$analysis$foldx_bins)) %>%
  dplyr::count(name, bin) %>%
  ggplot2::ggplot() +
  ggplot2::aes(y = name, x = n, fill = bin) +
  ggplot2::geom_col(position = "fill") +
  ggplot2::scale_x_reverse() +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.text.y  = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = 8),
    legend.position = "bottom"
  )

cat("Creating AlphaMissense pathogenicity plot...\n")

# AlphaMissense plot (pathogenicity classes)
am_plot <- alphamissense_analysis %>%
  dplyr::select(name, am) %>%
  tidyr::unnest(am) %>%
  dplyr::mutate(class = forcats::fct_relevel(class, "BENIGN")) %>%
  ggplot2::ggplot(ggplot2::aes(y = name, fill = class)) +
  ggplot2::geom_bar(position = "fill") +
  ggplot2::scale_x_reverse() +
  ggplot2::scale_fill_manual(values = c(
    "BENIGN" = config$analysis$alphamissense_colors$BENIGN,
    "AMBIGUOUS" = config$analysis$alphamissense_colors$AMBIGUOUS,
    "PATHOGENIC" = config$analysis$alphamissense_colors$PATHOGENIC
  )) +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.text.y  = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = 8),
    legend.position = "bottom"
  )

cat("Creating functional family distribution plot...\n")

# Functional family plot (Pharos classifications)
fam_plot <- pharos_analysis %>%
  dplyr::select(name, fam) %>%
  tidyr::unnest(fam) %>%
  dplyr::mutate(
    family = dplyr::case_when(
      is.na(family) ~ "Other",
      TRUE ~ family
    ),
    family = forcats::fct_relevel(family, "Other")
  ) %>%
  ggplot2::ggplot(ggplot2::aes(y = name, fill = family)) +
  ggplot2::geom_bar(position = "fill") +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.text.y  = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = 8),
    legend.position = "bottom"
  )

# ==============================================================================
# Create combined figure (Figure 2)
# ==============================================================================

cat("Creating combined multi-panel figure...\n")

# Combined plot with patchwork
figure2 <- patchwork::wrap_plots(am_plot, fx_plot, fam_plot, ncol = 3) +
  patchwork::plot_annotation(tag_levels = 'a')

# ==============================================================================
# Save figures
# ==============================================================================

figures_dir <- file.path(project_root, config$paths$output_figures)

# Create subdirectories for different formats
svg_dir <- file.path(figures_dir, "svg")
png_dir <- file.path(figures_dir, "png")

if (!dir.exists(svg_dir)) dir.create(svg_dir, recursive = TRUE)
if (!dir.exists(png_dir)) dir.create(png_dir, recursive = TRUE)

# Save Figure 2 in multiple formats
cat("Saving Figure 2...\n")

# SVG format (vector graphics)
save_figure(
  figure2, 
  file.path(svg_dir, "Figure_2.svg"),
  width = config$output$figure_width,
  height = config$output$figure_height,
  scale = config$output$figure_scale
)

# PNG format (raster graphics)
save_figure(
  figure2, 
  file.path(png_dir, "Figure_2.png"),
  width = config$output$figure_width,
  height = config$output$figure_height,
  scale = config$output$figure_scale,
  dpi = config$output$figure_dpi
)

# Save individual plots as well
cat("Saving individual plots...\n")

individual_plots <- list(
  "AlphaMissense_plot" = am_plot,
  "FoldX_plot" = fx_plot,
  "FunctionalFamily_plot" = fam_plot
)

for (plot_name in names(individual_plots)) {
  # SVG
  save_figure(
    individual_plots[[plot_name]], 
    file.path(svg_dir, paste0(plot_name, ".svg")),
    width = config$output$figure_width / 3,
    height = config$output$figure_height,
    scale = config$output$figure_scale
  )
  
  # PNG
  save_figure(
    individual_plots[[plot_name]], 
    file.path(png_dir, paste0(plot_name, ".png")),
    width = config$output$figure_width / 3,
    height = config$output$figure_height,
    scale = config$output$figure_scale,
    dpi = config$output$figure_dpi
  )
}

# ==============================================================================
# Figure Generation Summary
# ==============================================================================

cat("\n=== FIGURE GENERATION SUMMARY ===\n")
cat("Main figure (Figure 2): Created and saved\n")
cat("Individual plots: Created and saved\n")
cat("Output formats: SVG (vector) and PNG (raster)\n")
cat("Output directory:", figures_dir, "\n")

# List generated files
svg_files <- list.files(svg_dir, full.names = FALSE)
png_files <- list.files(png_dir, full.names = FALSE)

cat("\nSVG files generated:\n")
for (file in svg_files) cat("  -", file, "\n")

cat("\nPNG files generated:\n")
for (file in png_files) cat("  -", file, "\n")

cat("==================================\n")
cat("Figure generation completed successfully!\n")