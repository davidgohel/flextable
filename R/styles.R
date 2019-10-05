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
#' def_cell <- fp_cell(border = fp_border(color="#00FFFF"))
#'
#' def_par <- fp_par(text.align = "center")
#'
#' ft <- flextable(mtcars)
#'
#' ft <- style( ft, pr_c = def_cell, pr_p = def_par, part = "all")
#' ft <- style(ft, ~ drat > 3.5, ~ vs + am + gear + carb,
#'   pr_t = fp_text(color="red", italic = TRUE) )
#'
#' ft
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
#' ft <- flextable(mtcars)
#' ft <- bold(ft, bold = TRUE, part = "header")
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
#' ft <- flextable(mtcars)
#' ft <- fontsize(ft, size = 14, part = "header")
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
#' ft <- flextable(mtcars)
#' ft <- italic(ft, italic = TRUE, part = "header")
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
#' @param color color to use as font color
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(mtcars)
#' ft <- color(ft, color = "orange", part = "header")
color <- function(x, i = NULL, j = NULL, color, part = "body" ){

  if( !inherits(x, "flextable") ) stop("color supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- color(x = x, i = i, j = j, color = color, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
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
#' fontname <- "Times"
#'
#' if( !font_family_exists(fontname) ){
#'   ft <- flextable(head(iris))
#'   ft <- font(ft, fontname = fontname, part = "header")
#' }
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
#' ft <- flextable(mtcars)
#' ft <- padding(ft, padding.top = 4)
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
#' ft <- flextable(mtcars)
#' ft <- align(ft, align = "center")
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
#' @rdname align
#' @param header should the header be aligned with the body
#' @param footer should the footer be aligned with the body
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(mtcars)
#' ft <- align_text_col(ft, align = "left")
#' ft <- align_nottext_col(ft, align = "right")
#' ft
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
#' @param bg color to use as background color
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(mtcars)
#' ft <- bg(ft, bg = "#DDDDDD", part = "header")
bg <- function(x, i = NULL, j = NULL, bg, part = "body" ){

  if( !inherits(x, "flextable") ) stop("bg supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- bg(x = x, i = i, j = j, bg = bg, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

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
#' ft <- flextable(iris[c(1:3, 51:53, 101:103),])
#' ft <- theme_box(ft)
#' ft <- merge_v( ft, j = 5)
#' ft <- valign(ft, j = 5, valign = "top", part = "all")
#' ft
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
#' @description apply a rotation to cell text
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param rotation one of "lrtb", "tbrl", "btlr"
#' @param align vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @details
#' One common case is to rotate text to minimise column space. When rotating,
#' paragraph alignments will remain the same and often right aligned (
#' with an effect of top aligned when rotated). Use
#' \code{align(..., align = "center")} to center rotated text.
#'
#' When function \code{autofit} is used, the rotation will be
#' ignored.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- rotate(ft, rotation = "tbrl", part = "header", align = "center")
#' ft <- align(ft, align = "center")
#' ft <- autofit(ft)
#' ft <- height(ft, height = max(dim_pretty(ft, part = "header")$widths), part = "header")
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
#' ft <- flextable(head(iris), col_keys = c("Species",
#'   "break1", "Sepal.Length", "Sepal.Width",
#'   "break2", "Petal.Length", "Petal.Width") )
#' ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
#' ft <- merge_h(ft, part = "header")
#' ft <- theme_vanilla(ft)
#' ft <- empty_blanks(ft)
#' ft <- width(ft, j = c(2, 5), width = .1 )
#' ft
#' @export
empty_blanks <- function(x){
  if( !inherits(x, "flextable") ) stop("empty_blanks supports only flextable objects.")
  if( length(x$blanks) < 1 ) return(x)

  x <- border( x, j = x$blanks,
               border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = "all" )
  x <- bg(x, j = x$blanks, bg = "transparent", part = "all")
  x <- void(x, j = x$blanks, part = "all")
  x

}

