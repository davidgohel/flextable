library(magick)
zz <- list(
  z1 = image_read_svg("inst/medias/html5.svg"),
  z2 = image_read_svg("inst/medias/word.svg"),
  z3 = image_read_svg("inst/medias/powerpoint.svg"),
  z4 = image_read_svg("inst/medias/pdf.svg")
)
zz <- lapply(zz, image_scale, "x100")
img_stack <- do.call(c, zz)
img_stack <- image_append(img_stack, stack = FALSE)
dir_out <- tempfile()
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
out <- file.path(dir_out, "fig_formats.png")
image_write(img_stack, path = out)
imgpress::img_compress(dir_input = dir_out, dir_output = "man/figures")

