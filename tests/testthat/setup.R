# Collection of functions and data pre-processing to help with testing

# Utility function to manually test local snapshots ----------------------------
skip_if_not_local_testing <- function(min_pandoc_version = "2", check_html = FALSE) {
  skip_on_cran() # When doing manual testing, it should be always skipped on CRAN
  local_edition(3, .env = parent.frame()) # Set the local_edition at 3
  skip_if_not_installed("doconv")
  skip_if_not(doconv::msoffice_available())
  if (!is.null(min_pandoc_version)) { # Can be turned off with NULL
    skip_if_not(rmarkdown::pandoc_version() >= numeric_version(min_pandoc_version))
  }
  if (isTRUE(check_html)) {
    skip_if_not_installed("webshot2")
  }
  invisible(TRUE)
}


# xml related functions --------------------------------------------------------
get_docx_xml <- function(x) {
  if (inherits(x, "flextable")) {
    docx_file <- tempfile(fileext = ".docx")
    doc <- read_docx()
    doc <- body_add_flextable(doc, value = x)
    print(doc, target = docx_file)
    x <- docx_file
  }
  redoc <- read_docx(x)
  xml2::xml_child(docx_body_xml(redoc))
}

get_pptx_xml <- function(x) {
  if (inherits(x, "flextable")) {
    pptx_file <- tempfile(fileext = ".pptx")
    doc <- read_pptx()
    doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
    doc <- ph_with(doc, x, location = ph_location_type(type = "body"))
    print(doc, target = pptx_file)
    x <- pptx_file
  }

  redoc <- read_pptx(x)
  slide <- redoc$slide$get_slide(redoc$cursor)
  xml2::xml_child(slide$get())
}

get_html_xml <- function(x) {
  if (inherits(x, "flextable")) {
    html_file <- tempfile(fileext = ".html")
    save_as_html(tab, path = html_file)
    x <- html_file
  }
  doc <- read_html(x)
  xml2::xml_child(doc, "body")
}
get_pdf_text <- function(x, extract_fun) {
  stopifnot(grepl("\\.pdf$", x))

  doc <- extract_fun(x)
  txtfile <- tempfile()
  cat(paste0(doc, collapse = "\n"), file = txtfile)
  readLines(txtfile)
}

render_rmd <- function(file, rmd_format) {
  unlink(file, force = TRUE)
  sucess <- FALSE
  tryCatch(
    {
      render(rmd_file,
        output_format = rmd_format,
        output_file = pdf_file,
        envir = new.env(),
        quiet = TRUE
      )
      sucess <- TRUE
    },
    warning = function(e) {
    },
    error = function(e) {
    }
  )
  sucess
}
