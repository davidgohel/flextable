#' @importFrom purrr map_lgl
#' @importFrom lazyeval lazy_dots
#' @import oxbase
#' @title Define flextable displayed values
#' @description Modify flextable displayed values.
#' @param x a flextable object
#' @param ... see details.
#' @param i rows selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @examples
#'
#' # Formatting data values example ------
#' if( require(magrittr) ){
#'   ft <- flextable(head( mtcars, n = 10))
#'   ft <- display(ft, i = ~ drat > 3.5,
#'     carb = fpar("# ", ftext(carb, fp_text(color="orange") ) ) ) %>%
#'     autofit()
#'   write_docx("format_ft.docx", ft)
#' }
#' @export
display <- function(x, i = NULL, part = "body", ...){

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  args <- lazy_dots(... )
  stopifnot(all( names(args) %in% x$col_keys ) )

  fun_call <- map( args, "expr")
  fun_call <- map(fun_call, function(x) x[[1]])
  fun_call <- map_chr(fun_call, as.character)
  invalid_fun_call <- !fun_call %in% "fpar"
  if( any(invalid_fun_call) ){
    stop( paste0(names(args), collapse = ","), " should call fpar." )
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], names(args) )

  lazy_f_id <- map_chr(args, fp_sign )
  x[[part]]$style_ref_table$formats[lazy_f_id] <- args
  x[[part]]$styles$formats[i, j ] <- matrix( rep.int(lazy_f_id, length(i)), nrow = length(i), byrow = TRUE )

  x
}

