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
