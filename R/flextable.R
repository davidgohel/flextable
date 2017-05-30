#' @title flextable object
#'
#' @description Create a flextable object with function \code{flextable}.
#'
#' \code{flextable} are designed to make tabular reporting easier for
#' R users. Functions are available to let you format text, paragraphs and cells;
#' table cells can be merge vertically or horizontally, row headers can easilly
#' be defined, rows heights and columns widths can be manually set or automatically
#' computed.
#'
#' @details
#' A \code{flextable} is made of 2 parts: header and body.
#'
#' Most functions have an argument named \code{part} that will be used
#' to specify what part of of the table should be modified.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes.
#' @examples
#' ft <- flextable(mtcars)
#' ft
#' @export
#' @importFrom stats setNames
#' @importFrom purrr map
flextable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- map(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- table_part( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- table_part( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, col_keys = col_keys,
               blanks = blanks )
  class(out) <- "flextable"

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")

  out
}

#' @importFrom htmltools HTML browsable
#' @export
#' @rdname flextable
#' @param x flextable object
#' @param ... unused argument
print.flextable <- function(x, ...){
  if (!interactive() ){
    print(x$body$dataset)
  } else {
    html_ft <- html_flextable(x)
    tcss <- scan(system.file(package = "flextable",
                             "htmlwidgets/customcss/tabwid.css"),
                 what = "character", quiet = TRUE, sep = "\n")
    tcss <- paste(tcss, collapse = "\n")
    html_ <- paste0("<style type=\"text/css\">", attr(html_ft, "css"), "</style>",
                    "<style type=\"text/css\">\n", tcss, "</style>",
                    "<div class=\"tabwid\">", html_ft, "</div>" )
    print( browsable( HTML( html_ ) ) )
  }

}


#' @importFrom purrr map
#' @importFrom purrr map_int
#' @export
#' @title Add a row of labels in headers
#'
#' @description Add a single row of labels in the flextable's header part. It can
#' be inserted at the top or the bottom of header part.
#'
#' @details
#' An horizontal and a vertical merge are performed automatically.
#' Use \code{\link{merge_none}} to drop theses merging instructions.
#'
#' @param x a \code{flextable} object
#' @param top should the row be inserted at the top or the bottom.
#' @param ... a named list (names are data colnames) of strings
#' specifying corresponding labels to add.
#' @examples
#' ft <- flextable( head( iris ),
#'   col_keys = c("Species", "Sepal.Length", "Petal.Length", "Sepal.Width", "Petal.Width") )
#' ft <- add_header(x = ft, Sepal.Length = "length",
#'   Sepal.Width = "width", Petal.Length = "length",
#'   Petal.Width = "width", Species = "Species", top = FALSE )
#' ft <- add_header(ft, Sepal.Length = "Inches",
#'   Sepal.Width = "Inches", Petal.Length = "Inches",
#'   Petal.Width = "Inches", Species = "Species", top = TRUE )
#' ft <- merge_h(ft, part = "header")
#' ft
add_header <- function(x, top = TRUE, ...){

  args <- list(...)
  args_ <- map(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- map(args, format)
  header_data <- as.data.frame( args_, stringsAsFactors = FALSE )
  x$header <- add_rows( x$header, header_data, first = top )

  x
}



#' @title Set flextable's headers labels
#'
#' @description This function set labels for specified columns
#' in a single row header of a flextable.
#'
#' @param x a \code{flextable} object
#' @param ... a named list (names are data colnames), each element is a single character
#' value specifying label to use.
#' @examples
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header_labels(ft_1, Sepal.Length = "Sepal length",
#'   Sepal.Width = "Sepal width", Petal.Length = "Petal length",
#'   Petal.Width = "Petal width"
#' )
#' ft_1
#' @export
set_header_labels <- function(x, ...){

  args <- list(...)

  if( nrow(x$header$dataset) < 1 )
    stop("there is no header row to be replaced")

  header_ <- x$header$dataset

  values <- as.list(tail(x$header$dataset, n = 1))
  args <- args[is.element(names(args), x$col_keys)]
  values[names(args)] <- args

  x$header$dataset <- bind_rows( header_[-nrow(header_),],
             as.data.frame(values, stringsAsFactors = FALSE, check.names = FALSE ))
  x
}




#' @importFrom dplyr left_join funs mutate_at
#' @importFrom purrr map
#' @export
#' @title Set flextable's header rows
#'
#' @description Use a data.frame to specify flextable's header rows.
#'
#' The data.frame must contain a column whose values match flextable
#' \code{col_keys} argument, this column will be used as join key. The
#' other columns will be displayed as header rows. The leftmost column
#' is used as the top header row and the rightmost column
#' is used as the bottom header row.
#'
#' @param x a \code{flextable} object
#' @param mapping a \code{data.frame} specyfing for each colname
#' content of the column.
#' @param key column to use as key when joigning data_mapping.
#' @examples
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#'
#' ft <- flextable( head( iris ))
#' ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
#' ft <- merge_h(ft, part = "header")
#' ft <- merge_v(ft, j = "Species", part = "header")
#' ft <- theme_vanilla(ft)
#' ft
set_header_df <- function(x, mapping = NULL, key = "col_keys"){

  keys <- data.frame( col_keys = x$col_keys, stringsAsFactors = FALSE )
  names(keys) <- key
  header_data <- left_join(keys, mapping, by = setNames(key, key) )

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

  if( length(x$blanks) )
    header_data <- mutate_at(header_data, x$blanks, funs(character(length(.)) ) )

  colwidths <- x$header$colwidths
  cheight <- x$header$rowheights[length(x$header$rowheights)]

  x$header <- table_part( data = header_data, col_keys = x$col_keys, cwidth = .75, cheight = cheight )
  x$header$colwidths <- colwidths

  x
}
