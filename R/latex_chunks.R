sanitize_latex_str <- function(str) {
  z <- gsub("[\\\\]", "\\\\textbackslash", str)
  z <- gsub("([&%$#_{} ]{1})", "\\\\\\1", z)
  z <- gsub("[~]", "\\\\\\textasciitilde ", z)
  z <- gsub("^", "\\\\\\textasciicircum ", z, fixed = TRUE)

  z
}

as_table_latexstyle_lr <- function(x){
  left <- character(nrow(x))
  right <- character(nrow(x))


  valign_left <- character(nrow(x))
  valign_right <- character(nrow(x))
  valign_left[x$vertical.align %in% "subscript"] <- "\\textsubscript{"
  valign_right[x$vertical.align %in% "subscript"] <- "}"
  valign_left[x$vertical.align %in% "superscript"] <- "\\textsuperscript{"
  valign_right[x$vertical.align %in% "superscript"] <- "}"
  left <- paste0(valign_left, left)
  right <- paste0(right, valign_right)

  fontcolor_left <- paste0(latex_fontcolor(x$color), "{")
  fontcolor_right <- rep("}", nrow(x))
  fontcolor_left[is.na(x$color)] <- ""
  fontcolor_right[is.na(x$color)] <- ""
  left <- paste0(fontcolor_left, left)
  right <- paste0(right, fontcolor_right)

  highlight_left <- paste0(latex_highlightcolor(x$shading.color), "{")
  highlight_right <- rep("}", length(x$shading.color))
  highlight_left[is.na(x$shading.color) | colalpha(x$shading.color) < 1] <- ""
  highlight_right[is.na(x$shading.color) | colalpha(x$shading.color) < 1] <- ""
  left <- paste0(left, highlight_left)
  right <- paste0(highlight_right, right)


  fontsize_left <- paste0(latex_fontsize(x$font.size, x$line_spacing), "{")
  fontsize_right <- rep("}", nrow(x))
  fontsize_left[is.na(x$font.size) | is.na(x$line_spacing)] <- ""
  fontsize_right[is.na(x$font.size) | is.na(x$line_spacing)] <- ""
  left <- paste0(left, fontsize_left)
  right <- paste0(fontsize_right, right)


  fonts_ok <- get_pdf_engine() %in% c("xelatex", "lualatex")
  if(fonts_ok && !flextable_global$defaults$fonts_ignore ){
    font_family_left <- sprintf("\\global\\setmainfont{%s}{", x$font.family)
    font_family_right <- rep("}", nrow(x))
    font_family_left[is.na(x$font.family)] <- ""
    font_family_right[is.na(x$font.family)] <- ""
    left <- paste0(left, font_family_left)
    right <- paste0(font_family_right, right)
  }

  bold_left <- rep("", nrow(x))
  bold_right <- rep("", nrow(x))
  bold_left[x$bold %in% TRUE] <- "\\textbf{"
  bold_right[x$bold %in% TRUE] <- "}"
  left <- paste0(left, bold_left)
  right <- paste0(bold_right, right)

  italic_left <- rep("", nrow(x))
  italic_right <- rep("", nrow(x))
  italic_left[x$italic %in% TRUE] <- "\\textit{"
  italic_right[x$italic %in% TRUE] <- "}"
  left <- paste0(left, italic_left)
  right <- paste0(italic_right, right)

  underlined_left <- rep("", nrow(x))
  underlined_right <- rep("", nrow(x))
  underlined_left[x$underlined %in% TRUE] <- "\\underline{"
  underlined_right[x$underlined %in% TRUE] <- "}"
  left <- paste0(left, underlined_left)
  right <- paste0(underlined_right, right)
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
