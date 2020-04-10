#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply vanilla theme
#' @description Apply theme vanilla to a flextable
#' @param x a flextable object
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_vanilla(ftab)
theme_vanilla <- function(x){
  if( !inherits(x, "flextable") ) stop("theme_vanilla supports only flextable objects.")
  std_b <- fp_border(width = 1, color = "#333333")
  x <- border_remove(x)

  x <- hline( x, border = std_b, part = "all")
  x <- hline_top( x, border = std_b, part = "header" )
  x <- bg(x = x, bg = "transparent", part = "all")
  x <- color(x = x, color = "#111111", part = "all")
  x <- fontsize(x = x, size = 11, part = "all")
  x <- font(x = x, fontname = ifelse( font_family_exists(font_family = "Roboto"), "Roboto", "Arial" ), part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- padding(x = x, padding.left = 5, padding.right = 5,
               padding.bottom = 2, padding.top = 2, part = "all")
  x
}

#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply box theme
#' @description Apply theme box to a flextable
#' @param x a flextable object
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_box(ftab)
theme_box <- function(x){
  if( !inherits(x, "flextable") ) stop("theme_box supports only flextable objects.")
  x <- border_remove(x)

  std_border <- fp_border(width = 1, color = "#666666")

  x <- border_outer(x, part="all", border = std_border )
  x <- border_inner_h(x, border = std_border, part="all")
  x <- border_inner_v(x, border = std_border, part="all")

  x <- bg(x = x, bg = "transparent", part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- italic(x = x, italic = TRUE, part = "footer")
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- padding(x = x, padding.left = 5, padding.right = 5,
               padding.bottom = 2, padding.top = 2, part = "all")

  x
}

#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply alafoli theme
#' @description Apply theme alafoli to a flextable
#' @param x a flextable object
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_alafoli(ftab)
theme_alafoli <- function(x){
  if( !inherits(x, "flextable") ) stop("theme_alafoli supports only flextable objects.")
  x <- border_remove(x)
  x <- bg(x, bg = "transparent", part = "all")
  x <- color(x, color = "#666666", part = "all")
  x <- bold(x = x, bold = FALSE, part = "all")
  x <- italic(x = x, italic = FALSE, part = "all")
  x <- padding(x = x, padding = 3, part = "all")

  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- hline_bottom(x, part = "header", border = fp_border())
  x <- hline_top(x, part = "body", border = fp_border())
  x
}

#' @export
#' @title Apply Sith Lord Darth Vader
#' @description Apply Sith Lord Darth Vader theme to a flextable
#' @param x a flextable object
#' @param fontsize font size in pixel
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_vader(ftab)
theme_vader <- function(x, fontsize = 11){
  if( !inherits(x, "flextable") )
    stop("theme_vader supports only flextable objects.")

  x <- border_remove(x)
  x <- bg(x, bg = "#242424", part = "all")
  x <- color(x, color = "#dfdfdf", part = "all")
  x <- bold(x = x, bold = FALSE, part = "all")
  x <- italic(x = x, italic = FALSE, part = "all")
  x <- padding(x = x, padding = 4, part = "all")

  big_border <- fp_border(color = "#ff0000", width = 3)

  h_nrow <- nrow_part(x, "header")
  b_nrow <- nrow_part(x, "body")

  if(h_nrow > 0 ){
    x <- hline_bottom(x, border = big_border, part = "header")
  }
  if(b_nrow > 0 ){
    x <- hline_top(x, border = big_border, part = "body")
  }

  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- fontsize(x, size = fontsize, part = "all")
  x
}

#' @export
#' @title Apply zebra theme
#' @description Apply theme zebra to a flextable
#' @param x a flextable object
#' @param odd_header,odd_body,even_header,even_body odd/even colors for table header and body
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_zebra(ftab)
theme_zebra <- function(x, odd_header = "#CFCFCF", odd_body = "#EFEFEF",
                        even_header = "transparent", even_body = "transparent" ){
  if( !inherits(x, "flextable") ) stop("theme_zebra supports only flextable objects.")
  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border_remove(x)
  x <- padding(x = x, padding = 2, part = "all")
  x <- align(x = x, align = "center", part = "header")

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
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)



  x
}

#' @export
#' @title Apply tron legacy theme
#' @description Apply theme tron legacy to a flextable
#' @param x a flextable object
#' @family flextable theme
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_tron_legacy(ftab)
theme_tron_legacy <- function(x){

  if( !inherits(x, "flextable") ) stop("theme_tron_legacy supports only flextable objects.")
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
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)

  x
}

#' @export
#' @title Apply tron theme
#' @description Apply theme tron to a flextable
#' @param x a flextable object
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_tron(ftab)
#' @family flextable theme
theme_tron <- function(x){

  if( !inherits(x, "flextable") ) stop("theme_tron supports only flextable objects.")
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
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)

  x
}

#' @export
#' @title Apply booktabs theme
#' @description Apply theme booktabs to a flextable
#' @param x a flextable object
#' @param fontsize font size in pixel
#' @examples
#' ftab <- flextable(iris)
#' ftab <- theme_booktabs(ftab)
#' @family flextable theme
theme_booktabs <- function(x, fontsize = 11){
  if( !inherits(x, "flextable") ) stop("theme_booktabs supports only flextable objects.")
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
    # x <- hline(x, border = std_border, part = "footer")
    x <- hline_bottom(x, border = big_border, part = "footer")
  }
  if(b_nrow > 0 ){
    # x <- hline(x, border = std_border, part = "body")
    x <- hline_bottom(x, border = big_border, part = "body")
  }

  x <- padding(x = x, padding.left = 5, padding.right = 5,
               padding.bottom = 2, padding.top = 2, part = "all")
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- bg(x = x, bg = "transparent", part = "all")
  x <- fontsize(x, size = fontsize, part = "all")
  x

}
