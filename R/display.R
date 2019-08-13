#' @import officer
#' @title Define flextable displayed values
#' @description Modify flextable displayed values by specifying a
#' string expression. Function is handling complex formatting as well as
#' image insertion.
#' @note
#' You should use \code{\link{compose}} instead - the function is easier
#' to use. Function display will be deprecated in the next release.
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
#' @family cells formatters
compose <- function(x, i = NULL, j = NULL, value , part = "body"){

  if( !inherits(x, "flextable") ) stop("compose supports only flextable objects.")
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

#' @rdname compose
#' @section mk_par:
#' Function \code{mk_par} is another name for \code{compose} as
#' there is an unwanted conflict with package \code{purrr}.
#' @export
mk_par <- compose

#' @export
#' @title add footnotes to flextable
#' @description add footnotes to a flextable object. A symbol is appened
#' where the footnote is defined and the note is appened in the footer part
#' of the table.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function \code{\link{as_paragraph}}.
#' @param ref_symbols character value, symbols to append that will be used
#' as references to notes.
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @examples
#' ft <- flextable(head(iris))
#' ft <- footnote( ft, i = 1, j = 1:3,
#'             value = as_paragraph(
#'               c("This is footnote one",
#'                 "This is footnote two",
#'                 "This is footnote three")
#'             ),
#'             ref_symbols = c("a", "b", "c"),
#'             part = "header")
#' ft <- valign(ft, valign = "bottom", part = "header")
#' \donttest{ft <- autofit(ft)}
#' @export
#' @importFrom stats update
footnote <- function(x, i = NULL, j = NULL, value , ref_symbols = NULL, part = "body"){

  if( !inherits(x, "flextable") ) stop("footnote supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

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

  if(is.null(ref_symbols)){
    ref_symbols <- as.character(seq_along(value))
  }

  # create chunk for ref_symbols
  symbols_chunks <- rep(list(NULL), length(ref_symbols))
  for(symbi in seq_along(ref_symbols)){
    symbols_chunks[[symbi]] <- as_sup(ref_symbols[symbi])
  }

  new <- mapply(
    function(x, y){
      y$seq_index <- max(x$seq_index, na.rm = TRUE) + 1
      rbind.match.columns(list(x, y))
      },
    x = x[[part]]$content[i, j],
    y = symbols_chunks, SIMPLIFY = FALSE )

  x[[part]]$content[i, j] <- new


  n_row <- nrow_part(x, "footer")
  x <- add_footer_lines(x, values = ref_symbols)

  new <- mapply(
    function(x, y){
      x$seq_index <- min(y$seq_index, na.rm = TRUE) - 1
      x <- rbind.match.columns(list(x, y))
      x$seq_index <- order(x$seq_index)
      x
      }, x = symbols_chunks, y = value,
    SIMPLIFY = FALSE )

  x[["footer"]]$content[seq(n_row + 1, nrow_part(x, "footer")), 1] <- new

  x
}

