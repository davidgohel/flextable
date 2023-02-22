#' @title flextable: Functions for Tabular Reporting
#'
#' @description
#' The flextable package facilitates access to and manipulation of
#' tabular reporting elements from R.
#'
#' The documentation of functions can be opened with command `help(package = "flextable")`.
#'
#' `flextable()` function is producing flexible tables where each cell
#' can contain several chunks of text with their own set of formatting
#' properties (bold, font color, etc.). Function [mk_par()] lets customise
#' text of cells.
#'
#' The [as_flextable()] function is used to transform specific objects into
#' flextable objects. For example, you can transform a crosstab produced with
#' the 'tables' package into a flextable which can then be formatted,
#' annotated or augmented with footnotes.
#'
#' In order to reduce the homogenization efforts and the number of functions
#' to be called, it is recommended to define formatting properties such as
#' font, border color, number of decimals displayed which will then be applied
#' by default. See [set_flextable_defaults()] for more details.
#'
#' @seealso <https://davidgohel.github.io/flextable/>,
#' <https://ardata-fr.github.io/flextable-book/>, [flextable()]
#' @docType package
#' @aliases flextable-package
#' @name flextable-package
NULL
