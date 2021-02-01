library(flextable)
library(magick)
# need package cookimage -----
if(!require("cookimage")){
  stop("please install cookimage before using that script with command:\n",
       "remotes::install_github('ardata-fr/cookimage')")
}
node_available(error = TRUE)
if(!compress_images_npm_available()){
  install_compress_images_npm()
}
if(!puppeteer_npm_available()){
  install_puppeteer_npm()
}

# funs -----
#' @title topic names from a package
#' @description list documented topic names in a package
#' @param package_name package name
#' @examples
#' package_man_names("flextable")
#' @export
package_man_names <- function(package_name) {
  help_dir <- system.file("help", package = package_name)
  db_file <- file.path(help_dir, package_name)
  z <- tools:::fetchRdDB(db_file)
  names(z)
}


#' @export
#' @title Get images from flextable examples
#' @description Run examples from a topic in help pages
#' and create corresponding images in a temporary directory.
#' @param name help topic name, its examples will be run
#' @param pkg the package name where the help topic is located
#' @param pattern name pattern too look for, default to objects whose
#' name start with *ft*.
#' @examples
#' library(flextable)
#' process_manual_flextable(name = "theme_vader", pkg = "flextable")
#' @importFrom utils example
#' @importFrom flextable save_as_image
process_manual_flextable <- function(name, pkg, pattern = "^ft[_0-9]*?$", dir = tempfile()){
  obj_start <- ls(envir = .GlobalEnv)

  if(!dir.exists(dir)){
    dir.create(path = dir, showWarnings = FALSE, recursive = TRUE)
  }

  zz=utils::example(topic = name, package = pkg, character.only = TRUE,
                    give.lines = FALSE, echo = FALSE, local = FALSE)

  obj_list <- ls(pattern = pattern, envir = .GlobalEnv)
  out <- character(length(obj_list))
  names(out) <- obj_list
  for (i in seq_along(obj_list)) {
    obj <- get(obj_list[i])
    if (!inherits(obj, "flextable")) {
      next
    }
    htmlname <- file.path(dir, paste0("fig_", name, "_", i, ".html"))
    filename <- file.path(dir, paste0("fig_", name, "_", i, ".png"))
    save_as_html(obj, path = htmlname)
    screenshot(htmlname, file = filename, selector = "body > div > table")
    out[obj_list[i]] <- filename
  }
  rm(list = setdiff(ls(envir = .GlobalEnv), obj_start), envir = .GlobalEnv)
  out
}

# get images from examples ----
man_names <- package_man_names(package_name = "flextable")
drop <- c("qflextable", "ph_with.flextable", "save_as_docx",
          "save_as_pptx", "save_as_image", "as_raster",
          "save_as_html",
          "dim.flextable", "fix_border_issues", "flextable",
          "ph_with_flextable",
          "border", "flextable-defunct", "flextable-package",
          "footers_flextable_at_bkm", "headers_flextable_at_bkm",
          "print.flextable", "as_flextable", "add_body")
as_ft_methods <- man_names[grepl("^as_flextable", man_names)]
drop <- c(drop, as_ft_methods)
man_names <- setdiff(man_names, drop)
man_names <- c(man_names, as_ft_methods)
out <- list()

dir <- file.path(tempfile(), "figures")

for (man_index in seq_along(man_names)) {
  man_name <- man_names[man_index]
  message(man_name, " (", man_index, " on ", length(man_names), ")")
  out[[man_name]] <- process_manual_flextable(name = man_name, pkg = "flextable", dir = dir)
}


out[["logo"]] <- file.path(dir, "logo.png")
out[["fig_flextable"]] <- file.path(dir, "fig_flextable_1.png")
rsvg::rsvg_png("inst/flextablelogo.svg", file.path(dir, "logo.png"))
rsvg::rsvg_png("inst/medias/functions.svg", file.path(dir, "fig_flextable_1.png"))

# fig_formats.png ----
zz <- list(
  z1 = image_read_svg("inst/medias/html5.svg"),
  z2 = image_read_svg("inst/medias/word.svg"),
  z3 = image_read_svg("inst/medias/powerpoint.svg"),
  z4 = image_read_svg("inst/medias/pdf.svg")
)
zz <- lapply(zz, image_scale, "x100")
img_stack <- do.call(c, zz)
img_stack <- image_append(img_stack, stack = FALSE)
image_write(img_stack, path = file.path(dir, "fig_formats.png"))


# compress all images ----
cookimage::compress_images(dir_input = dir, "man")
