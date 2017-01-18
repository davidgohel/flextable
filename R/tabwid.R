#' @title htmlwidget for flextable
#'
#' @description htmlwidget for flextable
#'
#' @import htmlwidgets
#' @importFrom htmltools HTML
#' @param x \code{flextable} object
#' @param width widget width. Unused argument, columns widths are managed by function width.
#' @param height widget height Unused argument, rows heights are managed by function height.
#'
#' @export
tabwid <- function(x, width = NULL, height = NULL) {

  codes <- html_flextable(x)

  # forward options using x
  x = list(
    html = HTML(codes),
    css = attr(codes, "css")
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'tabwid',
    x,
    width = width,
    height = height,
    package = 'flextable',
    sizingPolicy = sizingPolicy(padding = 5,knitr.figure = FALSE)
  )
}

#' @title Shiny bindings for tabwid
#'
#' @description Output and render functions for using tabwid within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a tabwid
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name tabwid-shiny
#'
#' @export
tabwidOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'tabwid', width, height, package = 'flextable')
}

#' @rdname tabwid-shiny
#' @export
rendertabwid <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, tabwidOutput, env, quoted = TRUE)
}



html_flextable <- function( x ){

  dims <- dim(x)

  out <- "<table>"
  cw <- paste0("<col width=",
         shQuote( round(dims$widths * 72, 0 ), type="cmd"),
         ">",
         collapse = "")
  out = paste0(out, cw )
  css_ <- ""
  if( !is.null(x$header) ){
    tmp <- format(x$header, type = "html", header = TRUE)
    out = paste0(out, "<thead>", tmp, "</thead>" )
    css_ = paste0(css_, attr(tmp, "css"))
  }
  if( !is.null(x$body) ){
    tmp <- format(x$body, type = "html", header = FALSE)
    out = paste0(out, "<tbody>", tmp, "</tbody>" )
    css_ = paste0(css_, attr(tmp, "css"))
  }

  out = paste0(out,  "</table>" )
  attr(out, "css") <- css_
  out
}



