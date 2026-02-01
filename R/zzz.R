#' @importFrom officer to_rtf to_html
.onLoad <- function(libname, pkgname) {
  # registerS3method("to_rtf", "flextable", to_rtf.flextable)
  .onLoad_patchwork()
}
