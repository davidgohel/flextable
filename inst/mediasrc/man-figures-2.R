library(flextable)
library(processx)
library(callr)
library(magrittr)
library(purrr)
library(stringr)

z <- list.files(path = "R", full.names = TRUE, pattern = "\\.R$") %>%
  map(.f = readLines, encoding = "UTF-8") %>%
  map(.f = function(x){
    x[grepl("figure{", x, fixed = TRUE)]
  }) %>% Filter(f = length) %>%
  map(.f = function(z) str_extract_all(z, "fig_(.*)\\.png")) %>%
  unlist() %>% unique() %>% sort()
z




extract_example <- function(file = "man/autofit.Rd", dir = tempdir(), webshot = "webshot2",
                            base_width = 400) {
  example_script <- tempfile(fileext = ".R")
  root_str <- tools::file_path_sans_ext(basename(file))
  run(command = "R", args = c("CMD", "Rdconv", "--type=example",
                              file, "-o",
                              example_script))

  outfiles <- r(function(file, root_str, dir, webshot) {
    pattern <- "^ft[_0-9]*?$"
    require("flextable")
    source(file)
    obj_list <- ls(pattern = pattern, envir = .GlobalEnv)
    out <- character(length(obj_list))
    names(out) <- obj_list
    for (i in seq_along(obj_list)) {
      obj <- get(obj_list[i])
      if (!inherits(obj, "flextable")) {
        next
      }
      filename <- file.path(dir, paste0("fig_", root_str, "_", i, ".png"))
      save_as_image(obj, path = filename, webshot = webshot)
      out[obj_list[i]] <- filename
    }
    out
  }, args = list(file = example_script, root_str = root_str, dir = dir, webshot = webshot))
  widths <- map_dbl(outfiles, function(z) {
    attr(png::readPNG(z), "dim")[2]
  })
  widths <- (base_width * widths) / max(widths)
  rdtags <- sprintf("#' \\if{html}{\\figure{%s}{options: width=\"%.0f\"}}", basename(outfiles), widths)
  rdtags <- paste0(rdtags, collapse = "\n#'\n")
  rdtags <- paste("#' @section Illustrations:", "#'", rdtags, sep = "\n")
  message(rdtags)
  outfiles
}


unlink("figures2", recursive = TRUE, force = TRUE)
dir.create("figures2")

extract_example(file = "man/autofit.Rd", dir = "figures2", webshot = "webshot", base_width = 500)
extract_example(file = "man/add_body_row.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_footer_lines.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_footer_row.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_footer.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_header_lines.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_header_row.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/add_header.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/align.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/append_chunks.Rd", dir = "figures2", webshot = "webshot",
                base_width = 100)
extract_example(file = "man/as_b.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/as_bracket.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/as_chunk.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/compose.Rd", dir = "figures2", webshot = "webshot")
extract_example(file = "man/separate_header.Rd", dir = "figures2", webshot = "webshot",
                base_width = 500)
extract_example(file = "man/rotate.Rd", dir = "figures2", webshot = "webshot2",
                base_width = 400)
extract_example(file = "man/tabulator.Rd", dir = "figures2", webshot = "webshot2",
                base_width = 500)

fs::dir_info("figures2")
minimage::compress_images(input = "figures2", output = "man/figures", overwrite = TRUE)
unlink("figures2", recursive = TRUE, force = TRUE)
