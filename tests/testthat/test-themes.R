gdtools::register_liberationsans()

init_flextable_defaults()
set_flextable_defaults(
  font.family = "Liberation Sans",
  border.color = "#333333"
)

make_ft <- function() {
  autofit(flextable(head(airquality)))
}

make_ft_with_footer <- function() {
  ft <- make_ft()
  ft <- add_footer_lines(ft, values = "a note")
  autofit(ft)
}

# -- theme_borderless --------------------------------------------------------

test_that("theme_borderless returns a flextable", {
  ft <- theme_borderless(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_borderless rejects non-flextable", {
  expect_error(theme_borderless("not a ft"), "flextable objects")
})

test_that("theme_borderless renders with ragg", {
  ft <- theme_borderless(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_borderless works with footer", {
  ft <- theme_borderless(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_apa ---------------------------------------------------------------

test_that("theme_apa returns a flextable", {
  ft <- theme_apa(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_apa rejects non-flextable", {
  expect_error(theme_apa("not a ft"), "flextable objects")
})

test_that("theme_apa renders with ragg", {
  ft <- theme_apa(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_apa works with footer", {
  ft <- theme_apa(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_tron --------------------------------------------------------------

test_that("theme_tron returns a flextable", {
  ft <- theme_tron(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_tron rejects non-flextable", {
  expect_error(theme_tron("not a ft"), "flextable objects")
})

test_that("theme_tron renders with ragg", {
  ft <- theme_tron(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_tron works with footer", {
  ft <- theme_tron(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_tron_legacy -------------------------------------------------------

test_that("theme_tron_legacy returns a flextable", {
  ft <- theme_tron_legacy(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_tron_legacy rejects non-flextable", {
  expect_error(theme_tron_legacy("not a ft"), "flextable objects")
})

test_that("theme_tron_legacy renders with ragg", {
  ft <- theme_tron_legacy(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_tron_legacy works with footer", {
  ft <- theme_tron_legacy(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_zebra -------------------------------------------------------------

test_that("theme_zebra returns a flextable", {
  ft <- theme_zebra(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_zebra rejects non-flextable", {
  expect_error(theme_zebra("not a ft"), "flextable objects")
})

test_that("theme_zebra custom colors", {
  ft <- theme_zebra(
    make_ft(),
    odd_header = "#FF0000", odd_body = "#00FF00",
    even_header = "#0000FF", even_body = "#FFFF00"
  )
  expect_s3_class(ft, "flextable")
})

test_that("theme_zebra renders with ragg", {
  ft <- theme_zebra(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_zebra works with footer", {
  ft <- theme_zebra(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_vader -------------------------------------------------------------

test_that("theme_vader returns a flextable", {
  ft <- theme_vader(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_vader rejects non-flextable", {
  expect_error(theme_vader("not a ft"), "flextable objects")
})

test_that("theme_vader renders with ragg", {
  ft <- theme_vader(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_vader works with footer", {
  ft <- theme_vader(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- theme_alafoli -----------------------------------------------------------

test_that("theme_alafoli returns a flextable", {
  ft <- theme_alafoli(make_ft())
  expect_s3_class(ft, "flextable")
})

test_that("theme_alafoli rejects non-flextable", {
  expect_error(theme_alafoli("not a ft"), "flextable objects")
})

test_that("theme_alafoli renders with ragg", {
  ft <- theme_alafoli(make_ft())
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("theme_alafoli works with footer", {
  ft <- theme_alafoli(make_ft_with_footer())
  expect_s3_class(ft, "flextable")
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  save_as_image(ft, path = tf, res = 150)
  expect_gt(file.info(tf)$size, 1000)
})

# -- grob structure checks ---------------------------------------------------

test_that("theme_borderless grob has no border segments", {
  ft <- theme_borderless(make_ft())
  gr <- gen_grob(ft)
  bdr <- gr$children[[1]]$children$borders
  expect_length(bdr$children, 0)
})

test_that("all themes produce valid grobs", {
  ft <- make_ft()
  themes <- list(
    theme_borderless, theme_apa, theme_tron,
    theme_tron_legacy, theme_zebra, theme_vader,
    theme_alafoli
  )
  for (thm in themes) {
    themed <- thm(ft)
    gr <- gen_grob(themed)
    expect_s3_class(gr, "grob")
    expect_true(length(gr$children) > 0)
  }
})

init_flextable_defaults()
