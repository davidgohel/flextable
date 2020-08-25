#' @export
#' @title Set flextable style
#' @description Modify flextable text, paragraphs and cells formatting properties.
#' It allows to specify a set of formatting properties for a selection instead
#' of using multiple functions (.i.e \code{bold}, \code{italic}, \code{bg}) that
#' should all be applied to the same selection of rows and columns.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param pr_t object(s) of class \code{fp_text}
#' @param pr_p object(s) of class \code{fp_par}
#' @param pr_c object(s) of class \code{fp_cell}
#' @param part partname of the table (one of 'all', 'body', 'header' or 'footer')
#' @importFrom stats terms
#' @examples
#' library(officer)
#' def_cell <- fp_cell(border = fp_border(color="wheat"))
#'
#' def_par <- fp_par(text.align = "center")
#'
#' ft <- flextable(head(mtcars))
#'
#' ft <- style( ft, pr_c = def_cell, pr_p = def_par, part = "all")
#' ft <- style(ft, ~ drat > 3.5, ~ vs + am + gear + carb,
#'   pr_t = fp_text(color="red", italic = TRUE) )
#'
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_style_1.png}{options: width=100\%}}
style <- function(x, i = NULL, j = NULL,
                  pr_t = NULL, pr_p = NULL, pr_c = NULL, part = "body" ){

  if( !inherits(x, "flextable") ) stop("style supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    args <- list()
    for( p in c("header", "body", "footer") ){
      args$x <- x
      args$i <- i
      args$j <- j
      args$pr_t <- pr_t
      args$pr_p <- pr_p
      args$pr_c <- pr_c
      args$part <- p
      x <- do.call(style, args )
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  if( !is.null(pr_t) ){
    x[[part]]$styles$text[i, j] <- pr_t
  }

  if( !is.null(pr_p) ){
    x[[part]]$styles$pars[i, j] <- pr_p
  }

  if( !is.null(pr_c) ){
    x[[part]]$styles$cells[i, j] <- pr_c
  }

  x
}


# text format ----

#' @export
#' @title Set bold font
#' @description change font weight of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bold boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- bold(ft, bold = TRUE, part = "header")
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_bold_1.png}{options: width=50\%}}
bold <- function(x, i = NULL, j = NULL, bold = TRUE, part = "body" ){

  if( !inherits(x, "flextable") ) stop("bold supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- bold(x = x, i = i, j = j, bold = bold, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$styles$text[i, j, "bold"] <- bold

  x
}

#' @export
#' @title Set font size
#' @description change font size of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param size integer value (points)
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- fontsize(ft, size = 14, part = "header")
#' ft <- fontsize(ft, size = 14, j = 2)
#' ft <- fontsize(ft, size = 7, j = 3)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_fontsize_1.png}{options: width=50\%}}
fontsize <- function(x, i = NULL, j = NULL, size = 11, part = "body" ){

  if( !inherits(x, "flextable") ) stop("fontsize supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- fontsize(x = x, i = i, j = j, size = size, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$styles$text[i, j, "font.size"] <- size

  x
}

#' @export
#' @title Set italic font
#' @description change font decoration of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param italic boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- italic(ft, italic = TRUE, part = "header")
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_italic_1.png}{options: width=50\%}}
italic <- function(x, i = NULL, j = NULL, italic = TRUE, part = "body" ){

  if( !inherits(x, "flextable") ) stop("italic supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- italic(x = x, i = i, j = j, italic = italic, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$styles$text[i, j, "italic"] <- italic

  x
}

#' @export
#' @title Set font color
#' @description change font color of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param color color to use as font color. If a function, function need to return
#' a character vector of colors.
#' @param source if bg is a function, source is specifying the dataset column to be used
#' as argument to `color`. This is only useful if j is colored with values contained in another
#' (or other) column.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- color(ft, color = "orange", part = "header")
#' ft <- color(ft, color = "red",
#'   i = ~ qsec < 18 & vs < 1 )
#' ft
#'
#' if(require("scales")){
#' scale <- scales::col_numeric(domain= c(-1, 1), palette ="RdBu")
#'   x <- as.data.frame(cor(iris[-5]))
#'   x <- cbind(
#'     data.frame(colname = colnames(x),
#'                stringsAsFactors = FALSE),
#'     x)
#'
#'   ft_2 <- flextable(x)
#'   ft_2 <- color(ft_2, j = x$colname, color = scale)
#'   ft_2 <- set_formatter_type(ft_2)
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_color_1.png}{options: width=100\%}}
#'
#' \if{html}{\figure{fig_color_2.png}{options: width=50\%}}
color <- function(x, i = NULL, j = NULL, color, part = "body", source = j ){

  if( !inherits(x, "flextable") ) stop("color supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- color(x = x, i = i, j = j, color = color, part = p, source = source)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  if(is.function(color)){
    source <- get_dataset_columns_id(x[[part]], source )
    lcolor <- lapply(x[[part]]$dataset[source], color)
    color <- matrix( unlist( lcolor ), ncol = length(lcolor) )
  }


  x[[part]]$styles$text[i, j, "color"] <- color

  x
}

#' @export
#' @title Set font
#' @description change font of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param fontname string value, the font name.
#' @family sugar functions for table style
#' @examples
#' require("gdtools")
#' fontname <- "Brush Script MT"
#'
#' if( font_family_exists(fontname) ){
#'   ft_1 <- flextable(head(iris))
#'   ft_2 <- font(ft_1, fontname = fontname, part = "header")
#'   ft_2 <- font(ft_2, fontname = fontname, j = 5)
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_font_1.png}{options: width=70\%}}
#'
#' \if{html}{\figure{fig_font_2.png}{options: width=70\%}}
font <- function(x, i = NULL, j = NULL, fontname, part = "body" ){

  if( !inherits(x, "flextable") ) stop("font supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- font(x = x, i = i, j = j, fontname = fontname, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  x[[part]]$styles$text[i, j, "font.family"] <- fontname
  x
}

# paragraphs format ----

#' @export
#' @title Set paragraph paddings
#' @description change paddings of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param padding padding (shortcut for top, bottom, left and right)
#' @param padding.top padding top
#' @param padding.bottom padding bottom
#' @param padding.left padding left
#' @param padding.right padding right
#' @family sugar functions for table style
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- theme_vader(ft_1)
#' ft_1 <- padding(ft_1, padding.top = 4, part = "all")
#' ft_1 <- padding(ft_1, j = 1, padding.right = 40)
#' ft_1 <- padding(ft_1, i = 3, padding.top = 40)
#' ft_1 <- padding(ft_1, padding.top = 10, part = "header")
#' ft_1 <- padding(ft_1, padding.bottom = 10, part = "header")
#' ft_1 <- autofit(ft_1)
#' ft_1
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_padding_1.png}{options: width=50\%}}
padding <- function(x, i = NULL, j = NULL, padding = NULL,
                    padding.top = NULL, padding.bottom = NULL,
                    padding.left = NULL, padding.right = NULL,
                    part = "body" ){

  if( !inherits(x, "flextable") ) stop("padding supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( !is.null(padding) ){
    if( is.null( padding.top) ) padding.top <- padding
    if( is.null( padding.bottom) ) padding.bottom <- padding
    if( is.null( padding.left) ) padding.left <- padding
    if( is.null( padding.right) ) padding.right <- padding
  }
  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- padding(x = x, i = i, j = j,
                   padding.top = padding.top, padding.bottom = padding.bottom,
                   padding.left = padding.left, padding.right = padding.right,
                   part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )


  if(!is.null(padding.top)){
    x[[part]]$styles$pars[i, j, "padding.top"] <- padding.top
  }
  if(!is.null(padding.bottom)){
    x[[part]]$styles$pars[i, j, "padding.bottom"] <- padding.bottom
  }
  if(!is.null(padding.left)){
    x[[part]]$styles$pars[i, j, "padding.left"] <- padding.left
  }
  if(!is.null(padding.right)){
    x[[part]]$styles$pars[i, j, "padding.right"] <- padding.right
  }

  x
}


#' @export
#' @title Set text alignment
#' @description change text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param align text alignment - a single character value, expected value
#' is one of 'left', 'right', 'center', 'justify'.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars)[,3:6])
#' ft <- align(ft, align = "right", part = "all")
#' ft <- theme_tron_legacy(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_align_1.png}{options: width=100\%}}
align <- function(x, i = NULL, j = NULL, align = "left",
                  part = "body" ){

  if( !inherits(x, "flextable") ) stop("align supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- align(x = x, i = i, j = j, align = align, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$styles$pars[i, j, "text.align"] <- align

  x
}

#' @export
#' @title Set text alignment
#' @description change text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param space space between lines of text, 1 is single line spacing, 2 is double line spacing.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars)[,3:6])
#' ft <- line_spacing(ft, space = 1.6, part = "all")
#' ft <- set_table_properties(ft, layout = "autofit")
#' ft
line_spacing <- function(x, i = NULL, j = NULL, space = 1, part = "body" ){

  if( !inherits(x, "flextable") ) stop("align supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- line_spacing(x = x, i = i, j = j, space = space, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$styles$pars[i, j, "line_spacing"] <- space

  x
}

#' @export
#' @rdname align
#' @param header should the header be aligned with the body
#' @param footer should the footer be aligned with the body
#' @examples
#' ftab <- flextable(mtcars)
#' ftab <- align_text_col(ftab, align = "left")
#' ftab <- align_nottext_col(ftab, align = "right")
#' ftab
align_text_col <- function(x, align = "left", header = TRUE, footer = TRUE ){

  which_j <- which( sapply(x$body$dataset[x$col_keys], function(x) is.character(x) | is.factor(x) ) )
  x <- align(x, j = which_j, align = align, part = "body" )
  if( header ) {
    x <- align(x, j = which_j, align = align, part = "header" )
  }
  if( footer ) {
    x <- align(x, j = which_j, align = align, part = "footer" )
  }
  x
}

#' @export
#' @rdname align
align_nottext_col <- function(x, align = "right", header = TRUE, footer = TRUE ){

  which_j <- which( !sapply(x$body$dataset[x$col_keys], function(x) is.character(x) | is.factor(x) ) )
  x <- align(x, j = which_j, align = align, part = "body" )
  if( header ) {
    x <- align(x, j = which_j, align = align, part = "header" )
  }
  if( footer ) {
    x <- align(x, j = which_j, align = align, part = "footer" )
  }
  x
}

# cells format ----

#' @export
#' @title Set background color
#' @description change background color of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bg color to use as background color. If a function, function need to return
#' a character vector of colors.
#' @param source if bg is a function, source is specifying the dataset column to be used
#' as argument to `bg`. This is only useful if j is colored with values contained in another
#' (or other) column.
#' @family sugar functions for table style
#' @examples
#' ft_1 <- flextable(head(mtcars))
#' ft_1 <- bg(ft_1, bg = "wheat", part = "header")
#' ft_1 <- bg(ft_1, i = ~ qsec < 18, bg = "#EFEFEF", part = "body")
#' ft_1 <- bg(ft_1, j = "drat", bg = "#606060", part = "all")
#' ft_1 <- color(ft_1, j = "drat", color = "white", part = "all")
#' ft_1
#'
#' if(require("scales")){
#'   ft_2 <- flextable(head(iris))
#'   colourer <- col_numeric(
#'     palette = c("wheat", "red"),
#'     domain = c(0, 7))
#'   ft_2 <- bg(ft_2, j = c("Sepal.Length", "Sepal.Width",
#'                      "Petal.Length", "Petal.Width"),
#'            bg = colourer, part = "body")
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_bg_1.png}{options: width=100\%}}
#'
#' \if{html}{\figure{fig_bg_2.png}{options: width=50\%}}
bg <- function(x, i = NULL, j = NULL, bg, part = "body", source = j ){

  if( !inherits(x, "flextable") ) stop("bg supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- bg(x = x, i = i, j = j, bg = bg, part = p, source = source)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  if(is.function(bg)){
    source <- get_dataset_columns_id(x[[part]], source )
    lbg <- lapply(x[[part]]$dataset[source], bg)
    bg <- matrix( unlist( lbg ), ncol = length(lbg) )
  }

  x[[part]]$styles$cells[i, j, "background.color"] <- bg

  x
}
#' @export
#' @title Set vertical alignment
#' @description change vertical alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param valign vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @family sugar functions for table style
#' @examples
#' ft_1 <- flextable(iris[c(1:3, 51:53, 101:103),])
#' ft_1 <- theme_box(ft_1)
#' ft_1 <- merge_v(ft_1, j = 5)
#' ft_1
#'
#' ft_2 <- valign(ft_1, j = 5, valign = "top", part = "all")
#' ft_2
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_valign_1.png}{options: width=50\%}}
#'
#' \if{html}{\figure{fig_valign_2.png}{options: width=50\%}}
valign <- function(x, i = NULL, j = NULL, valign = "center", part = "body" ){

  if( !inherits(x, "flextable") ) stop("valign supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- valign(x = x, i = i, j = j, valign = valign, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  x[[part]]$styles$cells[i, j, "vertical.align"] <- valign

  x
}


#' @export
#' @title rotate cell text
#' @description apply a rotation to cell text. The text direction can
#' be "lrtb" which mean from left to right and top to bottom (the default direction).
#' In some cases, it can be useful to be able
#' to change the direction, when the table headers are huge for example, header labels can
#' be rendered as "tbrl" (top to bottom and right to left) corresponding to a 90 degrees rotation
#' or "btlr" corresponding to a 270 degrees rotation.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param rotation one of "lrtb", "tbrl", "btlr". Note that "btlr" is ignored
#' when output is HTML.
#' @param align vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @details
#' When function \code{autofit} is used, the rotation will be
#' ignored. In that case, use [dim_pretty] and [width] instead
#' of [autofit].
#' @family sugar functions for table style
#' @examples
#' library(flextable)
#'
#' ft <- flextable(head(iris))
#'
#' # measure column widths but only for the body part
#' w_body <- dim_pretty(ft, part = "body")$widths
#' # measure column widths only for the header part and get the max
#' # as height value for rotated text
#' h_header <- max( dim_pretty(ft, part = "header")$widths )
#'
#' ft <- rotate(ft, j = 1:4, rotation="btlr",part="header")
#' ft <- rotate(ft, j = 5, rotation="tbrl",part="header")
#'
#' ft <- valign(ft, valign = "center", part = "header")
#' ft <- flextable::align(ft, align = "center", part = "all")
#'
#' # Manage header height
#' ft <- height(ft, height = h_header * 1.1, part = "header")
#' # ... mainly because Word don't handle auto height with rotated headers
#' ft <- hrule(ft, i = 1, rule = "exact", part = "header")
#'
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_rotate_1.png}{options: width=50\%}}
rotate <- function(x, i = NULL, j = NULL, rotation, align = "center", part = "body" ){

  if( !inherits(x, "flextable") ) stop("rotate supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- rotate(x = x, i = i, j = j, rotation = rotation, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  x[[part]]$styles$cells[i, j, "text.direction"] <- rotation
  x[[part]]$styles$cells[i, j, "vertical.align"] <- align

  x
}



# misc. ----


#' @title make blank columns as transparent
#' @description blank columns are set as transparent. This is a shortcut function
#' that will delete top and bottom borders, change background color to
#' transparent and display empty content.
#' @param x a flextable object
#' @family sugar functions for table style
#' @examples
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", " "),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#' typology
#'
#' ftab <- flextable(head(iris), col_keys = c("Species",
#'   "break1", "Sepal.Length", "Sepal.Width",
#'   "break2", "Petal.Length", "Petal.Width") )
#' ftab <- set_header_df(ftab, mapping = typology, key = "col_keys" )
#' ftab <- merge_h(ftab, part = "header")
#' ftab <- theme_vanilla(ftab)
#' ftab <- empty_blanks(ftab)
#' ftab <- width(ftab, j = c(2, 5), width = .1 )
#' ftab
#' @export
#' @importFrom officer shortcuts
empty_blanks <- function(x){
  if( !inherits(x, "flextable") ) stop("empty_blanks supports only flextable objects.")
  if( length(x$blanks) < 1 ) return(x)

  x <- border( x, j = x$blanks,
               border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = "all" )
  x <- bg(x, j = x$blanks, bg = "transparent", part = "all")
  x <- void(x, j = x$blanks, part = "all")
  x

}

