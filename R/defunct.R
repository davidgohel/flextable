#' @name flextable-defunct
#' @title Defunct Functions in Package flextable
NULL

#' @export
#' @export
#' @rdname flextable-defunct
#' @details `ph_with_flextable()` is replaced by `officer::ph_with`.
#' @param ... unused arguments
ph_with_flextable <- function( ... ){
  .Defunct("officer::ph_with")
}

