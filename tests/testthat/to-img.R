compare_image <- function(img1, img2){
  img.reference<-png::readPNG(img1)
  img.empty<-png::readPNG(img2)
  sum(img.reference==img.empty) == length(img.reference)
}

save_pptx <- function(x, path) {
  pptx_path <- save_as_pptx(x, path = tempfile(fileext = ".pptx"))
  doconv::to_miniature(pptx_path, fileout = path, width = 1600)
  path
}

save_docx <- function(x, path) {
  docx_path <- save_as_docx(x, path = tempfile(fileext = ".docx"))
  doconv::to_miniature(docx_path, fileout = path, width = 1000)
  path
}

save_pdf <- function(x, path) {
  rmd <- tempfile(fileext = ".Rmd")
  cat("```{r echo=FALSE, ft.tabcolsep = 0, ft.arraystretch = 1.2}\nx\n```\n", file = rmd)
  render(rmd, output_format = pdf_document(latex_engine="xelatex"), quiet = TRUE)
  pdf_out <- gsub("\\.Rmd$", ".pdf", rmd)
  doconv::to_miniature(pdf_out, fileout = path, width = 1000)
  path
}
expect_snapshot_to <- function(name, x, format = "docx") {
  skip_if_not_installed("doconv")
  skip_if_not_installed("png")

  skip_on_os("linux")
  skip_on_os("solaris")
  skip_on_cran()

  name <- paste0(name, ".png")
  announce_snapshot_file(name = name)
  if ("docx" %in% format) {
    path <- save_docx(x, path = tempfile(fileext = ".png"))
  } else if ("pptx" %in% format) {
    path <- save_pptx(x, path = tempfile(fileext = ".png"))
  } else if ("pdf" %in% format) {
    path <- save_pdf(x, path = tempfile(fileext = ".png"))
  } else {
    path <- save_docx(x, path = tempfile(fileext = ".png"))
  }
  expect_snapshot_file(path, name, compare = compare_image)
}

