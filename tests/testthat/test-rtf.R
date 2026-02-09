init_flextable_defaults()

test_that("to_rtf produces valid RTF string", {
  ft <- flextable(head(iris, 3))
  ft <- autofit(ft)

  rtf_str <- to_rtf(ft)
  expect_type(rtf_str, "character")
  expect_length(rtf_str, 1)
  expect_true(nchar(rtf_str) > 0)
  # RTF row markers
  expect_true(grepl("\\trowd", rtf_str, fixed = TRUE))
  expect_true(grepl("\\row", rtf_str, fixed = TRUE))
  expect_true(grepl("\\cell", rtf_str, fixed = TRUE))
})

test_that("to_rtf handles caption at top", {
  ft <- flextable(head(iris, 2))
  ft <- set_caption(ft, caption = "Iris dataset")

  rtf_top <- to_rtf(ft, topcaption = TRUE)
  rtf_bottom <- to_rtf(ft, topcaption = FALSE)

  expect_type(rtf_top, "character")
  expect_type(rtf_bottom, "character")
  # caption text should appear in both
  expect_true(grepl("Iris dataset", rtf_top, fixed = TRUE))
  expect_true(grepl("Iris dataset", rtf_bottom, fixed = TRUE))
})

test_that("to_rtf respects layout fixed vs autofit", {
  ft_fixed <- flextable(head(iris, 2))
  ft_fixed <- set_table_properties(ft_fixed, layout = "fixed")

  ft_auto <- flextable(head(iris, 2))
  ft_auto <- set_table_properties(ft_auto, layout = "autofit")

  rtf_fixed <- to_rtf(ft_fixed)
  rtf_auto <- to_rtf(ft_auto)

  expect_true(grepl("\\trautofit0", rtf_fixed, fixed = TRUE))
  expect_true(grepl("\\trautofit1", rtf_auto, fixed = TRUE))
})

test_that("to_rtf handles merged cells", {
  ft <- flextable(head(mtcars, 4)[, 1:3])
  ft <- merge_at(ft, i = 1:2, j = 1)

  rtf_str <- to_rtf(ft)
  expect_type(rtf_str, "character")
  expect_true(grepl("\\trowd", rtf_str, fixed = TRUE))
})

test_that("to_rtf handles styling", {
  ft <- flextable(head(iris, 2))
  ft <- bold(ft, part = "header")
  ft <- color(ft, color = "red", part = "body")

  rtf_str <- to_rtf(ft)
  expect_type(rtf_str, "character")
  # bold marker in header
  expect_true(grepl("\\b\\", rtf_str, fixed = TRUE))
  # color marker in body
  expect_true(grepl("%ftcolor:red%", rtf_str, fixed = TRUE))
})

test_that("rtf_add.flextable works with officer", {
  ft <- flextable(head(iris, 2))
  ft <- autofit(ft)

  doc <- officer::rtf_doc()
  doc <- officer::rtf_add(doc, ft)

  expect_s3_class(doc, "rtf")
  expect_true(length(doc$content) > 0)

  # write and verify file exists
  rtf_file <- tempfile(fileext = ".rtf")
  print(doc, target = rtf_file)
  expect_true(file.exists(rtf_file))
  content <- readLines(rtf_file, warn = FALSE)
  content <- paste(content, collapse = "\n")
  expect_true(grepl("\\trowd", content, fixed = TRUE))
  unlink(rtf_file)
})

test_that("to_rtf handles table alignment", {
  ft <- flextable(head(iris, 2))

  ft_left <- set_table_properties(ft, align = "left")
  ft_center <- set_table_properties(ft, align = "center")
  ft_right <- set_table_properties(ft, align = "right")

  expect_true(grepl("\\trql", to_rtf(ft_left), fixed = TRUE))
  expect_true(grepl("\\trqc", to_rtf(ft_center), fixed = TRUE))
  expect_true(grepl("\\trqr", to_rtf(ft_right), fixed = TRUE))
})

init_flextable_defaults()
