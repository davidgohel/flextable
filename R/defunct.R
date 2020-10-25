#' @name flextable-defunct
#' @title Defunct Functions in Package flextable
NULL

#' @export
#' @rdname flextable-defunct
#' @details `ph_with_flextable_at()` is replaced by `officer::ph_with`.
#' @param ... unused arguments
ph_with_flextable_at <- function(...){
  .Defunct("officer::ph_with")
}

#' @export
#' @rdname flextable-defunct
#' @details `display()` is replaced by `compose`.
display <- function(...){
  .Defunct("compose")
}

#' @export
#' @rdname flextable-defunct
#' @details `ph_with_flextable()` is replaced by `officer::ph_with`.
ph_with_flextable <- function( ... ){
  .Defunct("officer::ph_with")
}

