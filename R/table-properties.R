#' @importFrom officer table_layout table_width table_colwidths prop_table
#' @export
#' @title Set table layout and width properties
#' @description Set table layout and table width. Default to fixed
#' algorithm.
#'
#' If layout is fixed, column widths will be used to display the table;
#' `width` is ignored.
#'
#' If layout is autofit, column widths will not be used;
#' table width is used (as a percentage).
#' @note
#' PowerPoint output ignore 'autofit layout'.
#' @inheritParams args_x_only
#' @param layout 'autofit' or 'fixed' algorithm. Default to 'fixed'.
#' @param width The parameter has a different effect depending on the
#' output format. Users should consider it as a minimum width.
#' In HTML, it is the minimum width of the space that the
#' table should occupy. In Word, it is a preferred size and Word
#' may decide not to strictly stick to it. It has no effect on
#' PowerPoint and PDF output. Its default value is 0, as an effect, it
#' only use necessary width to display all content. It is not used by the
#' PDF output.
#' @param align alignment in document (only Word, HTML and PDF),
#' supported values are 'left', 'center' and 'right'.
#' @param opts_html html options as a list. Supported elements are:
#' - 'extra_css': extra css instructions to be integrated with the HTML
#' code of the table.
#' - 'scroll': NULL or a list if you want to add a scroll-box.
#'     - Use an empty list to add an horizontal scroll.  The with
#'     is fixed, corresponding to the container's width.
#'     - If the list has a value named `height` it will be used as
#'     height and the scroll will happen also vertically. The height
#'     will be in pixel if numeric, if a string it should be a valid css
#'     measure.
#'     - If the list has a value named `freeze_first_column` set to `TRUE`,
#'     the first column is set as a *sticky* column.
#'     - If the list has a value named `add_css` it will be used as extra
#'     css to add, .i.e: `border:1px solid red;`.
#' - 'extra_class': extra classes to add in the table tag
#' @param opts_word Word options as a list. Supported elements are:
#' - 'split':  Word option 'Allow row to break across pages' can be
#' activated when TRUE.
#' - 'keep_with_next': Word option 'keep rows together' is
#' activated when TRUE. It avoids page break within tables. This
#' is handy for small tables, i.e. less than a page height.
#' - 'repeat_headers': Word option 'Repeat as header row' is
#' activated and associated to header rows when TRUE.
#' @param opts_pdf PDF options as a list. Supported elements are:
#' - 'tabcolsep': space between the text and the left/right border of its containing
#' cell.
#' - 'arraystretch': height of each row relative to its default
#' height, the default value is 1.5.
#' - 'float': type of floating placement in the PDF document, one of:
#'     * 'none' (the default value), table is placed after the preceding
#' paragraph.
#'     * 'float', table can float to a place in the text where it fits best
#'     * 'wrap-r', wrap text around the table positioned to the right side of the text
#'     * 'wrap-l', wrap text around the table positioned to the left side of the text
#'     * 'wrap-i', wrap text around the table positioned inside edge-near the binding
#'     * 'wrap-o', wrap text around the table positioned outside edge-far from the binding
#' - 'fonts_ignore': if TRUE, pdf-engine 'pdflatex' can be used instead of
#' 'xelatex' or 'lualatex.' If pdflatex is used, fonts will be ignored because they are
#' not supported by pdflatex, whereas with the xelatex and lualatex engines they are.
#' - 'caption_repeat': a boolean that indicates if the caption should be
#' repeated along pages. Its default value is `TRUE`.
#' - 'footer_repeat': a boolean that indicates if the footer should be
#' repeated along pages. Its default value is `TRUE`.
#' - 'default_line_color': default line color, restored globally after
#' the flextable is produced.
#' @param word_title alternative text for Word table (used as title of the table)
#' @param word_description alternative text for Word table (used as description of the table)
#' @examples
#' library(flextable)
#' ft_1 <- flextable(head(cars))
#' ft_1 <- autofit(ft_1)
#' ft_2 <- set_table_properties(ft_1, width = .5, layout = "autofit")
#' ft_2
#' ft_3 <- set_table_properties(ft_1, width = 1, layout = "autofit")
#'
#' # add scroll for HTML ----
#' set.seed(2)
#' dat <- lapply(1:14, function(x) rnorm(n = 20))
#' dat <- setNames(dat, paste0("colname", 1:14))
#' dat <- as.data.frame(dat)
#'
#' ft_4 <- flextable(dat)
#' ft_4 <- colformat_double(ft_4)
#' ft_4 <- bg(ft_4, j = 1, bg = "#DDDDDD", part = "all")
#' ft_4 <- bg(ft_4, i = 1, bg = "#DDDDDD", part = "header")
#' ft_4 <- autofit(ft_4)
#' ft_4 <- set_table_properties(
#'   x = ft_4,
#'   opts_html = list(
#'     scroll = list(
#'       height = "500px",
#'       freeze_first_column = TRUE
#'     )
#'   )
#' )
#' ft_4
#' @seealso [flextable()], [as_flextable()], [autofit()],
#' [knit_print.flextable()]
#' @family functions for flextable size management
set_table_properties <- function(
  x,
  layout = "fixed",
  width = 0,
  align = NULL,
  opts_html = list(),
  opts_word = list(),
  opts_pdf = list(),
  word_title = NULL,
  word_description = NULL
) {
  stopifnot(
    `wrong layout value` = layout %in% c("fixed", "autofit"),
    `width is not numeric` = is.numeric(width),
    `width is > 1` = width <= 1
  )

  if (!is.null(word_title)) {
    stopifnot(
      is.character(word_title),
      length(word_title) == 1
    )
    stopifnot(
      is.character(word_description),
      length(word_description) == 1
    )
  }

  x$properties <- list(
    layout = layout,
    width = width,
    align = if (is.null(align)) get_flextable_defaults()$table_align else align,
    opts_html = do.call(opts_ft_html, opts_html),
    opts_word = do.call(opts_ft_word, opts_word),
    opts_pdf = do.call(opts_ft_pdf, opts_pdf),
    word_title = word_title,
    word_description = word_description
  )
  x
}

opts_ft_html <- function(
  extra_css = get_flextable_defaults()$extra_css,
  scroll = get_flextable_defaults()$scroll,
  extra_class = NULL,
  ...
) {
  if (
    !is.character(extra_css) || length(extra_css) != 1 || any(is.na(extra_css))
  ) {
    stop(
      sprintf("'%s' is expected to be a single %s.", "extra_css", "character"),
      call. = FALSE
    )
  }
  if (!is.null(scroll) && !is.list(scroll)) {
    stop(
      sprintf("'%s' is expected to be %s.", "scroll", "NULL or a list"),
      call. = FALSE
    )
  }

  z <- list(extra_css = extra_css, scroll = scroll, extra_class = extra_class)
  class(z) <- "opts_ft_html"
  z
}

opts_ft_word <- function(
  split = get_flextable_defaults()$split,
  keep_with_next = get_flextable_defaults()$keep_with_next,
  repeat_headers = TRUE
) {
  if (!is.logical(split) || length(split) != 1) {
    stop(
      sprintf("'%s' is expected to be a single %s.", "split", "logical"),
      call. = FALSE
    )
  }
  if (!is.logical(keep_with_next) || length(keep_with_next) != 1) {
    stop(
      sprintf(
        "'%s' is expected to be a single %s.",
        "keep_with_next",
        "logical"
      ),
      call. = FALSE
    )
  }
  if (!is.logical(repeat_headers) || length(repeat_headers) != 1) {
    stop(
      sprintf(
        "'%s' is expected to be a single %s.",
        "repeat_headers",
        "logical"
      ),
      call. = FALSE
    )
  }

  z <- list(
    split = split,
    keep_with_next = keep_with_next,
    repeat_headers = repeat_headers
  )
  class(z) <- "opts_ft_word"
  z
}

opts_ft_pdf <- function(
  tabcolsep = get_flextable_defaults()$tabcolsep,
  arraystretch = get_flextable_defaults()$arraystretch,
  float = get_flextable_defaults()$float,
  fonts_ignore = get_flextable_defaults()$fonts_ignore,
  caption_repeat = TRUE,
  footer_repeat = FALSE,
  default_line_color = "black"
) {
  if (!is.logical(fonts_ignore) || length(fonts_ignore) != 1) {
    stop(
      sprintf("'%s' is expected to be a single %s.", "fonts_ignore", "logical"),
      call. = FALSE
    )
  }
  if (
    !is.numeric(tabcolsep) || length(tabcolsep) != 1 || any(sign(tabcolsep) < 0)
  ) {
    stop(
      sprintf(
        "'%s' is expected to be a single %s.",
        "tabcolsep",
        "positive number"
      ),
      call. = FALSE
    )
  }
  if (
    !is.numeric(arraystretch) ||
      length(arraystretch) != 1 ||
      any(sign(arraystretch) < 0)
  ) {
    stop(
      sprintf(
        "'%s' is expected to be a single %s.",
        "arraystretch",
        "positive number"
      ),
      call. = FALSE
    )
  }
  if (
    !is.character(float) ||
      length(float) != 1 ||
      !all(
        float %in% c("none", "float", "wrap-r", "wrap-l", "wrap-i", "wrap-o")
      )
  ) {
    stop(
      sprintf(
        "'%s' is expected to be a single %s.",
        "float",
        "character (one of 'none', 'float', 'wrap-r', 'wrap-l', 'wrap-i', 'wrap-o')"
      ),
      call. = FALSE
    )
  }
  if (!is.logical(caption_repeat) || length(caption_repeat) != 1) {
    stop(
      sprintf("'%s' is expected to be a single %s.", "caption_repeat", "logical"),
      call. = FALSE
    )
  }

  z <- list(
    tabcolsep = tabcolsep,
    arraystretch = arraystretch,
    float = float,
    default_line_color = default_line_color,
    caption_repeat = caption_repeat,
    footer_repeat = footer_repeat,
    fonts_ignore = fonts_ignore
  )
  class(z) <- "opts_ft_pdf"
  z
}
