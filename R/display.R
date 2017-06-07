#' @importFrom purrr map_lgl
#' @importFrom lazyeval is_formula
#' @import officer
#' @title Define flextable displayed values
#' @description Modify flextable displayed values by specifying a
#' string expression. Function is handling complex formatting as well as
#' image insertion.
#' @param x a flextable object
#' @param i rows selection
#' @param col_key column to modify, a single character
#' @param pattern string to format
#' @param formatters a list of formula, left side for the name,
#' right side for the content.
#' @param fprops a named list of \link[officer]{fp_text}
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @examples
#'
#' # Formatting data values example ------
#' library(magrittr)
#' ft <- flextable(head( mtcars, n = 10))
#' ft <- display(ft, col_key = "carb",
#'   i = ~ drat > 3.5, pattern = "# {{carb}}",
#'   formatters = list(carb ~ sprintf("%.1f", carb)),
#'   fprops = list(carb = fp_text(color="orange") ) )
#' \donttest{ft <- autofit(ft)}
#' @export
display <- function(x, i = NULL, col_key,
                    pattern, formatters = list(), fprops = list(),
                    part = "body"){

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  stopifnot(is.character(pattern), length(pattern)==1)

  if( length( fprops ) && !all(map_lgl( fprops, inherits, "fp_text")) ){
    stop("argument fprops should be a list of fp_text")
  }

  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], col_key )



  obj <- display_parser$new( x = pattern,
                             formatters = formatters, fprops = fprops )

  lazy_f_id <- fp_sign(obj)
  x[[part]]$styles$formats$set_fp(i, x$col_keys[j], obj, lazy_f_id )

  x
}

