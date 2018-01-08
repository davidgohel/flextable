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
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @examples
#' ft <- flextable(mtcars)
#' ft
#' @export
#' @importFrom stats setNames
flextable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){

  stopifnot(is.data.frame(data))
  if( any( duplicated(col_keys) ) ){
    stop("duplicated col_keys")
  }
  if( !all( make.names(col_keys) == col_keys ) ){
    stop("invalid col_keys, flextable support only syntactic names")
  }

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- lapply(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- complex_tabpart( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- complex_tabpart( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  footer_data <- header_data[FALSE, , drop = FALSE]
  footer <- complex_tabpart( data = footer_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, footer = footer, col_keys = col_keys,
               blanks = blanks )
  class(out) <- c("flextable", "complextable")

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")

  out
}

#' @importFrom htmltools htmlDependency
tabwid_htmldep <- function(){
  htmlDependency("tabwid",
                 "1.0.0",
                 src = system.file(package="flextable", "web_1.0.0"),
                 stylesheet = "tabwid.css", script = "tabwid.js")

}

#' @export
#' @rdname knit_print.flextable
htmltools_value <- function(x){
  codes <- html_str(x)
  html_o <- div( class='tabwid',
                 tabwid_htmldep(),
                 HTML(as.character(codes))
  )
}


#' @importFrom htmltools HTML browsable
#' @export
#' @rdname flextable
#' @param x flextable object
#' @param preview preview type, one of c("html", "pptx", "docx", "log").
#' When \code{"log"} is used, a description of the flextable is printed.
#' @param ... unused argument
#' @importFrom utils browseURL
#' @importFrom officer read_pptx add_slide read_docx
print.flextable <- function(x, preview = "html", ...){
  if (!interactive() || "log" %in% preview ){
    cat("type:", ifelse( inherits(x, "regulartable"), "regulartable", "flextable" ), "object.\n")
    cat( "col_keys:", paste0("`", x$col_keys, "`", collapse = ", " ), "\n" )
    cat( "header has", nrow(x$header$dataset), "row(s)", "\n" )
    cat( "body has", nrow(x$body$dataset), "row(s)", "\n" )
    cat("original dataset sample:", "\n")
    print(x$body$dataset[seq_len( min(c(5, nrow(x$body$dataset) ) ) ), ])
  } else {
    if( preview == "html" ){
      print( browsable( htmltools_value(x) ) )
    }else if( preview == "pptx" ){
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

#' @title Render flextable in rmarkdown (including Word output)
#' @description Function used to render flextable in knitr/rmarkdown documents.
#' HTML and Word outputs are supported. Function \code{htmltools_value} return
#' an HTML version of the flextable, this function can to be used within Shiny
#' applications for example.
#' @note
#' For Word (docx) output, if pandoc vesion >= 2.0 is used, a raw XML block
#' with the table code will be inserted. If pandoc vesion < 2.0 is used, an
#' error will be raised. Note also that insertion of images is not supported
#' with rmarkdow for Word documents.
#'
#' @param x a \code{flextable} object
#' @param ... further arguments, not used.
#' @export
#' @author Maxim Nazarov
#' @importFrom htmltools HTML div
#' @importFrom knitr knit_print asis_output opts_knit
#' @importFrom rmarkdown pandoc_version
knit_print.flextable <- function(x, ...){

  if (is.null(opts_knit$get("rmarkdown.pandoc.to")))
    stop("`render_flextable` needs to be used as a renderer for ",
         "a knitr/rmarkdown R code chunk")
  if ( grepl( "^html", opts_knit$get("rmarkdown.pandoc.to") ) ) {
    knit_print(htmltools_value(x))
  } else if (opts_knit$get("rmarkdown.pandoc.to") == "docx") {

    if (pandoc_version() >= 2) {
      # insert rawBlock with Open XML
      knit_print( asis_output(
        paste("```{=openxml}", docx_str(x), "```", sep = "\n")
      ) )
    } else {
      stop("pandoc version >= 2.0 required for flextable rendering in docx")
    }

  } else {
    stop("unsupported format for flextable rendering:", opts_knit$get("rmarkdown.pandoc.to"))
  }
}



