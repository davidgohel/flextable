#' @export
#' @title Add flextable at a bookmark location in document's header
#' @description Function is now defunct, use [officer::prop_section()] instead.
#' @param ... unused
#' @keywords internal
headers_flextable_at_bkm <- function(...) {
  .Defunct(new = "prop_section", package = "officer")
}

#' @export
#' @title Add flextable at a bookmark location in document's footer
#' @description Function is now defunct, use [officer::prop_section()] instead.
#' @param ... unused
#' @keywords internal
footers_flextable_at_bkm <- function(...) {
  .Defunct(new = "prop_section", package = "officer")
}



#' @export
#' @title Transform a flextable into a raster
#' @description Function is now defunct, use [gen_grob()] instead.
#' @param ... unused
#' @keywords internal
as_raster <- function(...) {
  .Defunct(new = "gen_grob", package = "flextable")
}


#' @export
#' @title Mini lollipop chart chunk wrapper
#' @description Function is now defunct, use [gg_chunk()] instead.
#' @keywords internal
lollipop <- function(...) {
  .Defunct(new = "gg_chunk", package = "flextable")
}





#' @export
#' @title Set Formatter by Types of Columns
#' @description Function is now defunct, use `colformat_` functions instead.
#' @keywords internal
set_formatter_type <- function(...) {
  .Defunct(new = "colformat_*", package = "flextable")
}

