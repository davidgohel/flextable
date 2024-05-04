test_that("add_footer", {
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
  ft <- add_footer(
    ft,
    Sepal.Length = "Sepal",
    Sepal.Width = "Sepal", Petal.Length = "Petal",
    Petal.Width = "Petal", Species = "Species"
  )
  ft <- add_footer(ft, Sepal.Length = "s", top = FALSE)
  ft <- add_footer(
    ft,
    Sepal.Length = "(cm)",
    Sepal.Width = "(cm)", Petal.Length = "(cm)",
    Petal.Width = "(cm)", Species = "(cm)", top = FALSE
  )
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text
  )$txt
  expect_equal(has_, as.character(unlist(data_ref)))


  ft <- flextable(iris[1:6, ])
  ft <- add_footer_row(
    ft,
    values = c("Sepal", "Petal", "Species"),
    colwidths = c(2, 2, 1)
  )
  ft <- add_footer_lines(ft, "s", top = FALSE)
  ft <- add_footer_row(ft, values = "(cm)", colwidths = 5, top = FALSE)
  has_ <- flextable:::fortify_content(
    ft$footer$content,
    default_chunk_fmt = ft$footer$styles$text
  )$txt

  ref <- c(
    "Sepal", "s", "(cm)", "Sepal", "s", "(cm)", "Petal", "s", "(cm)",
    "Petal", "s", "(cm)", "Species", "s", "(cm)"
  )
  expect_equal(has_, ref)
})
