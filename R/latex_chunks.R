get_text_data <- function(x, ls_df){

  txt_data <- as_table_text(x)
  txt_data$col_id <- factor(txt_data$col_id, levels = x$col_keys)
  setDT(txt_data)
  txt_data <- merge(txt_data, ls_df, by = c("part", "ft_row_id", "col_id"))

  data_ref_text <- part_style_list(as.data.frame(txt_data),
                                   fun = function( color = "black", font.size = 10,
                                                   bold = FALSE, italic = FALSE, underlined = FALSE,
                                                   font.family = "Arial",
                                                   vertical.align = "baseline",
                                                   shading.color = "transparent", line_spacing = 2 ){})


  by_columns <- intersect(colnames(data_ref_text), colnames(txt_data))
  txt_data <- merge(txt_data, data_ref_text, by = by_columns)
  setorderv(txt_data, c("ft_row_id", "col_id", "seq_index"))


  span_style_str <- text_latex_styles(data_ref_text)

  dat <- merge(txt_data, span_style_str, by =  "classname")
  dat[, c("txt") := list(sanitize_latex_str(.SD$txt))]

  is_eq <- !is.na(dat$eq_data)
  dat[is_eq==TRUE, c("txt") := list(paste0('$', .SD$eq_data, '$'))]
  is_hlink <- !is.na(dat$url)
  is_raster <- sapply(dat$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  dat[is_hlink, c("txt") := list(paste0("\\href{", sanitize_latex_str(.SD$url), "}{", .SD$txt, "}"))]
  dat[is_raster==TRUE, c("txt") := list(img_to_latex(.SD$img_data, .SD$width, .SD$height))]
  dat[is_raster==FALSE, c("txt") := list(gsub("\n", "\\linebreak ", .SD$txt, fixed = TRUE))]
  dat[is_raster==FALSE, c("txt") := list(gsub("\t", "\\quad ", .SD$txt, fixed = TRUE))]
  dat[is_raster==FALSE, c("txt") := list(sprintf("%s%s%s", .SD$left, .SD$txt, .SD$right))]

  dat[, c("left", "right") := NULL]
  setorderv(dat, c("ft_row_id", "col_id", "seq_index"))
  dat <- dat[, list(txt = paste0(get("txt"), collapse = "")), by = c("part", "ft_row_id", "col_id")]
  setDF(dat)
  dat
}

#  https://stackoverflow.com/questions/5406071/r-sweave-latex-escape-variables-to-be-printed-in-latex
sanitize_latex_str <- function(str) {
  z <- gsub('([#$%&~_\\^\\\\{}])', '\\\\\\1', str, perl = TRUE)
  gsub(" ", "\\ ", z, , fixed = TRUE)
}

text_latex_styles <- function(x){
  left <- character(nrow(x))
  right <- character(nrow(x))


  vertical.align_left <- character(nrow(x))
  vertical.align_right <- character(nrow(x))
  vertical.align_left[x$vertical.align %in% "subscript"] <- "\\textsubscript{"
  vertical.align_right[x$vertical.align %in% "subscript"] <- "}"
  vertical.align_left[x$vertical.align %in% "superscript"] <- "\\textsuperscript{"
  vertical.align_right[x$vertical.align %in% "superscript"] <- "}"
  left <- paste0(vertical.align_left, left)
  right <- paste0(right, vertical.align_right)

  left <- paste0(left, latex_fontcolor(x$color), "{")
  right <- paste0("}", right)

  hg_left <- paste0(latex_highlightcolor(x$shading.color), "{")
  hg_right <- rep("}", length(x$shading.color))
  hg_left[colalpha(x$shading.color) < 1] <- ""
  hg_right[colalpha(x$shading.color) < 1] <- ""
  left <- paste0(left, hg_left)
  right <- paste0(hg_right, right)


  font.size <- latex_fontsize(x$font.size, x$line_spacing)
  left <- paste0(font.size, "{", left)
  right <- paste0(right, "}")
  fonts_ok <- get_pdf_engine() %in% c("xelatex", "lualatex")
  if(fonts_ok && !flextable_global$defaults$fonts_ignore ){
    left <- paste0(left, sprintf("\\global\\setmainfont{%s}{", x$font.family))
    right <- paste0(right, "}")
  }

  left <- paste0(left, ifelse(x$bold, "\\textbf{", "" ))
  right <- paste0(right, ifelse(x$bold, "}", "" ))

  left <- paste0(left, ifelse(x$italic, "\\textit{", "" ))
  right <- paste0(right, ifelse(x$italic, "}", "" ))

  left <- paste0(left, ifelse(x$underlined, "\\underline{", "" ))
  right <- paste0(right, ifelse(x$underlined, "}", "" ))




  data.frame(left = left, right = right, classname = x$classname, stringsAsFactors = TRUE)
}

latex_fontsize <- function(x, line_spacing = 1, digits = 0){
  size <- format_double(x, digits = 0)
  baselineskip <- format_double(x*line_spacing, digits = 0)
  z <- sprintf("\\fontsize{%s}{%s}\\selectfont", size, baselineskip)
  z[is.na(x)] <- ""
  z
}

latex_fontcolor <- function(x){
  col <- colcode0(x)
  z <- sprintf("\\textcolor[HTML]{%s}", col)
  z
}

latex_cell_bgcolor <- function(x){
  is_transparent <- colalpha(x) < 1
  z <- sprintf("\\cellcolor[HTML]{%s}", colcode0(x))
  z[is_transparent] <- ""
  z
}

latex_text_direction <- function(x, left = TRUE){
  textdir <- rep("", length(x))
  if(left){
    textdir[x %in% "tbrl"] <- "\\rotatebox[origin=c]{270}{"
    textdir[x %in% "btlr"] <- "\\rotatebox[origin=c]{90}{"
  } else {
    textdir[x %in% c("tbrl", "btlr")] <- "}"
  }
  textdir
}


latex_highlightcolor <- function(x){
  col <- colcode0(x)
  z <- sprintf("\\colorbox[HTML]{%s}", col)
  z
}

#' @importFrom knitr fig_path
img_to_latex <- function(img_data, width, height){

  new_files <- fig_path(suffix = ".png", number = seq_along(img_data))
  for(d in unique(dirname(new_files))) {
    dir.create(d, showWarnings = FALSE, recursive = TRUE)
  }

  str_raster <- mapply(function(img_raster, new_file, width, height ){
    if(inherits(img_raster, "raster")){
      png(filename = new_file, units = "in", res = 300, bg = "transparent", width = width, height = height)
      op <- par(mar=rep(0, 4))
      plot(img_raster, interpolate = FALSE, asp=NA)
      par(op)
      dev.off()
    } else if(is.character(img_raster)){
      if(!file.exists(img_raster)){
        stop("file ", shQuote(img_raster), " could not be read")
      }
      file.copy(from = img_raster, to = new_file, overwrite = TRUE)
    } else  {
      stop("unknown image format")
    }
    sprintf("\\includegraphics[width=%sin, height=%sin]{%s}", width, height, new_file)
  }, img_data, new_files, width, height, SIMPLIFY = FALSE, USE.NAMES = FALSE)
  str_raster <- as.character(unlist(str_raster))
  str_raster
}
