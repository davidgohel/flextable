#' @title Wrap a flextable for use with patchwork
#'
#' @description
#' This function wraps a flextable as a patchwork-compliant patch, similar
#' to what [patchwork::wrap_table()] does for gt tables. It allows flextable
#' objects to be combined with ggplot2 plots in a patchwork layout, with
#' optional alignment of table headers and body with plot panel areas.
#'
#' Note this is experimental and may change in the future.
#' @param x A flextable object.
#' @param panel What portion of the table should be aligned with the panel
#' region? `"body"` means that header and footer will be placed outside the
#' panel region. `"full"` means that the whole table will be placed inside the
#' panel region. `"rows"` keeps all rows inside the panel but is otherwise
#' equivalent to `"body"`. `"cols"` places all columns within the panel region
#' but keeps column headers on top.
#' @param space How should the dimension of the table influence the final
#' composition? `"fixed"` means that the table width and height will set the
#' dimensions of the area it occupies. `"free"` means the table dimensions will
#' not influence the sizing. `"free_x"` and `"free_y"` allow freeing either
#' direction.
#' @param n_row_headers Number of leading columns to treat as row headers.
#' These columns will be placed outside the panel region and will not
#' participate in alignment with the plot axes.
#' @param flex_body If `TRUE`, the table body row heights become flexible:
#' the adjacent ggplot determines the panel height and the body rows
#' stretch equally to fill it. Header and footer keep their fixed size.
#' This is useful to align table rows with discrete bars or categories
#' in a neighbouring plot. Implies `free_y` for `space`.
#' @param flex_cols If `TRUE`, the data column widths (all columns after
#' `n_row_headers`) become flexible: the adjacent ggplot determines the
#' panel width and the data columns stretch to fill it. Row header
#' columns keep their fixed width. This is useful to align table columns
#' with discrete x-axis categories in a neighbouring plot.
#' Implies `free_x` for `space`.
#' @param expand Expansion value matching the ggplot discrete axis expansion
#' (`ggplot2::expansion(add = expand)`). Default is `0.6`, which is the
#' ggplot2 default for discrete axes. Only used when `flex_cols = TRUE`.
#' @param just Horizontal alignment of the table within its patchwork panel.
#' One of `"left"` (default), `"right"`, or `"center"`. Useful when the
#' table is narrower than the available panel width.
#' Ignored when `flex_cols = TRUE` (columns fill the panel).
#' @return A patchwork-compliant object that can be combined with ggplot2 plots
#' using `+`, `|`, or `/` operators.
#' @export
#' @examplesIf requireNamespace("patchwork", quietly = TRUE) && requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("ragg", quietly = TRUE)
#' library(gdtools)
#' font_set_liberation()
#' library(ggplot2)
#' library(patchwork)
#'
#' set_flextable_defaults(
#'   font.family = "Liberation Sans",
#'   font.size = 10,
#'   big.mark = "",
#'   border.color = "grey60"
#' )
#'
#' # Adapted from <https://r-graph-gallery.com/web-dumbell-chart.html>
#'
#' dataset <- data.frame(
#'   team = c(
#'     "FC Bayern Munchen", "SV Werder Bremen", "Borussia Dortmund",
#'     "VfB Stuttgart", "Borussia M'gladbach", "Hamburger SV",
#'     "Eintracht Frankfurt", "FC Schalke 04", "1. FC Koln",
#'     "Bayer 04 Leverkusen"
#'   ),
#'   matches = c(2000, 1992, 1924, 1924, 1898, 1866, 1856, 1832, 1754, 1524),
#'   won     = c(1206,  818,  881,  782,  763,  746,  683,  700,  674,  669),
#'   lost    = c( 363,  676,  563,  673,  636,  625,  693,  669,  628,  447)
#' )
#' dataset$win_pct  <- dataset$won  / dataset$matches * 100
#' dataset$loss_pct <- dataset$lost / dataset$matches * 100
#' dataset$team <- factor(dataset$team, levels = rev(dataset$team))
#'
#' # -- dumbbell chart --
#' pal <- c(lost = "#EFAC00", won = "#28A87D")
#' df_long <- reshape(dataset, direction = "long",
#'   varying = list(c("loss_pct", "win_pct")),
#'   v.names = "pct", timevar = "type",
#'   times = c("lost", "won"), idvar = "team"
#' )
#'
#' p <- ggplot(df_long, aes(x = pct / 100, y = team)) +
#'   stat_summary(
#'     geom = "linerange", fun.min = "min", fun.max = "max",
#'     linewidth = .7, color = "grey60"
#'   ) +
#'   geom_point(aes(fill = type), size = 4, shape = 21,
#'     stroke = .8, color = "white"
#'   ) +
#'   scale_x_continuous(
#'     labels = scales::percent,
#'     expand = expansion(add = c(.02, .02))
#'   ) +
#'   scale_y_discrete(name = NULL, guide = "none") +
#'   scale_fill_manual(
#'     values = pal,
#'     labels = c(lost = "Lost", won = "Won")
#'   ) +
#'   labs(x = NULL, fill = NULL) +
#'   theme_minimal(base_family = "Liberation Sans", base_size = 10) +
#'   theme(
#'     legend.position = "top",
#'     legend.justification = "left",
#'     panel.grid.minor = element_blank(),
#'     panel.grid.major.y = element_blank()
#'   )
#'
#' # -- flextable --
#' ft_dat <- dataset[, c("matches", "win_pct", "loss_pct", "team")]
#' ft_dat$team <- as.character(ft_dat$team)
#'
#' ft <- flextable(ft_dat)
#' ft <- border_remove(ft)
#' ft <- bold(ft, part = "header")
#' ft <- colformat_double(ft, j = c("win_pct", "loss_pct"),
#'   digits = 1, suffix = "%"
#' )
#' ft <- set_header_labels(ft,
#'   team = "Team", matches = "GP",
#'   win_pct = "", loss_pct = ""
#' )
#' ft <- color(ft, color = "#28A87D", j = 2)
#' ft <- color(ft, color = "#EFAC00", j = 3)
#' ft <- bold(ft, bold = TRUE, j = 2:3)
#' ft <- italic(ft, italic = TRUE, j = 4)
#' ft <- align(ft, align = "right", part = "all")
#' ft <- autofit(ft)
#'
#' \dontshow{
#' cap <- ragg::agg_capture(width = 7, height = 6, units = "in", res = 150)
#' grDevices::dev.control("enable")
#' }
#' print(
#'   wrap_flextable(ft, flex_body = TRUE, just = "right") +
#'     p + plot_layout(widths = c(1.1, 2))
#' )
#' \dontshow{
#' raster <- cap()
#' dev.off()
#' plot(as.raster(raster))
#' init_flextable_defaults()
#' }
#' @family flextable_output_export
wrap_flextable <- function(
  x,
  panel = c("body", "full", "rows", "cols"),
  space = c("free", "free_x", "free_y", "fixed"),
  n_row_headers = 0L,
  flex_body = FALSE,
  flex_cols = FALSE,
  expand = 0.6,
  just = c("left", "right", "center")
) {
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Package 'patchwork' is required for wrap_flextable().", call. = FALSE)
  }
  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required for wrap_flextable().", call. = FALSE)
  }
  panel <- match.arg(panel)
  space <- match.arg(space)
  just <- match.arg(just)
  flex_body <- isTRUE(flex_body)
  flex_cols <- isTRUE(flex_cols)

  if (flex_body) {
    attr(x, ".patchwork_flex_body") <- TRUE
  }
  if (flex_cols) {
    attr(x, ".patchwork_flex_cols") <- TRUE
    attr(x, ".patchwork_n_row_headers") <- as.integer(n_row_headers)
    attr(x, ".patchwork_flex_cols_expand") <- expand
  }
  attr(x, ".patchwork_just") <- just

  wrapped <- patchwork::wrap_elements(panel = x, ignore_tag = FALSE)
  attr(wrapped, "patch_settings")$panel <- panel
  attr(wrapped, "patch_settings")$n_row_headers <- as.integer(n_row_headers)
  attr(wrapped, "patch_settings")$space <- c(
    if (flex_cols) TRUE else space %in% c("free", "free_x"),
    if (flex_body) TRUE else space %in% c("free", "free_y")
  )
  class(wrapped) <- c("wrapped_table", class(wrapped))
  wrapped
}

# S3 method: ggplot_add.flextable -------------------------------------------
# Enables: ggplot_obj + flextable_obj
ggplot_add.flextable <- function(object, plot, object_name) {
  plot + wrap_flextable(object)
}

# S3 method: as_patch.flextable ---------------------------------------------
# Called by patchwork when it needs to convert a flextable to a grob.
# Returns a gtable with named components so that patchwork's
# patchGrob.wrapped_table() can split header/body/footer.
#' @importFrom grid unit viewport grobWidth grobHeight
as_patch.flextable <- function(x, ...) {
  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required.", call. = FALSE)
  }

  flex_body <- isTRUE(attr(x, ".patchwork_flex_body"))
  flex_cols <- isTRUE(attr(x, ".patchwork_flex_cols"))
  n_row_hdrs <- as.integer(attr(x, ".patchwork_n_row_headers") %||% 0L)

  n_header <- nrow_part(x, "header")
  n_body <- nrow_part(x, "body")
  n_footer <- nrow_part(x, "footer")
  n_rows <- n_header + n_body + n_footer

  if (flex_body || flex_cols) {
    grob <- gen_grob(x, fit = "auto", scaling = "fixed")
  } else {
    grob <- gen_grob(x, fit = "fixed", scaling = "fixed")
  }
  widths <- grob$ftpar$widths
  heights <- grob$ftpar$heights
  n_cols <- length(widths)

  # --- row heights ---
  if (flex_body && n_body > 0) {
    grob$ftpar$flex_body <- TRUE
    grob$ftpar$n_header_rows <- n_header
    grob$ftpar$n_body_rows <- n_body
    grob$ftpar$n_footer_rows <- n_footer

    row_heights <- unit(heights, "in")
    body_seq <- seq.int(n_header + 1L, n_header + n_body)
    row_heights[body_seq] <- unit(rep(1, n_body), "null")
  } else {
    row_heights <- unit(heights, "in")
  }

  # --- column widths ---
  n_data_cols <- n_cols - n_row_hdrs
  if (flex_cols && n_data_cols > 0) {
    grob$ftpar$flex_cols <- TRUE
    grob$ftpar$n_row_header_cols <- n_row_hdrs
    grob$ftpar$n_data_cols <- n_data_cols

    col_widths <- unit(widths, "in")
    data_seq <- seq.int(n_row_hdrs + 1L, n_cols)
    col_widths[data_seq] <- unit(rep(1, n_data_cols), "null")
  } else {
    col_widths <- unit(widths, "in")
  }

  # Create the gtable skeleton
  gt <- gtable::gtable(
    widths = col_widths,
    heights = row_heights
  )

  # Add the flextable grob spanning the entire table
  gt <- gtable::gtable_add_grob(
    gt,
    grobs = list(grob),
    t = 1L,
    l = 1L,
    b = n_rows,
    r = n_cols,
    clip = "off",
    name = "table"
  )

  # Add a zero-size grob for "table_body" so patchwork can find boundaries
  body_top <- n_header + 1L
  body_bottom <- n_header + n_body
  if (n_body > 0) {
    gt <- gtable::gtable_add_grob(
      gt,
      grobs = list(grid::nullGrob()),
      t = body_top,
      l = 1L,
      b = body_bottom,
      r = n_cols,
      clip = "off",
      name = "table_body"
    )
  }

  # --- viewport height ---
  if (flex_body && n_header > 0) {
    header_height <- sum(unit(heights[seq_len(n_header)], "in"))
    vp_height <- unit(1, "npc") + header_height
  } else if (flex_body) {
    vp_height <- unit(1, "npc")
  } else {
    vp_height <- sum(row_heights)
  }

  # --- viewport width and horizontal position ---
  if (flex_cols && n_data_cols > 0) {
    expand_val <- as.numeric(
      attr(x, ".patchwork_flex_cols_expand") %||% 0.6
    )
    # clamp: below 0.5, viewport would overflow the panel
    expand_eff <- max(expand_val, 0.5)
    range_units <- n_data_cols - 1 + 2 * expand_eff
    # data columns span n_dc/range of the panel; margins are empty
    cat_fraction <- n_data_cols / range_units
    vp_x <- unit((expand_eff - 0.5) / range_units, "npc")
    if (n_row_hdrs > 0) {
      row_hdr_width <- sum(unit(widths[seq_len(n_row_hdrs)], "in"))
      vp_width <- unit(cat_fraction, "npc") + row_hdr_width
    } else {
      vp_width <- unit(cat_fraction, "npc")
    }
    vp_just_x <- 0
  } else {
    halign <- attr(x, ".patchwork_just") %||% "left"
    if (halign == "right") {
      vp_x <- unit(1, "npc")
      vp_just_x <- 1
    } else if (halign == "center") {
      vp_x <- unit(0.5, "npc")
      vp_just_x <- 0.5
    } else {
      vp_x <- unit(0, "npc")
      vp_just_x <- 0
    }
    vp_width <- sum(col_widths)
  }

  gt$vp <- viewport(
    x = vp_x,
    y = 1,
    width = vp_width,
    height = vp_height,
    default.units = "npc",
    just = c(vp_just_x, 1)
  )

  gt
}

# .onLoad registration ------------------------------------------------------
# Register S3 methods for generics from other packages (ggplot2 and patchwork)
# so that flextable objects are handled natively.
.onLoad_patchwork <- function() {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    registerS3method(
      "ggplot_add",
      "flextable",
      ggplot_add.flextable,
      envir = asNamespace("ggplot2")
    )
  }
  if (requireNamespace("patchwork", quietly = TRUE)) {
    registerS3method(
      "as_patch",
      "flextable",
      as_patch.flextable,
      envir = asNamespace("patchwork")
    )
  }
}
