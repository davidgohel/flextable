# main ----
#' @export
#' @title flextable as an 'HTML' object
#'
#' @description get a [div()] from a flextable object.
#' This can be used in a shiny application. For an output within
#' "R Markdown" document, use [knit_print.flextable].
#' @return an object marked as [HTML] ready to be used within
#' a call to `shiny::renderUI` for example.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.shadow deprecated.
#' @param extra_dependencies a list of HTML dependencies to
#' add in the HTML output.
#' @family flextable print function
#' @examples
#' htmltools_value(flextable(iris[1:5, ]))
#' @importFrom htmltools tagList
htmltools_value <- function(x, ft.align = NULL, ft.shadow = NULL,
                            extra_dependencies = NULL) {
  x <- flextable_global$defaults$post_process_html(x)

  if (!is.null(ft.align)) {
    x$properties$align <- ft.align
  }

  caption <- caption_default_html(x)
  manual_css <- attr(caption, "css")

  html_o <- tagList(
    if (length(extra_dependencies) > 0) attachDependencies(
      x = tags$style(""),
      extra_dependencies
    ),
    flextable_html_dependencies(x),
    HTML(gen_raw_html(x,
      class = "tabwid",
      caption = caption,
      manual_css = manual_css
    ))
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
#' See [knit_print.flextable] for more details.
#' @param x a flextable object
#' @param ... unused argument
#' @family flextable print function
#' @examples
#' \dontrun{
#' library(rmarkdown)
#' if (pandoc_available() &&
#'   pandoc_version() > numeric_version("2")) {
#'   demo_loop <- system.file(
#'     package = "flextable",
#'     "examples/rmd",
#'     "loop_with_flextable.Rmd"
#'   )
#'   rmd_file <- tempfile(fileext = ".Rmd")
#'   file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
#'   render(
#'     input = rmd_file, output_format = "html_document",
#'     output_file = "loop_with_flextable.html"
#'   )
#' }
#' }
flextable_to_rmd <- function(x, ...) {
  is_bookdown <- is_in_bookdown()
  is_quarto <- is_in_quarto()
  x <- knitr_update_properties(x)

  if (is.null(pandoc_to())) {
    # for 'glossr' test
    return(invisible("```{=html}\n<div class=\"tabwid tabwid_left\"><style></style></div>\n```\n"))
  } else if (is_html_output()) { # html
    type_output <- "html"
  } else if (is_latex_output()) { # latex
    type_output <- "pdf"
  } else if (grepl("docx", opts_knit$get("rmarkdown.pandoc.to"))) { # docx
    type_output <- "docx"
  } else if (grepl("pptx", opts_knit$get("rmarkdown.pandoc.to"))) { # pptx
    type_output <- "pptx"
  } else {
    type_output <- "html"
  }

  if ("html" %in% type_output) {
    x <- flextable_global$defaults$post_process_html(x)
    if (!is_bookdown) {
      caption <- caption_default_html(x)
      manual_css <- attr(caption, "css")
    } else {
      caption <- caption_bookdown_html(x)
      manual_css <- ""
    }
    str <- gen_raw_html(x,
      class = "tabwid",
      caption = caption,
      manual_css = manual_css
    )
    str <- raw_block(str, type = "html")
  } else if ("docx" %in% type_output) {
    str <- knit_to_wml(x, bookdown = is_bookdown, quarto = is_quarto)
  } else if ("pptx" %in% type_output) {
    str <- knit_to_pml(x)
  } else if ("pdf" %in% type_output) {
    str <- knit_to_latex(x, bookdown = is_bookdown, quarto = is_quarto)
    add_latex_dep()
    str <- raw_latex(x = str)
  }
  cat(str)
  invisible("")
}

#' @export
#' @title Get HTML code as a string
#' @description Generate HTML code of corresponding
#' flextable as an HTML table or an HTML image.
#' @param x a flextable object
#' @param type output type. one of "table" or "img".
#' @param ... unused
#' @return If `type='img'`, the result will be a string
#' containing HTML code of an image tag, otherwise, the
#' result will be a string containing HTML code of
#' a table tag.
#' @family flextable print function
#' @examples
#' library(officer)
#' library(flextable)
#' x <- to_html(as_flextable(cars))
to_html.flextable <- function(x, type = c("table", "img"), ...) {
  type_output <- match.arg(type)

  x <- knitr_update_properties(x)

  is_bookdown <- is_in_bookdown()
  is_quarto <- is_in_quarto()

  if ("table" %in% type_output) {
    x <- flextable_global$defaults$post_process_html(x)
    manual_css <- readLines(system.file(package = "flextable", "web_1.1.3", "tabwid.css"), encoding = "UTF-8")
    gen_raw_html(x, class = "tabwid", caption = "", manual_css = paste0(manual_css, collapse = "\n"))
  } else {
    tmp <- tempfile(fileext = ".png")
    dir.create(dirname(tmp), showWarnings = FALSE, recursive = TRUE)
    save_as_image(x, path = tmp, expand = 0, res = 200)
    base64_string <- image_to_base64(tmp)
    width <- flextable_dim(x)$width
    height <- flextable_dim(x)$height
    sprintf("<img style=\"width:%.0fpx;height:%.0fpx;\" src=\"%s\" />", width * 72, height * 72, base64_string)
  }
}

#' @export
to_wml.flextable <- function(x, ...) {
  x <- flextable_global$defaults$post_process_docx(x)
  x <- knitr_update_properties(x)
  gen_raw_wml(x)
}


#' @noRd
#' @title flextable HTML string
#' @description get a string for HTML output with pandoc.
#' @param x a flextable object
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @param quarto `TRUE` or `FALSE` (default).
#' @examples
#' knit_to_html(flextable(iris[1:5, ]))
#' @importFrom knitr raw_html
knit_to_html <- function(x, bookdown = FALSE, quarto = FALSE) {
  x <- flextable_global$defaults$post_process_html(x)

  tab_props <- opts_current_table()
  topcaption <- tab_props$topcaption

  manual_css <- ""
  if (bookdown) {
    caption_str <- caption_bookdown_html(x)
    manual_css <- attr(caption_str, "css")
  } else if (quarto) {
    caption_str <- caption_quarto_html(x)
  } else {
    caption_str <- caption_default_html(x)
    manual_css <- attr(caption_str, "css")
  }

  table_str <- gen_raw_html(x,
    caption = caption_str,
    topcaption = topcaption,
    manual_css = manual_css
  )

  table_str
}


#' @noRd
#' @title flextable Office Open XML string for Word
#' @description get openxml raw code for Word
#' from a flextable object.
#' @importFrom officer opts_current_table run_autonum to_wml
knit_to_wml <- function(x, bookdown = FALSE, quarto = FALSE) {
  x <- flextable_global$defaults$post_process_docx(x)

  is_rdocx_document <- opts_current$get("is_rdocx_document")
  if (is.null(is_rdocx_document)) is_rdocx_document <- FALSE

  tab_props <- opts_current_table()
  topcaption <- tab_props$topcaption

  if (!is.null(tab_props$alt.title)) {
    x$properties$word_title <- tab_props$alt.title
  }
  if (!is.null(tab_props$alt.description)) {
    x$properties$word_description <- tab_props$alt.description
  }

  apply_cap_kwn <- FALSE
  if (topcaption) {
    apply_cap_kwn <- TRUE
  }

  word_autonum <- FALSE
  if (is_rdocx_document || quarto) {
    word_autonum <- TRUE
  }
  if (bookdown) {
    caption <- caption_bookdown_docx_md(x)
  } else {
    caption <- caption_default_docx_openxml(
      x,
      keep_with_next = apply_cap_kwn,
      allow_autonum = word_autonum
    )
  }

  table_str <- gen_raw_wml(x = x)

  if (bookdown) {
    out <- c(
      if (topcaption) caption,
      with_openxml_quotes(table_str),
      if (!topcaption) caption
    )
  } else {
    out <- with_openxml_quotes(
      c(
        if (topcaption) caption,
        table_str,
        if (!topcaption) caption
      )
    )
  }

  out
}

#' @noRd
#' @title flextable latex string for PDF
#'
#' @description get latex raw code for PDF
#' from a flextable object.
#' @param x a flextable object
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param tabcolsep space between the text and the left/right border of its containing
#' cell, the default value is 8 points.
#' @param ft.arraystretch height of each row relative to its default
#' height, the default value is 1.5.
#' @param ft.latex.float 'none' (the default value), 'float', 'wrap-r',
#' 'wrap-l', 'wrap-i', 'wrap-o'.
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @examples
#' knit_to_latex(flextable(airquality[1:5, ]))
#' @importFrom officer opts_current_table run_autonum to_wml
#' @importFrom knitr raw_block raw_latex
knit_to_latex <- function(x, bookdown, quarto = FALSE) {
  align <- x$properties$align
  tabcolsep <- x$properties$opts_pdf$tabcolsep
  ft.arraystretch <- x$properties$opts_pdf$arraystretch
  ft.latex.float <- x$properties$opts_pdf$float

  x <- flextable_global$defaults$post_process_pdf(x)

  if ("none" %in% ft.latex.float) {
    lat_container <- latex_container_none()
  } else if ("float" %in% ft.latex.float) {
    lat_container <- latex_container_float()
  } else if ("wrap-l" %in% ft.latex.float) {
    lat_container <- latex_container_wrap(placement = "l")
  } else if ("wrap-r" %in% ft.latex.float) {
    lat_container <- latex_container_wrap(placement = "r")
  } else if ("wrap-i" %in% ft.latex.float) {
    lat_container <- latex_container_wrap(placement = "i")
  } else if ("wrap-o" %in% ft.latex.float) {
    lat_container <- latex_container_wrap(placement = "o")
  } else {
    lat_container <- latex_container_none()
  }

  tab_props <- opts_current_table()
  topcaption <- tab_props$topcaption
  if (quarto) {
    caption_str <- caption_quarto_latex(x)
  } else if (bookdown) {
    caption_str <- caption_bookdown_latex(x)
  } else {
    caption_str <- caption_default_latex(x)
  }

  container_str <- latex_container_str(
    x = x,
    latex_container = lat_container,
    quarto = quarto
  )

  str <- gen_raw_latex(
    x,
    lat_container = lat_container,
    caption = caption_str,
    topcaption = topcaption,
    quarto = quarto
  )
  latex <- paste(
    container_str[1],
    str,
    container_str[2],
    sep = "\n\n"
  )
  z <- paste(
    "\\global\\setlength{\\Oldarrayrulewidth}{\\arrayrulewidth}",
    "\\global\\setlength{\\Oldtabcolsep}{\\tabcolsep}",
    sprintf("\\setlength{\\tabcolsep}{%spt}", format_double(x$properties$opts_pdf$tabcolsep, 0)),
    sprintf("\\renewcommand*{\\arraystretch}{%s}", format_double(x$properties$opts_pdf$arraystretch, 2)),
    latex,
    sprintf("\\arrayrulecolor[HTML]{%s}", colcode0(x$properties$opts_pdf$default_line_color)),
    "\\global\\setlength{\\arrayrulewidth}{\\Oldarrayrulewidth}",
    "\\global\\setlength{\\tabcolsep}{\\Oldtabcolsep}",
    "\\renewcommand*{\\arraystretch}{1}",
    sep = "\n\n"
  )
  z
}

#' @importFrom knitr raw_block
knit_to_pml <- function(x) {
  left <- opts_current$get("ft.left")
  top <- opts_current$get("ft.top")

  if (is.null(left)) {
    left <- 1
  }
  if (is.null(top)) {
    top <- 2
  }
  x <- flextable_global$defaults$post_process_pptx(x)

  uid <- as.integer(runif(n = 1) * 10^9)

  str <- gen_raw_pml(x, uid = uid, offx = left, offy = top, cx = 10, cy = 6)
  with_openxml_quotes(str)
}

#' @importFrom htmltools HTML browsable
#' @export
#' @title flextable printing
#'
#' @description print a flextable object to format `html`, `docx`,
#' `pptx` or as text (not for display but for informative purpose).
#' This function is to be used in an interactive context.
#'
#' @note
#' When argument `preview` is set to `"docx"` or `"pptx"`, an
#' external client linked to these formats (Office is installed) is used to
#' edit a document. The document is saved in the temporary directory of
#' the R session and will be removed when R session will be ended.
#'
#' When argument `preview` is set to `"html"`, an
#' external client linked to these HTML format is used to display the table.
#' If RStudio is used, the Viewer is used to display the table.
#'
#' Note also that a print method is used when flextable are used within
#' R markdown documents. See [knit_print.flextable()].
#' @param x flextable object
#' @param preview preview type, one of c("html", "pptx", "docx", "pdf, "log").
#' When `"log"` is used, a description of the flextable is printed.
#' @param align left, center (default) or right. Only for docx/html/pdf.
#' @param ... arguments for 'pdf_document' call when preview is "pdf".
#' @family flextable print function
#' @importFrom utils browseURL
#' @importFrom rmarkdown render pdf_document
#' @importFrom officer read_pptx add_slide read_docx
print.flextable <- function(x, preview = "html", align = "center", ...) {
  if (is_in_pkgdown()) {
    return(htmltools_value(x, ft.align = align))
  } else if (!interactive() || "log" %in% preview) {
    cat("a flextable object.\n")
    cat("col_keys:", paste0("`", x$col_keys, "`", collapse = ", "), "\n")
    cat("header has", nrow(x$header$dataset), "row(s)", "\n")
    cat("body has", nrow(x$body$dataset), "row(s)", "\n")
    cat("original dataset sample:", "\n")
    print(x$body$dataset[seq_len(min(c(5, nrow(x$body$dataset)))), ])
  } else if (preview == "html") {
    print(browsable(htmltools_value(x = x, ft.align = align)))
  } else if (preview == "pptx") {
    doc <- read_pptx()
    doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
    doc <- ph_with(doc, value = x, location = ph_location_type(type = "body"))
    file_out <- print(doc, target = tempfile(fileext = ".pptx"))
    browseURL(file_out)
  } else if (preview == "docx") {
    doc <- read_docx()
    doc <- body_add_flextable(doc, value = x, align = align)
    file_out <- print(doc, target = tempfile(fileext = ".docx"))
    browseURL(file_out)
  } else if (preview == "pdf") {
    rmd <- tempfile(fileext = ".Rmd")
    cat(sprintf("```{r echo=FALSE, ft.align=\"%s\"}\nx\n```\n", align), file = rmd)
    render(rmd, output_format = pdf_document(...), quiet = TRUE)
    file_out <- gsub("\\.Rmd$", ".pdf", rmd)
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
#' R Markdown outputs can be :
#'
#' * HTML
#' * 'Microsoft Word'
#' * 'Microsoft PowerPoint'
#' * PDF
#'
#' \if{html}{\figure{fig_formats.png}{options: width="200"}}
#'
#'
#' Table captioning is a flextable feature compatible with R Markdown
#' documents. The feature is available for HTML, PDF and Word documents.
#' Compatibility with the "bookdown" package is also ensured, including the
#' ability to produce captions so that they can be used in cross-referencing.
#'
#' For Word, it's recommanded to work with package 'officedown' that supports
#' all features of flextable.
#'
#' @note
#' Supported formats require some
#' minimum [pandoc](https://pandoc.org/installing.html) versions:
#'
#' \tabular{rc}{
#'   **Output format** \tab **pandoc minimal version** \cr
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
#' - HTML, PDF and Word:
#'   - `ft.align`: flextable alignment, supported values are 'left', 'center'
#'   and 'right'. Its default value is 'center'.
#' - HTML only:
#'   - `ft.htmlscroll`, can be `TRUE` or `FALSE` (default) to enable
#'   horizontal scrolling. Use [set_table_properties()] for more
#'   options about scrolling.
#' - Word only:
#'   - `ft.split` Word option 'Allow row to break across pages' can be
#'   activated when TRUE (default value).
#'   - `ft.keepnext` default `FALSE`. Word option 'keep rows
#'   together' is activated when TRUE. It avoids page break
#'   within tables. This is handy for small tables, i.e. less than
#'   a page height. Be careful, if you print long tables, you should
#'   rather set its value to `FALSE` to avoid that the tables
#'   also generate a page break before being placed in the
#'   Word document. Since Word will try to keep it with the **next
#'   paragraphs that follow the tables**.
#' - PDF only:
#'   - `ft.tabcolsep` space between the text and the left/right border of its containing
#'   cell, the default value is 0 points.
#'   - `ft.arraystretch` height of each row relative to its default
#'   height, the default value is 1.5.
#'   - `ft.latex.float` type of floating placement in the document, one of:
#'     - 'none' (the default value), table is placed after the preceding
#'     paragraph.
#'     - 'float', table can float to a place in the text where it fits best
#'     - 'wrap-r', wrap text around the table positioned to the right side of the text
#'     - 'wrap-l', wrap text around the table positioned to the left side of the text
#'     - 'wrap-i', wrap text around the table positioned inside edge-near the binding
#'     - 'wrap-o', wrap text around the table positioned outside edge-far from the binding
#' - PowerPoint only:
#'   - `ft.left`, `ft.top` Position should be defined with these options.
#'   Theses are the top left coordinates in inches of the placeholder
#'   that will contain the table. Their default values are 1 and 2
#'   inches.
#'
#' If some values are to be used all the time in the same
#' document, it is recommended to set these values in a
#' 'knitr r chunk' by using function
#' `knitr::opts_chunk$set(ft.split=FALSE, ft.keepnext = FALSE, ...)`.
#'
#' @section Table caption:
#'
#' Captions can be defined in two ways.
#'
#' The first is with the [set_caption()] function. If it is used,
#' the other method will be ignored. The second method is by using
#' knitr chunk option `tab.cap`.
#'
#' ```
#' set_caption(x, caption = "my caption")
#' ```
#'
#'
#' If `set_caption` function is not used, caption identifier will be
#' read from knitr's chunk option `tab.id`. Note that in a bookdown and
#' when not using `officedown::rdocx_document()`, the usual numbering
#' feature of bookdown is used.
#'
#' `tab.id='my_id'`.
#'
#' Some options are available to customise captions for any output:
#'
#' | **label**                                        |    **name**     | **value**  |
#' |:-------------------------------------------------|:---------------:|:----------:|
#' | Word stylename to use for table captions.        | tab.cap.style   |    NULL    |
#' | caption id/bookmark                              | tab.id          |    NULL    |
#' | caption                                          | tab.cap         |    NULL    |
#' | display table caption on top of the table or not | tab.topcaption  |    TRUE    |
#' | caption table sequence identifier.               | tab.lp          |   "tab:"   |
#'
#' Word output when `officedown::rdocx_document()` is used is coming with
#' more options such as ability to choose the prefix for numbering chunk for
#' example. The table below expose these options:
#'
#' | **label**                                               |    **name**     | **value**  |
#' |:--------------------------------------------------------|:---------------:|:----------:|
#' | prefix for numbering chunk (default to   "Table ").     | tab.cap.pre     |   Table    |
#' | suffix for numbering chunk (default to   ": ").         | tab.cap.sep     |    " :"    |
#' | title number depth                                      | tab.cap.tnd     |      0     |
#' | caption prefix formatting properties                    | tab.cap.fp_text | fp_text_lite(bold = TRUE) |
#' | separator to use between title number and table number. | tab.cap.tns     |     "-"    |
#'
#' @section HTML output:
#'
#' HTML output is using shadow dom to encapsule the table
#' into an isolated part of the page so that no clash happens
#' with styles.
#'
#' @section PDF output:
#'
#' Some features are not implemented in PDF due to technical
#' infeasibility. These are the padding, line_spacing and
#' height properties.
#'
#' It is recommended to set theses values in a
#' 'knitr r chunk' so that they are permanent
#' all along the document:
#' `knitr::opts_chunk$set(ft.tabcolsep=0, ft.latex.float = "none")`.
#'
#' See [add_latex_dep()] if caching flextable results in 'R Markdown'
#' documents.
#'
#' @section PowerPoint output:
#'
#' Auto-adjust Layout is not available for PowerPoint, PowerPoint only support
#' fixed layout. It's then often necessary to call function [autofit()] so
#' that the columns' widths are adjusted if user does not provide the withs.
#'
#' Images cannot be integrated into tables with the PowerPoint format.
#'
#' @param x a `flextable` object
#' @param ... unused.
#' @export
#' @importFrom utils getFromNamespace
#' @importFrom htmltools HTML div
#' @importFrom knitr knit_print asis_output opts_knit opts_current
#' fig_path is_html_output is_latex_output include_graphics pandoc_to
#' @importFrom rmarkdown pandoc_version
#' @importFrom stats runif
#' @importFrom graphics plot par
#' @family flextable print function
#' @examples
#' \dontrun{
#' library(rmarkdown)
#' if (pandoc_available() &&
#'   pandoc_version() > numeric_version("2")) {
#'   demo_loop <- system.file(
#'     package = "flextable",
#'     "examples/rmd",
#'     "demo.Rmd"
#'   )
#'   rmd_file <- tempfile(fileext = ".Rmd")
#'   file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
#'   render(
#'     input = rmd_file, output_format = "html_document",
#'     output_file = "demo.html"
#'   )
#' }
#' }
knit_print.flextable <- function(x, ...) {
  is_bookdown <- is_in_bookdown()
  is_quarto <- is_in_quarto()

  x <- knitr_update_properties(x, bookdown = is_bookdown, quarto = is_quarto)

  if (is.null(pandoc_to())) {
    str <- to_html(x, type = "table")
    str <- asis_output(str)
  } else if (!is.null(getOption("xaringan.page_number.offset"))) { #xaringan
    str <- knit_to_html(x, bookdown = FALSE, quarto = FALSE)
    str <- asis_output(str, meta = flextable_html_dependencies(x))
  } else if (is_html_output()) { # html
    str <- knit_to_html(x, bookdown = is_bookdown, quarto = is_quarto)
    str <- raw_html(str, meta = flextable_html_dependencies(x))
  } else if (is_latex_output()) { # latex
    str <- knit_to_latex(x, bookdown = is_bookdown, quarto = is_quarto)
    str <- raw_latex(
      x = str,
      meta = list_latex_dep(float = TRUE, wrapfig = TRUE)
    )
  } else if (grepl("docx", opts_knit$get("rmarkdown.pandoc.to"))) { # docx
    if (pandoc_version() < numeric_version("2")) {
      stop("pandoc version >= 2 required for printing flextable in docx")
    }
    str <- knit_to_wml(x, bookdown = is_bookdown, quarto = is_quarto)
    str <- asis_output(str)
  } else if (grepl("pptx", opts_knit$get("rmarkdown.pandoc.to"))) { # pptx
    if (pandoc_version() < numeric_version("2.4")) {
      stop("pandoc version >= 2.4 required for printing flextable in pptx")
    }
    str <- knit_to_pml(x)
    str <- asis_output(str)
  } else {
    plot_counter <- getFromNamespace("plot_counter", "knitr")
    in_base_dir <- getFromNamespace("in_base_dir", "knitr")
    tmp <- fig_path("png", number = plot_counter())
    in_base_dir({
      dir.create(dirname(tmp), showWarnings = FALSE, recursive = TRUE)
      save_as_image(x, path = tmp, expand = 0)
    })
    str <- include_graphics(tmp)
  }
  str
}

#' @export
#' @title Save flextable objects in an 'HTML' file
#' @description save a flextable in an 'HTML' file. This function
#' is useful to save the flextable in 'HTML' file without using
#' R Markdown (it is highly recommanded to use R Markdown
#' instead).
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as titles. If provided, argument `...` will be ignored.
#' @param path HTML file to be created
#' @param title page title
#' @param lang language of the document using IETF language tags
#' @return a string containing the full name of the generated file
#' @examples
#' ft1 <- flextable(head(iris))
#' tf1 <- tempfile(fileext = ".html")
#' save_as_html(ft1, path = tf1)
#' # browseURL(tf1)
#'
#' ft2 <- flextable(head(mtcars))
#' tf2 <- tempfile(fileext = ".html")
#' save_as_html(
#'   `iris table` = ft1,
#'   `mtcars table` = ft2,
#'   path = tf2,
#'   title = "rhoooo"
#' )
#' # browseURL(tf2)
#' @family flextable print function
#' @importFrom htmltools save_html
save_as_html <- function(..., values = NULL, path,
                         lang = "en",
                         title = deparse(sys.call())) {
  if (is.null(values)) {
    values <- list(...)
  }
  values <- Filter(function(x) inherits(x, "flextable"), values)
  values <- lapply(values, flextable_global$defaults$post_process_html)
  values <- lapply(values, htmltools_value)
  titles <- names(values)
  show_names <- !is.null(titles)
  if (show_names) {
    old_values <- values
    values <- rep(list(NULL), length(old_values)*2)
    values[seq_along(old_values)*2] <- old_values
    values[seq_along(old_values)*2 - 1] <- lapply(titles, htmltools::h2)
  }
  values <- do.call(htmltools::tagList, values)

  is_succes <- render_htmltag(x = values, path = absolute_path(path), title = title,
                              lang = lang)
  if (!is_succes) stop("could not write the file ", shQuote(path))
  invisible(path)
}



#' @export
#' @importFrom officer ph_location_type
#' @title Save flextable objects in a 'PowerPoint' file
#' @description sugar function to save flextable objects in
#' an PowerPoint file.
#'
#' This feature is available to simplify the work of users by avoiding
#' the need to use the 'officer' package. If it doesn't suit your needs,
#' then use the API offered by 'officer' which allows simple and
#' complicated things.
#' @note
#' The PowerPoint format ignores captions (see [set_caption()]).
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as slide titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as slide titles. If provided, argument `...` will be ignored.
#' @param path PowerPoint file to be created
#' @return a string containing the full name of the generated file
#' @examples
#' ft1 <- flextable(head(iris))
#' tf <- tempfile(fileext = ".pptx")
#' save_as_pptx(ft1, path = tf)
#'
#' ft2 <- flextable(head(mtcars))
#' tf <- tempfile(fileext = ".pptx")
#' save_as_pptx(`iris table` = ft1, `mtcars table` = ft2, path = tf)
#' @family flextable print function
save_as_pptx <- function(..., values = NULL, path) {
  if (is.null(values)) {
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)
  z <- read_pptx()
  for (i in seq_along(values)) {
    z <- add_slide(z)
    if (show_names) {
      z <- ph_with(z, titles[i], location = ph_location_type(type = "title"))
    }
    z <- ph_with(z, values[[i]], location = ph_location_type(type = "body"))
  }
  print(z, target = path)
  invisible(path)
}



#' @export
#' @title Save flextable objects in a 'Word' file
#' @description sugar function to save flextable objects in an Word file.
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as titles. If provided, argument `...` will be ignored.
#' @param path Word file to be created
#' @param pr_section a [prop_section] object that can be used to define page
#' layout such as orientation, width and height.
#' @param align left, center (default) or right.
#' @return a string containing the full name of the generated file
#' @examples
#'
#' tf <- tempfile(fileext = ".docx")
#'
#' library(officer)
#' ft1 <- flextable(head(iris))
#' save_as_docx(ft1, path = tf)
#'
#'
#' ft2 <- flextable(head(mtcars))
#' sect_properties <- prop_section(
#'   page_size = page_size(
#'     orient = "landscape",
#'     width = 8.3, height = 11.7
#'   ),
#'   type = "continuous",
#'   page_margins = page_mar()
#' )
#' save_as_docx(
#'   `iris table` = ft1, `mtcars table` = ft2,
#'   path = tf, pr_section = sect_properties
#' )
#' @family flextable print function
#' @importFrom officer body_add_par prop_section body_set_default_section
#'   page_size page_mar
save_as_docx <- function(..., values = NULL, path, pr_section = NULL, align = "center") {
  if (is.null(values)) {
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)

  titles <- names(values)
  show_names <- !is.null(titles)

  if (is.null(pr_section)) {
    pr_section <- prop_section(
      page_size = page_size(orient = "portrait", width = 8.3, height = 11.7),
      type = "continuous",
      page_margins = page_mar()
    )
  }

  if (!inherits(pr_section, "prop_section")) {
    stop("pr_section is not a prop_section object, use officer::prop_section.")
  }

  z <- read_docx()

  for (i in seq_along(values)) {
    if (show_names) {
      z <- body_add_par(z, titles[i], style = "heading 2")
    } else {
      z <- body_add_par(z, "")
    }
    z <- body_add_flextable(z, values[[i]], align = align)
  }
  z <- body_set_default_section(z, pr_section)
  print(z, target = path)
  invisible(path)
}

#' @export
#' @title Save flextable objects in an 'RTF' file
#' @description sugar function to save flextable objects in an 'RTF' file.
#' @param ... flextable objects, objects, possibly named. If named objects, names are
#' used as titles.
#' @param values a list (possibly named), each element is a flextable object. If named objects, names are
#' used as titles. If provided, argument `...` will be ignored.
#' @param path Word file to be created
#' @param pr_section a [prop_section] object that can be used to define page
#' layout such as orientation, width and height.
#' @return a string containing the full name of the generated file
#' @family flextable print function
#' @examples
#'
#' tf <- tempfile(fileext = ".rtf")
#'
#' library(officer)
#' ft1 <- flextable(head(iris))
#' save_as_rtf(ft1, path = tf)
#'
#'
#' ft2 <- flextable(head(mtcars))
#' sect_properties <- prop_section(
#'   page_size = page_size(
#'     orient = "landscape",
#'     width = 8.3, height = 11.7
#'   ),
#'   type = "continuous",
#'   page_margins = page_mar(),
#'   header_default = block_list(
#'     fpar(ftext("text for default page header")),
#'       qflextable(data.frame(a = 1L)))
#' )
#' tf <- tempfile(fileext = ".rtf")
#' save_as_rtf(
#'   `iris table` = ft1, `mtcars table` = ft2,
#'   path = tf, pr_section = sect_properties
#' )
#' @importFrom officer rtf_doc fp_text_lite fpar
save_as_rtf <- function(..., values = NULL, path, pr_section = NULL) {
  if (is.null(values)) {
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)

  titles <- names(values)
  show_names <- !is.null(titles)
  if (is.null(pr_section)) {
    pr_section <- prop_section(
      page_size = page_size(orient = "portrait", width = 8.3, height = 11.7),
      type = "continuous",
      page_margins = page_mar()
    )
  }

  if (!inherits(pr_section, "prop_section")) {
    stop("pr_section is not a prop_section object, use officer::prop_section.")
  }

  z <- rtf_doc(def_sec = pr_section)

  for (i in seq_along(values)) {
    if (show_names) {
      z <- rtf_add(z,
                   value = fpar(
                     titles[i],
                     fp_p = fp_par(text.align = "left", padding.top = 6, padding.bottom = 6),
                     fp_t = fp_text_lite(bold = TRUE, font.size = 18, font.family = "Arial")
                   ))
    }
    z <- rtf_add(z, values[[i]])
  }
  print(z, target = path)
  invisible(path)
}



#' @export
#' @title Save a flextable in an 'png' file
#' @description Save a flextable as a png image.
#' @param x a flextable object
#' @param path image file to be created. It should end with '.png'.
#' @param expand space in pixels to add around the table.
#' @param res The resolution of the device
#' @param ... unused arguments
#' @return a string containing the full name of the generated file
#' @examples
#' library(gdtools)
#' register_liberationsans()
#' set_flextable_defaults(font.family = "Liberation Sans")
#'
#' ft <- flextable(head(mtcars))
#' ft <- autofit(ft)
#' tf <- tempfile(fileext = ".png")
#' save_as_image(x = ft, path = tf)
#'
#' init_flextable_defaults()
#' @family flextable print function
#' @importFrom ragg agg_png
save_as_image <- function(x, path, expand = 10, res = 200, ...) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", as.character(sys.call()[[1]])))
  }

  gr <- gen_grob(x, fit = "fixed", just = "center")
  dims <- dim(gr)

  agg_png(
    filename = path,
    width = dims$width + expand/72,
    height = dims$height + expand/72,
    res = res, units = "in",
    background = "transparent")

  tryCatch(
    {
      plot(gr)
    },
    finally = {
      dev.off()
    }
  )

  path
}


#' @export
#' @title Plot a flextable
#' @description plots a flextable as a grid grob object
#' and display the result in a new graphics window.
#' 'ragg' or 'svglite' or 'ggiraph' graphical device drivers
#' should be used to ensure a correct rendering.
#' @param x a flextable object
#' @param ... additional arguments passed to [gen_grob()].
#' @examples
#' library(gdtools)
#' library(ragg)
#' register_liberationsans()
#' set_flextable_defaults(font.family = "Liberation Sans")
#' ftab <- as_flextable(cars)
#'
#' tf <- tempfile(fileext = ".png")
#' agg_png(filename = tf, width = 1.7, height = 3.26, unit = "in",
#'   background = "transparent", res = 150)
#' plot(ftab)
#' dev.off()
#' @family flextable print function
#' @importFrom grid grid.newpage grid.draw viewport pushViewport popViewport
plot.flextable <- function(x, ...) {
  grid.newpage()
  # leave a 5pt margin around the plot
  pushViewport(viewport(
    width = unit(1, "npc") - unit(10, "pt"),
    height = unit(1, "npc") - unit(10, "pt")
  ))
  grid.draw(gen_grob(x, ...))
  popViewport()
  invisible()
}

#' @export
#' @title Transform a flextable into a raster
#' @description save a flextable as an image and return the corresponding
#' raster. This function has been implemented to let flextable be printed
#' on a ggplot object.
#' @note This function requires package 'magick'.
#' @param x a flextable object
#' @param ... additional arguments passed to other functions
#' @importFrom grDevices as.raster
#' @examples
#' ft <- qflextable(head(mtcars))
#' \dontrun{
#' if (require("ggplot2") && require("magick")) {
#'   print(qplot(speed, dist, data = cars, geom = "point"))
#'   grid::grid.raster(as_raster(ft))
#' }
#' }
#' @family flextable print function
as_raster <- function(x, ...) {
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop(sprintf(
      "'%s' package should be installed to create an image from a flextable.",
      "magick"
    ))
  }
  path <- tempfile(fileext = ".png")
  on.exit(unlink(path))
  save_as_image(x, path, expand = 0)
  img <- magick::image_read(path = path)
  as.raster(img, ...)
}


# utils ----
is_in_bookdown <- function() {
  is_rdocx_document <- opts_current$get("is_rdocx_document")
  if (is.null(is_rdocx_document)) is_rdocx_document <- FALSE

  isTRUE(opts_knit$get("bookdown.internal.label")) &&
    isTRUE(!is_rdocx_document)
}
is_in_quarto <- function() {
  isTRUE(knitr::opts_knit$get("quarto.version") > numeric_version("0"))
}
is_in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true") &&
    requireNamespace("pkgdown", quietly = TRUE)
}

#' @importFrom knitr opts_current
knitr_update_properties <- function(x, bookdown = FALSE, quarto = FALSE) {

  # global properties
  ft.align <- opts_current$get("ft.align")
  ft.split <- opts_current$get("ft.split")
  ft.keepnext <- opts_current$get("ft.keepnext")
  ft.tabcolsep <- opts_current$get("ft.tabcolsep")
  ft.arraystretch <- opts_current$get("ft.arraystretch")
  ft.latex.float <- mcoalesce_options(opts_current$get("ft.latex.float"), opts_current$get("ft-latex-float"))
  ft.left <- opts_current$get("ft.left")
  ft.top <- opts_current$get("ft.top")
  ft.htmlscroll <- opts_current$get("ft.htmlscroll")

  if (!is.null(ft.align)) {
    x$properties$align <- ft.align
  }
  if (isTRUE(ft.htmlscroll)) {
    x$properties$opts_html$scroll <- list()
  }
  # word chunk options
  if (!is.null(ft.split)) {
    x$properties$opts_word$split <- ft.split
  }
  if (!is.null(ft.keepnext)) {
    x$properties$opts_word$keep_with_next <- ft.keepnext
  }
  # latex chunk options
  if (!is.null(ft.tabcolsep)) {
    x$properties$opts_pdf$tabcolsep <- ft.tabcolsep
  }
  if (!is.null(ft.arraystretch)) {
    x$properties$opts_pdf$arraystretch <- ft.arraystretch
  }
  if (!is.null(ft.latex.float)) {
    x$properties$opts_pdf$float <- ft.latex.float
  }

  # captions properties
  knitr_tab_opts = opts_current_table()
  if (is.null(knitr_tab_opts$cap.style)) {
    knitr_tab_opts$cap.style <- "Table Caption"
  }
  x <- update_caption(
    x = x,
    caption = knitr_tab_opts$cap,
    word_stylename = knitr_tab_opts$cap.style)
  if (has_caption(x) &&
      !has_autonum(x) &&
      !is.null(knitr_tab_opts$id)) {
    autonum <- run_autonum(
      seq_id = gsub(":$", "", knitr_tab_opts$tab.lp),
      pre_label = knitr_tab_opts$cap.pre,
      post_label = knitr_tab_opts$cap.sep,
      bkm = knitr_tab_opts$id, bkm_all = FALSE,
      tnd = knitr_tab_opts$cap.tnd,
      tns = knitr_tab_opts$cap.tns,
      prop = knitr_tab_opts$cap.fp_text
    )
    x <- update_caption(x = x, autonum = autonum)
  }

  x
}

