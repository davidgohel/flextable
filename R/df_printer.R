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
#' @family flextable print function
#' @examples
#' df_printer(head(mtcars))
df_printer <- function(dat, ...) {
  args <- Filter(function(z) !is.null(z),
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
#' @title set data.frame automatic printing as a flextable
#' @description Define [df_printer()] as data.frame
#' print method in an R Markdown document.
#'
#' In a setup run chunk:
#'
#' ```
#' flextable::use_df_printer()
#' ```
#' @seealso [df_printer()], [flextable()]
use_df_printer <- function() {
  registerS3method("knit_print", "data.frame", df_printer)
  registerS3method("knit_print", "data.table", df_printer)
  registerS3method("knit_print", "tibble", df_printer)
  registerS3method("knit_print", "grouped_df", df_printer)
  registerS3method("knit_print", "spec_tbl_df", df_printer)
  registerS3method("knit_print", "tbl", df_printer)
  invisible()
}

