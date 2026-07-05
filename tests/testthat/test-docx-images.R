img_file <- file.path(R.home("doc"), "html", "logo.jpg")

ft_img <- function() {
  ft <- flextable(data.frame(a = "x"))
  compose(
    ft,
    j = "a",
    value = as_paragraph(as_image(img_file, width = .5, height = .4))
  )
}

test_that("knit_to_wml warns when images can not be embedded by pandoc", {
  old <- knitr::opts_knit$get("rmarkdown.pandoc.to")
  knitr::opts_knit$set("rmarkdown.pandoc.to" = "docx")
  on.exit(knitr::opts_knit$set("rmarkdown.pandoc.to" = old))

  expect_warning(
    flextable:::knit_to_wml(ft_img(), quarto = TRUE),
    "repair_docx"
  )
  expect_no_warning(
    flextable:::knit_to_wml(flextable(head(cars, 2)), quarto = TRUE)
  )

  # hyperlinks are also unresolved references in pandoc-written docx
  ft_url <- flextable(data.frame(a = "flextable"))
  ft_url <- compose(
    ft_url,
    j = "a",
    value = as_paragraph(
      hyperlink_text(x = a, url = "https://davidgohel.github.io/flextable/")
    )
  )
  expect_true(flextable:::has_hlink(ft_url))
  expect_false(flextable:::has_hlink(flextable(head(cars, 2))))
  expect_warning(
    flextable:::knit_to_wml(ft_url, quarto = TRUE),
    "repair_docx"
  )

  # no warning when officedown post-processes the document
  knitr::opts_current$set(is_rdocx_document = TRUE)
  on.exit(knitr::opts_current$set(is_rdocx_document = NULL), add = TRUE)
  expect_no_warning(flextable:::knit_to_wml(ft_img()))
})

test_that("repair_docx registers image references", {
  # simulate a pandoc-written docx: image referenced by path, not
  # registered in the package
  path <- tempfile(fileext = ".docx")
  z <- officer::read_docx()
  z <- officer::body_add_par(z, "placeholder")
  print(z, target = path)

  dir <- tempfile()
  officer::unpack_folder(path, dir)
  doc_xml_path <- file.path(dir, "word", "document.xml")
  doc <- readLines(doc_xml_path, warn = FALSE)
  run <- flextable:::wml_image(img_file, width = .5, height = .4)
  doc <- sub(
    "placeholder",
    paste0("placeholder", "</w:t></w:r>", run, "<w:r><w:t>"),
    doc,
    fixed = TRUE
  )
  writeLines(doc, doc_xml_path, useBytes = TRUE)
  broken <- officer::pack_folder(dir, tempfile(fileext = ".docx"))

  fixed <- tempfile(fileext = ".docx")
  repair_docx(broken, target = fixed)

  out <- tempfile()
  officer::unpack_folder(fixed, out)
  xml <- paste(
    readLines(file.path(out, "word", "document.xml"), warn = FALSE),
    collapse = ""
  )
  expect_match(xml, "r:embed=\"rId[0-9]+\"")
  expect_no_match(xml, "r:embed=\"[^\"]*logo\\.jpg\"")
  expect_length(list.files(file.path(out, "word", "media")), 1)

  expect_error(repair_docx(tempfile(fileext = ".docx")), "existing")
  expect_error(repair_docx(img_file), "docx")
})
