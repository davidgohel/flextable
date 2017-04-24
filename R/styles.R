#' @export
#' @title Set flextable style
#' @description Modify flextable text, paragraphs and cells formatting properties.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param pr_t object(s) of class \code{fp_text}
#' @param pr_p object(s) of class \code{fp_par}
#' @param pr_c object(s) of class \code{fp_cell}
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @importFrom lazyeval lazy_eval
#' @importFrom stats terms update
#' @examples
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

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    args <- list()
    for( p in c("header", "body") ){
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

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
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
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param bg color to use as background color
#' @examples
#' ft <- flextable(mtcars)
#' ft <- bg(ft, bg = "#DDDDDD", part = "header")
bg <- function(x, i = NULL, j = NULL, bg, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- bg(x = x, i = i, j = j, bg = bg, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )


  sign_target <- unique( as.vector( x[[part]]$styles$cells[i,j] ) )
  new_cells <- x[[part]]$style_ref_table$cells[sign_target]
  new_cells <- map(new_cells, function(x, bg ) update(x, background.color = bg ), bg = bg )
  names(new_cells) <- sign_target

  new_key <- map_chr(new_cells, fp_sign )
  x[[part]]$style_ref_table$cells[new_key] <- new_cells
  x[[part]]$styles$cells[i,j] <- matrix( new_key[match( x[[part]]$styles$cells[i,j], names(new_key) )], ncol = length(j) )

  x
}


#' @export
#' @title bold font
#' @description change font weight of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param bold boolean value
#' @examples
#' ft <- flextable(mtcars)
#' ft <- bold(ft, bold = TRUE, part = "header")
bold <- function(x, i = NULL, j = NULL, bold = TRUE, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- bold(x = x, i = i, j = j, bold = bold, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )


  sign_target <- unique( as.vector( x[[part]]$styles$text[i,j] ) )
  new_text <- x[[part]]$style_ref_table$text[sign_target]
  new_text <- map(new_text, function(x, bold ) update(x, bold = bold ), bold = bold )
  names(new_text) <- sign_target

  new_key <- map_chr(new_text, fp_sign )
  x[[part]]$style_ref_table$text[new_key] <- new_text
  x[[part]]$styles$text[i,j] <- matrix(
    new_key[match( x[[part]]$styles$text[i,j], names(new_key) )],
    ncol = length(j) )

  x
}

#' @export
#' @title font size
#' @description change font size of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param size integer value (points)
#' @examples
#' ft <- flextable(mtcars)
#' ft <- fontsize(ft, size = 14, part = "header")
fontsize <- function(x, i = NULL, j = NULL, size = 11, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- fontsize(x = x, i = i, j = j, size = size, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )


  sign_target <- unique( as.vector( x[[part]]$styles$text[i,j] ) )
  new_text <- x[[part]]$style_ref_table$text[sign_target]
  new_text <- map(new_text, function(x, size ) update(x, font.size = size ), size = size )
  names(new_text) <- sign_target

  new_key <- map_chr(new_text, fp_sign )
  x[[part]]$style_ref_table$text[new_key] <- new_text
  x[[part]]$styles$text[i,j] <- matrix(
    new_key[match( x[[part]]$styles$text[i,j], names(new_key) )],
    ncol = length(j) )

  x
}

#' @export
#' @title italic font
#' @description change font decoration of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param italic boolean value
#' @examples
#' ft <- flextable(mtcars)
#' ft <- italic(ft, italic = TRUE, part = "header")
italic <- function(x, i = NULL, j = NULL, italic = TRUE, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- italic(x = x, i = i, j = j, italic = italic, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )


  sign_target <- unique( as.vector( x[[part]]$styles$text[i,j] ) )
  new_text <- x[[part]]$style_ref_table$text[sign_target]
  new_text <- map(new_text, function(x, italic ) update(x, italic = italic ), italic = italic )
  names(new_text) <- sign_target

  new_key <- map_chr(new_text, fp_sign )
  x[[part]]$style_ref_table$text[new_key] <- new_text
  x[[part]]$styles$text[i,j] <- matrix(
    new_key[match( x[[part]]$styles$text[i,j], names(new_key) )],
    ncol = length(j) )

  x
}
#' @export
#' @title Set font color
#' @description change font color of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param color color to use as font color
#' @examples
#' ft <- flextable(mtcars)
#' ft <- color(ft, color = "orange", part = "header")
color <- function(x, i = NULL, j = NULL, color, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- color(x = x, i = i, j = j, color = color, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )


  sign_target <- unique( as.vector( x[[part]]$styles$text[i,j] ) )
  new_text <- x[[part]]$style_ref_table$text[sign_target]
  new_text <- map(new_text, function(x, color ) update(x, color = color ), color = color )
  names(new_text) <- sign_target

  new_key <- map_chr(new_text, fp_sign )
  x[[part]]$style_ref_table$text[new_key] <- new_text
  x[[part]]$styles$text[i,j] <- matrix(
    new_key[match( x[[part]]$styles$text[i,j], names(new_key) )],
    ncol = length(j) )

  x
}



#' @export
#' @title Set paddings
#' @description change paddings of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
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

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( !is.null(padding) ){
    if( is.null( padding.top) ) padding.top <- padding
    if( is.null( padding.bottom) ) padding.bottom <- padding
    if( is.null( padding.left) ) padding.left <- padding
    if( is.null( padding.right) ) padding.right <- padding
  }
  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- padding(x = x, i = i, j = j,
                   padding.top = padding.top, padding.bottom = padding.bottom,
                   padding.left = padding.left, padding.right = padding.right,
                   part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )

  sign_target <- unique( as.vector( x[[part]]$styles$pars[i,j] ) )
  new_pars <- x[[part]]$style_ref_table$pars[sign_target]

  if(!is.null(padding.top))
    new_pars <- map(new_pars, function(x, padding.top ) update(x, padding.top = padding.top ), padding.top = padding.top )
  if(!is.null(padding.bottom))
    new_pars <- map(new_pars, function(x, padding.bottom ) update(x, padding.bottom = padding.bottom ), padding.bottom = padding.bottom )
  if(!is.null(padding.left))
    new_pars <- map(new_pars, function(x, padding.left ) update(x, padding.left = padding.left ), padding.left = padding.left )
  if(!is.null(padding.right))
    new_pars <- map(new_pars, function(x, padding.right ) update(x, padding.right = padding.right ), padding.right = padding.right )
  names(new_pars) <- sign_target
  new_key <- map_chr(new_pars, fp_sign )
  x[[part]]$style_ref_table$pars[new_key] <- new_pars
  x[[part]]$styles$pars[i,j] <- matrix( new_key[match( x[[part]]$styles$pars[i,j], names(new_key) )], ncol = length(j) )

  x
}


#' @export
#' @title Set text alignment
#' @description change text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param align text alignment - a single character value, expected value
#' is one of 'left', 'right', 'center', 'justify'.
#' @examples
#' ft <- flextable(mtcars)
#' ft <- align(ft, align = "center")
align <- function(x, i = NULL, j = NULL, align = "left",
                    part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- align(x = x, i = i, j = j, align = align, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )

  sign_target <- unique( as.vector( x[[part]]$styles$pars[i,j] ) )
  new_pars <- x[[part]]$style_ref_table$pars[sign_target]

  new_pars <- map(new_pars, function(x, align ) update(x, text.align = align ), align = align )
  names(new_pars) <- sign_target
  new_key <- map_chr(new_pars, fp_sign )
  x[[part]]$style_ref_table$pars[new_key] <- new_pars
  x[[part]]$styles$pars[i,j] <- matrix( new_key[match( x[[part]]$styles$pars[i,j], names(new_key) )], ncol = length(j) )

  x
}



#' @importFrom purrr map map_chr
#' @export
#' @title Set borders
#' @description change borders of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @param border border (shortcut for top, bottom, left and right)
#' @param border.top border top
#' @param border.bottom border bottom
#' @param border.left border left
#' @param border.right border right
#' @examples
#' ft <- flextable(mtcars)
#' ft <- border(ft, border.top = fp_border(color = "orange") )
border <- function(x, i = NULL, j = NULL, border = NULL,
                   border.top = NULL, border.bottom = NULL,
                   border.left = NULL, border.right = NULL,
                   part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( !is.null(border) ){
    if( is.null( border.top) ) border.top <- border
    if( is.null( border.bottom) ) border.bottom <- border
    if( is.null( border.left) ) border.left <- border
    if( is.null( border.right) ) border.right <- border
  }

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- border(x = x, i = i, j = j,
                  border.top = border.top, border.bottom = border.bottom,
                  border.left = border.left, border.right = border.right,
                  part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )

  sign_target <- unique( as.vector( x[[part]]$styles$cells[i,j] ) )
  new_cells <- x[[part]]$style_ref_table$cells[sign_target]

  if(!is.null(border.top))
    new_cells <- map(new_cells, function(x, border.top ) update(x, border.top = border.top ), border.top = border.top )
  if(!is.null(border.bottom))
    new_cells <- map(new_cells, function(x, border.bottom ) update(x, border.bottom = border.bottom ), border.bottom = border.bottom )
  if(!is.null(border.left))
    new_cells <- map(new_cells, function(x, border.left ) update(x, border.left = border.left ), border.left = border.left )
  if(!is.null(border.right))
    new_cells <- map(new_cells, function(x, border.right ) update(x, border.right = border.right ), border.right = border.right )
  names(new_cells) <- sign_target
  new_key <- map_chr(new_cells, fp_sign )
  x[[part]]$style_ref_table$cells[new_key] <- new_cells
  x[[part]]$styles$cells[i,j] <- matrix( new_key[match( x[[part]]$styles$cells[i,j], names(new_key) )], ncol = length(j) )

  x
}

#' @title make blank columns as transparent
#' @description blank columns are set as transparent. This is a shortcut function
#' that will delete top and bottom borders, change background color to
#' transparent and display empty content.
#' @param x a flextable object
#' @examples
#' library(magrittr)
#'
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", " "),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#' typology
#'
#' head(iris) %>%
#'   flextable(
#'     col_keys = c("Species",
#'                  "break1", "Sepal.Length", "Sepal.Width",
#'                  "break2", "Petal.Length", "Petal.Width") ) %>%
#'   set_header_df(mapping = typology, key = "col_keys" ) %>%
#'   theme_vanilla() %>%
#'   empty_blanks() %>%
#'   autofit() %>%
#'   tabwid()
#' @export
empty_blanks <- function(x){
  if( length(x$blanks) < 1 ) return(x)

  x <- border( x, j = x$blanks,
          border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = "all" )
  x <- bg(x, j = x$blanks, bg = "transparent", part = "all")
  x <- void(x, j = x$blanks)
  x

}

