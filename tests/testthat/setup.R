# Collection of functions and data pre-processing to help with testing
library(officer)
library(xml2)

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
  xml_child(docx_body_xml(redoc))
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
  xml_child(slide$get())
}

get_html_xml <- function(x) {
  if (inherits(x, "flextable")) {
    html_file <- tempfile(fileext = ".html")
    save_as_html(tab, path = html_file)
    x <- html_file
  }
  doc <- read_html(x)
  xml_child(doc, "body")
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

# Getting snapshots in the _snaps folder for local testing if conditions are met
do_manual_msoffice_snapshot_testing <- FALSE
copy_back_new_snapshots <- FALSE # if snapshots are updated can be rewritten back

# Utility function to manually test local snapshots ----------------------------
skip_if_not_local_testing <- function(min_pandoc_version = "2", check_html = FALSE) {
  skip_on_cran() # When doing manual testing, it should be always skipped on CRAN
  skip_on_ci() # msoffice testing can not be done on ci
  skip_if_not(do_manual_msoffice_snapshot_testing)
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

handle_manual_snapshots <- function(snapshot_folder, snapshot_name) {
  skip_if_not_installed("withr")
  skip_if_not(do_manual_msoffice_snapshot_testing)

  snapshot_name <- paste0(snapshot_name, ".png")

  # Folder where the snapshots are stored
  main_inst_folder <- system.file("snapshots_for_manual_tests", package = "flextable", mustWork = TRUE)

  snapshot_file <- file.path(main_inst_folder, snapshot_folder, snapshot_name)

  if (!file.exists(snapshot_file)) {
    stop("Following snapshot file not found in {flextable}:", snapshot_file)
  }

  # Construct the path to the _snaps folder
  path_to_snaps <- file.path("_snaps", snapshot_folder)
  if (!dir.exists("_snaps")) {
    dir.create("_snaps")
  }
  if (!dir.exists(path_to_snaps)) {
    dir.create(path_to_snaps)
  }

  # Main copy
  file.copy(snapshot_file, path_to_snaps, overwrite = TRUE)

  # Copying back and cleaning test folder
  withr::defer(
    {
      snap_file <- file.path(path_to_snaps, snapshot_name)
      if (copy_back_new_snapshots) {
        file.copy(snap_file, dirname(snapshot_file), overwrite = TRUE)
      }
      if (file.exists(snap_file)) {
        file.remove(snap_file)
      }
    },
    envir = parent.frame()
  )
}

defer_cleaning_snapshot_directory <- function(snap_folder_test_file) {
  skip_if_not_installed("withr")
  skip_if_not(do_manual_msoffice_snapshot_testing)
  withr::defer({
    last_folder <- file.path("_snaps", snap_folder_test_file)
    files_not_removed_for_error <- list.files(last_folder)
    if (length(files_not_removed_for_error)) {
      lapply(files_not_removed_for_error, file.remove)
    }
    if (dir.exists("_snaps")) {
      unlink("_snaps", recursive = TRUE)
    }
  })
}
