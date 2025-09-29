#' Create FoldX prediction plot
#'
#' @param foldx_data nested data.frame with FoldX predictions
#' @param bins numeric vector of bin breaks
#' @return ggplot object
#' @export
create_foldx_plot <- function(foldx_data, bins = c(-Inf, -4, -2, 0, 2, 4, Inf)) {
  foldx_data %>%
    dplyr::select(name, fix) %>%
    tidyr::unnest(fix) %>%
    dplyr::mutate(bin = cut(fx, breaks = bins)) %>%
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
}

#' Create AlphaMissense pathogenicity plot
#'
#' @param alphamissense_data nested data.frame with AlphaMissense scores
#' @param colors named vector of colors for each class
#' @return ggplot object
#' @export
create_alphamissense_plot <- function(alphamissense_data, 
                                    colors = c("BENIGN" = "dodgerblue",
                                             "AMBIGUOUS" = "orange",
                                             "PATHOGENIC" = "firebrick")) {
  alphamissense_data %>%
    dplyr::select(name, am) %>%
    tidyr::unnest(am) %>%
    dplyr::mutate(class = forcats::fct_relevel(class, "BENIGN")) %>%
    ggplot2::ggplot(ggplot2::aes(y = name, fill = class)) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::scale_x_reverse() +
    ggplot2::scale_fill_manual(values = colors) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.y  = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 8),
      legend.position = "bottom"
    )
}

#' Create functional family distribution plot
#'
#' @param family_data nested data.frame with functional family data
#' @return ggplot object
#' @export
create_family_plot <- function(family_data) {
  family_data %>%
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
}

#' Save plot with specified parameters
#'
#' @param plot ggplot object
#' @param filename character string for output filename
#' @param width numeric width in specified units
#' @param height numeric height in specified units
#' @param scale numeric scaling factor
#' @param units character string for units
#' @param dpi numeric DPI for output
#' @export
save_plot <- function(plot, filename, width = 14, height = 6, scale = 2, 
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

#' Create combined multi-panel plot
#'
#' @param am_plot ggplot AlphaMissense plot
#' @param fx_plot ggplot FoldX plot  
#' @param fam_plot ggplot family plot
#' @param ncol numeric number of columns
#' @return patchwork plot object
#' @export
create_combined_plot <- function(am_plot, fx_plot, fam_plot, ncol = 3) {
  patchwork::wrap_plots(am_plot, fx_plot, fam_plot, ncol = ncol) +
    patchwork::plot_annotation(tag_levels = 'a')
}