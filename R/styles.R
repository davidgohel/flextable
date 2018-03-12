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
#' @importFrom stats terms update
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

  if( !is.null(pr_t) )
    x[[part]] <- set_formatting_properties(x[[part]], i = i, j = j, pr_t )
  if( !is.null(pr_p) )
    x[[part]] <- set_formatting_properties(x[[part]], i = i, j = j, pr_p )
  if( !is.null(pr_c) )
    x[[part]] <- set_formatting_properties(x[[part]], i = i, j = j, pr_c )

  x
}

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

  pr_id <- x[[part]]$styles$cells$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$cells$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, bg ) update(x, background.color = bg ), bg = bg )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name

  x[[part]]$styles$cells$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

  x
}

# fonts ----

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

  pr_id <- x[[part]]$styles$text$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$text$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, bold ) update(x, bold = bold ), bold = bold )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name
  x[[part]]$styles$text$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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

  pr_id <- x[[part]]$styles$text$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$text$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, size ) update(x, font.size = size ), size = size )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name
  x[[part]]$styles$text$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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

  pr_id <- x[[part]]$styles$text$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$text$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, italic ) update(x, italic = italic ), italic = italic )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name
  x[[part]]$styles$text$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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

  pr_id <- x[[part]]$styles$text$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$text$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, color ) update(x, color = color ), color = color )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name
  x[[part]]$styles$text$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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
#' ft <- regulartable(head(iris))
#' ft <- font(ft, fontname = fontname, part = "header")
font <- function(x, i = NULL, j = NULL, fontname, part = "body" ){

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

  pr_id <- x[[part]]$styles$text$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$text$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, fontname ) update(x, font.family = fontname ), fontname = fontname )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name
  x[[part]]$styles$text$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

  x
}

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

  pr_id <- x[[part]]$styles$pars$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$pars$get_fp()[unique(pr_id)]

  if(!is.null(padding.top))
    pr <- lapply(pr, function(x, padding.top ) update(x, padding.top = padding.top ), padding.top = padding.top )
  if(!is.null(padding.bottom))
    pr <- lapply(pr, function(x, padding.bottom ) update(x, padding.bottom = padding.bottom ), padding.bottom = padding.bottom )
  if(!is.null(padding.left))
    pr <- lapply(pr, function(x, padding.left ) update(x, padding.left = padding.left ), padding.left = padding.left )
  if(!is.null(padding.right))
    pr <- lapply(pr, function(x, padding.right ) update(x, padding.right = padding.right ), padding.right = padding.right )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name

  x[[part]]$styles$pars$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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

  pr_id <- x[[part]]$styles$pars$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$pars$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, align ) update(x, text.align = align ), align = align )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name

  x[[part]]$styles$pars$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

  x
}



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

  pr_id <- x[[part]]$styles$cells$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$cells$get_fp()[unique(pr_id)]

  if(!is.null(border.top))
    pr <- lapply(pr, function(x, border.top ) update(x, border.top = border.top ), border.top = border.top )
  if(!is.null(border.bottom))
    pr <- lapply(pr, function(x, border.bottom ) update(x, border.bottom = border.bottom ), border.bottom = border.bottom )
  if(!is.null(border.left))
    pr <- lapply(pr, function(x, border.left ) update(x, border.left = border.left ), border.left = border.left )
  if(!is.null(border.right))
    pr <- lapply(pr, function(x, border.right ) update(x, border.right = border.right ), border.right = border.right )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name

  x[[part]]$styles$cells$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

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
      pr_id_from <- x$styles$cells$get_pr_id_at(apply_bottom_border$from[i], x$col_keys[j])
      pr_id_to <- x$styles$cells$get_pr_id_at(apply_bottom_border$to[i], x$col_keys[j])
      pr_from <- x$styles$cells$get_fp()[[pr_id_from]]
      pr_to <- x$styles$cells$get_fp()[[pr_id_to]]
      pr_to <- update(pr_to, border.bottom = pr_from$border.bottom )
      new_pr <- list( pr_to )
      names(new_pr) <- fp_sign(pr_to)
      x$styles$cells$set_pr_id_at(apply_bottom_border$to[i], x$col_keys[j], pr_id = names(new_pr), fp_list = new_pr)
    }

  }

  x
}


#' @export
#' @title Set horizontal or vertical borders
#' @description change horizontal or vertical borders of a
#' flextable (bottom side). These functions are taking care
#' of propagating the border properties to the adjacent cells.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param border border
#' @examples
#' library(officer)
#' big_border = fp_border(color="gray", width = 2)
#' std_border = fp_border(color="orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105),]
#' ft <- regulartable(dat, col_keys = c("Species", "Sepal.Length",
#'   "Sepal.Width", "Petal.Length", "Petal.Width" ))
#' ft <- border(x = ft, part="all", border =fp_border(color="transparent"))
#' ft <- merge_v(ft, j = 1)
#' ft <- hline(ft, part="all", border = std_border )
#' ft <- hline(ft, part="header", i = 1, border = big_border )
#' ft <- hline(ft, part="body", i = c(5, 10, 15), border = big_border )
#' ft <- hline_top(ft, part="header", border = big_border )
#' ft <- vline(ft, part = "all", border = std_border)
#' ft <- vline_left(ft, part = "all", border = std_border)
#' ft
hline <- function(x, i = NULL, j = NULL, border = NULL, part = "body"){
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
#' @rdname hline
hline_top <- function(x, j = NULL, border = NULL, part = "body"){
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
#' @rdname hline
hline_bottom <- function(x, j = NULL, border = NULL, part = "body"){
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
#' @rdname hline
vline_left <- function(x, i = NULL, border = NULL, part = "body"){
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
#' @rdname hline
vline_right <- function(x, i = NULL, border = NULL, part = "body"){
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

#' @export
#' @rdname hline
vline <- function(x, i = NULL, j = NULL, border = NULL, part = "body"){
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
  j <- setdiff(j, 1 )
  x <- border(x, i = i, j = j, border.left = border, part = part )
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
#' @param align one of "center" or "top" or "bottom"
#' @examples
#' ft <- flextable(mtcars)
#' ft <- rotate(ft, rotation = "lrtb", align = "top", part = "header")
rotate <- function(x, i = NULL, j = NULL, rotation, align = "center", part = "body" ){

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

  pr_id <- x[[part]]$styles$cells$get_pr_id_at(i, x$col_keys[j])
  pr <- x[[part]]$styles$cells$get_fp()[unique(pr_id)]

  pr <- lapply(pr, function(x, rotation ) update(x, text.direction = rotation ), rotation = rotation )
  pr <- lapply(pr, function(x, align ) update(x, vertical.align = align ), align = align )
  new_name <- sapply(pr, fp_sign )
  names(pr) <- new_name

  x[[part]]$styles$cells$set_pr_id_at(i, x$col_keys[j], pr_id = as.character(new_name[pr_id]), fp_list = pr)

  x
}



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
  if( length(x$blanks) < 1 ) return(x)

  x <- border( x, j = x$blanks,
          border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = "all" )
  x <- bg(x, j = x$blanks, bg = "transparent", part = "all")
  x <- void(x, j = x$blanks, part = "all")
  x

}

