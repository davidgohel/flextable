#' @export
#' @title Summarize a data.frame as a flextable
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
#' @param dat the data.frame
#' @param ... unused argument
#' @details
#' 'knitr' chunk options are available to customize the output:
#'
#' * `ft_max_row`: The number of rows to print.
#' * `ft_split_colnames`: Should the column names be split (with non alpha-numeric characters)
#' * `ft_short_strings`: Should the character column be shorten
#' * `ft_short_size`: Maximum length of character column
#' * `ft_short_suffix`: Suffix to add when character values are shorten
#' * `ft_do_autofit`: Use autofit() before rendering the table
#' * `ft_show_coltype`: Show column types
#' * `ft_color_coltype`: Color to use for column types
#' @family flextable print function
#' @examples
#' df_printer(head(mtcars))
df_printer <- function(dat, ...) {

  x <- as.data.frame(dat)
  nro <- nrow(x)

  z <- get_flextable_defaults()

  max_row <- knitr::opts_current$get("ft_max_row")
  split_colnames <- knitr::opts_current$get("ft_split_colnames")
  short_strings <- knitr::opts_current$get("ft_short_strings")
  short_size <- knitr::opts_current$get("ft_short_size")
  short_suffix <- knitr::opts_current$get("ft_short_suffix")
  do_autofit <- knitr::opts_current$get("ft_do_autofit")
  show_coltype <- knitr::opts_current$get("ft_show_coltype")
  color_coltype <- knitr::opts_current$get("ft_color_coltype")

  if(is.null(max_row)) max_row <- 10
  if(is.null(split_colnames)) split_colnames <- FALSE
  if(is.null(short_strings)) short_strings <- FALSE
  if(is.null(short_size)) short_size <- 35
  if(is.null(short_suffix)) short_suffix <- "..."
  if(is.null(do_autofit)) do_autofit <- TRUE
  if(is.null(show_coltype)) show_coltype <- TRUE
  if(is.null(color_coltype)) color_coltype <- "#999999"

  x <- head(x, n = max_row)
  coltypes <- as.character(sapply(x, function(x) head(class(x), 1)))

  look_like_int <- function(x){
    (is.numeric(x) && isTRUE(all.equal(x, as.integer(x)))) || is.integer(x)
  }
  lli <- sapply(x, look_like_int)
  x[lli] <- lapply(x[lli], as.integer)


  if(!is.null(short_strings) && short_strings){
    wic <- sapply(x, is.character)
    x[wic] <- lapply(x[wic], function(x){
      paste0(substring(text = x, first = 1, last = short_size), short_suffix)
    })
  }

  colkeys <- colnames(x)

  ft <- flextable(x, col_keys = colkeys)

  if(split_colnames){
    labs <- strsplit(colkeys, split = "[^[:alnum:]]+")
    names(labs) <- colkeys
    labs <- lapply(labs, paste, collapse = "\n")
    ft <- set_header_labels(ft, values = labs)
  }

  if(show_coltype){
    ft <- add_header_row(ft, top = FALSE, values = coltypes)
  }


  ft <- colformat_double(ft)
  ft <- colformat_int(ft)

  if(nro > max_row){
    ft <- add_footer_lines(ft, values = sprintf("n: %.0f", nro))
  }
  ft <- set_table_properties(ft, layout = z$table.layout)
  if("fixed" %in% z$table.layout && do_autofit){
    ft <- autofit(ft)
  }

  ft <- do.call(z$theme_fun, list(ft))

  if(show_coltype){
    ft <- color(ft, i = nrow_part(ft, "header"), part = "header", color = color_coltype)
  }
  ft <- align(ft, align = "left", part = "footer")

  knitr::knit_print(ft)
}
