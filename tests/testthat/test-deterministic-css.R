# CSS class names are cross references between the style sheet and the
# cells; each of them is a hash of the properties it stands for, so that
# the same table always renders the same bytes.

render_html <- function(x) {
  as.character(htmltools_value(x))
}

class_names <- function(str) {
  regmatches(str, gregexpr("cl-[0-9a-f]+", str))[[1]]
}

# the class names declared in the style sheet
declared_class_names <- function(str) {
  css <- regmatches(str, regexpr("<style>.*</style>", str))
  rules <- regmatches(css, gregexpr("\\.cl-[0-9a-f]+\\{", css))[[1]]
  substr(rules, 2L, nchar(rules) - 1L)
}

# the class names used by the table elements
used_class_names <- function(str) {
  body <- sub("^.*</style>", "", str)
  unique(class_names(body))
}

ft <- flextable(head(iris))
ft <- bold(ft, part = "header")
ft <- bg(ft, i = 1, bg = "#EFEFEF", part = "body")
ft <- add_footer_lines(ft, "a footer")

test_that("two renderings of a same flextable are identical", {
  expect_identical(render_html(ft), render_html(ft))
})

test_that("class names are hashes and not random values", {
  # a random value would differ from one rendering to the other
  expect_true(all(grepl("^cl-[0-9a-f]{8,}$", class_names(render_html(ft)))))
})

test_that("every class name used is declared, and only once", {
  str <- render_html(ft)
  declared <- declared_class_names(str)
  expect_identical(anyDuplicated(declared), 0L)
  expect_length(setdiff(used_class_names(str), declared), 0L)
})

test_that("a same style keeps its name from one table to another", {
  other <- flextable(head(iris, n = 3))
  other <- bold(other, part = "header")

  shared <- intersect(
    unique(class_names(render_html(ft))),
    unique(class_names(render_html(other)))
  )
  expect_true(length(shared) > 0)
})

test_that("different properties get different class names", {
  red <- color(ft, color = "red", part = "body")
  expect_false(identical(
    unique(class_names(render_html(ft))),
    unique(class_names(render_html(red)))
  ))
})

test_that("cell class names depend on the table layout", {
  # widths are only part of the cell CSS rule when the layout is fixed,
  # so a fixed and an autofit table must not share cell class names
  cell_class_names <- function(str) {
    tags <- regmatches(
      str,
      gregexpr("<t[dh] [^>]*class=\"cl-[0-9a-f]+\"", str)
    )[[1]]
    unique(unlist(regmatches(tags, gregexpr("cl-[0-9a-f]+", tags))))
  }
  fixed <- set_table_properties(ft, layout = "fixed")
  autofit <- set_table_properties(ft, layout = "autofit")
  expect_true(length(cell_class_names(render_html(fixed))) > 0)
  expect_length(
    intersect(
      cell_class_names(render_html(fixed)),
      cell_class_names(render_html(autofit))
    ),
    0L
  )
})

test_that("the table class name depends on the scroll options", {
  scrolled <- set_table_properties(
    ft,
    opts_html = list(scroll = list(height = "300px"))
  )
  expect_false(identical(
    declared_class_names(render_html(ft))[1],
    declared_class_names(render_html(scrolled))[1]
  ))
})

test_that("class names remain unique within a table", {
  # a truncated hash that collided would merge two sets of properties
  big <- flextable(head(iris))
  for (i in seq_len(nrow_part(big, "body"))) {
    big <- bg(big, i = i, bg = sprintf("#%02X0000", i * 20L))
  }
  expect_identical(anyDuplicated(declared_class_names(render_html(big))), 0L)
})

test_that("close but distinct property values get distinct class names", {
  # computed column widths (pagination, rtables) can differ beyond the 15
  # significant digits of `as.character()`; such widths must not be given
  # the same class name, as the styles are joined back on that name
  close_widths <- width(flextable(head(iris, 2)), j = 1, width = 0.1 + 0.2)
  close_widths <- width(close_widths, j = 2, width = 0.3)

  expect_no_error(flextable:::gen_raw_wml(close_widths))
  str <- render_html(close_widths)
  expect_identical(anyDuplicated(declared_class_names(str)), 0L)
  expect_length(unique(regmatches(
    str,
    gregexpr("width:[0-9.]+in", str)
  )[[1]]), 2L)
})

test_that("other formats are not broken by hashed class names", {
  expect_no_error(flextable:::gen_raw_wml(ft))
  expect_no_error(flextable:::gen_raw_pml(ft))
  expect_no_error(officer::to_rtf(ft))
  expect_no_error(flextable:::gen_raw_latex(ft))
})
