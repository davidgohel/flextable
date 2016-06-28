#' @title Create flextable object
#'
#' @description Create an object of class \code{flextable}.
#'
#' \code{flextable} are designed to make tabular reporting easier for
#' R users.
#'
#' An API lets you format text, paragraphs and cells, table elements can
#' be merge vertically or horizontally.
#'
#' A \code{flextable} is made of 3 parts: header, body and footer.
#' @param data dataset
#' @param select columns names/keys to display
#' @examples
#' ft <- flextable(mtcars)
#' write_docx("ft.docx", ft)
#' @export
#' @import Rcpp
#' @importFrom stats setNames
flextable <- function( data, select = names(data) ){

  orig_dataset <- data
  data <- data[, select, drop = FALSE]
  col_keys <- names(data)
  # body
  body <- table_part( data = data, col_keys = col_keys,
                      orig_dataset = orig_dataset )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)

  header <- table_part( data = header_data, col_keys = col_keys )

  out <- list( header = header, body = body, footer = NULL, col_keys = col_keys,
               orig_dataset = orig_dataset )
  class(out) <- "flextable"
  out
}

#' @export
#' @importFrom dplyr add_rownames
#' @importFrom oxbase pr_border
#' @rdname flextable
#' @param row.names should row.names be displayed or not
#' @examples
#' vanilla_table(head(iris))
vanilla_table <- function(data, row.names = TRUE){
  hnames <- names(data)
  if( row.names ){
    data <- add_rownames( data )
    hnames <- c("", hnames)
  }
  ft <- flextable(data)
  ft <- set_header(ft, values = hnames )

  def_cell_pr <- pr_cell(border.bottom = pr_border(), border.top = pr_border())
  def_par_pr <- pr_par(padding=2, text.align = "right")
  def_text_pr <- pr_text(bold = TRUE)
  ft <- set_style(ft, def_cell_pr, def_par_pr, part = "body" )
  ft <- set_style(ft, def_cell_pr, def_par_pr, def_text_pr, part = "header" )
  ft
}


#' @export
#' @rdname flextable
print.flextable <- function(x, ...){
  if( interactive())
    print(tabwid(x))
  else invisible()
}


#' @rdname flextable
#' @export
dim.flextable <- function(x){
  max_widths <- list()
  max_heights <- list()
  if( !is.null(x$header)){
    dimensions_ <- get_dimensions(x$header)
    max_widths$header <- dimensions_$widths
    max_heights$header <- dimensions_$heights
  }
  if( !is.null(x$body)){
    dimensions_ <- get_dimensions(x$body)
    max_widths$body <- dimensions_$widths
    max_heights$body <- dimensions_$heights
  }
  if( !is.null(x$footer)){
    dimensions_ <- get_dimensions(x$footer)
    max_widths$footer <- dimensions_$widths
    max_heights$footer <- dimensions_$heights
  }

  mat_widths <- do.call("rbind", max_widths)
  out_widths <- apply( mat_widths, 2, max )
  names(out_widths) <- x$col_keys
  list(width = out_widths, height = as.double(unlist(max_heights)))
}


#' @importFrom purrr map_lgl
#' @rdname flextable
#' @param x \code{flextable} to modify
#' @param ... see section \code{Formatting data values} and
#' \code{Styling - formatting properties}.
#' @section Formatting data values:
#'
#' Use format_that or format_simple to define cell content.
#'
#' @seealso \code{\link{formatting_functions}}
#' @examples
#'
#' # Formatting data values example ------
#' ft <- vanilla_table(head( mtcars, n = 10))
#' ft <- set_display(ft, i = ~ drat > 3.5,
#'   gear = format_that("# {{ carb_ }}",
#'     carb_ = ftext(carb, pr_text(color="orange") ) ) )
#' write_docx("format_ft.docx", ft)
#' @export
set_display <- function(x, i = NULL, part = "body", ...){
  args <- lazy_dots(... )
  stopifnot(all( names(args) %in% x$col_keys ) )

  if( inherits(i, "formula") && any( c("header", "footer") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
    i <- which( i )
  } else i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], names(args) )
  lazy_f_id <- map_chr(args, digest )
  x[[part]]$style_ref_table$formats[lazy_f_id] <- args
  x[[part]]$styles$formats[i, j ] <- matrix( rep.int(lazy_f_id, length(i)), nrow = length(i), byrow = TRUE )
  x
}

#' @export
#' @param part partname of the table
#' @param i rows selection
#' @param j columns selection
#' @importFrom lazyeval lazy_eval
#' @importFrom stats terms update
#' @rdname flextable
#' @section Styling - formatting properties:
#'
#' Table text, paragraphs and cells can be modified with
#' \code{set_style} function.
#'
#' @examples
#'
#' # Styles example ------
#' def_cell <- pr_cell(border.bottom = pr_border(),
#'   border.top = pr_border(),
#'   border.left = pr_border(),
#'   border.right = pr_border())
#'
#' def_par <- pr_par(text.align = "center")
#'
#' ft <- flextable(mtcars)
#'
#' ft <- set_style( ft, def_cell, def_par, parts = c("body"))
#' ft <- set_style( ft, def_cell, def_par, parts = c("header"))
#' ft <- set_style(ft, ~ drat > 3.5, ~ vs + am + gear + carb,
#'   pr_text(color="red", italic = TRUE) )
#'
#' write_docx("style_ft.docx", ft)
set_style <- function(x, ..., i = NULL, j = NULL, part = "body" ){

  if( inherits(i, "formula") && any( c("header", "footer") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  } else i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  } else j <- get_columns_id(x[[part]], j )

  args <- list(...)
  for(arg in args )
    x[[part]] <- set_formatting_properties(x[[part]], i = i, j = j, arg )

  x
}

#' @export
#' @rdname flextable
#' @param color color to use as background color
#' @section Styling - background color:
#'
#' set background color with function \code{set_bg}.
#'
#' @examples
#'
#' # set_bg example ------
#' ft <- flextable(mtcars)
#' ft <- set_bg(ft, color = "#DDDDDD", part = "header")
set_bg <- function(x, i = NULL, j = NULL, color, part = "body" ){

  if( inherits(i, "formula") && any( c("header", "footer") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )

  for(i_ in i){
    for(j_ in j){
      cp_ <- get_pr_cell(x[[part]], i = i_, j = j_)
      cp_ <- update(cp_, background.color = color )
      x[[part]] <- set_formatting_properties(x[[part]], i = i_, j = j_, cp_ )
    }
  }

  x
}


#' @importFrom purrr map map_chr
#' @export
#' @rdname flextable
#' @param border.bottom,border.left,border.top,border.right \code{\link{pr_border}} for borders.
#' @section Styling - borders:
#'
#' set cell borders with function \code{set_border}.
#'
#' @examples
#'
#' # set_bg example ------
#' ft <- flextable(mtcars)
#' ft <- set_border(ft, border.top = pr_border(color = "orange") )
set_border <- function(x, i = NULL, j = NULL,
                       border.top = NULL, border.bottom = NULL,
                       border.left = NULL, border.right = NULL,
                       part = "body" ){

  if( inherits(i, "formula") && any( c("header", "footer") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
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
  new_key <- map_chr(new_cells, digest )
  x[[part]]$style_ref_table$cells[new_key] <- new_cells
  x[[part]]$styles$cells[i,j] <- matrix( new_key[match( x[[part]]$styles$cells[i,j], names(new_key) )], ncol = length(j) )

  x
}


#' @importFrom purrr map_int
#' @importFrom stats setNames
#' @importFrom dplyr left_join
#' @importFrom purrr map
#' @importFrom purrr map_int
#' @export
#' @title set flextable's headers
#'
#' @description The definition of flextable's headers can be done
#' in different manner.
#'
#' @param x a \code{flextable} object
#' @param ... a named list (names are data colnames) with character
#' values specifying in reverse order content of the column.
#' @param data_mapping a \code{data.frame} specyfing for each colname
#' content of the column.
#' @param key column to use as key when joigning data_mapping.
#' @param values character vector indicating colnames' labels.
#' @examples
#'
#' # set_header - method 1 ------
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header(ft_1,
#'   values = c("Sepal length", "Sepal width",
#'              "Petal length", "Petal width", "Species") )
#' write_docx("ft_1.docx", ft_1)
#'
#' # set_header - method 2 ------
#' ft_2 <- flextable( head( iris ))
#' ft_2 <- set_header(x = ft_2,
#'   Sepal.Length = list("Sepal", "Length"),
#'   Sepal.Width = list("Sepal", "Width"),
#'   Petal.Length = list("Petal", "Length"),
#'   Petal.Width = list("Petal", "Width"),
#'   Species = list("Species", "Species") )
#' write_docx("ft_2.docx", ft_2)
#'
#' # set_header - method 3 ------
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#'
#' ft_3 <- flextable( head( iris ))
#' ft_3 <- set_header(ft_3, data_mapping = typology, key = "col_keys" )
#' write_docx("ft_3.docx", ft_3)
set_header <- function(x, ..., data_mapping = NULL, key = "col_keys", values = NULL){

  if( !is.null(values) && !is.character(values) ){
    stop("values is expected to be a character vector")
  }
  if( !is.null(values) && length(values) != length(x$col_keys) ){
    stop("values' length should be ", length(x$col_keys) )
  }
  args <- list(...)[x$col_keys]

  if( !is.null(values) ){
    header_data <- setNames(as.list(values), x$col_keys)
    header_data <- as.data.frame(header_data, stringsAsFactors = FALSE )
  } else if( !is.null(data_mapping) ) {
    keys <- data.frame( col_keys = data_mapping[[key]], stringsAsFactors = FALSE )
    names(keys) <- key
    # keys <- keys[ keys[[key]] %in% x$col_keys, , drop = FALSE]
    header_data <- left_join(keys, data_mapping, by = setNames(key, key) )
    header_data <- header_data[ header_data[[key]] %in% x$col_keys, ]

    header_data[[key]] <- NULL
    header_data <- map(header_data, function(x){
      if( is.character(x))
        x
      else if( is.integer(x) || is.logical(x) || is.factor(x) )
        as.character(x)
      else if( is.double(x) )
        formatC(x)
      else format(x)
    })
    header_data <- do.call( rbind, header_data )
    dimnames(header_data) <- NULL
    header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)
    names(header_data) <- x$col_keys
  } else if( length(args) > 0 ) {
    args <- list(...)[x$col_keys]
    missing_cols <- setdiff(x$col_keys, names(args) )
    l_ <- map_int( args, length )
    args <- map( args, function(x, s){
      dat <- as.list(character(s))
      dat[seq_along(x)] <- rev(x)
      dat
    }, s = max(l_) )

    header_data <- as.data.frame( map(args, format), stringsAsFactors = FALSE )
    if( length(missing_cols) > 0){
      missing_data <- lapply( missing_cols, function(x, s) character(s), max(l_) )
      names(missing_data) <- missing_cols
      missing_data <- as.data.frame(missing_data)
      header_data <- cbind(header_data, missing_data)[, x$col_keys]
    }
  } else {
    stop("unimplemened case")
  }

  header_ <- table_part( data = header_data, col_keys = x$col_keys )
  header_ <- span_rows(header_, rows = seq_len(nrow(header_data)))
  x$header <- span_columns(header_, x$col_keys)
  x
}



#' @importFrom knitr knit_print
#' @importFrom knitr asis_output
#' @rdname flextable
#' @export
knit_print.flextable<- function(x, ...){
  print(tabwid(x))
}


