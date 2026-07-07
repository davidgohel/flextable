# Liberation Sans is registered so the emitted `font: "..."` is deterministic
# across machines (mirrors test-latex.R).
gdtools::register_liberationsans()

# build a flextable with a fixed font on every part
ft_lib <- function(df) {
  ft <- flextable(df)
  font(ft, fontname = "Liberation Sans", part = "all")
}

# a small real PNG file (path-based image, no raster rendering needed)
make_png <- function() {
  f <- tempfile(fileext = ".png")
  grDevices::png(f, width = 60, height = 40)
  old <- graphics::par(mar = c(0, 0, 0, 0))
  graphics::plot.new()
  graphics::rect(0, 0, 1, 1, col = "grey")
  graphics::par(old)
  grDevices::dev.off()
  f
}

# -- table structure ---------------------------------------------------------
test_that("gen_raw_typst emits a Typst table skeleton", {
  str <- flextable:::gen_raw_typst(ft_lib(head(iris, 2)))
  expect_type(str, "character")
  expect_match(str, "#table(", fixed = TRUE)
  expect_match(str, "columns:", fixed = TRUE)
  expect_match(str, "stroke: none", fixed = TRUE)
  expect_match(str, "table.cell(", fixed = TRUE)
  expect_match(str, "table.header(", fixed = TRUE)
})

test_that("font family is emitted from the cell property", {
  str <- flextable:::gen_raw_typst(ft_lib(head(iris, 1)))
  expect_match(str, 'font: "Liberation Sans"', fixed = TRUE)
})

# -- fills, borders, alignment ----------------------------------------------
test_that("background colour becomes fill: rgb(...)", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- bg(ft, j = "a", bg = "#FFEEAA", part = "body")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, 'fill: rgb("FFEEAA")', fixed = TRUE)
})

test_that("borders become per-side stroke entries", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- hline(
    ft,
    j = "a",
    border = fp_border_default(color = "red", width = 2),
    part = "body"
  )
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "stroke: (", fixed = TRUE)
  expect_match(str, 'rgb("FF0000")', fixed = TRUE)
  # a side without border is emitted as none
  expect_match(str, "left: none", fixed = TRUE)
})

test_that("alignment maps to Typst align", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- align(ft, j = "a", align = "center", part = "body")
  ft <- valign(ft, j = "a", valign = "top", part = "body")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "align: center + top", fixed = TRUE)
})

# -- text run styling --------------------------------------------------------
test_that("bold / italic / colour render as #text args", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- bold(ft, j = "a", part = "body")
  ft <- italic(ft, j = "a", part = "body")
  ft <- color(ft, j = "a", color = "red", part = "body")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, 'weight: "bold"', fixed = TRUE)
  expect_match(str, 'style: "italic"', fixed = TRUE)
  expect_match(str, 'fill: rgb("FF0000")', fixed = TRUE)
})

test_that("underline, strike and super/subscript wrap the run", {
  mk <- function(props) {
    ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
    ft <- compose(
      ft,
      j = "a",
      value = as_paragraph(as_chunk("x", props = props))
    )
    flextable:::gen_raw_typst(ft)
  }
  expect_match(
    mk(fp_text_default(underlined = TRUE)),
    "#underline[",
    fixed = TRUE
  )
  expect_match(mk(fp_text_default(strike = TRUE)), "#strike[", fixed = TRUE)
  expect_match(
    mk(fp_text_default(vertical.align = "superscript")),
    "#super[",
    fixed = TRUE
  )
  expect_match(
    mk(fp_text_default(vertical.align = "subscript")),
    "#sub[",
    fixed = TRUE
  )
})

test_that("special characters are escaped in text", {
  ft <- ft_lib(data.frame(a = "x#y*z", stringsAsFactors = FALSE))
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "x\\#y\\*z", fixed = TRUE)
})

test_that("markup shorthand triggers are escaped (no dash/ellipsis/quote subst)", {
  # Typst would otherwise turn --/---/... into en/em dash/ellipsis, `-` before
  # a digit into a minus sign, and '/" into curly quotes. Each trigger char is
  # escaped individually so the literal text is preserved.
  mk <- function(txt) {
    flextable:::gen_raw_typst(ft_lib(data.frame(
      a = txt,
      stringsAsFactors = FALSE
    )))
  }
  expect_match(mk("a--b"), "a\\-\\-b", fixed = TRUE)
  expect_match(mk("a---b"), "a\\-\\-\\-b", fixed = TRUE)
  expect_match(mk("x...y"), "x\\.\\.\\.y", fixed = TRUE)
  expect_match(mk("-5"), "\\-5", fixed = TRUE)
  expect_match(mk("q\"u'v"), "q\\\"u\\'v", fixed = TRUE)
})

test_that("line-start markers are escaped (no heading/enum/term marker)", {
  # `=`/`+`/`/` are markup markers at a line start; `/` even fails to compile.
  # Escaping every occurrence keeps the literal text and is safe mid-line too.
  mk <- function(txt) {
    flextable:::gen_raw_typst(ft_lib(data.frame(
      a = txt,
      stringsAsFactors = FALSE
    )))
  }
  expect_match(mk("= Titre"), "\\= Titre", fixed = TRUE)
  expect_match(mk("+ item"), "\\+ item", fixed = TRUE)
  expect_match(mk("/ terme"), "\\/ terme", fixed = TRUE)
  expect_match(mk("a/b"), "a\\/b", fixed = TRUE)
})

# -- spans -------------------------------------------------------------------
test_that("horizontal merge produces colspan", {
  ft <- ft_lib(data.frame(a = "x", b = "y", stringsAsFactors = FALSE))
  ft <- merge_at(ft, i = 1, j = 1:2, part = "header")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "colspan: 2", fixed = TRUE)
})

test_that("vertical merge produces rowspan", {
  ft <- ft_lib(data.frame(a = c("X", "X"), b = 1:2, stringsAsFactors = FALSE))
  ft <- merge_v(ft, j = "a")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "rowspan: 2", fixed = TRUE)
})

# -- equations ---------------------------------------------------------------
test_that("equations become mitex #mi(`...`)", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- compose(ft, j = "a", value = as_paragraph(as_equation("\\alpha")))
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "#mi(`\\alpha`)", fixed = TRUE)
})

# -- as_qmd ------------------------------------------------------------------
test_that("as_qmd emits a base64 marker, not wrapped in #text", {
  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- compose(ft, j = "a", value = as_paragraph(as_qmd("**bold**")))
  str <- flextable:::gen_raw_typst(ft)
  expected <- sprintf("/*tblqmd:%s*/", officer::as_base64("**bold**"))
  expect_match(str, expected, fixed = TRUE)
  # marker sits directly inside the cell content (no #text wrapper)
  expect_match(str, "[/*tblqmd:", fixed = TRUE)
})

# -- rotation ----------------------------------------------------------------
test_that("text rotation wraps content in #rotate(..., reflow: true)", {
  ft <- ft_lib(data.frame(tb = 1, bt = 2, stringsAsFactors = FALSE))
  ft <- rotate(ft, j = "tb", rotation = "tbrl", part = "header")
  ft <- rotate(ft, j = "bt", rotation = "btlr", part = "header")
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, "#rotate(90deg, reflow: true)[", fixed = TRUE)
  expect_match(str, "#rotate(-90deg, reflow: true)[", fixed = TRUE)
})

# -- images: path mode (Quarto) vs embed mode (standalone) -------------------
test_that("image path mode emits #image(\"path\")", {
  # path mode writes the image under fig_path()'s dir ("figure/" by default);
  # run in a throwaway working dir so nothing leaks into the package sources.
  withr::local_dir(withr::local_tempdir())
  img <- make_png()
  ft <- ft_lib(data.frame(a = "", stringsAsFactors = FALSE))
  ft <- compose(
    ft,
    j = "a",
    value = as_paragraph(as_image(img, width = .5, height = .3))
  )
  str <- flextable:::gen_raw_typst(ft)
  expect_match(str, '#image("', fixed = TRUE)
  expect_no_match(str, "ft-b64-decode", fixed = TRUE)
})

test_that("image embed mode emits base64 decoder call", {
  img <- make_png()
  ft <- ft_lib(data.frame(a = "", stringsAsFactors = FALSE))
  ft <- compose(
    ft,
    j = "a",
    value = as_paragraph(as_image(img, width = .5, height = .3))
  )
  str <- flextable:::gen_raw_typst(ft, image_mode = "embed")
  expect_match(str, "#image(ft-b64-decode(\"", fixed = TRUE)
  # no `format:` is emitted: a bytes source is auto-detected by Typst, and the
  # mime subtype ("jpeg"/"svg+xml") is not a valid Typst format string.
  expect_no_match(str, "format:", fixed = TRUE)
})

# -- knit_to_typst -----------------------------------------------------------
test_that("knit_to_typst returns character and injects mitex on equations", {
  z <- flextable:::knit_to_typst(ft_lib(head(iris, 2)))
  expect_type(z, "character")
  expect_no_match(z, "@preview/mitex", fixed = TRUE)

  ft <- ft_lib(data.frame(a = "x", stringsAsFactors = FALSE))
  ft <- compose(ft, j = "a", value = as_paragraph(as_equation("\\alpha")))
  z <- flextable:::knit_to_typst(ft)
  expect_match(z, "@preview/mitex", fixed = TRUE)
})

# -- save_as_typst -----------------------------------------------------------
test_that("save_as_typst writes a standalone document", {
  tf <- tempfile(fileext = ".typ")
  res <- save_as_typst(ft_lib(head(iris, 2)), path = tf)
  expect_equal(res, tf)
  lines <- readLines(tf)
  doc <- paste(lines, collapse = "\n")
  expect_match(doc, "#set page", fixed = TRUE)
  expect_match(doc, "#table(", fixed = TRUE)
  # no image / no equation -> no decoder, no mitex import
  expect_no_match(doc, "ft-b64-decode", fixed = TRUE)
  expect_no_match(doc, "@preview/mitex", fixed = TRUE)
})

test_that("save_as_typst injects the base64 decoder when images are embedded", {
  img <- make_png()
  ft <- ft_lib(data.frame(a = "", stringsAsFactors = FALSE))
  ft <- compose(
    ft,
    j = "a",
    value = as_paragraph(as_image(img, width = .5, height = .3))
  )
  tf <- tempfile(fileext = ".typ")
  save_as_typst(ft, path = tf)
  doc <- paste(readLines(tf), collapse = "\n")
  expect_match(doc, "#let ft-b64-decode", fixed = TRUE)
  expect_match(doc, "#image(ft-b64-decode(\"", fixed = TRUE)
})

test_that("save_as_typst errors without a flextable", {
  expect_error(save_as_typst(1, path = tempfile()), "no flextable")
})

test_that("cells are not justified unless text.align is justify", {
  ft <- ft_lib(data.frame(a = "some long text", stringsAsFactors = FALSE))
  ty <- paste(flextable:::gen_raw_typst(ft), collapse = "\n")
  # Quarto sets par(justify: true) document-wide; the table opts out
  expect_match(ty, "#set par(justify: false)", fixed = TRUE)
  expect_no_match(ty, "justify: true", fixed = TRUE)

  ft <- align(ft, align = "justify", part = "body")
  ty <- paste(flextable:::gen_raw_typst(ft), collapse = "\n")
  expect_match(ty, "#par(justify: true)[", fixed = TRUE)
})
