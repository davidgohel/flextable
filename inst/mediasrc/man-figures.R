library(flextable)
library(uuid)
library(webshot2)

read_rd_names <- function(pkg) {
  path <- file.path(system.file("help", package = pkg), pkg)
  names(tools:::fetchRdDB(path))
}

drop_from_run <- c("qflextable", "ph_with.flextable", "save_as_docx",
                   "save_as_pptx", "save_as_image", "as_raster",
                   "as_flextable.xtable", "save_as_html",
                   "dim.flextable", "fix_border_issues", "flextable",
                   "as_flextable.glm", "as_flextable.lm", "ph_with_flextable",
                   "border", "flextable-defunct", "flextable-package",
                   "footers_flextable_at_bkm", "headers_flextable_at_bkm",
                   "print.flextable", "as_flextable")

rd_names <- read_rd_names(pkg = "flextable")
rd_names <- base::setdiff(rd_names, drop_from_run)
rd_names <- c(rd_names, "as_flextable.glm", "as_flextable.lm", "as_flextable.xtable")

temp_id <- UUIDgenerate()
temp_dir <- file.path("/Users/davidgohel/Documents/sandbox/compimg/imgs/src/img", temp_id)
build_dir <- file.path("/Users/davidgohel/Documents/sandbox/compimg/imgs/build/img", temp_id)
dir.create(temp_dir, showWarnings = FALSE)
rsvg::rsvg_png("inst/medias/functions.svg", file.path(temp_dir, "fig_flextable_1.png"))

rm(list = ls(pattern = "^ft[_0-9]*?$"))

for (rd_name in rd_names) {
  message(rd_name)
  current_ls <- ls()
  example(topic = rd_name, package = "flextable", character.only = TRUE,
          give.lines = FALSE, echo = FALSE)

  ft_list <- ls(pattern = "^ft[_0-9]*?$")
  for (i in seq_along(ft_list)) {
    if (!inherits(get(ft_list[i]), "flextable")) {
      stop("All `ft_#` objects should be flextable objects")
    }
    filename <- file.path(temp_dir, paste0("fig_", rd_name, "_", i, ".png"))
    img_file <- save_as_image(get(ft_list[i]), path = filename, zoom = 3,
                  webshot = "webshot2")
    resize(img_file, "50%")
  }
  rm(list = setdiff(ls(), current_ls))
}

png_list <- list.files(temp_dir, ".*\\.png$")

system("cd ~/Documents/sandbox/compimg;node index.js;")

build_png <- file.path(build_dir, png_list)
dest_png <- file.path("man", "figures", png_list)
file.copy(build_png, dest_png, overwrite = TRUE)
unlink(c(build_dir, temp_dir), recursive = TRUE, force = TRUE)
remove(list = setdiff(ls(), "dest_png"))

