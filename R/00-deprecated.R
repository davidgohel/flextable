#' @keywords internal
#' @title flextable old functions
#' @description The function is maintained for compatibility with old codes
#' mades by users but be aware it produces the same exact object than [flextable()].
#' This function should be deprecated then removed in the next versions.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @export
regulartable <- function(data, col_keys = names(data), cwidth = .75, cheight = .25) {
  .Deprecated(new = "flextable")
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}
