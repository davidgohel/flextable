context("check footnotes")


test_that("create multiple footnote with callout in header", {
  ft <- flextable(head(iris))
  ft <- footnote( ft, i = 1, j = 1:3,
                  value = as_paragraph(
                    c("This is footnote one",
                      "This is footnote two",
                      "This is footnote three")
                  ),
                  ref_symbols = c("a", "b", "c"),
                  part = "header")

  # Check the footnotes themselves
  expected_footnote <- c(
    "a", "This is footnote one",
    "b", "This is footnote two",
    "c", "This is footnote three"
  )
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text )$txt
  expect_equal(expected_footnote, has_[1:6])

  # Check the footnote vertical alignment
  expected_va <- c(
    "superscript", "baseline",
    "superscript", "baseline",
    "superscript", "baseline"
  )
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text )$vertical.align
  expect_equal(expected_va, has_[1:6])

  # Check the header for the footnote callouts
  expected_header <- c(
    "Sepal.Length", "a",
    "Sepal.Width", "b",
    "Petal.Length", "c",
    "Petal.Width",
    "Species"
  )
  has_ <- flextable:::fortify_content(
    ft$header$content,
    default_chunk_fmt = ft$header$styles$text)$txt
  expect_equal(expected_header, has_)

  # Check the header for the callout vertical alignment
  expected_va <- c(
    "baseline", "superscript",
    "baseline", "superscript",
    "baseline", "superscript",
    "baseline",
    "baseline"
  )
  has_ <- flextable:::fortify_content(
    ft$header$content,
    default_chunk_fmt = ft$header$styles$text)$vertical.align
  expect_equal(expected_va, has_)
})

test_that("use formulas and character to target footnotes in body", {
  ft <- flextable(head(iris))
  ft <- footnote( ft, i = ~ Sepal.Length > 5.0, j = c("Sepal.Width",
                                                      "Petal.Length"),
                  value = as_paragraph(
                    "This is footnote one"
                  ),
                  ref_symbols = "a",
                  part = "body")

  # Check the footnotes
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text )$txt
  expect_equal(has_[1:2], c("a", "This is footnote one"))

  # Check the callouts
  expected_body <- c("5.1", "4.9", "4.7", "4.6", "5.0", "5.4", "3.5", "a",
                     "3.0", "3.2", "3.1", "3.6", "3.9", "a", "1.4", "a",
                     "1.4", "1.3", "1.5", "1.4", "1.7", "a", "0.2", "0.2",
                     "0.2", "0.2", "0.2", "0.4", "setosa", "setosa",
                     "setosa", "setosa", "setosa", "setosa")
  has_ <- flextable:::fortify_content(
    ft$body$content,
    default_chunk_fmt = ft$body$styles$text )$txt
  expect_equal(expected_body, has_)
})

test_that("add footnote with callouts in several cells in body", {
  ft <- flextable(head(iris))
  ft <- footnote_multi_callout(ft,
                               i_list = list(1, 3, ~ Petal.Length == 1.7),
                               j_list = list(1, 2, "Petal.Length"),
                               value = as_paragraph("This is footnote one"),
                               ref_symbol = "(a)")
  ft <- footnote_multi_callout(ft, i_list = list(1, 5), j_list = list(1, 2),
                               value = as_paragraph("This is footnote two"),
                               ref_symbol = "(b)")

  # Check the footnotes themselves
  expected_footnote <- c(
    "(a)", "This is footnote one",
    "(b)", "This is footnote two"
  )
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text )$txt
  expect_equal(expected_footnote, has_[1:4])

  # Check that the footnotes callouts are in the right place
  expected_body <- c("5.1", "(a)", "(b)", "4.9", "4.7", "4.6", "5.0",
                     "5.4", "3.5", "3.0", "3.2", "(a)", "3.1", "3.6",
                     "(b)", "3.9", "1.4", "1.4", "1.3", "1.5", "1.4",
                     "1.7", "(a)", "0.2", "0.2", "0.2", "0.2", "0.2",
                     "0.4", "setosa", "setosa", "setosa", "setosa",
                     "setosa", "setosa")
  has_ <- flextable:::fortify_content(
    ft$body$content,
    default_chunk_fmt = ft$body$styles$text)$txt
  expect_equal(expected_body, has_)
})
