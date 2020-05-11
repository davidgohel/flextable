#' @importFrom htmltools htmlDependency
#' @export
#' @title htmlDependency for flextable objects
#' @description When using loops in an R Markdown for HTML document, the
#' htmlDependency object for flextable must also be added at least once.
#' @examples
#' if(require("htmltools"))
#'   div(flextable_html_dependency())
flextable_html_dependency <- function(){
  htmlDependency("tabwid",
                 "1.0.0",
                 src = system.file(package="flextable", "web_1.0.0"),
                 stylesheet = "tabwid.css", script = "tabwid.js")

}

#' @export
#' @title flextable as a div object
#'
#' @description get a \code{\link[htmltools]{div}} from a flextable object.
#' This can be used in a shiny application.
#'
#' Argument `ft.align` can be specified also as knitr chunk options.

#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param class css classes (default to "tabwid"), if ft.align is set to 'left' or 'right',
#' class 'tabwid_left' or 'tabwid_right' will be added to class.
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @family flextable print function
#' @examples
#' htmltools_value(flextable(iris[1:5,]))
htmltools_value <- function(
  x, ft.align = opts_current$get("ft.align"), class = "tabwid", bookdown = FALSE
){

  if( is.null(ft.align) ) ft.align <- "center"

  if( "left" %in% ft.align )
    tab_class <- paste0(class, " tabwid_left")
  else if( "right" %in% ft.align )
    tab_class <- paste0(class, " tabwid_right")
  else tab_class <- class

  codes <- html_str(x, bookdown = bookdown)
  html_o <- div( class=tab_class,
                 flextable_html_dependency(),
                 HTML(as.character(codes))
  )
  html_o
}

#' @export
#' @title flextable Office Open XML string for Word
#'
#' @description get openxml raw code for Word
#' from a flextable object.
#'
#' The function is particularly useful when you want
#' to generate flextable in a loop from a R Markdown document.
#' By default, the output is printed and is returned as a
#' character scalar.
#'
#' When used inside an R Markdown document, chunk option `results`
#' must be set to 'asis'.
#'
#' Arguments `ft.align` and `ft.split` can be
#' specified also as knitr chunk options.
#' @param x a flextable object
#' @param print print output if TRUE
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.split Word option 'Allow row to break across pages' can be
#' activated when TRUE.
#' @inheritParams htmltools_value
#' @family flextable print function
#' @examples
#' docx_value(flextable(iris[1:5,]))
#' @importFrom officer opts_current_table block_caption styles_info run_autonum to_wml
docx_value <- function(x, print = TRUE,
                       ft.align = opts_current$get("ft.align"),
                       ft.split = opts_current$get("ft.split"),
                       bookdown = FALSE){

  if( is.null(ft.align) ) ft.align <- "center"
  if( is.null(ft.split) ) ft.split <- FALSE

  tab_props <- opts_current_table()
  if(!is.null(x$caption$value)){
    bc <- block_caption(label = x$caption$value, style = x$caption$style,
                        autonum = x$caption$autonum)
    caption <- to_wml(bc, knitting = TRUE)
  } else if(!is.null(tab_props$cap) && !is.null(tab_props$id)) {
    bc <- block_caption(label = tab_props$cap, style = tab_props$cap.style,
                        autonum = run_autonum(
                          seq_id = gsub(":$", "", tab_props$tab.lp),
                          pre_label = tab_props$cap.pre,
                          post_label = tab_props$cap.sep,
                          bkm = tab_props$id
                        ))
    caption <- to_wml(bc, knitting = TRUE)
  } else if(bookdown) {
    bkm <- opts_current$get("label")
    caption <- paste0(
      "\n\n::: {custom-style=\"",
      tab_props$cap.style,
      "\"}\n\n",
      "<caption>", ref_label(), tab_props$cap, "</caption>",
      "\n\n", ":::\n\n")
  }  else if(!is.null(tab_props$cap)) {
    caption <- paste0(
      "\n\n::: {custom-style=\"", tab_props$cap.style,
      "\"}\n\n", tab_props$cap, ":::\n\n")
  } else caption <- ""

  out <- paste(caption,
      "```{=openxml}",
      docx_str(x, align = ft.align, split = ft.split),
      "```\n\n", sep = "\n")
  if( print) cat(out)
  invisible(out)
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
#' @family flextable print function
#' @importFrom utils browseURL
#' @importFrom officer read_pptx add_slide read_docx
print.flextable <- function(x, preview = "html", ...){
  if (!interactive() || "log" %in% preview ){
    cat("a flextable object.\n")
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
    doc <- ph_with(doc, value = x, location = ph_location_type(type = "body"))
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

#' @title Render flextable in rmarkdown
#' @description Function used to render flextable in knitr/rmarkdown documents.
#' HTML, Word and PowerPoint outputs are supported.
#' @note
#' For Word (docx) output, if pandoc version >= 2.0 is used, a raw XML block
#' with the table code will be inserted. If pandoc version < 2.0 is used, an
#' error will be raised. Insertion of images is not supported
#' with rmarkdown for Word documents (use the package officedown instead).
#' For PowerPoint (pptx) output, if pandoc version < 2.4 is used, an error
#' will be raised.
#'
#' @section HTML chunk options:
#' Result can be aligned with chunk option \code{ft.align} that
#' accepts values 'left', 'center' and 'right'.
#'
#' @section Word chunk options:
#' Result can be aligned with chunk option \code{ft.align} that
#' accepts values 'left', 'center' and 'right'.
#'
#' Word option 'Allow row to break across pages' can be
#' activated with chunk option \code{ft.split} set to TRUE.
#'
#' Table captioning is a flextable feature compatible with knitr. Three methods are available and are presented below in order of triggering:
#'
#' * with the `set_caption` function, if the function is used, this definition will be chosen.
#' * with knitr's chunk options:
#'
#'     * `tab.cap.style`: Word style name to use for table captions.
#'     * `tab.cap.pre`: Prefix for numbering chunk (default to "Table").
#'     * `tab.cap.sep`: Suffix for numbering chunk (default to ": ").
#'     * `tab.cap`: Caption label.
#'     * `tab.id`: Caption reference unique identifier.
#'
#' * with knitr chunk and bookdown options (if you're in a bookdown):
#'
#'     * `tab.cap.style`: Word style name to use for table captions.
#'     * `tab.cap.pre`: Prefix for numbering chunk (default to "Table").
#'     * `tab.cap.sep`: Suffix for numbering chunk (default to ": ").
#'     * `tab.cap`: Caption label.
#'     * `label`: Caption reference unique identifier.
#'
#' @section PowerPoint chunk options:
#' Position should be defined with options \code{ft.left}
#' and \code{ft.top}. Theses are the top left coordinates
#' of the placeholder that will contain the table. They
#' default to \code{{r ft.left=1, ft.left=2}}.
#'
#' @section PDF chunk options:
#'
#' Using flextable with template `pdf_document` is OK if the
#' flextable fits on one single page. The PDF output is not
#' a real latex output but a PNG image generated with package
#' 'webshot' or package 'webshot2'. Package 'webshot2' should
#' be prefered as 'webshot' can have issues with some properties
#' (i.e. bold are not rendered for some users).
#'
#' To specify usage of 'webshot2', use chunk option `webshot="webshot2"`.
#'
#' @param x a \code{flextable} object
#' @param ... further arguments, not used.
#' @export
#' @author Maxim Nazarov
#' @importFrom utils getFromNamespace
#' @importFrom htmltools HTML div
#' @importFrom knitr knit_print asis_output opts_knit opts_current fig_path
#' @importFrom rmarkdown pandoc_version
#' @importFrom stats runif
#' @importFrom graphics plot par
#' @family flextable print function
#' @examples
#'
#' # simple examples -----
#' demo_docx <- system.file(package = "flextable", "examples/rmd", "demo.Rmd")
#' rmd_file <- tempfile(fileext = ".Rmd")
#' file.copy(demo_docx, to = rmd_file, overwrite = TRUE)
#' rmd_file # R Markdown document used for demo
#' if(require("rmarkdown", quietly = TRUE)){
#' #  knitr::opts_chunk$set(webshot = "webshot2")
#' #  render(input = rmd_file, output_format = "word_document", output_file = "doc.docx")
#' #  render(input = rmd_file, output_format = "pdf_document", output_file = "doc.pdf")
#' #  render(input = rmd_file, output_format = "html_document", output_file = "doc.html")
#' #  render(input = rmd_file, output_format = "powerpoint_presentation", output_file = "pres.pptx")
#' #  render(input = rmd_file, output_format = "slidy_presentation", output_file = "slidy.html")
#' #  render(input = rmd_file, output_format = "beamer_presentation", output_file = "beamer.pdf")
#' #  render(input = rmd_file, output_format = "pagedown::html_paged", output_file = "paged.html")
#' }
#'
#'
#' # looping examples for Word output -----
#' demo_loop <- system.file(package = "flextable", "examples/rmd", "loop_docx.Rmd")
#' rmd_file <- tempfile(fileext = ".Rmd")
#' file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
#' rmd_file # R Markdown document used for demo
#' if(require("rmarkdown", quietly = TRUE)){
#' #  render(input = rmd_file, output_format = "word_document", output_file = "loop_docx.docx")
#' }
#'
#' # looping examples for HTML output -----
#' demo_loop <- system.file(package = "flextable", "examples/rmd", "loop_html.Rmd")
#' rmd_file <- tempfile(fileext = ".Rmd")
#' file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
#' rmd_file # R Markdown document used for demo
#' if(require("rmarkdown", quietly = TRUE)){
#' #  render(input = rmd_file, output_format = "html_document", output_file = "loop_html.html")
#' }
knit_print.flextable <- function(x, ...){

  is_bookdown <- isTRUE(opts_knit$get('bookdown.internal.label'))

  if ( is.null(opts_knit$get("rmarkdown.pandoc.to"))){
    knit_print(asis_output(html_str(x)))
  } else if ( grepl( "(html|slidy)", opts_knit$get("rmarkdown.pandoc.to") ) ) {
    tab_class <- "tabwid"

    if( !is.null(align <- opts_current$get("ft.align")) ){
      if( align == "left")
        tab_class <- "tabwid tabwid_left"
      else if( align == "right")
        tab_class <- "tabwid tabwid_right"
    }
    knit_print(htmltools_value(x, class = tab_class, bookdown = is_bookdown))
  } else if ( grepl( "(latex|beamer)", opts_knit$get("rmarkdown.pandoc.to") ) ) {

    if( is.null( webshot_package <- opts_current$get("webshot")) ){
      webshot_package <- "webshot"
    }
    if( requireNamespace(webshot_package, quietly = TRUE) ){
      # copied from https://github.com/ropensci/magick/blob/1e92b8331cd2cad6418b5e738939ac5918947a2f/R/base.R#L126
      webshot_fun <- getFromNamespace('webshot', webshot_package)

      plot_counter <- getFromNamespace('plot_counter', 'knitr')
      in_base_dir <- getFromNamespace('in_base_dir', 'knitr')
      tmp <- fig_path("png", number = plot_counter())
      width <- flextable_dim(x)$width
      height <- flextable_dim(x)$height
      # save relative to 'base' directory, see discussion in #110
      in_base_dir({
        dir.create(dirname(tmp), showWarnings = FALSE, recursive = TRUE)
        tf <- tempfile(fileext = ".html", tmpdir = ".")
        save_as_html(x = x, path = tf)
        webshot_fun(url = basename(tf),
                    file = tmp, selector = "body > table",
                    zoom = 3, expand = 0 )
        unlink(tf)
      })
      knit_print( asis_output(sprintf("\\includegraphics[width=%.02fin,height=%.02fin,keepaspectratio]{%s}\n", width, height, tmp)) )
    }
  } else if (grepl( "docx", opts_knit$get("rmarkdown.pandoc.to") )) {

    if (pandoc_version() >= 2) {
      str <- docx_value(x, print = FALSE, bookdown = is_bookdown)
      knit_print( asis_output(str) )
    } else {
      stop("pandoc version >= 2.0 required for flextable rendering in docx")
    }

  } else if (grepl( "pptx", opts_knit$get("rmarkdown.pandoc.to") ) ) {
    if (pandoc_version() < 2.4) {
      stop("pandoc version >= 2.4 required for printing flextable in pptx")
    }

    if( is.null(left <- opts_current$get("ft.left")) )
      left <- 1
    if( is.null(top <- opts_current$get("ft.top")) )
      top <- 2
    uid <- as.integer(runif(n=1) * 10^9)
    str <- pml_flextable(x, uid = uid, offx = left, offy = top, cx = 10, cy = 6)

    caption <- ""
    if(is_bookdown && !is.null(opts_current$get("tab.cap"))) {
      bkm <- opts_current$get("label")
      caption <- paste0("<caption>", ref_label(), opts_current$get("tab.cap"), "</caption>\n\n")
    }
    knit_print( asis_output(
      paste(caption, "```{=openxml}", str, "```", sep = "\n")
    ) )


  } else {
    stop("unsupported format for flextable rendering:", opts_knit$get("rmarkdown.pandoc.to"))
  }
}

#' @export
#' @title save a flextable in an HTML file
#' @description save a flextable in an HTML file. This function
#' is useful to save the flextable in HTML file without using
#' R Markdown (it is highly recommanded to use R Markdown
#' instead).
#' @param x a flextable object
#' @param path HTML file to be created
#' @examples
#' ft <- flextable( head( mtcars ) )
#' tf <- tempfile(fileext = ".html")
#' save_as_html(ft, tf)
#' @family flextable print function
save_as_html <- function(x, path){

  if( !inherits(x, "flextable"))
    stop("x is not a flextable")

  str <- paste('<!DOCTYPE htm><html><head>',
  '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',
  '<meta name="viewport" content="width=device-width, initial-scale=1.0"/>',
  '<title>', deparse(substitute(x)), '</title></head>',
  '<body>', html_str(x),
  '</body></html>')
  cat(str, file = path)
  invisible(path)
}



#' @export
#' @title save flextable objects in an PowerPoint file
#' @description sugar function to save flextable objects in an PowerPoint file.
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as slide titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as slide titles. If provided, argument \code{...} will be ignored.
#' @param path PowerPoint file to be created
#' @examples
#' ft1 <- flextable( head( iris ) )
#' tf <- tempfile(fileext = ".pptx")
#' save_as_pptx(ft1, path = tf)
#'
#' ft2 <- flextable( head( mtcars ) )
#' tf <- tempfile(fileext = ".pptx")
#' save_as_pptx(`iris table` = ft1, `mtcars table` = ft2, path = tf)
#' @family flextable print function
save_as_pptx <- function(..., values = NULL, path){

  if( is.null(values) ){
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)
  z <- read_pptx()
  for( i in seq_along(values) ){
    z <- add_slide(z)
    if(show_names){
      z <- ph_with(z, titles[i], location = ph_location_type(type = "title") )
    }
    z <- ph_with(z, values[[i]], location = ph_location_type(type = "body") )
  }
  print(z, target = path )
  invisible(path)
}



#' @export
#' @title save flextable objects in an Word file
#' @description sugar function to save flextable objects in an Word file.
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as titles. If provided, argument \code{...} will be ignored.
#' @param path Word file to be created
#' @examples
#' ft1 <- flextable( head( iris ) )
#' tf <- tempfile(fileext = ".docx")
#' save_as_docx(ft1, path = tf)
#'
#'
#' ft2 <- flextable( head( mtcars ) )
#' tf <- tempfile(fileext = ".docx")
#' save_as_docx(`iris table` = ft1, `mtcars table` = ft2, path = tf)
#' @family flextable print function
#' @importFrom officer body_add_par
save_as_docx <- function(..., values = NULL, path){

  if( is.null(values) ){
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)

  z <- read_docx()
  for( i in seq_along(values) ){
    if(show_names){
      z <- body_add_par(z, titles[i], style = "heading 2" )
    }
    z <- body_add_flextable(z, values[[i]] )
  }
  print(z, target = path )
  invisible(path)
}



#' @export
#' @title save a flextable as an image
#' @description save a flextable as a png, pdf or jpeg image.
#'
#' Image generated with package 'webshot' or package 'webshot2'.
#' Package 'webshot2' should be prefered as 'webshot' can have
#' issues with some properties (i.e. bold are not rendered for some users).
#' @note This function requires package webshot or webshot2.
#' @param x a flextable object
#' @param path image file to be created. It should end with .png, .pdf, or .jpeg.
#' @param zoom,expand parameters used by \code{webshot} function.
#' @param webshot webshot package as a scalar character, one of "webshot" or
#' "webshot2".
#' @examples
#' ft <- flextable( head( mtcars ) )
#' ft <- autofit(ft)
#' tf <- tempfile(fileext = ".png")
#' \dontrun{
#' if( require("webshot") ){
#'   save_as_image(x = ft, path = "myimage.png")
#' }
#' }
#' @family flextable print function
save_as_image <- function(x, path, zoom = 3, expand = 10, webshot = "webshot" ){

  if( !inherits(x, "flextable")){
    stop("x must be a flextable")
  }

  if (!requireNamespace(webshot, quietly = TRUE)) {
    stop("package ", webshot, " is required when saving a flextable as an image.")
  } else webshot_fun <- getFromNamespace('webshot', webshot)

  curr_wd <- getwd()
  path <- absolute_path(path)

  tf <- tempfile(fileext = ".html")
  save_as_html(x = x, path = tf)
  setwd(dirname(tf))
  tryCatch({
    webshot_fun(url = basename(tf),
                   file = path, selector = "body > table",
                   zoom = zoom, expand = expand )
  }, finally = {
    setwd(curr_wd)
  })

  path
}


#' @export
#' @title plot a flextable
#' @description save a flextable as an image and display the
#' result in a new R graphics window.
#' @note This function requires packages: webshot and magick.
#' @param x a flextable object
#' @param zoom,expand parameters used by \code{webshot} function.
#' @param ... additional parameters sent to [as_raster()] function
#' @examples
#' ftab <- flextable( head( mtcars ) )
#' ftab <- autofit(ftab)
#' \dontrun{
#' if( require("webshot") ){
#'   plot(ftab)
#' }
#' }
#' @family flextable print function
#' @importFrom grDevices as.raster
plot.flextable <- function(x, zoom = 2, expand = 2, ... ){
  img <- as_raster(x = x, zoom = zoom, expand = expand)
  par(mar = rep(0, 4))
  plot(grDevices::as.raster(img, ...))
}

#' @export
#' @title get a flextable as a raster
#' @description save a flextable as an image and return the corresponding
#' raster. This function has been implemented to let flextable be printed
#' on a ggplot object.
#' @note This function requires packages: webshot and magick.
#' @param x a flextable object
#' @param zoom,expand parameters used by \code{webshot} function.
#' @param webshot webshot package as a scalar character, one of "webshot" or
#' "webshot2".
#' @importFrom grDevices as.raster
#' @examples
#' ft <- qflextable( head( mtcars ) )
#' \dontrun{
#' if( require("ggplot2") && require("webshot") ){
#'   print(qplot(speed, dist, data = cars, geom = "point"))
#'   grid::grid.raster(as_raster(ft))
#' }
#' }
#' @family flextable print function
as_raster <- function(x, zoom = 2, expand = 2, webshot = "webshot"){
  if (!requireNamespace(webshot, quietly = TRUE)) {
    stop("package webshot is required when saving a flextable as an image.")
  }
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("package magick is required when saving a flextable as an image.")
  }
  path <- tempfile(fileext = ".png")
  save_as_image(x, path, zoom = zoom, expand = expand, webshot = webshot )
  magick::image_read(path = path)
}
