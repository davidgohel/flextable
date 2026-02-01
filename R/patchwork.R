#' Wrap a flextable for use with patchwork
#'
#' This function wraps a flextable as a patchwork-compliant patch, similar
#' to what [patchwork::wrap_table()] does for gt tables. It allows flextable
#' objects to be combined with ggplot2 plots in a patchwork layout, with
#' optional alignment of table headers and body with plot panel areas.
#'
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
#' @return A patchwork-compliant object that can be combined with ggplot2 plots
#' using `+`, `|`, or `/` operators.
#' @export
#' @examples
#' if (require("patchwork") && require("ggplot2")) {
#'   ft <- flextable(head(iris))
#'   ft <- autofit(ft)
#'   p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
#'     geom_point()
#'
#'   # Place side by side
#'   p | wrap_flextable(ft)
#'
#'   # Stack vertically
#'   p / wrap_flextable(ft)
#'
#'   # Use + operator (also works directly: p + ft)
#'   p + wrap_flextable(ft)
#' }
#' @family flextable print function
wrap_flextable <- function(
    x,
    panel = c("body", "full", "rows", "cols"),
    space = c("free", "free_x", "free_y", "fixed")) {
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Package 'patchwork' is required for wrap_flextable().", call. = FALSE)
  }
  if (!requireNamespace("gtable", quietly = TRUE)) {
    stop("Package 'gtable' is required for wrap_flextable().", call. = FALSE)
  }
  panel <- match.arg(panel)
  space <- match.arg(space)

  wrapped <- patchwork::wrap_elements(panel = x, ignore_tag = FALSE)
  attr(wrapped, "patch_settings")$panel <- panel
  attr(wrapped, "patch_settings")$n_row_headers <- 0L
  attr(wrapped, "patch_settings")$space <- c(
    space %in% c("free", "free_x"),
    space %in% c("free", "free_y")
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

  n_header <- nrow_part(x, "header")
  n_body <- nrow_part(x, "body")
  n_footer <- nrow_part(x, "footer")
  n_rows <- n_header + n_body + n_footer

  # Generate the grob with fixed dimensions
  grob <- gen_grob(x, fit = "fixed", scaling = "fixed")
  widths <- grob$ftpar$widths
  heights <- grob$ftpar$heights

  col_widths <- unit(widths, "in")
  row_heights <- unit(heights, "in")

  # Create the gtable skeleton
  gt <- gtable::gtable(
    widths = col_widths,
    heights = row_heights
  )

  # Add the flextable grob spanning the entire table
  gt <- gtable::gtable_add_grob(
    gt,
    grobs = list(grob),
    t = 1L, l = 1L,
    b = n_rows, r = length(widths),
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
      t = body_top, l = 1L,
      b = body_bottom, r = length(widths),
      clip = "off",
      name = "table_body"
    )
  }

  # Set viewport for positioning (top-left anchored)
  gt$vp <- viewport(
    x = 0,
    y = 1,
    width = sum(col_widths),
    height = sum(row_heights),
    default.units = "npc",
    just = c(0, 1)
  )

  gt
}

# .onLoad registration ------------------------------------------------------
# Register S3 methods for generics from other packages (ggplot2 and patchwork)
# so that flextable objects are handled natively.
.onLoad_patchwork <- function() {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    registerS3method(
      "ggplot_add", "flextable",
      ggplot_add.flextable,
      envir = asNamespace("ggplot2")
    )
  }
  if (requireNamespace("patchwork", quietly = TRUE)) {
    registerS3method(
      "as_patch", "flextable",
      as_patch.flextable,
      envir = asNamespace("patchwork")
    )
  }
}
