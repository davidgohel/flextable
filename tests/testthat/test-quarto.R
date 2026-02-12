skip_on_cran()

library(officer)
library(xml2)

# -- test data ---------------------------------------------------------------
dat <- data.frame(
  label = c("bold", "link", "code", "xref"),
  content = c(
    "This is **bold** text",
    "Visit [Quarto](https://quarto.org)",
    "Use `print()` here",
    "See @tbl-results"
  ),
  stringsAsFactors = FALSE
)

ft_qmd <- flextable(dat)
ft_qmd <- mk_par(ft_qmd, j = "content",
  value = as_paragraph(as_qmd(content)))

# -- as_qmd() object creation ------------------------------------------------
test_that("as_qmd creates a chunk with qmd_data", {
  chunk <- as_qmd("**bold**")
  expect_true(inherits(chunk, "data.frame"))
  expect_true("qmd_data" %in% colnames(chunk))
  expect_equal(chunk$qmd_data, "**bold**")
  expect_equal(chunk$txt, "**bold**")
})

test_that("as_qmd uses display as fallback text", {
  chunk <- as_qmd("@tbl-results", display = "Table 1")
  expect_equal(chunk$txt, "Table 1")
  expect_equal(chunk$qmd_data, "@tbl-results")
})

# -- DOCX markers (<!--TBLQMD:base64-->) ------------------------------------
test_that("DOCX output contains TBLQMD markers", {
  docx_file <- tempfile(fileext = ".docx")
  save_as_docx(ft_qmd, path = docx_file)
  doc <- read_docx(docx_file)
  body <- docx_body_xml(doc)

  # structure: header + data rows
  rows <- xml_find_all(body, "w:body/w:tbl/w:tr")
  expect_length(rows, nrow(dat) + 1)

  # label column: regular text
  labels <- xml_text(xml_find_all(
    body, "w:body/w:tbl/w:tr[position()>1]/w:tc[1]"
  ))
  expect_equal(labels, dat$label)

  # content column: TBLQMD markers in raw XML
  doc_str <- as.character(body)

  markers <- regmatches(
    doc_str,
    gregexpr("<!--TBLQMD:([A-Za-z0-9+/=]+)-->", doc_str)
  )[[1]]
  expect_length(markers, nrow(dat))

  # markers should NOT be wrapped in <w:r>...</w:r>
  expect_false(grepl("<w:r><!--TBLQMD:", doc_str))

  # decode each marker and verify content
  for (i in seq_along(markers)) {
    encoded <- sub("<!--TBLQMD:(.+)-->", "\\1", markers[i])
    expect_equal(officer::from_base64(encoded), dat$content[i])
  }
})

# -- HTML markers (<span data-qmd-base64="...">) ----------------------------
test_that("HTML output contains data-qmd-base64 spans", {
  html_str <- flextable:::gen_raw_html(ft_qmd)

  # each cell should produce a data-qmd-base64 span
  spans <- regmatches(
    html_str,
    gregexpr('data-qmd-base64="[^"]+"', html_str)
  )[[1]]
  expect_length(spans, nrow(dat))

  # extract and decode the first marker
  encoded <- sub('data-qmd-base64="([^"]+)"', "\\1", spans[1])
  decoded <- officer::from_base64(encoded)
  expect_equal(decoded, dat$content[1])
})

# -- LaTeX markers (\tblqmd{base64}) ----------------------------------------
test_that("LaTeX output contains tblqmd markers", {
  latex_str <- flextable:::knit_to_latex(
    ft_qmd, bookdown = FALSE, quarto = TRUE
  )

  # each cell should produce a \tblqmd{...} marker
  markers <- regmatches(
    latex_str,
    gregexpr("\\\\tblqmd\\{([A-Za-z0-9+/=]+)\\}", latex_str)
  )[[1]]
  expect_length(markers, nrow(dat))

  # decode the first marker
  encoded <- sub("\\\\tblqmd\\{(.+)\\}", "\\1", markers[1])
  decoded <- officer::from_base64(encoded)
  expect_equal(decoded, dat$content[1])
})

# -- use_flextable_qmd() installs the extension -----------------------------
test_that("use_flextable_qmd copies extension files", {
  tmp_project <- tempfile("qmd_project_")
  dir.create(tmp_project)

  path <- use_flextable_qmd(path = tmp_project, quiet = TRUE)

  ext_dir <- file.path(tmp_project, "_extensions", "flextable-qmd")
  expect_true(dir.exists(ext_dir))
  expect_true(file.exists(file.path(ext_dir, "_extension.yml")))
  expect_true(file.exists(file.path(ext_dir, "flextable-qmd.lua")))
  expect_true(file.exists(file.path(ext_dir, "unwrap-float.lua")))

  unlink(tmp_project, recursive = TRUE, force = TRUE)
})

# -- mixed content: as_qmd alongside regular chunks -------------------------
test_that("as_qmd works alongside other chunk types in DOCX", {
  mixed <- data.frame(
    a = c("row1", "row2"),
    b = c("plain text", "also plain"),
    stringsAsFactors = FALSE
  )
  ft_mix <- flextable(mixed)
  ft_mix <- mk_par(ft_mix, i = 1, j = "a",
    value = as_paragraph(
      as_chunk("prefix: "),
      as_qmd("**bold ref** to @tbl-x")
    ))

  docx_file <- tempfile(fileext = ".docx")
  save_as_docx(ft_mix, path = docx_file)
  doc <- read_docx(docx_file)
  doc_str <- as.character(docx_body_xml(doc))

  # regular chunk produces text run
  expect_true(grepl("prefix: ", doc_str))
  # as_qmd chunk produces TBLQMD marker
  expect_true(grepl("<!--TBLQMD:", doc_str))
  # only one marker (one as_qmd cell)
  marker_count <- lengths(regmatches(
    doc_str, gregexpr("<!--TBLQMD:", doc_str)
  ))
  expect_equal(marker_count, 1)
})
