context("check headers")

library(xml2)
library(officer)

test_that("set_header_labels", {
  col_keys <- c(
    "Species",
    "sep1", "Sepal.Length", "Sepal.Width",
    "sep2", "Petal.Length", "Petal.Width"
  )
  ft <- flextable(head(iris), col_keys = col_keys)
  ft <- set_header_labels(ft,
    Sepal.Length = "Sepal length",
    Sepal.Width = "Sepal width", Petal.Length = "Petal length",
    Petal.Width = "Petal width"
  )

  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  doc <- print(doc, target = docx_file)

  main_folder <- file.path(getwd(), "docx_folder")
  unpack_folder(file = docx_file, folder = main_folder)

  doc_file <- file.path(main_folder, "/word/document.xml")
  doc <- read_xml(doc_file)

  colnodes <- xml_find_all(doc, "w:body/w:tbl/w:tr[w:trPr/w:tblHeader]/w:tc")

  expect_equal(
    xml_text(colnodes),
    c("Species", "", "Sepal length", "Sepal width", "", "Petal length", "Petal width")
  )

  unlink(main_folder, recursive = TRUE, force = TRUE)

  ft <- flextable(mtcars)
  ft <- set_header_labels(ft, values = letters[1:ncol(mtcars)])
  ft <- delete_part(ft, part = "body")
  expect_equal(
    flextable:::fortify_run(ft)$txt,
    letters[1:ncol(mtcars)]
  )
})

test_that("add_header", {
  data_ref <- structure(
    list(
      Sepal.Length = c("Sepal", "s", "(cm)"),
      Sepal.Width = c("Sepal", "", "(cm)"),
      Petal.Length = c("Petal", "", "(cm)"),
      Petal.Width = c("Petal", "", "(cm)"),
      Species = c("Species", "", "(cm)")
    ),
    .Names = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species"),
    row.names = c(NA, -3L), class = "data.frame"
  )


  ft <- flextable(iris[1:6, ])
  ft <- set_header_labels(
    ft,
    Sepal.Length = "Sepal",
    Sepal.Width = "Sepal", Petal.Length = "Petal",
    Petal.Width = "Petal", Species = "Species"
  )
  ft <- add_header(ft, Sepal.Length = "s", top = FALSE)
  ft <- add_header(
    ft,
    Sepal.Length = "(cm)",
    Sepal.Width = "(cm)", Petal.Length = "(cm)",
    Petal.Width = "(cm)", Species = "(cm)", top = FALSE
  )
  has_ <- flextable:::fortify_content(
    ft$header$content,
    default_chunk_fmt = ft$header$styles$text
  )$txt
  expect_equal(has_, as.character(unlist(data_ref)))


  ft <- flextable(iris[1:6, ])
  ft <- set_header_labels(
    ft,
    Sepal.Length = "Sepal",
    Sepal.Width = "Sepal", Petal.Length = "Petal",
    Petal.Width = "Petal", Species = "Species"
  )
  ft <- add_header(ft, Sepal.Length = "s", top = FALSE)
  ft <- add_header(
    ft,
    Sepal.Length = "(cm)",
    Sepal.Width = "(cm)", Petal.Length = "(cm)",
    Petal.Width = "(cm)", Species = "(cm)", top = FALSE
  )
  has_ <- flextable:::fortify_content(
    ft$header$content,
    default_chunk_fmt = ft$header$styles$text
  )$txt
  expect_equal(has_, as.character(unlist(data_ref)))
})

test_that("set_header_df", {
  typology <- data.frame(
    col_keys = c(
      "Sepal.Length", "Sepal.Width", "Petal.Length",
      "Petal.Width", "Species"
    ),
    what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
    measure = c("Length", "Width", "Length", "Width", "Species"),
    stringsAsFactors = FALSE
  )
  data <- iris[c(1:3, 51:53, 101:104), ]

  ft <- flextable(
    data,
    col_keys = c(
      "Species",
      "sep_1", "Sepal.Length", "Sepal.Width",
      "sep_2", "Petal.Length", "Petal.Width"
    )
  )
  ft <- set_header_df(ft, mapping = typology, key = "col_keys")

  data_ref <- structure(
    list(
      Species = c("Species", "Species"),
      sep_1 = c("", ""),
      Sepal.Length = c("Sepal", "Length"),
      Sepal.Width = c("Sepal", "Width"),
      sep_2 = c("", ""),
      Petal.Length = c("Petal", "Length"),
      Petal.Width = c("Petal", "Width")
    ),
    .Names = c("Species", "sep_1", "Sepal.Length", "Sepal.Width", "sep_2", "Petal.Length", "Petal.Width"),
    row.names = c(NA, -2L), class = "data.frame"
  )
  expect_ <- as.character(unlist(data_ref))
  has_ <- flextable:::fortify_content(
    ft$header$content,
    default_chunk_fmt = ft$header$styles$text
  )$txt
  expect_equal(has_, expect_)
})
