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
#' @family borders management
#' @note this function requires careful
#' settings to avoid overlapping borders.
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


#' @title remove borders
#' @description The function is deleting all borders of the flextable object.
#' @param x a flextable object
#' @examples
#' dat <- iris[c(1:5, 51:55, 101:105),]
#' ft <- flextable(dat)
#' ft <- theme_box(ft)
#' ft
#'
#' # remove all borders
#' ft <- border_remove(x = ft)
#' ft
#' @export
#' @family borders management
border_remove <- function(x){
  if( !inherits(x, "flextable") ) stop("border_remove supports only flextable objects.")
  x <- border(x = x, border = fp_border(width = 0), part = "all")
  x
}

#' @title set outer borders
#' @description The function is applying a border to outer cells of one
#' or all parts of a flextable.
#' @param x a flextable object
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param border border defined by a call to \code{\link[officer]{fp_border}}
#' @export
#' @examples
#' library(officer)
#' big_border = fp_border(color="red", width = 2)
#'
#' dat <- iris[c(1:5, 51:55, 101:105),]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add outer borders
#' ft <- border_outer(ft, part="all", border = big_border )
#' ft
#' @family borders management
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
#' @title set inner borders
#' @description The function is applying a border to inner content of one
#' or all parts of a flextable.
#' @inheritParams border_outer
#' @examples
#' library(officer)
#' std_border = fp_border(color="orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105),]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add inner horizontal borders
#' ft <- border_inner_h(ft, border = std_border )
#' ft
#' @family borders management
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
#' @title set vertical inner borders
#' @description The function is applying a vertical border to inner content of one
#' or all parts of a flextable.
#' @inheritParams border_outer
#' @examples
#' library(officer)
#' std_border = fp_border(color="orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105),]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add inner vertical borders
#' ft <- border_inner_v(ft, border = std_border )
#' ft
#' @family borders management
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
#' @title set horizontal borders
#' @description The function is applying an horizontal border to inner
#' content of one or all parts of a flextable. The lines are the
#' bottom borders of selected cells.
#' @inheritParams border_outer
#' @param i rows selection
#' @param j columns selection
#' @examples
#' library(officer)
#' std_border = fp_border(color="gray")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add horizontal borders
#' ft <- hline(ft, part="all", border = std_border )
#' ft
#' @rdname borders
#' @family borders management
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

  ii <- i + 1
  ii <- ii[ii > 1 & ii <= nrow_part(x, part) ]

  if( length(ii) > 0 )
    x <- border(x, i = ii, j = j, border.top = border, part = part )
  x
}

#' @export
#' @title set top horizontal border
#' @description The function is applying an horizontal border to the
#' top of one or all parts of a flextable. The line is the
#' top border of selected parts.
#' @inheritParams border_outer
#' @param j columns selection
#' @examples
#' library(officer)
#' big_border = fp_border(color="orange", width = 3)
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add horizontal border on top
#' ft <- hline_top(ft, part="all", border = big_border )
#' ft
#' @family borders management
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
#' @title set bottom horizontal border
#' @description The function is applying an horizontal border to the
#' bottom of one or all parts of a flextable. The line is the
#' bottom border of selected parts.
#' @inheritParams border_outer
#' @param j columns selection
#' @examples
#' library(officer)
#' big_border = fp_border(color="orange", width = 3)
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add/replace horizontal border on bottom
#' ft <- hline_bottom(ft, part="body", border = big_border )
#' ft
#' @family borders management
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

#' @export
#' @title set vertical borders
#' @description The function is applying vertical borders to inner
#' content of one or all parts of a flextable. The lines are the
#' right borders of selected cells.
#' @inheritParams hline
#' @examples
#' library(officer)
#' std_border = fp_border(color="orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add vertical borders
#' ft <- vline(ft, border = std_border )
#' ft
#' @family borders management
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
#' @title set flextable left vertical borders
#' @description The function is applying vertical borders to the
#' left side of one or all parts of a flextable. The line is the
#' left border of selected cells of the first column.
#' @inheritParams border_outer
#' @param i rows selection
#' @examples
#' library(officer)
#' std_border = fp_border(color="orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add vertical border on the left side of the table
#' ft <- vline_left(ft, border = std_border )
#' ft
#' @family borders management
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

#' @export
#' @title set flextable right vertical borders
#' @description The function is applying vertical borders to the
#' right side of one or all parts of a flextable. The line is the
#' right border of selected cells of the last column.
#' @inheritParams vline_left
#' @examples
#' library(officer)
#' std_border = fp_border(color="orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add vertical border on the left side of the table
#' ft <- vline_right(ft, border = std_border )
#' ft
#' @family borders management
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

