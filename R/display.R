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
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @section pattern:
#' It defined the template used to format the produced strings. Names enclosed
#' by double braces will be evaluated as R code, the corresponding R code is defined
#' with the argument \code{formatters}.
#' @section formatters:
#' Each compound is specifying the R code to execute to produce strings that will be
#' substituted in the \code{pattern} argument. An element must be a formula: the
#' left-hand side is a name (matching a name enclosed by double braces in
#' \code{pattern}) and the right-hand side is an R expression to be evaluated (that
#' will produce the corresponding strings).
#'
#' The function is designed to work with columns in the dataset provided to
#' \code{flextable} (the col_keys).
#' @section fprops:
#' A named list of \link[officer]{fp_text}. It defines the formatting properties
#' associated to a compound in \code{formatters}. If not defined for an element
#' of \code{formatters}, the default formatting properties will be applied.
#' @examples
#' library(officer)
#' # Formatting data values example ------
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

  if( !inherits(x, "flextable") ) stop("display supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  stopifnot(is.character(pattern), length(pattern)==1)

  if( length( fprops ) && !all(sapply( fprops, inherits, "fp_text")) ){
    stop("argument fprops should be a list of fp_text")
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], col_key )

  newcontent <- old_display_init(x = pattern,
                   formatters = formatters, fprops = fprops, x[[part]]$dataset[i,])
  x[[part]]$content[i, j] <- newcontent

  x
}

#' @export
#' @importFrom rlang eval_tidy enquo
#' @title Define flextable displayed values
#' @description Modify flextable displayed values. Function is
#' handling complex formatting as well as image insertion.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function \code{\link{as_paragraph}}.
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @examples
#' library(officer)
#' ft <- flextable(head( mtcars, n = 10))
#' ft <- compose(ft, j = "carb", i = ~ drat > 3.5,
#'   value = as_paragraph("carb is ", as_chunk( sprintf("%.1f", carb)) )
#'   )
#' \donttest{ft <- autofit(ft)}
#' @export
compose <- function(x, i = NULL, j = NULL, value , part = "body"){

  if( !inherits(x, "flextable") ) stop("italic supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- compose(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$content[i, j] <- eval_tidy(enquo(value), data = x[[part]]$dataset[i,, drop = FALSE])

  x
}

