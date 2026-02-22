# main ----
#' @export
#' @title Convert a flextable to an HTML object
#'
#' @description get a [htmltools::div()] from a flextable object.
#' This can be used in a shiny application. For an output within
#' "R Markdown" document, use [knit_print.flextable].
#' @return an object marked as [htmltools::HTML] ready to be used within
#' a call to `shiny::renderUI` for example.
#' @inheritParams args_x_only
#' @param ft.align flextable alignment, supported values are 'left', 'center' and 'right'.
#' @param ft.shadow deprecated.
#' @param extra_dependencies a list of HTML dependencies to
#' add in the HTML output.
#' @family flextable_output_export
#' @examples
#' htmltools_value(flextable(iris[1:5, ]))
#' @importFrom htmltools tagList attachDependencies tags
htmltools_value <- function(x, ft.align = NULL, ft.shadow = NULL,
                            extra_dependencies = NULL) {
  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_html(x)
  x <- fix_border_issues(x)

  if (!is.null(ft.align)) {
    x$properties$align <- ft.align
  }

  caption <- caption_default_html(x)
  manual_css <- attr(caption, "css")

  list_deps <- html_dependencies_list(x)

  html_o <- tagList(
    if (length(extra_dependencies) > 0) {
      attachDependencies(
        x = tags$style(""),
        extra_dependencies
      )
    },
    attachDependencies(
      x = tags$style(""),
      list_deps
    ),
    HTML(gen_raw_html(x,
      class = "tabwid",
      caption = caption,
      manual_css = manual_css
    ))
  )
  html_o
}

#' @importFrom knitr knit_child
#' @export
#' @title Print a flextable inside knitr loops and conditionals
#'
#' @description Print flextable in R Markdown or Quarto documents
#' within `for` loop or `if` statement.
#'
#' The function is particularly useful when you want
#' to generate flextable in a loop from a R Markdown document.
#'
#' Inside R Markdown document, chunk option `results` must be
#' set to 'asis'.
#'
#' See [knit_print.flextable] for more details.
#' @inheritParams args_x_only
#' @param ... unused argument
#' @family flextable_output_export
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

  x <- knitr_update_properties(x, bookdown = is_bookdown, quarto = is_quarto)

  if (is_quarto) {
    tmp_file <- tempfile(fileext = ".qmd")
  } else {
    tmp_file <- tempfile(fileext = ".Rmd")
  }

  writeLines(
    c("```{r echo=FALSE}",
      "x", "```", ""),
    tmp_file,
    useBytes = TRUE)

  z <- knit_child(
    input = tmp_file,
    options = list(
      fig.path=tempfile(),
      eval = isTRUE(knitr::opts_current$get("eval"))
    ),
    envir = environment(), quiet = TRUE)

  cat(z, sep = '\n')

  invisible("")
}

#' @export
#' @title Get HTML code as a string
#' @description Generate HTML code of corresponding
#' flextable as an HTML table or an HTML image.
#' @inheritParams args_x_only
#' @param type output type. one of "table" or "img".
#' @param ... unused
#' @return If `type='img'`, the result will be a string
#' containing HTML code of an image tag, otherwise, the
#' result will be a string containing HTML code of
#' a table tag.
#' @family flextable_output_export
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
    x <- flextable_global$defaults$post_process_all(x)
    x <- flextable_global$defaults$post_process_html(x)
    x <- fix_border_issues(x)
    manual_css <- readLines(system.file(package = "flextable", "web_1.1.3", "tabwid.css"), encoding = "UTF-8")
    gen_raw_html(x, class = "tabwid", caption = "", manual_css = paste0(manual_css, collapse = "\n"))
  } else {
    tmp <- tempfile(fileext = ".png")

    gr <- gen_grob(x, fit = "fixed", just = "center")
    dims <- dim(gr)
    expand <- 10
    width <- dims$width + expand / 72
    height <- dims$height + expand / 72

    agg_png(
      filename = tmp,
      width = dims$width + expand / 72,
      height = dims$height + expand / 72,
      res = 200, units = "in",
      background = "transparent"
    )

    tryCatch(
      {
        plot(gr)
      },
      finally = {
        dev.off()
      }
    )

    base64_string <- image_to_base64(tmp)

    sprintf("<img style=\"width:%.3fin;height:%.3fin;\" src=\"%s\" />", width, height, base64_string)
  }
}

#' @export
to_wml.flextable <- function(x, ...) {
  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_docx(x)
  x <- fix_border_issues(x)
  x <- knitr_update_properties(x)
  gen_raw_wml(x)
}


#' @noRd
#' @title flextable HTML string
#' @description get a string for HTML output with pandoc.
#' @inheritParams args_x_only
#' @param bookdown `TRUE` or `FALSE` (default) to support cross referencing with bookdown.
#' @param quarto `TRUE` or `FALSE` (default).
#' @examples
#' knit_to_html(flextable(iris[1:5, ]))
#' @importFrom knitr raw_html
knit_to_html <- function(x, bookdown = FALSE, quarto = FALSE) {
  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_html(x)
  x <- fix_border_issues(x)

  tab_props <- opts_current_table()
  topcaption <- tab_props$topcaption

  manual_css <- ""
  if (bookdown) {
    caption_str <- caption_bookdown_html(x)
    manual_css <- attr(caption_str, "css")
  } else if (quarto) {
    caption_str <- ""
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
  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_docx(x)
  x <- fix_border_issues(x)

  for(part in c("body", "header", "footer")) {
    if (nrow_part(x, part) > 0L) {
      x[[part]]$styles$pars$word_style$data[,] <- NA_character_
    }
  }

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
  } else if (quarto) {
    caption <- ""
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
#' @inheritParams args_x_only
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

  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_pdf(x)
  x <- fix_border_issues(x)

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
    caption_str <- ""
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
  x <- flextable_global$defaults$post_process_all(x)
  x <- flextable_global$defaults$post_process_pptx(x)
  x <- fix_border_issues(x)

  uid <- as.integer(runif(n = 1) * 10^9)

  str <- gen_raw_pml(x, uid = uid, offx = left, offy = top, cx = 10, cy = 6)
  with_openxml_quotes(str)
}

#' @importFrom htmltools HTML browsable
#' @export
#' @title Print a flextable
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
#' @inheritParams args_x_only
#' @param preview preview type, one of c("html", "pptx", "docx", "rtf", "pdf, "log").
#' When `"log"` is used, a description of the flextable is printed.
#' @param align left, center (default) or right. Only for docx/html/pdf.
#' @param ... arguments for 'pdf_document' call when preview is "pdf".
#' @family flextable_output_export
#' @importFrom utils browseURL str
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
    str(x$body$dataset)
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
  } else if (preview == "rtf") {
    file_out <- tempfile(fileext = ".rtf")
    save_as_rtf(x, path = file_out)
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



#' @title Render flextable in knitr documents
#' @description This function is called automatically by knitr to display
#' a flextable in R Markdown and Quarto documents. You do not need to call
#' it directly.
#'
#' Supported output formats: HTML, Word (docx), PDF and PowerPoint (pptx).
#' For other formats (e.g., `github_document`, `beamer_presentation`),
#' the table is rendered as a PNG image.
#'
#' @section Getting started:
#'
#' No special setup is needed: place a flextable object in a code chunk
#' and it will be rendered in the output document.
#'
#' Add a caption with [set_caption()]:
#'
#' ```r
#' ft <- set_caption(ft, caption = "My table caption")
#' ```
#'
#' In Quarto documents, use chunk options `tbl-cap` and `label` instead:
#'
#' ````
#' ```{r}
#' #| label: tbl-mytable
#' #| tbl-cap: "My table caption"
#' ft
#' ```
#' ````
#'
#' @section Captions:
#'
#' **Recommended method:** use [set_caption()] to define the caption
#' directly on the flextable object. When `set_caption()` is used,
#' chunk options related to captions are ignored.
#'
#' **Alternative (R Markdown only):** use knitr chunk options `tab.cap`
#' and `tab.id`:
#'
#' | **Description**                   |  **Chunk option** | **Default** |
#' |:----------------------------------|:-----------------:|:-----------:|
#' | Caption text                      | tab.cap           |    NULL     |
#' | Caption id/bookmark               | tab.id            |    NULL     |
#' | Caption on top of the table       | tab.topcaption    |    TRUE     |
#' | Caption sequence identifier       | tab.lp            |   "tab:"   |
#' | Word style for captions           | tab.cap.style     |    NULL     |
#'
#' **Bookdown:** cross-references use the pattern
#' `\@ref(tab:chunk_label)`. The usual bookdown numbering applies.
#'
#' **Quarto:** cross-references use `@tbl-chunk_label`. To embed
#' cross-references or other Quarto markdown inside flextable cells,
#' use [as_qmd()] with the `flextable-qmd` extension
#' (see [use_flextable_qmd()]).
#'
#' @section Chunk options:
#'
#' Use `knitr::opts_chunk$set(...)` to set defaults for the whole document.
#'
#' **All formats:**
#' - `ft.align`: table alignment, one of `'left'`, `'center'` (default)
#'   or `'right'`.
#'
#' **HTML:**
#' - `ft.htmlscroll`: `TRUE` or `FALSE` (default) to enable horizontal
#'   scrolling. See [set_table_properties()] for finer control.
#'
#' **Word:**
#' - `ft.split`: allow rows to break across pages (`TRUE` by default).
#'
#' **PDF:**
#' - `ft.tabcolsep`: space between text and cell borders (default 0 pt).
#' - `ft.arraystretch`: row height multiplier (default 1.5).
#' - `ft.latex.float`: floating placement. One of `'none'` (default),
#'   `'float'`, `'wrap-r'`, `'wrap-l'`, `'wrap-i'`, `'wrap-o'`.
#'
#' **PowerPoint:**
#' - `ft.left`, `ft.top`: top-left coordinates of the table placeholder
#'   in inches (defaults: 1 and 2).
#'
#' @section Word with officedown:
#'
#' When using `officedown::rdocx_document()`, additional caption options
#' are available:
#'
#' | **Description**                          |  **Chunk option** | **Default**               |
#' |:-----------------------------------------|:-----------------:|:-------------------------:|
#' | Numbering prefix                         | tab.cap.pre       | "Table "                  |
#' | Numbering suffix                         | tab.cap.sep       | ": "                      |
#' | Title number depth                       | tab.cap.tnd       | 0                         |
#' | Caption prefix formatting                | tab.cap.fp_text   | `fp_text_lite(bold=TRUE)` |
#' | Title number / table number separator    | tab.cap.tns       | "-"                       |
#'
#' @section Quarto:
#'
#' flextable works natively in Quarto documents for HTML, PDF and Word.
#'
#' The `flextable-qmd` Lua filter extension enables Quarto markdown
#' inside flextable cells: cross-references (`@tbl-xxx`, `@fig-xxx`),
#' bold/italic, links, math, inline code and shortcodes.
#' See [as_qmd()] and [use_flextable_qmd()] for setup instructions.
#'
#' @section PDF limitations:
#'
#' The following properties are not supported in PDF output:
#' `padding.top`, `padding.bottom`, `line_spacing` and row `height`.
#' Justified text is converted to left-aligned.
#'
#' To use system fonts, set `latex_engine: xelatex` in the YAML
#' header (the default `pdflatex` engine does not support them).
#'
#' See [add_latex_dep()] when caching flextable results.
#'
#' @section PowerPoint limitations:
#'
#' PowerPoint only supports fixed table layout. Use [autofit()] to
#' adjust column widths. Images inside table cells are not supported
#' (this is a PowerPoint limitation).
#'
#' @section HTML note:
#'
#' HTML output uses Shadow DOM to isolate table styles from the rest
#' of the page.
#'
#' @inheritParams args_x_only
#' @param ... unused.
#' @export
#' @importFrom utils getFromNamespace
#' @importFrom htmltools HTML div
#' @importFrom knitr knit_print asis_output opts_knit opts_current
#' fig_path is_html_output is_latex_output include_graphics pandoc_to
#' @importFrom rmarkdown pandoc_version
#' @importFrom stats runif
#' @importFrom graphics plot par
#' @family flextable_output_export
#' @seealso [set_caption()], [as_qmd()], [use_flextable_qmd()],
#' [paginate()]
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
  } else if (!is.null(getOption("xaringan.page_number.offset"))) { # xaringan
    str <- knit_to_html(x, bookdown = FALSE, quarto = FALSE)
    str <- asis_output(str, meta = html_dependencies_list(x))
  } else if(is_html_output(excludes = "gfm") && isTRUE(knitr::opts_knit$get("is.paged.js"))) {
    x$properties$opts_html$extra_class <- c(
      x$properties$opts_html$extra_class,
      "no-shadow-dom"
    )
    str <- knit_to_html(x, bookdown = FALSE, quarto = is_quarto)
    str <- raw_html(str, meta = html_dependencies_list(x))
  } else if (is_html_output(excludes = "gfm")) { # html
    str <- knit_to_html(x, bookdown = is_bookdown, quarto = is_quarto)
    str <- raw_html(str, meta = html_dependencies_list(x))
  } else if (is_latex_output()) { # latex
    str <- knit_to_latex(x, bookdown = is_bookdown, quarto = is_quarto)
    str <- raw_latex(
      x = str,
      meta = unname(list_latex_dep(float = TRUE, wrapfig = TRUE))
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
#' if (rmarkdown::pandoc_available()) {
#'   save_as_html(ft1, path = tf1)
#'   # browseURL(tf1)
#' }
#'
#' ft2 <- flextable(head(mtcars))
#' tf2 <- tempfile(fileext = ".html")
#' if (rmarkdown::pandoc_available()) {
#'   save_as_html(
#'     `iris table` = ft1,
#'     `mtcars table` = ft2,
#'     path = tf2,
#'     title = "rhoooo"
#'   )
#'   # browseURL(tf2)
#' }
#' @family flextable_output_export
#' @importFrom htmltools save_html
save_as_html <- function(..., values = NULL, path,
                         lang = "en",
                         title = "&#32;") {
  if (is.null(values)) {
    values <- list(...)
  }
  values <- Filter(function(x) inherits(x, "flextable"), values)
  values <- lapply(values, flextable_global$defaults$post_process_all)
  values <- lapply(values, flextable_global$defaults$post_process_html)
  values <- lapply(values, fix_border_issues)
  values <- lapply(values, htmltools_value)
  titles <- names(values)
  show_names <- !is.null(titles)
  if (show_names) {
    old_values <- values
    values <- rep(list(NULL), length(old_values) * 2)
    values[seq_along(old_values) * 2] <- old_values
    values[seq_along(old_values) * 2 - 1] <- lapply(titles, htmltools::h2)
  }
  values <- do.call(htmltools::tagList, values)

  is_succes <- render_htmltag(
    x = values, path = absolute_path(path), title = title,
    lang = lang
  )
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
#' @family flextable_output_export
save_as_pptx <- function(..., values = NULL, path) {
  if (is.null(values)) {
    values <- list(...)
  }

  values <- Filter(function(x) inherits(x, "flextable"), values)
  titles <- names(values)
  show_names <- !is.null(titles)
  z <- read_pptx()
  for (i in seq_along(values)) {
    z <- add_slide(z, "Title and Content")
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
#' @param pr_section a [officer::prop_section] object that can be used to define page
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
#' @family flextable_output_export
#' @seealso [paginate()]
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
      type = "continuous"
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
#' @param pr_section a [officer::prop_section] object that can be used to define page
#' layout such as orientation, width and height.
#' @return a string containing the full name of the generated file
#' @family flextable_output_export
#' @seealso [paginate()]
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
#'     qflextable(data.frame(a = 1L))
#'   )
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
      type = "continuous"
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
        )
      )
    }
    z <- rtf_add(z, values[[i]])
  }
  print(z, target = path)
  invisible(path)
}



#' @export
#' @title Save a flextable in a 'png' or 'svg' file
#' @description Save a flextable as a png or svg image.
#' This function uses R graphic system to create an image from the flextable,
#' allowing for high-quality image output. See [gen_grob()] for more options.
#'
#' @section caption:
#' It's important to note that captions are not part of the table itself.
#' This means when exporting a table to PNG or SVG formats (image formats),
#' the caption won't be included. Captions are intended for document outputs
#' like Word, HTML, or PDF, where tables are embedded within the document
#' itself.
#' @inheritParams args_x_only
#' @param path image file to be created. It should end with '.png'
#' or '.svg'.
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
#' @family flextable_output_export
#' @importFrom ragg agg_png agg_capture
save_as_image <- function(x, path, expand = 10, res = 200, ...) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", as.character(sys.call()[[1]])))
  }

  file_ext_pos <- regexpr("\\.([[:alnum:]]+)$", path)
  file_ext <- substring(path, file_ext_pos + 1L)

  file_ext <- match.arg(tolower(file_ext), choices = c("png", "svg"), several.ok = FALSE)

  gr <- gen_grob(x, fit = "fixed", just = "center")
  dims <- dim(gr)

  if (file_ext %in% "png") {
    agg_png(
      filename = path,
      width = dims$width + expand / 72,
      height = dims$height + expand / 72,
      res = res, units = "in",
      background = "transparent"
    )
  } else if (file_ext %in% "svg") {
    if (!requireNamespace("svglite", quietly = TRUE)) {
      stop(sprintf(
        "'%s' package should be installed to save a flextable in a '%s' image.",
        "svglite", "svg"
      ))
    }
    svglite::svglite(
      filename = path,
      width = dims$width + expand / 72,
      height = dims$height + expand / 72,
      bg = "transparent"
    )
  }

  tryCatch(
    {
      base::plot(gr)
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
#' @inheritParams args_x_only
#' @param ... additional arguments passed to [gen_grob()].
#' @inheritSection save_as_image caption
#' @examples
#' library(gdtools)
#' library(ragg)
#' register_liberationsans()
#' set_flextable_defaults(font.family = "Liberation Sans")
#' ftab <- as_flextable(cars)
#'
#' \dontshow{
#' cap <- ragg::agg_capture(width = 7, height = 6, units = "in", res = 150)
#' grDevices::dev.control("enable")
#' }
#' plot(ftab)
#' \dontshow{
#' raster <- cap()
#' dev.off()
#' plot(as.raster(raster))
#' init_flextable_defaults()
#' }
#' @family flextable_output_export
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


# utils ----
is_in_bookdown <- function() {
  is_rdocx_document <- opts_current$get("is_rdocx_document")
  if (is.null(is_rdocx_document)) is_rdocx_document <- FALSE

  isTRUE(opts_knit$get("bookdown.internal.label")) &&
    isTRUE(!is_rdocx_document)
}
is_in_quarto <- function() {
  if (getRversion() >= numeric_version("4.4.0")) {
    isTRUE(knitr::opts_knit$get("quarto.version") > 0)
  } else {
    isTRUE(knitr::opts_knit$get("quarto.version") > numeric_version("0"))
  }
}
fake_quarto <- function() {
  if (getRversion() >= numeric_version("4.4.0")) {
    knitr::opts_knit$set("quarto.version" = 1)
  } else {
    knitr::opts_knit$set("quarto.version" = numeric_version("1.0"))
  }
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
  knitr_tab_opts <- opts_current_table()
  if (is.null(knitr_tab_opts$cap.style)) {
    knitr_tab_opts$cap.style <- "Table Caption"
  }
  x <- update_caption(
    x = x,
    caption = knitr_tab_opts$cap,
    word_stylename = knitr_tab_opts$cap.style
  )
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
