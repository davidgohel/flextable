library(logger)
library(imgpress)
library(magrittr)

log_layout(layout_glue_colors)
log_threshold(TRACE)

man_names <- package_man_names(package_name = "flextable")
drop <- c("qflextable", "ph_with.flextable", "save_as_docx",
          "save_as_pptx", "save_as_image", "as_raster",
          "save_as_html",
          "dim.flextable", "fix_border_issues", "flextable",
          "ph_with_flextable",
          "border", "flextable-defunct", "flextable-package",
          "footers_flextable_at_bkm", "headers_flextable_at_bkm",
          "print.flextable")
as_ft_methods <- man_names[grepl("^as_flextable", man_names)]
drop <- c(drop, as_ft_methods)
man_names <- setdiff(man_names, drop)
man_names <- c(man_names, as_ft_methods)

out <- list()
for (man_name in man_names) {
  log_info("watching {man_name}")
  out[[man_name]] <- process_manual_flextable(name = man_name, pkg = "flextable")
}

out <- Filter(function(x) length(x)>0, out)
file.copy(unlist(out), to = 'inst/medias/figures/', overwrite = TRUE)

rsvg::rsvg_png("inst/medias/functions.svg", file.path("inst/medias/figures", "fig_flextable_1.png"))
img_compress(dir_input = "inst/medias/figures",
             dir_output = "man/figures")

