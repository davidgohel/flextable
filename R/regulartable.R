#' @rdname flextable
#' @importFrom stats setNames
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}



