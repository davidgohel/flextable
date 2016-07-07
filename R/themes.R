#' @export
#' @importFrom oxbase pr_border
#' @rdname theme_flextable
#' @title flextable theme
#' @description apply a theme to a flextable
#' @param x a flextable object
#' @examples
#' # theme_vanilla -------
#' ft <- flextable(iris)
#' ft <- theme_tron(ft)
#' @seealso \code{\link{flextable}}
theme_vanilla <- function(x){
  x <- border(x = x, border.bottom = pr_border(width = 1, color = "#333333"),
              border.top = pr_border(width = 1, color = "#333333"),
              border.left = pr_border(width = 0),
              border.right = pr_border(width = 0),
              part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  x <- bg(x = x, bg = "transparent", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x
}

#' @export
#' @rdname theme_flextable
#' @param odd_header,odd_body,even_header,even_body odd/even colors for table header and body
#' @examples
#' # theme_zebra -------
#' ft <- flextable(iris)
#' ft <- theme_zebra(ft)
theme_zebra <- function(x, odd_header = "#CFCFCF", odd_body = "#EFEFEF",
                        even_header = "transparent", even_body = "transparent" ){
  x <- border(x = x, border = pr_border(width = 0), part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  even <- seq_len( nrow(x$body$dataset) ) %% 2 == 0
  odd <- !even

  x <- bg(x = x, i = odd, bg = odd_body, part = "body")
  x <- bg(x = x, i = even, bg = even_body, part = "body")

  even <- seq_len( nrow(x$header$dataset) ) %% 2 == 0
  odd <- !even

  x <- bg(x = x, i = odd, bg = odd_header, part = "header")
  x <- bg(x = x, i = even, bg = even_header, part = "header")
  x <- bold(x = x, bold = TRUE, part = "header")

  x
}

#' @export
#' @rdname theme_flextable
#' @examples
#' # theme_tron_legacy -------
#' ft <- flextable(iris)
#' ft <- theme_tron_legacy(ft)
theme_tron_legacy <- function(x){
  x <- border(x = x, border = pr_border(width = 1, color = "#6FC3DF"),
              part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  x <- bg(x = x, bg = "#0C141F", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- color(x = x, color = "#DF740C", part = "header")
  x <- color(x = x, color = "#FFE64D", part = "body")
  x
}

#' @export
#' @rdname theme_flextable
#' @examples
#' # theme_tron -------
#' ft <- flextable(iris)
#' ft <- theme_tron(ft)
theme_tron <- function(x){
  x <- border(x = x, border = pr_border(width = 1, color = "#a4cee5"),
              part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  x <- bg(x = x, bg = "#000000", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- color(x = x, color = "#ec9346", part = "header")
  x <- color(x = x, color = "#a4cee5", part = "body")
  x
}
