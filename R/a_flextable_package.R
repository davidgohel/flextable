#' @title flextable: Functions for Tabular Reporting
#'
#' @description
#' The flextable package facilitates access to and manipulation of
#' tabular reporting elements from R.
#'
#' The documentation of functions can be opened with command \code{help(package = "flextable")}.
#'
#' To learn more about officer, start with the vignettes:
#' \code{browseVignettes(package = "flextable")}
#'
#' \code{flextable()} function is producing flexible tables where each cell can contain several chunks of text
#' with their own set of formatting properties (bold, font color, etc.).
#' Function display lets customise text of cells (See display function).
#'
#' \code{regulartable()} function has been written because the first one is
#' ressource consumming. The main difference is that it is producing tables
#' where cells can contain only one chunk of text with its own set of formatting
#' properties. Function set_formatter is customizing text of cells.
#'
#' These two type of table DO NOT ACCEPT new lines in text.
#'
#' @docType package
#' @name a_flextable_package
#' @aliases flextable-package
#' @rdname a_flextable_package
"_PACKAGE"
