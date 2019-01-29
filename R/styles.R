#' @export
#' @title Set flextable style
#' @description Modify flextable text, paragraphs and cells formatting properties.
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
#' @examples
#' require("gdtools")
#' fontname <- "Times"
#'
#' if( !font_family_exists(fontname) ){
#'   # if Times is not available, we will use the first available
#'   font_list <- sys_fonts()
#'   fontname <- as.character(font_list$family[1])
#' }
#'
#' ft <- flextable(head(iris))
#' ft <- font(ft, fontname = fontname, part = "header")
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

# cells format ----

#' @export
#' @title Set background color
#' @description change background color of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bg color to use as background color
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

# borders format ----

#' @export
#' @title Set cell borders
#' @description change borders of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param border border (shortcut for top, bottom, left and right)
#' @param border.top border top
#' @param border.bottom border bottom
#' @param border.left border left
#' @param border.right border right
#' @note
#' This function should not be used directly by users and functions \code{\link{hline}},
#' \code{\link{vline}}, \code{\link{hline_top}}, \code{\link{vline_left}} should
#' be prefered.
#' @examples
#' library(officer)
#' ft <- flextable(mtcars)
#' ft <- border(ft, border.top = fp_border(color = "orange") )
border <- function(x, i = NULL, j = NULL, border = NULL,
                   border.top = NULL, border.bottom = NULL,
                   border.left = NULL, border.right = NULL,
                   part = "body" ){

  if( !inherits(x, "flextable") ) stop("border supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( !is.null(border) ){
    if( is.null( border.top) ) border.top <- border
    if( is.null( border.bottom) ) border.bottom <- border
    if( is.null( border.left) ) border.left <- border
    if( is.null( border.right) ) border.right <- border
  }

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- border(x = x, i = i, j = j,
                  border.top = border.top, border.bottom = border.bottom,
                  border.left = border.left, border.right = border.right,
                  part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  if(!is.null(border.top)){
    x[[part]]$styles$cells[i, j, "border.style.top"] <- border.top$style
    x[[part]]$styles$cells[i, j, "border.color.top"] <- border.top$color
    x[[part]]$styles$cells[i, j, "border.width.top"] <- border.top$width
  }
  if(!is.null(border.bottom)){
    x[[part]]$styles$cells[i, j, "border.style.bottom"] <- border.bottom$style
    x[[part]]$styles$cells[i, j, "border.color.bottom"] <- border.bottom$color
    x[[part]]$styles$cells[i, j, "border.width.bottom"] <- border.bottom$width
  }
  if(!is.null(border.left)){
    x[[part]]$styles$cells[i, j, "border.style.left"] <- border.left$style
    x[[part]]$styles$cells[i, j, "border.color.left"] <- border.left$color
    x[[part]]$styles$cells[i, j, "border.width.left"] <- border.left$width
  }
  if(!is.null(border.right)){
    x[[part]]$styles$cells[i, j, "border.style.right"] <- border.right$style
    x[[part]]$styles$cells[i, j, "border.color.right"] <- border.right$color
    x[[part]]$styles$cells[i, j, "border.width.right"] <- border.right$width
  }

  x
}


correct_h_border <- function(x){

  span_cols <- as.list(as.data.frame(x$spans$columns))

  bool_to_be_corrected <- lapply( span_cols, function(x) x > 1 )
  l_apply_bottom_border <- lapply( span_cols, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1 )
  })

  for(j in seq_len(ncol(x$spans$columns)) ){
    apply_bottom_border <- l_apply_bottom_border[[j]]

    if( apply_bottom_border$dont ) next

    for( i in seq_along(apply_bottom_border$from) ){
      i_from <- apply_bottom_border$from[i]
      i_to <- apply_bottom_border$to[i]

      x$styles$cells$border.color.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.color.bottom[i_from, x$col_keys[j]]
      x$styles$cells$border.width.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.width.bottom[i_from, x$col_keys[j]]
      x$styles$cells$border.style.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.style.bottom[i_from, x$col_keys[j]]
    }

  }

  x
}
correct_v_border <- function(x){

  span_rows <- as.list(as.data.frame(t(x$spans$rows)))

  l_apply_right_border <- lapply( span_rows, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1 )
  })

  for(i in seq_along(l_apply_right_border) ){

    apply_right_border <- l_apply_right_border[[i]]

    if( apply_right_border$dont ) next

    for( j in seq_along(apply_right_border$from) ){

      colkeyto <- x$col_keys[apply_right_border$to[j]]
      colkeyfrom <- x$col_keys[apply_right_border$from[j]]
      x$styles$cells$border.color.right[i, colkeyto] <- x$styles$cells$border.color.right[i, colkeyfrom]
      x$styles$cells$border.width.right[i, colkeyto] <- x$styles$cells$border.width.right[i, colkeyfrom]
      x$styles$cells$border.style.right[i, colkeyto] <- x$styles$cells$border.style.right[i, colkeyfrom]

    }

  }

  x
}

# borders format - sugar ----

#' @title borders management
#' @description These functions let control the horizontal or vertical
#' borders of a flextable. They are sugar functions and should be used
#' instead of function \code{\link{border}} that requires careful
#' settings to avoid overlapping borders.
#'
#' @name borders
#' @rdname borders
#' @examples
#' # need officer to define border properties
#' library(officer)
#' big_border = fp_border(color="red", width = 2)
#' std_border = fp_border(color="orange", width = 1)
#'
#' # dataset to be used for examples
#' dat <- iris[c(1:5, 51:55, 101:105),]
#'
NULL

#' @section border_remove:
#' The function is deleting all borders of the flextable object.
#' @export
#' @rdname borders
border_remove <- function(x){
  if( !inherits(x, "flextable") ) stop("border_remove supports only flextable objects.")
  x <- border(x = x, border = fp_border(width = 0), part = "all")
  x
}

#' @export
#' @rdname borders
#' @section border_outer:
#' The function is applying a border to outer cells of one
#' or all parts of a flextable.
#' @examples
#'
#' # use of flextable() to create a table
#' ft <- flextable(dat)
#'
#' # remove all borders
#' ft <- border_remove(x = ft)
#'
#' # add outer borders
#' ft <- border_outer(ft, part="all", border = big_border )
#' ft
border_outer <- function(x, border = NULL, part = "all"){
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )
  if( !inherits(x, "flextable") ) stop("border_outer supports only flextable objects.")

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- border_outer(x = x, border = border, part = p)
    }
    return(x)
  }
  if( nrow_part(x, part) < 1 ) return(x)

  x <- hline_top(x, border = border, part = part)
  x <- hline_bottom(x, border = border, part = part)
  x <- vline_right(x, border = border, part = part)
  x <- vline_left(x, border = border, part = part)

  x
}

#' @export
#' @rdname borders
#' @section border_inner_h:
#' The function is applying horizontal borders to inner content of one
#' or all parts of a flextable.
#' @examples
#'
#' # add inner horizontal borders
#' ft <- border_inner_h(ft, border = std_border )
#' ft
border_inner_h <- function(x, border = NULL, part = "body"){
  if( !inherits(x, "flextable") ) stop("border_inner_h supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- border_inner_h(x = x, border = border, part = p)
    }
    return(x)
  }
  if( (nl <- nrow_part(x, part)) < 1 ) return(x)
  at <- seq_len(nl)
  at <- at[-length(at)]
  x <- hline(x, i = at, border = border, part = part)

  x
}

#' @export
#' @rdname borders
#' @section border_inner_v:
#' The function is applying vertical borders to inner content of one
#' or all parts of a flextable.
#' @examples
#'
#' # add inner vertical borders
#' ft <- border_inner_v(ft, border = std_border )
#' ft
border_inner_v <- function(x, border = NULL, part = "all"){
  if( !inherits(x, "flextable") ) stop("border_inner_v supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- border_inner_v(x = x, border = border, part = p)
    }
    return(x)
  }
  if( nrow_part(x, part) < 1 ) return(x)
  at <- seq_along(x$col_keys)
  at <- at[-length(at)]
  x <- vline(x, j = at, border = border, part = part)

  x
}

#' @export
#' @section hline:
#' The function is setting horizontal lines along the part
#' \code{part} of the flextable object. The lines are the
#' bottom borders of selected cells.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param border border
#' @examples
#'
#' # new example
#' ft <- flextable(dat, col_keys = c("Species", "Sepal.Length",
#'   "Sepal.Width", "Petal.Length", "Petal.Width" ))
#' ft <- border_remove(x = ft)
#'
#' # add horizontal borders
#' ft <- hline(ft, part="all", border = std_border )
#' ft
#' @rdname borders
hline <- function(x, i = NULL, j = NULL, border = NULL, part = "body"){
  if( !inherits(x, "flextable") ) stop("hline supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- hline(x = x, i = i, j = j,
                 border = border,
                 part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x <- border(x, i = i, j = j, border.bottom = border, part = part )

  i <- i + 1
  i <- i[i > 1 & i < nrow_part(x, part) ]
  if( length(i) > 0 )
    x <- border(x, i = i, j = j, border.top = border, part = part )
  x
}

#' @export
#' @rdname borders
#' @section hline_top:
#' The function is setting the first horizontal line of the part
#' \code{part} of the flextable object. The line is the
#' top border of selected cells of the first row.
#' @examples
#'
#' # add horizontal border on top
#' ft <- hline_top(ft, part="all", border = big_border )
#' ft
hline_top <- function(x, j = NULL, border = NULL, part = "body"){
  if( !inherits(x, "flextable") ) stop("hline_top supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- hline_top(x = x, j = j, border = border, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  j <- get_columns_id(x[[part]], j )
  x <- border(x, i = 1, j = j, border.top = border, part = part )
  x
}

#' @export
#' @rdname borders
#' @section hline_bottom:
#' The function is setting the last horizontal line of the part
#' \code{part} of the flextable object. The line is the
#' bottom border of selected cells of the last row.
#' @examples
#'
#' # add/replace horizontal border on bottom
#' ft <- hline_bottom(ft, part="body", border = big_border )
#' ft
hline_bottom <- function(x, j = NULL, border = NULL, part = "body"){
  if( !inherits(x, "flextable") ) stop("hline_bottom supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- hline_bottom(x = x, j = j, border = border, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  j <- get_columns_id(x[[part]], j )
  x <- border(x, i = nrow_part(x, part), j = j, border.bottom = border, part = part )
  x
}

#' @section vline:
#' The function is setting vertical lines along the part
#' \code{part} of the flextable object. The lines are the
#' right borders of selected cells.
#' @export
#' @rdname borders
#' @examples
#'
#' # add vertical borders
#' ft <- vline(ft, border = std_border )
#' ft
vline <- function(x, i = NULL, j = NULL, border = NULL, part = "all"){
  if( !inherits(x, "flextable") ) stop("vline supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- vline(x = x, i = i, j = j, border = border, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 ){
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x <- border(x, i = i, j = j, border.right = border, part = part )
  j <- setdiff(j, length(x$col_keys) )
  if( length(j) > 0 )
    x <- border(x, i = i, j = j + 1, border.left = border, part = part )
  x
}

#' @export
#' @rdname borders
#' @section vline_left:
#' The function is setting the first vertical line of the part
#' \code{part} of the flextable object. The line is the
#' left border of selected cells of the first column.
#' @examples
#'
#' # add vertical border on the left side of the table
#' ft <- vline_left(ft, border = big_border )
#' ft
vline_left <- function(x, i = NULL, border = NULL, part = "all"){
  if( !inherits(x, "flextable") ) stop("vline_left supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- vline_left(x = x, i = i, border = border, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  x <- border(x, j = 1, i = i, border.left = border, part = part )
  x
}

#' @section vline_right:
#' The function is setting the last vertical line of the part
#' \code{part} of the flextable object. The line is the
#' right border of selected cells of the last column.
#' @export
#' @rdname borders
#' @examples
#'
#' # add vertical border on the right side of the table
#' ft <- vline_right(ft, border = big_border )
#' ft
vline_right <- function(x, i = NULL, border = NULL, part = "all"){
  if( !inherits(x, "flextable") ) stop("vline_right supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- vline_right(x = x, i = i, border = border, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  x <- border(x, j = length(x$col_keys), i = i, border.right = border, part = part )
  x
}



# misc. ----


#' @title make blank columns as transparent
#' @description blank columns are set as transparent. This is a shortcut function
#' that will delete top and bottom borders, change background color to
#' transparent and display empty content.
#' @param x a flextable object
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

