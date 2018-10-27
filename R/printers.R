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
#' @title flextable printing
#'
#' @description print a flextable object to format \code{html}, \code{docx},
#' \code{pptx} or as text (not for display but for informative purpose).
#' This function is to be used in an interactive context.
#'
#' @note
#' When argument \code{preview} is set to \code{"docx"} or \code{"pptx"}, an
#' external client linked to these formats (Office is installed) is used to
#' edit a document. The document is saved in the temporary directory of
#' the R session and will be removed when R session will be ended.
#'
#' When argument \code{preview} is set to \code{"html"}, an
#' external client linked to these HTML format is used to display the table.
#' If RStudio is used, the Viewer is used to display the table.
#'
#' Note also that a print method is used when flextable are used within
#' R markdown documents. See \code{\link{knit_print.flextable}}.
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
  } else  if( preview == "html" ){
    print( browsable( htmltools_value(x) ) )
  } else if( preview == "pptx" ){
    doc <- read_pptx()
    doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
    doc <- ph_with_flextable(doc, value = x, type = "body")
    file_out <- print(doc, target = tempfile(fileext = ".pptx"))
    browseURL(file_out)
  } else if( preview == "docx" ){
    doc <- read_docx()
    doc <- body_add_flextable(doc, value = x, align = "center")
    file_out <- print(doc, target = tempfile(fileext = ".docx"))
    browseURL(file_out)
  }

  invisible(NULL)
}

#' @title Render flextable in rmarkdown (including Word output)
#' @description Function used to render flextable in knitr/rmarkdown documents.
#' HTML and Word outputs are supported.
#'
#' Function \code{htmltools_value} return an HTML version of the flextable,
#' this function is to be used within Shiny applications with \code{renderUI()}.
#' @note
#' For Word (docx) output, if pandoc version >= 2.0 is used, a raw XML block
#' with the table code will be inserted. If pandoc version < 2.0 is used, an
#' error will be raised. Note also that insertion of images is not supported
#' with rmarkdow for Word documents. Result can be aligned with
#' chunk option \code{ft.align} that accepts values 'left', 'center'
#' and 'right'.
#'
#' @param x a \code{flextable} object
#' @param ... further arguments, not used.
#' @export
#' @author Maxim Nazarov
#' @importFrom htmltools HTML div
#' @importFrom knitr knit_print asis_output opts_knit opts_current
#' @importFrom rmarkdown pandoc_version
knit_print.flextable <- function(x, ...){

  if (is.null(opts_knit$get("rmarkdown.pandoc.to")))
    stop("`render_flextable` needs to be used as a renderer for ",
         "a knitr/rmarkdown R code chunk (render by rmarkdown)")

  if ( grepl( "^html", opts_knit$get("rmarkdown.pandoc.to") ) ) {
    knit_print(htmltools_value(x))
  } else if (opts_knit$get("rmarkdown.pandoc.to") == "docx") {

    if (pandoc_version() >= 2) {
      # insert rawBlock with Open XML
      if( !is.null( align <- opts_current$get("ft.align") ) ){
        str <- docx_str(x, align = align)
      } else {
        str <- docx_str(x)
      }
      knit_print( asis_output(
        paste("```{=openxml}", str, "```", sep = "\n")
      ) )
    } else {
      stop("pandoc version >= 2.0 required for flextable rendering in docx")
    }

  } else {
    stop("unsupported format for flextable rendering:", opts_knit$get("rmarkdown.pandoc.to"))
  }
}

#' @export
#' @title Encode flextable in a document format.
#'
#' @description Encode flextable in a document format, \code{html}, \code{docx},
#' \code{pptx}.
#'
#' This function is exported so that users can create their own custom
#' component.
#' @param x flextable object
#' @param type one of pptx, docx or html.
#' @param ... unused
#' @examples
#' ft <- flextable(head(iris, n = 2))
#' format(ft, type = "html")
format.flextable <- function(x, type, ...){

  stopifnot( length(type) == 1,
             type %in% c("wml", "pml", "html", "pptx", "docx") )

  if( type %in% "pptx") type <- "pml"
  if( type %in% "docx") type <- "wml"

  if( type == "wml" ){
    out <- docx_str(x, ...)
  } else if( type == "pml" ){
    out <- pml_flextable(x)
  } else if( type == "html" ){
    out <- html_str(x)
  } else stop("unimplemented")
  out
}
