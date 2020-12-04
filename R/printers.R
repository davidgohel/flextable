#' @export
#' @title flextable as an HTML object
#'
#' @description get a [div()] from a flextable object.
#' This can be used in a shiny application. For an output within
#' "R Markdown" document, use [knit_print.flextable].
#' @return an object marked as [HTML] ready to be used within
#' a call to `shiny::renderUI` for example.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @family flextable print function
#' @examples
#' htmltools_value(flextable(iris[1:5,]))
#' @importFrom htmltools tagList
htmltools_value <- function(x, ft.align = "center"){
  html_o <- tagList(flextable_html_dependency(),
                    HTML(html_str(x, ft.align = ft.align, class = "tabwid",
                                  caption = caption_html_str(x, bookdown = FALSE),
                                  shadow = TRUE))
  )
  html_o
}

#' @export
#' @title flextable raw code
#'
#' @description Print openxml, latex or html code of a
#' flextable. The function is particularly useful when you want
#' to generate flextable in a loop from a R Markdown document.
#'
#' Inside R Markdown document, chunk option `results` must be
#' set to 'asis'.
#'
#' All arguments whose name starts with `ft.` can be set in the chunk options.
#'
#' See [knit_print.flextable] for more details.
#'
#'
#' @param x a flextable object
#' @param print print output if TRUE
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.split Word option 'Allow row to break across pages' can be
#' activated when TRUE.
#' @param ft.tabcolsep space between the text and the left/right border of its containing
#' cell, the default value is 8 points.
#' @param ft.arraystretch height of each row relative to its default
#' height, the default value is 1.5.
#' @param ft.left,ft.top Position should be defined with options \code{ft.left}
#' and \code{ft.top}. Theses are the top left coordinates in inches
#' of the placeholder that will contain the table. Their
#' default valuues are 1 and 2 inches.
#' @param webshot webshot package as a scalar character, one of "webshot" or
#' "webshot2".
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @param pandoc2 `TRUE` (default) or `FALSE` to get the string in a pandoc raw HTML attribute
#' (only valid when pandoc version is `>= 2`.
#' @param print print output if TRUE
#' @family flextable print function
#' @examples
#' demo_loop <- system.file(package = "flextable", "examples/rmd", "loop_with_flextable.Rmd")
#' rmd_file <- tempfile(fileext = ".Rmd")
#' file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
#' rmd_file # R Markdown document used for demo
#' if(require("rmarkdown", quietly = TRUE)){
#' #  render(input = rmd_file, output_format = "word_document",
#' #    output_file = "loop_with_flextable.docx")
#' #  render(input = rmd_file, output_format = "html_document",
#' #    output_file = "loop_with_flextable.html")
#' #  render(input = rmd_file,
#' #    output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
#' #    output_file = "loop_with_flextable.pdf")
#' }
#'
flextable_to_rmd <- function(
                             x,
                             ft.align = opts_current$get("ft.align"),
                             ft.split = opts_current$get("ft.split"),
                             ft.tabcolsep = opts_current$get("ft.tabcolsep"),
                             ft.arraystretch = opts_current$get("ft.arraystretch"),
                             ft.left = opts_current$get("ft.left"),
                             ft.top = opts_current$get("ft.top"),
                             webshot = opts_current$get("webshot"),
                             bookdown = FALSE, pandoc2 = TRUE, print = TRUE) {
  str <- ""
  is_xaringan <- !is.null(getOption("xaringan.page_number.offset"))

  if (is.null(opts_knit$get("rmarkdown.pandoc.to"))) {
    # with markdown package ----
    str <- html_value(x,
      ft.align = ft.align, bookdown = FALSE,
      pandoc2 = FALSE, ft.shadow = FALSE
    )
  } else if (is_xaringan) {
    # xaringan ----
    str <- html_value(x,
      ft.align = ft.align, bookdown = FALSE,
      pandoc2 = FALSE, ft.shadow = TRUE
    )
    # return(htmltools_value(x, ft.align = ft.align))
  } else if (grepl("(html|slidy)", opts_knit$get("rmarkdown.pandoc.to"))) {
    #  html ----
    str <- html_value(x, ft.align = ft.align, bookdown = bookdown, pandoc2 = pandoc2)
  } else if (grepl("latex", opts_knit$get("rmarkdown.pandoc.to"))) {
    # latex ----
    str <- latex_value(x,
      ft.tabcolsep = ft.tabcolsep, ft.align = ft.align,
      ft.arraystretch = ft.arraystretch, bookdown = bookdown
    )
  } else if (grepl("docx", opts_knit$get("rmarkdown.pandoc.to"))) {
    # docx ----
    if (pandoc2) {
      str <- docx_value(x,
        bookdown = bookdown, ft.align = ft.align,
        ft.split = ft.split
      )
    } else {
      stop("pandoc version >= 2.0 required for flextable rendering in docx")
    }
  } else if (grepl("pptx", opts_knit$get("rmarkdown.pandoc.to"))) {
    # pptx ----
    if (pandoc_version() < numeric_version("2.4")) {
      stop("pandoc version >= 2.4 required for printing flextable in pptx")
    }
    str <- pptx_value(x, ft.left = ft.left, ft.top = ft.top, bookdown = bookdown)
  } else {
    # default ----
    if (is.null(webshot_package <- webshot)) {
      webshot_package <- "webshot"
    }
    if (requireNamespace(webshot_package, quietly = TRUE)) {
      # copied from https://github.com/ropensci/magick/blob/1e92b8331cd2cad6418b5e738939ac5918947a2f/R/base.R#L126
      plot_counter <- getFromNamespace("plot_counter", "knitr")
      in_base_dir <- getFromNamespace("in_base_dir", "knitr")
      tmp <- fig_path("png", number = plot_counter())
      width <- flextable_dim(x)$width
      height <- flextable_dim(x)$height

      in_base_dir({
        dir.create(dirname(tmp), showWarnings = FALSE, recursive = TRUE)
        save_as_image(x, path = tmp, zoom = 3, expand = 0, webshot = webshot_package)
      })
      str <- sprintf("\\includegraphics[width=%.02fin,height=%.02fin,keepaspectratio]{%s}\n", width, height, tmp)
    }
  }
  if (print) {
    cat(str, "\n", sep = "")
  }
  invisible(str)
}

#' @noRd
#' @title flextable HTML string
#' @description get a string for HTML output with pandoc.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.shadow use shadow dom, this option is existing mainly
#' to disable shadow dom (sett to `FALSE`) for pagedown that can not support it for now.
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @param pandoc2 `TRUE` (default) or `FALSE` to get the string in a pandoc raw HTML attribute.
#' @examples
#' html_value(flextable(iris[1:5,]))
html_value <- function(x, ft.align = opts_current$get("ft.align"), ft.shadow = opts_current$get("ft.shadow"), bookdown = FALSE, pandoc2 = TRUE){

  if(is.null(ft.shadow)){
    ft.shadow <- TRUE
  }

  caption_str <- caption_html_str(x, bookdown = bookdown)
  if(pandoc2 && bookdown) {
    # This is unfortunate but mandatory as bookdown need to scan captions...
    caption_str <- paste0("\n```\n", caption_str, "\n```{=html}\n")
  }
  out <- paste(
    if(pandoc2) "```{=html}",
    html_str(x, ft.align = ft.align, caption = caption_str, shadow = ft.shadow),
    if(pandoc2) "```",
    sep = "\n")
  knit_meta_add(list(flextable_html_dependency()))

  out
}

#' @noRd
#' @title flextable Office Open XML string for Word
#'
#' @description get openxml raw code for Word
#' from a flextable object.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.split Word option 'Allow row to break across pages' can be
#' activated when TRUE.
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @examples
#' docx_value(flextable(iris[1:5,]))
#' @importFrom officer opts_current_table block_caption styles_info run_autonum to_wml
docx_value <- function(x,
                       ft.align = opts_current$get("ft.align"),
                       ft.split = opts_current$get("ft.split"),
                       bookdown = FALSE){

  if( is.null(ft.align) ) ft.align <- "center"
  if( is.null(ft.split) ) ft.split <- FALSE

  caption <- caption_docx_str(x, bookdown = bookdown)
  out <- paste(caption,
      "```{=openxml}",
      docx_str(x, align = ft.align, split = ft.split),
      "```\n\n", sep = "\n")

  out
}

#' @noRd
#' @title flextable latex string for PDF
#'
#' @description get latex raw code for PDF
#' from a flextable object.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.tabcolsep space between the text and the left/right border of its containing
#' cell, the default value is 8 points.
#' @param ft.arraystretch height of each row relative to its default
#' height, the default value is 1.5.
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @examples
#' latex_value(flextable(airquality[1:5,]))
#' @importFrom officer opts_current_table block_caption styles_info run_autonum to_wml
latex_value <- function(x,
                        ft.align = opts_current$get("ft.align"),
                        ft.tabcolsep = opts_current$get("ft.tabcolsep"),
                        ft.arraystretch = opts_current$get("ft.arraystretch"),
                        bookdown) {
  if (is.null(ft.align)) ft.align <- "center"
  if (is.null(ft.tabcolsep)) ft.tabcolsep <- 8
  if (is.null(ft.arraystretch)) ft.arraystretch <- 1.5


  fonts_ignore <- flextable_global$defaults$fonts_ignore
  fontspec_compat <- get_pdf_engine() %in% c("xelatex", "lualatex")
  if (!fonts_ignore && !fontspec_compat) {
    warning("Warning: fonts used in `flextable` are ignored because ",
      "the `pdflatex` engine is used and not `xelatex` or ",
      "`lualatex`. You can avoid this warning by using the ",
      "`set_flextable_defaults(fonts_ignore=TRUE)` command or ",
      "use a compatible engine by defining `latex_engine: xelatex` ",
      "in the YAML header of the R Markdown document.",
      call. = FALSE
    )
  }
  if (fontspec_compat) {
    usepackage_latex("fontspec")
  }
  usepackage_latex("multirow")
  usepackage_latex("multicol")
  usepackage_latex("colortbl")
  usepackage_latex("hhline")
  usepackage_latex("longtable")
  usepackage_latex("array")
  usepackage_latex("hyperref")

  out <- paste(
    cline_cmd,
    latex_str(x,
      ft.align = ft.align,
      ft.tabcolsep = ft.tabcolsep,
      ft.arraystretch = ft.arraystretch,
      bookdown = bookdown
    ),
    sep = "\n\n"
  )
  out
}

pptx_value <- function(x, ft.left = opts_current$get("ft.left"),
                       ft.top = opts_current$get("ft.top"),
                       bookdown = bookdown) {
  if( is.null(ft.left) )
    ft.left <- 1
  if( is.null(ft.top) )
    ft.top <- 2

  uid <- as.integer(runif(n=1) * 10^9)

  str <- pml_flextable(x, uid = uid, offx = ft.left, offy = ft.top, cx = 10, cy = 6)

  caption <- caption_html_str(x, bookdown = bookdown)

  paste(caption, "```{=openxml}", str, "```", sep = "\n")
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
#'
#' You should not call this method directly. This function is used by the knitr
#' package to automatically display a flextable in an "R Markdown" document from
#' a chunk. However, it is recommended to read its documentation in order to get
#' familiar with the different options available.
#'
#' \if{html}{\figure{fig_formats.png}{options: width=200px}} HTML, Word, PowerPoint and PDF outputs are supported.
#'
#'
#' Table captioning is a flextable feature compatible with R Markdown
#' documents. The feature is available for HTML, PDF and Word documents.
#' Compatibility with the "bookdown" package is also ensured, including the
#' ability to produce captions so that they can be used in cross-referencing.
#' @note
#' Supported formats require some
#' minimum [pandoc](https://pandoc.org/installing.html) versions:
#'
#' \tabular{rc}{
#'   \strong{Output format} \tab \strong{pandoc minimal version} \cr
#'   HTML              \tab >= 1.12\cr
#'   Word (docx)       \tab >= 2.0 \cr
#'   PowerPoint (pptx) \tab >= 2.4 \cr
#'   PDF               \tab >= 1.12
#' }
#' @section Chunk options:
#'
#' Some features, often specific to an output format, are available to help you
#' configure some global settings relatve to the table output. knitr's chunk options
#' are to be used to change the default settings:
#'
#' \tabular{lcccccc}{
#'   \strong{chunk option} \tab \strong{property} \tab \strong{default value} \tab \strong{HTML} \tab \strong{docx} \tab \strong{PDF} \tab \strong{pptx} \cr
#'   ft.align        \tab flextable alignment, supported values are 'left', 'center' and 'right'    \tab 'center' \tab yes \tab yes \tab yes \tab no \cr
#'   ft.split        \tab Word option 'Allow row to break across pages' can be activated when TRUE. \tab FALSE    \tab no  \tab yes \tab no  \tab no \cr
#'   ft.tabcolsep    \tab space between the text and the left/right border of its containing cell   \tab 8.0      \tab no  \tab no  \tab yes \tab no \cr
#'   ft.arraystretch \tab height of each row relative to its default height                         \tab 1.5      \tab no  \tab no  \tab yes \tab no \cr
#'   ft.left         \tab left coordinates in inches                                                \tab 1.0      \tab no  \tab no  \tab no  \tab yes\cr
#'   ft.top          \tab top coordinates in inches                                                 \tab 2.0      \tab no  \tab no  \tab no  \tab yes
#' }
#' @section Table caption:
#'
#' Captions can be defined in two ways.
#'
#' The first is with the `set_caption` function. If it is used,
#' the other method will be ignored. The second method is by using
#' knitr chunk option `tab.cap`.
#'
#' ```
#' set_caption(x, caption = "my caption")
#' ```
#'
#'
#' If `set_caption` function is not used, caption identifier will be
#' read from knitr's chunk option `tab.id` or `label` if in a bookdown
#' (this is to respect the bookdown standards).
#'
#' `tab.id='my_id'` or `label='my_id'`
#'
#' Word output provide more options such as ability to choose the prefix for numbering chunk for
#' example. The table below expose these options:
#'
#' \tabular{llll}{
#'   \strong{chunk option} \tab \strong{purpose} \tab \strong{rmarkdown} \tab \strong{bookdown} \cr
#'   tab.cap.style \tab (Word only) style name to use for table captions            \tab yes \tab yes\cr
#'   tab.cap.pre   \tab (Word only) Prefix for numbering chunk (default to "Table") \tab yes \tab yes\cr
#'   tab.cap.sep   \tab (Word only) Suffix for numbering chunk (default to ": ")    \tab yes \tab yes\cr
#'   tab.cap       \tab \strong{Caption label}                                      \tab yes \tab yes\cr
#'   tab.id        \tab \strong{Caption reference unique identifier}                \tab yes \tab no \cr
#'   label         \tab \strong{Caption reference unique identifier}                \tab no  \tab yes
#' }
#' @section HTML output:
#'
#' HTML output is using shadow dom to encapsule the table
#' into an isolated part of the page so that no clash happens
#' with styles. Some output may not support this feature. To our
#' knowledge, only the pagedown output is concerned.
#' Use knitr chunk option `ft.shadow=FALSE` to disable shadow dom.
#'
#' @section PDF output:
#'
#' Some features are not implemented in PDF due to technical
#' infeasibility. These are the padding, line_spacing and
#' height properties.
#'
#' @section PowerPoint output:
#'
#' Auto-adjust Layout is not available for PowerPoint.
#'
#' Also images cannot be integrated into tables with the PowerPoint format.
#'
#' @param x a \code{flextable} object
#' @param ... further arguments, not used.
#' @export
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
#' ## bookdown examples wth captions and cross ref -----
#' # captions_example <- system.file(
#' #   package = "flextable",
#' #   "examples/rmd", "captions_example.Rmd")
#' #
#' # dir_tmp <- tempfile(pattern = "dir")
#' # dir.create(dir_tmp, showWarnings = FALSE, recursive = TRUE)
#' # file.copy(captions_example, dir_tmp)
#' # rmd_file <- file.path(dir_tmp, basename(captions_example))
#' #
#' # file.copy(captions_example, to = rmd_file, overwrite = TRUE)
#' #
#' # if(require("rmarkdown", quietly = TRUE)){
#' #   render(input = rmd_file,
#' #          output_format = word_document(),
#' #          output_file = "doc.docx")
#' #   render(input = rmd_file,
#' #          output_format = pdf_document(latex_engine = "xelatex"),
#' #          output_file = "doc.pdf")
#' #   render(input = rmd_file,
#' #          output_format = html_document(),
#' #          output_file = "doc.html")
#' #
#' #   # bookdown ----
#' #   if(require("bookdown", quietly = TRUE)){
#' #     render(input = rmd_file, output_format = word_document2(),
#' #            output_file = "book.docx")
#' #     render(input = rmd_file,
#' #            output_format = pdf_document2(latex_engine = "xelatex"),
#' #            output_file = "book.pdf")
#' #     render(input = rmd_file,
#' #            output_format = html_document2(),
#' #            output_file = "book.html")
#' #
#' #     # officedown ----
#' #     if(require("officedown", quietly = TRUE)){
#' #       render(input = rmd_file,
#' #              output_format = markdown_document2(base_format=rdocx_document),
#' #              output_file = "officedown.docx")
#' #     }
#' #   }
#' # }
#' # browseURL(dirname(rmd_file))
#'
#'
knit_print.flextable <- function(x, ...){

  is_bookdown <- isTRUE(opts_knit$get('bookdown.internal.label'))
  pandoc2 <- pandoc_version() >= numeric_version("2.0")
  str <- flextable_to_rmd(x, bookdown = is_bookdown, pandoc2 = pandoc2, print = FALSE)
  knit_print(asis_output(str))
}

#' @export
#' @title Save a Flextable in an HTML File
#' @description save a flextable in an HTML file. This function
#' is useful to save the flextable in HTML file without using
#' R Markdown (it is highly recommanded to use R Markdown
#' instead).
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as titles. If provided, argument \code{...} will be ignored.
#' @param path HTML file to be created
#' @param encoding encoding to be used in the HTML file
#' @param title page title
#' @examples
#' ft1 <- flextable( head( iris ) )
#' tf1 <- tempfile(fileext = ".html")
#' save_as_html(ft1, path = tf1)
#' # browseURL(tf1)
#'
#' ft2 <- flextable( head( mtcars ) )
#' tf2 <- tempfile(fileext = ".html")
#' save_as_html(
#'   `iris table` = ft1,
#'   `mtcars table` = ft2,
#'   path = tf2,
#'   title = "rhoooo")
#' # browseURL(tf2)
#' @family flextable print function
save_as_html <- function(..., values = NULL, path, encoding = "utf-8", title = deparse(sys.call())){

  if( is.null(values) ){
    values <- list(...)
  }
  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)

  val <- character(length(values))

  for( i in seq_along(values) ){
    txt <- character(2L)
    if(show_names){
      txt[1] <- paste0("<h2>", titles[i], "</h2>")
    }
    txt[2] <- html_str(values[[i]],
                       caption = caption_html_str(values[[i]], bookdown = FALSE),
                       shadow = FALSE)

    val[i] <- paste(txt, collapse = "")
  }
  tabwid_css <- paste(c("<style>", readLines(system.file(package="flextable", "web_1.0.0", "tabwid.css"), encoding = "UTF-8"), "</style>"), collapse = "\n")

  str <- c('<!DOCTYPE htm><html><head>',
  sprintf('<meta http-equiv="Content-Type" content="text/html; charset=%s"/>', encoding),
  '<meta name="viewport" content="width=device-width, initial-scale=1.0"/>',
  '<title>', title, '</title>', tabwid_css, '</head>',
  '<body style="background-color:transparent;">',
  val,
  '</body></html>')
  writeLines(str, path, useBytes = TRUE)
  invisible(path)
}



#' @export
#' @importFrom officer ph_location_type
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
#' @param pr_section a [prop_section] object that can be used to define page
#' layout such as orientation, width and height.
#' @examples
#'
#' tf <- tempfile(fileext = ".docx")
#'
#' library(officer)
#' ft1 <- flextable( head( iris ) )
#' save_as_docx(ft1, path = tf)
#'
#'
#' ft2 <- flextable( head( mtcars ) )
#' sect_properties <- prop_section(
#'   page_size = page_size(orient = "landscape",
#'     width = 8.3, height = 11.7),
#'   type = "continuous",
#'   page_margins = page_mar()
#' )
#' save_as_docx(`iris table` = ft1, `mtcars table` = ft2,
#'   path = tf, pr_section = sect_properties)
#' @family flextable print function
#' @importFrom officer body_add_par prop_section body_set_default_section
#'   page_size page_mar
save_as_docx <- function(..., values = NULL, path, pr_section = NULL){

  if( is.null(values) ){
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)

  if(is.null(pr_section)){
    pr_section <- prop_section(
      page_size = page_size(orient = "portrait", width = 8.3, height = 11.7),
      type = "continuous",
      page_margins = page_mar()
    )
  }

  if(!inherits(pr_section, "prop_section")){
    stop("pr_section is not a prop_section object, use officer::prop_section.")
  }

  z <- read_docx()

  for( i in seq_along(values) ){
    if(show_names){
      z <- body_add_par(z, titles[i], style = "heading 2" )
    }
    z <- body_add_flextable(z, values[[i]] )
  }
  z <- body_set_default_section(z, pr_section)
  print(z, target = path )
  invisible(path)
}



#' @export
#' @title save a flextable as an image
#' @description save a flextable as a png, pdf or jpeg image.
#'
#' Image generated with package 'webshot' or package 'webshot2'.
#' **Package 'webshot2' should be prefered** as 'webshot' can have
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
                   file = path, selector = "body > div > table",
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
    stop("package webshot2 is required when saving a flextable as an image.")
  }
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("package magick is required when saving a flextable as an image.")
  }
  path <- tempfile(fileext = ".png")
  save_as_image(x, path, zoom = zoom, expand = expand, webshot = webshot )
  magick::image_read(path = path)
}
