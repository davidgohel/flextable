#' @title flextable creation
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

  if( any( duplicated(col_keys) ) ){
    stop("duplicated col_keys")
  }

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- map(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- complex_tabpart( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- complex_tabpart( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, col_keys = col_keys,
               blanks = blanks )
  class(out) <- c("flextable", "complextable")

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")

  out
}

#' @importFrom htmltools HTML browsable
#' @export
#' @rdname flextable
#' @param x flextable object
#' @param preview preview type, one of c("html", "pptx", "docx").
#' @param ... unused argument
#' @importFrom utils browseURL
#' @importFrom officer read_pptx add_slide read_docx
print.flextable <- function(x, preview = "html", ...){
  if (!interactive() ){
    print(x$body$dataset)
  } else {
    if( preview == "html" )
      print(tabwid(x))
    else if( preview == "pptx" ){
      doc <- read_pptx()
      doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
      doc <- ph_with_flextable(doc, value = x, type = "body")
      file_out <- print(doc, target = tempfile(fileext = ".pptx"))
      browseURL(file_out)
      return(invisible())
    } else if( preview == "docx" ){
      doc <- read_docx()
      doc <- body_add_flextable(doc, value = x, align = "center")
      file_out <- print(doc, target = tempfile(fileext = ".docx"))
      browseURL(file_out)
      return(invisible())
    }
  }

}

