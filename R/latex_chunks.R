sanitize_latex_str <- function(str) {
  z <- gsub("[\\\\]", "\\\\textbackslash", str)
  z <- gsub("([&%$#_{} ]{1})", "\\\\\\1", z)
  z <- gsub("[~]", "\\\\\\textasciitilde ", z)
  z <- gsub("^", "\\\\\\textasciicircum ", z, fixed = TRUE)

  z
}

as_table_latexstyle_lr <- function(x) {
  left <- character(nrow(x))
  right <- character(nrow(x))

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

  # line height of the fonts, as Word for single line spacing
  # (gdtools::font_line_metrics()), in em
  line_height <- rep(NA_real_, nrow(x))
  has_font <- !is.na(x$font.family) & nzchar(x$font.family)
  if (any(has_font)) {
    line_height[has_font] <- gdtools::font_line_metrics(
      fontname = x$font.family[has_font],
      fontsize = 72,
      bold = x$bold[has_font] %in% TRUE,
      italic = x$italic[has_font] %in% TRUE
    )$line_height
  }
  fontsize_left <- paste0(
    latex_fontsize(x$font.size, x$line_spacing, line_height),
    "{"
  )
  fontsize_right <- rep("}", nrow(x))
  fontsize_left[is.na(x$font.size) | is.na(x$line_spacing)] <- ""
  fontsize_right[is.na(x$font.size) | is.na(x$line_spacing)] <- ""
  left <- paste0(left, fontsize_left)
  right <- paste0(fontsize_right, right)

  fonts_ok <- get_pdf_engine() %in% c("xelatex", "lualatex")
  if (fonts_ok && !flextable_global$defaults$fonts_ignore) {
    font_family_left <- sprintf("{\\fontspec{%s} ", x$font.family)
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
  underlined_left[x$strike %in% TRUE] <- "\\sout{"
  underlined_right[x$strike %in% TRUE] <- "}"
  left <- paste0(left, underlined_left)
  right <- paste0(underlined_right, right)

  valign_left <- character(nrow(x))
  valign_right <- character(nrow(x))
  valign_left[x$vertical.align %in% "subscript"] <- "\\textsubscript{"
  valign_right[x$vertical.align %in% "subscript"] <- "}"
  valign_left[x$vertical.align %in% "superscript"] <- "\\textsuperscript{"
  valign_right[x$vertical.align %in% "superscript"] <- "}"
  left <- paste0(left, valign_left)
  right <- paste0(valign_right, right)

  data.frame(
    left = left,
    right = right,
    classname = x$classname,
    stringsAsFactors = TRUE
  )
}

# `\\fontsize{size}{baselineskip}`: the distance between the baselines is the
# line spacing times the line height of the font (in em, `line_height`), as
# in Word; 1.2 em, the ratio of LaTeX, when it is unknown.
latex_fontsize <- function(x, line_spacing = 1, line_height = NA_real_) {
  line_height <- rep_len(line_height, length(x))
  line_height[is.na(line_height)] <- 1.2
  size <- format_double(x, digits = 1)
  baselineskip <- format_double(x * line_spacing * line_height, digits = 2)
  z <- sprintf("\\fontsize{%s}{%s}\\selectfont", size, baselineskip)
  z[is.na(x)] <- ""
  z
}

latex_fontcolor <- function(x) {
  col <- colcode0(x)
  z <- sprintf("\\textcolor[HTML]{%s}", col)
  z
}

latex_cell_bgcolor <- function(x) {
  is_transparent <- colalpha(x) < 1
  z <- sprintf("\\cellcolor[HTML]{%s}", colcode0(x))
  z[is_transparent] <- ""
  z
}

latex_text_direction <- function(x, left = TRUE) {
  textdir <- rep("", length(x))
  if (left) {
    textdir[x %in% "tbrl"] <- "\\rotatebox[origin=c]{270}{"
    textdir[x %in% "btlr"] <- "\\rotatebox[origin=c]{90}{"
  } else {
    textdir[x %in% c("tbrl", "btlr")] <- "}"
  }
  textdir
}


latex_highlightcolor <- function(x) {
  col <- colcode0(x)
  z <- sprintf("\\colorbox[HTML]{%s}", col)
  z
}

# Where to write a file whose path comes from knitr::fig_path(). This path is
# relative to the document, but during a chunk the working directory is
# `root.dir` when this option is set: the file is written in the directory of
# the document (`base.dir` if set, otherwise `output.dir`), the path written in
# the document stays relative. Outside knitr, the path is not changed.
#' @importFrom knitr opts_knit
knitr_output_path <- function(path) {
  base <- opts_knit$get("base.dir")
  if (!is.character(base) || !nzchar(base)) {
    base <- opts_knit$get("output.dir")
  }
  if (!is.character(base) || !nzchar(base)) {
    return(path)
  }
  is_absolute <- grepl("^(/|~|[A-Za-z]:|\\\\)", path)
  path[!is_absolute] <- file.path(base, path[!is_absolute])
  path
}

#' @importFrom knitr fig_path
img_to_latex <- function(img_data, width, height) {
  new_files <- fig_path(suffix = ".png", number = seq_along(img_data))
  disk_files <- knitr_output_path(new_files)
  for (d in unique(dirname(disk_files))) {
    dir.create(d, showWarnings = FALSE, recursive = TRUE)
  }

  str_raster <- mapply(
    function(img_raster, new_file, disk_file, width, height) {
      if (inherits(img_raster, "raster")) {
        plot_in_png(
          code = {
            op <- par(mar = rep(0, 4))
            plot(img_raster, interpolate = FALSE, asp = NA)
            par(op)
          },
          width = width,
          height = height,
          res = 300,
          units = "in",
          path = disk_file
        )
      } else if (is.character(img_raster)) {
        if (!file.exists(img_raster)) {
          stop(sprintf("File '%s' could not be found.", img_raster))
        }
        file.copy(from = img_raster, to = disk_file, overwrite = TRUE)
      } else {
        stop("`image_data` can only be a raster or a filename.")
      }
      sprintf(
        "\\includegraphics[width=%sin, height=%sin]{%s}",
        width,
        height,
        new_file
      )
    },
    img_data,
    new_files,
    disk_files,
    width,
    height,
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )
  str_raster <- as.character(unlist(str_raster))
  str_raster
}
