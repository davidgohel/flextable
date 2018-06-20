#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply vanilla theme
#' @description Apply theme vanilla to a flextable
#' @param x a flextable object
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_vanilla(ft)
theme_vanilla <- function(x){
  std_b <- fp_border(width = 1, color = "#333333")
  x <- border_remove(x)

  x <- hline( x, border = std_b, part = "all")
  x <- hline_top( x, border = std_b, part = "header" )
  x <- style( x = x, pr_p = fp_par(text.align = "right", padding = 2), part = "all")
  x <- bg(x = x, bg = "transparent", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x
}

#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply box theme
#' @description Apply theme box to a flextable
#' @param x a flextable object
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_box(ft)
theme_box <- function(x){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  x <- border_remove(x)

  std_border <- fp_border(width = 1, color = "black")

  x <- border_outer(x, part="all", border = std_border )
  x <- border_inner_h(x, border = std_border, part="all")
  x <- border_inner_v(x, border = std_border, part="all")

  x <- style( x = x, pr_p = fp_par(text.align = "center", padding = 2), part = "all")
  x <- bg(x = x, bg = "transparent", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- italic(x = x, italic = TRUE, part = "footer")
  x
}

#' @export
#' @title Apply zebra theme
#' @description Apply theme zebra to a flextable
#' @param x a flextable object
#' @param odd_header,odd_body,even_header,even_body odd/even colors for table header and body
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_zebra(ft)
theme_zebra <- function(x, odd_header = "#CFCFCF", odd_body = "#EFEFEF",
                        even_header = "transparent", even_body = "transparent" ){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border_remove(x)
  x <- padding(x = x, padding = 2, part = "all")
  x <- align(x = x, align = "right", part = "all")

  if(h_nrow > 0 ){
    even <- seq_len( h_nrow ) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_header, part = "header")
    x <- bg(x = x, i = even, bg = even_header, part = "header")
    x <- bold(x = x, bold = TRUE, part = "header")
  }
  if(f_nrow > 0 ){
    even <- seq_len( f_nrow ) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_header, part = "footer")
    x <- bg(x = x, i = even, bg = even_header, part = "footer")
    x <- bold(x = x, bold = TRUE, part = "footer")
  }
  if(b_nrow > 0 ){
    even <- seq_len( b_nrow ) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_body, part = "body")
    x <- bg(x = x, i = even, bg = even_body, part = "body")
  }



  x
}

#' @export
#' @title Apply tron legacy theme
#' @description Apply theme tron legacy to a flextable
#' @param x a flextable object
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_tron_legacy(ft)
theme_tron_legacy <- function(x){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border(x = x, border = fp_border(width = 1, color = "#6FC3DF"),
              part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  x <- align(x = x, align = "right", part = "all")
  x <- bg(x = x, bg = "#0C141F", part = "all")

  if(h_nrow > 0 ){
    x <- bold(x = x, bold = TRUE, part = "header")
    x <- color(x = x, color = "#DF740C", part = "header")
  }
  if(f_nrow > 0 ){
    x <- color(x = x, color = "#DF740C", part = "footer")
  }
  if(b_nrow > 0 ){
    x <- color(x = x, color = "#FFE64D", part = "body")
  }


  x
}

#' @export
#' @title Apply tron theme
#' @description Apply theme tron to a flextable
#' @param x a flextable object
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_tron(ft)
theme_tron <- function(x){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border(x = x, border = fp_border(width = 1, color = "#a4cee5"),
              part = "all")
  x <- padding(x = x, padding = 2, part = "all")
  x <- align(x = x, align = "right", part = "all")
  x <- bg(x = x, bg = "#000000", part = "all")

  if(h_nrow > 0 ){
    x <- bold(x = x, bold = TRUE, part = "header")
    x <- color(x = x, color = "#ec9346", part = "header")
  }
  if(f_nrow > 0 ){
    x <- color(x = x, color = "#ec9346", part = "footer")
  }
  if(b_nrow > 0 ){
    x <- color(x = x, color = "#a4cee5", part = "body")
  }

  x
}

#' @export
#' @title Apply booktabs theme
#' @description Apply theme tron to a flextable
#' @param x a flextable object
#' @examples
#' ft <- flextable(iris)
#' ft <- theme_booktabs(ft)
theme_booktabs <- function(x){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  big_border <- fp_border(width = 2)
  std_border <- fp_border(width = 1)
  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border_remove(x)

  if(h_nrow > 0 ){
    x <- hline_top(x, border = big_border, part = "header")
    x <- hline(x, border = std_border, part = "header")
    x <- hline_bottom(x, border = big_border, part = "header")
  }
  if(f_nrow > 0 ){
    x <- hline(x, border = std_border, part = "footer")
    x <- hline_bottom(x, border = big_border, part = "footer")
  }
  if(b_nrow > 0 ){
    x <- hline(x, border = std_border, part = "body")
    x <- hline_bottom(x, border = big_border, part = "body")
  }

  x <- style( x = x, pr_p = fp_par(text.align = "right", padding = 2), part = "all")
  x <- bg(x = x, bg = "transparent", part = "all")
  x

}
