test_that("white spaces are protected", {
  ft <- flextable(data.frame(x = ""))
  ft <- delete_part(ft, part = "header")
  ft <- mk_par(ft, 1, 1, as_paragraph("foo", " ", "bar"))
  str <- flextable:::gen_raw_latex(ft)
  expect_true(grepl("{\\ }", str, fixed = TRUE))
})


test_that("merge_v places content at top of merged range", {
  ft <- flextable(data.frame(a = c("X", "X", "Y", "Y"), b = 1:4))
  ft <- merge_v(ft, j = "a")
  latex_str <- flextable:::gen_raw_latex(ft)

  lines <- unlist(strsplit(latex_str, "\n"))

  # no \multirow should be used (removed in favour of row placement)
  expect_false(any(grepl("\\\\multirow", lines)))

  # "X" should appear in first body row (with value "1")
  x_line <- grep("X", lines)[1]
  expect_true(grepl("1", lines[x_line]))

  # "Y" should appear in first row of its group (with value "3")
  y_line <- grep("Y", lines)[1]
  expect_true(grepl("3", lines[y_line]))
})

test_that("valign works in merged cells with varying row heights", {
  ft <- flextable(data.frame(
    col1 = c("A1", "A1", "A1"),
    col2 = c("B1", "long text", "B3")
  ))
  ft <- merge_at(ft, i = 1:3, j = 1)

  lines_for <- function(va) {
    ft2 <- valign(ft, valign = va)
    latex_str <- flextable:::gen_raw_latex(ft2)
    strsplit(latex_str, "\n")[[1]]
  }

  # top: A1 in first row, no multirow
  top_lines <- lines_for("top")
  top_body <- grep("A1|B1|B3", top_lines, value = TRUE)
  a1_line <- grep("A1", top_lines)[1]
  b1_line <- grep("B1", top_lines)[1]
  expect_equal(a1_line, b1_line) # A1 and B1 on same line
  expect_false(any(grepl("\\\\multirow", top_body)))

  # center: A1 in middle row (row 2), no multirow
  ctr_lines <- lines_for("center")
  a1_line <- grep("A1", ctr_lines)[1]
  b1_line <- grep("B1", ctr_lines)[1]
  b3_line <- grep("B3", ctr_lines)[1]
  expect_true(a1_line > b1_line) # A1 is after B1 (not in first row)
  expect_true(a1_line < b3_line) # A1 is before B3 (not in last row)
  expect_false(any(grepl("\\\\multirow", grep("A1", ctr_lines, value = TRUE))))

  # bottom: A1 in last row, no multirow
  bot_lines <- lines_for("bottom")
  bot_body <- grep("A1|B1|B3", bot_lines, value = TRUE)
  a1_line <- grep("A1", bot_lines)[1]
  b3_line <- grep("B3", bot_lines)[1]
  expect_equal(a1_line, b3_line) # A1 and B3 on same line
  expect_false(any(grepl("\\\\multirow", bot_body)))
})

# knit_to_latex tests ----
test_that("knit_to_latex default float none", {
  ft <- flextable(head(iris, 2))
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_true(is.character(z))
  expect_match(z, "\\\\setlength\\{\\\\tabcolsep\\}", perl = TRUE)
  expect_match(z, "\\\\renewcommand", perl = TRUE)
  expect_match(z, "arrayrulewidth", fixed = TRUE)
  # none container => no \begin{table}
  expect_no_match(z, "\\begin{table}", fixed = TRUE)
  expect_no_match(z, "\\begin{wraptable}", fixed = TRUE)
})

test_that("knit_to_latex float container", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$float <- "float"
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\begin{table}", fixed = TRUE)
  expect_match(z, "\\end{table}", fixed = TRUE)
})

test_that("knit_to_latex wrap-l container", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$float <- "wrap-l"
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\begin{wraptable}{l}", fixed = TRUE)
  expect_match(z, "\\end{wraptable}", fixed = TRUE)
})

test_that("knit_to_latex wrap-r container", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$float <- "wrap-r"
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\begin{wraptable}{r}", fixed = TRUE)
})

test_that("knit_to_latex wrap-i container", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$float <- "wrap-i"
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\begin{wraptable}{i}", fixed = TRUE)
})

test_that("knit_to_latex wrap-o container", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$float <- "wrap-o"
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\begin{wraptable}{o}", fixed = TRUE)
})

test_that("knit_to_latex quarto caption is empty", {
  ft <- flextable(head(iris, 2))
  ft <- set_caption(ft, caption = "A test caption")
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = TRUE
  )
  # quarto mode: caption should not appear in latex
  expect_no_match(z, "A test caption", fixed = TRUE)
})

test_that("knit_to_latex bookdown caption", {
  ft <- flextable(head(iris, 2))
  ft <- set_caption(ft, caption = "My bookdown cap")
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = TRUE,
    quarto = FALSE
  )
  expect_true(is.character(z))
})

test_that("knit_to_latex tabcolsep and arraystretch", {
  ft <- flextable(head(iris, 2))
  ft$properties$opts_pdf$tabcolsep <- 5
  ft$properties$opts_pdf$arraystretch <- 2.0
  z <- flextable:::knit_to_latex(
    ft,
    bookdown = FALSE,
    quarto = FALSE
  )
  expect_match(z, "\\setlength{\\tabcolsep}{5pt}", fixed = TRUE)
  expect_match(z, "\\renewcommand*{\\arraystretch}{2}", fixed = TRUE)
})

test_that("fonts are defined in latex", {
  gdtools::register_liberationsans()
  ft <- flextable::flextable(head(cars, n = 1))
  ft <- flextable::font(ft, fontname = "Liberation Sans", part = "body")

  # R Markdown with pdflatex
  knitr::opts_knit$set("quarto.version" = NULL)
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_no_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)

  knitr::opts_knit$set("rmarkdown.pandoc.args" = c("--pdf-engine", "xelatex"))
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  # quarto (defaults to xelatex)
  flextable:::fake_quarto()
  latex_str <- flextable:::gen_raw_latex(ft, quarto = TRUE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
  knitr::opts_knit$set("quarto.version" = NULL)
})

# helper to temporarily set rmarkdown::metadata
local_rmarkdown_metadata <- function(value, envir = parent.frame()) {
  ns <- asNamespace("rmarkdown")
  unlockBinding("metadata", ns)
  old <- rmarkdown::metadata
  assign("metadata", value, envir = ns)
  withr::defer(
    {
      assign("metadata", old, envir = ns)
      lockBinding("metadata", ns)
    },
    envir = envir
  )
}

# get_pdf_engine tests ----
test_that("get_pdf_engine returns pdflatex for Quarto with top-level pdf-engine", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list("pdf-engine" = "pdflatex"))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  engine <- flextable:::get_pdf_engine()
  expect_equal(engine, "pdflatex")

  knitr::opts_knit$set("quarto.version" = NULL)
})

test_that("get_pdf_engine returns pdflatex for Quarto with nested pdf-engine", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list(
    format = list(pdf = list("pdf-engine" = "pdflatex"))
  ))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  engine <- flextable:::get_pdf_engine()
  expect_equal(engine, "pdflatex")

  knitr::opts_knit$set("quarto.version" = NULL)
})

test_that("get_pdf_engine defaults to xelatex for Quarto with no engine", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list())
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  engine <- flextable:::get_pdf_engine()
  expect_equal(engine, "xelatex")

  knitr::opts_knit$set("quarto.version" = NULL)
})

test_that("get_pdf_engine reads QUARTO_EXECUTE_INFO when available", {
  skip_if_not_installed("jsonlite")
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list())
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  # write a temporary JSON file mimicking QUARTO_EXECUTE_INFO
  info <- list(format = list(pandoc = list("pdf-engine" = "pdflatex")))
  tmp <- tempfile(fileext = ".json")
  jsonlite::write_json(info, tmp, auto_unbox = TRUE)
  withr::local_envvar("QUARTO_EXECUTE_INFO" = tmp)

  engine <- flextable:::get_pdf_engine()
  expect_equal(engine, "pdflatex")

  knitr::opts_knit$set("quarto.version" = NULL)
})

test_that("get_pdf_engine QUARTO_EXECUTE_INFO takes priority over metadata", {
  skip_if_not_installed("jsonlite")
  flextable:::fake_quarto()
  # metadata says xelatex, but QUARTO_EXECUTE_INFO says pdflatex
  local_rmarkdown_metadata(list("pdf-engine" = "xelatex"))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  info <- list(format = list(pandoc = list("pdf-engine" = "pdflatex")))
  tmp <- tempfile(fileext = ".json")
  jsonlite::write_json(info, tmp, auto_unbox = TRUE)
  withr::local_envvar("QUARTO_EXECUTE_INFO" = tmp)

  engine <- flextable:::get_pdf_engine()
  expect_equal(engine, "pdflatex")

  knitr::opts_knit$set("quarto.version" = NULL)
})

# list_latex_dep / fontspec tests ----
test_that("list_latex_dep does not include fontspec when Quarto + pdflatex", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list("pdf-engine" = "pdflatex"))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  deps <- suppressWarnings(withr::with_options(
    list(knitr.in.progress = TRUE),
    {
      knitr::opts_knit$set("out.format" = "latex")
      flextable:::list_latex_dep()
    }
  ))
  dep_names <- vapply(deps, function(d) d$name, character(1))
  expect_false("fontspec" %in% dep_names)

  knitr::opts_knit$set("quarto.version" = NULL, "out.format" = NULL)
})

test_that("list_latex_dep includes fontspec when Quarto + xelatex", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list("pdf-engine" = "xelatex"))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  deps <- withr::with_options(
    list(knitr.in.progress = TRUE),
    {
      knitr::opts_knit$set("out.format" = "latex")
      flextable:::list_latex_dep()
    }
  )
  dep_names <- vapply(deps, function(d) d$name, character(1))
  expect_true("fontspec" %in% dep_names)

  knitr::opts_knit$set("quarto.version" = NULL, "out.format" = NULL)
})

test_that("font warning fires for Quarto + pdflatex", {
  flextable:::fake_quarto()
  local_rmarkdown_metadata(list("pdf-engine" = "pdflatex"))
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  expect_warning(
    withr::with_options(
      list(knitr.in.progress = TRUE),
      {
        knitr::opts_knit$set("out.format" = "latex")
        flextable:::list_latex_dep()
      }
    ),
    "fonts used in `flextable` are ignored"
  )

  knitr::opts_knit$set("quarto.version" = NULL, "out.format" = NULL)
})
