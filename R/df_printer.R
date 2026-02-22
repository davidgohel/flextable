#' @export
#' @title data.frame automatic printing as a flextable
#' @description Create a summary from a data.frame as a flextable. This function
#' is to be used in an R Markdown document.
#'
#' To use that function, you must declare it in the part `df_print` of the 'YAML'
#' header of your R Markdown document:
#'
#' ```
#' ---
#' df_print: !expr function(x) flextable::df_printer(x)
#' ---
#' ```
#'
#' We notice an unexpected behavior with bookdown. When using bookdown it
#' is necessary to use [use_df_printer()] instead in a setup run chunk:
#'
#' ```
#' use_df_printer()
#' ```
#'
#' @param dat the data.frame
#' @param ... unused argument
#' @details
#' 'knitr' chunk options are available to customize the output:
#'
#' * `ft_max_row`: The number of rows to print. Default to 10.
#' * `ft_split_colnames`: Should the column names be split
#' (with non alpha-numeric characters). Default to FALSE.
#' * `ft_short_strings`: Should the character column be shorten.
#' Default to FALSE.
#' * `ft_short_size`: Maximum length of character column if
#' `ft_short_strings` is TRUE. Default to 35.
#' * `ft_short_suffix`: Suffix to add when character values are shorten.
#' Default to "...".
#' * `ft_do_autofit`: Use autofit() before rendering the table.
#' Default to TRUE.
#' * `ft_show_coltype`: Show column types.
#' Default to TRUE.
#' * `ft_color_coltype`: Color to use for column types.
#' Default to "#999999".
#' @family flextable_output_export
#' @examples
#' df_printer(head(mtcars))
df_printer <- function(dat, ...) {
  args <- Filter(
    function(z) !is.null(z),
    list(
      max_row = knitr::opts_current$get("ft_max_row"),
      split_colnames = knitr::opts_current$get("ft_split_colnames"),
      short_strings = knitr::opts_current$get("ft_short_strings"),
      short_size = knitr::opts_current$get("ft_short_size"),
      short_suffix = knitr::opts_current$get("ft_short_suffix"),
      do_autofit = knitr::opts_current$get("ft_do_autofit"),
      show_coltype = knitr::opts_current$get("ft_show_coltype"),
      color_coltype = knitr::opts_current$get("ft_color_coltype")
    )
  )
  args$x <- dat

  if (is.null(knitr::pandoc_to())) {
    message("this function is to be used in a knitr context.")
    return(invisible(FALSE))
  }

  knitr::knit_print(
    do.call(as_flextable, args)
  )
}

#' @export
#' @title Set data.frame automatic printing as a flextable
#' @description Define [df_printer()] as data.frame
#' print method in an R Markdown document.
#'
#' In a setup run chunk:
#'
#' ```
#' flextable::use_df_printer()
#' ```
#' @seealso [df_printer()], [flextable()]
#' @family flextable_configuration
use_df_printer <- function() {
  registerS3method("knit_print", "data.frame", df_printer)
  registerS3method("knit_print", "data.table", df_printer)
  registerS3method("knit_print", "tibble", df_printer)
  registerS3method("knit_print", "grouped_df", df_printer)
  registerS3method("knit_print", "spec_tbl_df", df_printer)
  registerS3method("knit_print", "tbl", df_printer)
  registerS3method("knit_print", "table", df_printer)
  invisible()
}

look_like_int <- function(x) {
  (is.numeric(x) && isTRUE(all.equal(x, as.integer(x)))) || is.integer(x)
}

multirow_df_printer <- function(dat,
                                max_row = 10,
                                split_colnames = FALSE,
                                short_strings = FALSE,
                                short_size = 35,
                                short_suffix = "...",
                                do_autofit = TRUE,
                                show_coltype = TRUE,
                                color_coltype = "#999999") {
  x <- as.data.frame(dat)
  nro <- nrow(x)

  z <- get_flextable_defaults()

  x <- head(x, n = max_row)
  coltypes <- as.character(sapply(dat, function(x) head(class(x), 1)))

  lli <- sapply(x, look_like_int)
  x[lli] <- lapply(x[lli], as.integer)

  if (!is.null(short_strings) && short_strings) {
    wic <- sapply(x, is.character)
    x[wic] <- lapply(x[wic], function(x) {
      paste0(substring(text = x, first = 1, last = short_size), short_suffix)
    })
  }

  colkeys <- colnames(x)

  ft <- flextable(x, col_keys = colkeys)

  if (split_colnames) {
    labs <- strsplit(colkeys, split = "[^[:alnum:]]+")
    names(labs) <- colkeys
    labs <- lapply(labs, paste, collapse = "\n")
    ft <- set_header_labels(ft, values = labs)
  }

  if (show_coltype) {
    ft <- add_header_row(ft, top = FALSE, values = coltypes)
  }

  ft <- colformat_double(ft)
  ft <- colformat_int(ft)

  ft <- add_footer_lines(ft, values = sprintf("n: %.0f", nro))

  ft <- set_table_properties(ft, layout = z$table.layout)
  if ("fixed" %in% z$table.layout && do_autofit) {
    ft <- autofit(ft)
  }

  ft <- do.call(z$theme_fun, list(ft))

  if (show_coltype) {
    ft <- color(ft, i = nrow_part(ft, "header"), part = "header", color = color_coltype)
  }
  ft <- align(ft, align = "left", part = "footer")
  ft
}

singlerow_df_printer <- function(dat,
                                 max_row = 10,
                                 split_colnames = FALSE,
                                 short_strings = FALSE,
                                 short_size = 35,
                                 short_suffix = "...",
                                 do_autofit = TRUE,
                                 show_coltype = TRUE,
                                 color_coltype = "#999999") {
  coltypes <- as.character(sapply(dat, function(x) head(class(x), 1)))

  lli <- sapply(dat, look_like_int)
  dat[lli] <- lapply(dat[lli], as.integer)

  x <- data.frame(
    "Col." = colnames(dat),
    "Type" = coltypes,
    "Val." = vapply(dat, format_fun.default, FUN.VALUE = NA_character_)
  )

  z <- get_flextable_defaults()

  x <- head(x, n = max_row)

  if (!is.null(short_strings) && short_strings) {
    wic <- sapply(x, is.character)
    x[wic] <- lapply(x[wic], function(x) {
      paste0(substring(text = x, first = 1, last = short_size), short_suffix)
    })
  }

  colkeys <- c("Col.", "Val.")

  ft <- flextable(x, col_keys = colkeys)
  ft <- delete_part(ft, part = "header")
  ft <- set_table_properties(ft, layout = z$table.layout)
  if ("fixed" %in% z$table.layout && do_autofit) {
    ft <- autofit(ft)
  }
  ft <- do.call(z$theme_fun, list(ft))
  ft <- align(ft, align = "center", part = "all")
  ft <- align(ft, j = 1, align = "right", part = "all")
  ft <- valign(x = ft, valign = "top", part = "body")
  if (show_coltype) {
    ft <- append_chunks(
      x = ft, j = "Col.",
      as_chunk("\n"),
      colorize(
        x = as_chunk(Type, props = fp_text_default(font.size = z$font.size * 2 / 3)),
        color = color_coltype
      )
    )
  }
  ft
}

#' @export
#' @title Transform and summarise a 'data.frame' into a flextable
#' Simple summary of a data.frame as a flextable
#' @description It displays the first rows and shows the column types.
#' If there is only one row, a simplified vertical table is produced.
#' @param x a data.frame
#' @param max_row The number of rows to print. Default to 10.
#' @param split_colnames Should the column names be split
#' (with non alpha-numeric characters). Default to FALSE.
#' @param short_strings Should the character column be shorten.
#' Default to FALSE.
#' @param short_size Maximum length of character column if
#' `short_strings` is TRUE. Default to 35.
#' @param short_suffix Suffix to add when character values are shorten.
#' Default to "...".
#' @param do_autofit Use [autofit()] before rendering the table.
#' Default to TRUE.
#' @param show_coltype Show column types.
#' Default to TRUE.
#' @param color_coltype Color to use for column types.
#' Default to "#999999".
#' @param ... unused arguments
#' @examples
#' as_flextable(mtcars)
#' @family as_flextable methods
as_flextable.data.frame <- function(x,
                                    max_row = 10,
                                    split_colnames = FALSE,
                                    short_strings = FALSE,
                                    short_size = 35,
                                    short_suffix = "...",
                                    do_autofit = TRUE,
                                    show_coltype = TRUE,
                                    color_coltype = "#999999",
                                    ...) {
  if (inherits(x, "data.table")) {
    x <- as.data.frame(x)
  } else if (inherits(x, "tbl_df")) {
    x <- as.data.frame(x)
  }

  if (nrow(x) == 1) {
    singlerow_df_printer(
      dat = x,
      max_row = max_row,
      short_strings = short_strings,
      short_size = short_size,
      short_suffix = short_suffix,
      do_autofit = do_autofit,
      show_coltype = show_coltype,
      color_coltype = color_coltype
    )
  } else {
    multirow_df_printer(
      dat = x,
      max_row = max_row,
      split_colnames = split_colnames,
      short_strings = short_strings,
      short_size = short_size,
      short_suffix = short_suffix,
      do_autofit = do_autofit,
      show_coltype = show_coltype,
      color_coltype = color_coltype
    )
  }
}

#' @export
#' @title Transform a 'table' object into a flextable
#' @description produce a flextable describing a
#' count table produced by function `table()`.
#'
#' This function uses the [proc_freq()] function.
#' @param x table object
#' @param ... arguments used by [proc_freq()].
#' @examples
#' tab <- with(warpbreaks, table(wool, tension))
#' ft <- as_flextable(tab)
#' ft
#' @family as_flextable methods
as_flextable.table <- function(x, ...) {
  x <- as.data.frame(x)
  by <- setdiff(colnames(x), "Freq")
  if (length(by) > 2) {
    stop("table must have maximum two dimensions.")
  } else if (length(by) > 1) {
    proc_freq(x, row = by[1], col = by[2], weight = "Freq", ...)
  } else {
    proc_freq(x, row = by[1], weight = "Freq", ...)
  }
}
