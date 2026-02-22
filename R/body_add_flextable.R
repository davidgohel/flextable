#' @export
#' @title Add flextable into a Word document
#' @description Add a flextable into a Word document
#' created with 'officer'.
#' @family officer_integration
#'
#' @details
#' Use the [paginate()] function to define whether the table should
#' be displayed on one or more pages, and whether the header should be
#' displayed with the first lines of the table body on the same page.
#'
#' Use the [set_caption()] function to define formatted captions
#' (with [as_paragraph()]) or simple captions (with a string).
#' `topcaption` can be used to insert the caption before the table
#' (default) or after the table (use `FALSE`).
#' @param x an rdocx object
#' @param value `flextable` object
#' @param align left, center (default) or right.
#' The `align` parameter is still supported for the time being, but
#' we recommend using `set_flextable_defaults(table_align = "center")` instead
#' that will set this default alignment for all flextables during
#' the R session, or to define alignement for each table with
#' `set_table_properties(align = "center")`.
#' @param split set to TRUE if you want to activate Word
#' option 'Allow row to break across pages'.
#' This argument is still supported for the time being, but
#' we recommend using `set_flextable_defaults(split = TRUE)` instead
#' that will set this as default setting for all flextables during
#' the R session, or to define alignement for each table with
#' [set_table_properties()] with argument `opts_word=list(split = TRUE)`
#' instead.
#' @param keepnext Defunct in favor of [paginate()]. The default value
#' used for `keep_with_next` is set with
#' `set_flextable_defaults(keep_with_next = TRUE)`.
#' @param pos where to add the flextable relative to the cursor,
#' one of "after", "before", "on" (end of line).
#' @param topcaption if TRUE caption is added before the table, if FALSE,
#' caption is added after the table.
#' @importFrom officer body_add_xml
#' @seealso [knit_print.flextable()], [save_as_docx()]
#' @examples
#' \dontshow{
#' init_flextable_defaults()
#' }
#' library(officer)
#'
#' # define global settings
#' set_flextable_defaults(
#'   split = TRUE,
#'   table_align = "center",
#'   table.layout = "autofit"
#' )
#'
#' # produce 3 flextable
#' ft_1 <- flextable(head(airquality, n = 20))
#' ft_1 <- color(ft_1, i = ~ Temp > 70, color = "red", j = "Temp")
#' ft_1 <- highlight(ft_1, i = ~ Wind < 8, color = "yellow", j = "Wind")
#' ft_1 <- set_caption(
#'   x = ft_1,
#'   autonum = run_autonum(seq_id = "tab"),
#'   caption = "Daily air quality measurements"
#' )
#' ft_1 <- paginate(ft_1, init = TRUE, hdr_ftr = TRUE)
#'
#' ft_2 <- proc_freq(mtcars, "vs", "gear")
#' ft_2 <- set_caption(
#'   x = ft_2,
#'   autonum = run_autonum(seq_id = "tab", bkm = "mtcars"),
#'   caption = as_paragraph(
#'     as_b("mtcars"), " ",
#'     colorize("table", color = "orange")
#'   ),
#'   fp_p = fp_par(keep_with_next = TRUE)
#' )
#' ft_2 <- paginate(ft_2, init = TRUE, hdr_ftr = TRUE)
#'
#' ft_3 <- summarizor(iris, by = "Species")
#' ft_3 <- as_flextable(ft_3, spread_first_col = TRUE)
#' ft_3 <- set_caption(
#'   x = ft_3,
#'   autonum = run_autonum(seq_id = "tab"),
#'   caption = "iris summary"
#' )
#' ft_3 <- paginate(ft_3, init = TRUE, hdr_ftr = TRUE)
#'
#' # add the 3 flextable in a new Word document
#' doc <- read_docx()
#' doc <- body_add_flextable(doc, value = ft_1)
#' doc <- body_add_par(doc, value = "")
#' doc <- body_add_flextable(doc, value = ft_2)
#' doc <- body_add_par(doc, value = "")
#' doc <- body_add_flextable(doc, value = ft_3)
#'
#' fileout <- tempfile(fileext = ".docx")
#' print(doc, target = fileout)
#' \dontshow{
#' init_flextable_defaults()
#' }
body_add_flextable <- function(x, value,
                               align = NULL,
                               pos = "after",
                               split = NULL,
                               topcaption = TRUE,
                               keepnext = NULL) {
  stopifnot(
    inherits(x, "rdocx"),
    inherits(value, "flextable")
  )

  if (!is.null(align)) {
    value$properties$align <- align
  }
  if (!is.null(split)) {
    value$properties$opts_word$split <- split
  }

  value <- flextable_global$defaults$post_process_all(value)
  value <- flextable_global$defaults$post_process_docx(value)
  value <- fix_border_issues(value)

  caption_str <- NULL
  if (has_caption(value)) {
    if (topcaption) {
      apply_cap_kwn <- TRUE
    } else {
      value <- keep_with_next(value, part = "all", value = TRUE)
      apply_cap_kwn <- FALSE
    }
    caption_str <- caption_default_docx_openxml(
      x = value,
      keep_with_next = apply_cap_kwn,
      allow_autonum = TRUE
    )
    if ("" %in% caption_str) caption_str <- NULL
  }

  if (topcaption && !is.null(caption_str)) {
    x <- body_add_xml(x = x, str = caption_str, pos = pos)
  }
  out <- gen_raw_wml(value, doc = x)

  x <- body_add_xml(x = x, str = out, pos = pos)

  if (!topcaption && !is.null(caption_str)) {
    x <- body_add_xml(x = x, str = caption_str, pos = pos)
  }

  x
}

#' @export
#' @title Add flextable at bookmark location in a Word document
#' @family officer_integration
#' @description
#' Use this function if you want to replace a paragraph containing
#' a bookmark with a flextable. As a side effect, the bookmark will be lost.
#' @param x an rdocx object
#' @param value `flextable` object
#' @param bookmark bookmark id
#' @param align left, center (default) or right.
#' @param split set to TRUE if you want to activate Word
#' option 'Allow row to break across pages'.
#' @importFrom officer cursor_bookmark
#' @importFrom xml2 as_xml_document
body_replace_flextable_at_bkm <- function(x, bookmark, value, align = "center", split = FALSE) {
  x <- cursor_bookmark(x, bookmark)
  x <- body_add_flextable(x = x, value = value, pos = "on", align = align, split = split)
  x
}

