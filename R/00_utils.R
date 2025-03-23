colcode <- function(x) {
  rgb(t(col2rgb(x, alpha = TRUE)), maxColorValue = 255)
}
colcodecss <- function(x) {
  args <- as.list(as.data.frame(t(col2rgb(x, alpha = TRUE))))
  args$alpha <- args$alpha / 255
  args$fmt <- "rgba(%.0f, %.0f, %.0f, %.2f)"
  do.call(sprintf, args)
}
colalpha <- function(x) {
  x[x %in% "transparent"] <- "#FFFFFF00"
  rgbvals <- col2rgb(x, alpha = TRUE)
  as.integer(rgbvals[4, ] / 255 * 100000)
}

colcode0 <- function(x) {
  x[x %in% "transparent"] <- "#FFFFFF00"
  substr(rgb(t(col2rgb(x, alpha = TRUE)), maxColorValue = 255), 2, 7)
}

check_choice <- function(value, choices) {
  varname <- as.character(substitute(value))
  if (is.character(value) && length(value) == 1) {
    if (!value %in% choices) {
      stop(
        sprintf(
          "%s is expected to be one of: %s",
          varname, paste(shQuote(choices))
        ),
        call. = FALSE
      )
    }
  } else {
    stop(sprintf("`%s` must be a character scalar.", varname), call. = FALSE)
  }
  TRUE
}

cast_borders <- function(value) {
  borders_id <- c("border.bottom", "border.top", "border.left", "border.right")
  borders_side <- c("bottom", "top", "left", "right")

  z <- mapply(function(name, fp_b) {
    x <- unclass(fp_b)
    names(x) <- paste("border", names(x), name, sep = ".")
    x
  }, borders_side, value[borders_id], SIMPLIFY = FALSE, USE.NAMES = FALSE)
  z <- Reduce(f = append, z)
  value <- append(value, z)
  value[borders_id] <- NULL
  value
}

as_struct <- function(nrow, keys, pr, fun) {
  args <- pr
  args$nrow <- nrow
  args$keys <- keys

  borders_id <- c("border.bottom", "border.top", "border.left", "border.right")
  borders_side <- c("bottom", "top", "left", "right")
  avail_bdr_id <- borders_id %in% names(pr)
  bdr_id <- borders_id[avail_bdr_id]
  bdr_side <- borders_side[avail_bdr_id]
  z <- mapply(function(name, fp_b) {
    x <- unclass(fp_b)
    names(x) <- paste("border", names(x), name, sep = ".")
    x
  }, bdr_side, pr[bdr_id], SIMPLIFY = FALSE, USE.NAMES = FALSE)
  z <- Reduce(f = append, z)

  args <- append(args, z)
  args[bdr_id] <- NULL

  obj_str <- do.call(fun, args)
  obj_str
}

base_ns <- "xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\""

wml_image <- function(src, width, height) {
  str <- paste0(
    sprintf("<w:r %s>", base_ns),
    "<w:rPr/><w:drawing><wp:inline distT=\"0\" distB=\"0\" distL=\"0\" distR=\"0\">",
    sprintf("<wp:extent cx=\"%.0f\" cy=\"%.0f\"/>", width * 12700 * 72, height * 12700 * 72),
    "<wp:docPr id=\"\" name=\"\"/>",
    "<wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" noChangeAspect=\"1\"/></wp:cNvGraphicFramePr>",
    "<a:graphic xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"><pic:pic xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\">",
    "<pic:nvPicPr>",
    "<pic:cNvPr id=\"\" name=\"\"/>",
    "<pic:cNvPicPr><a:picLocks noChangeAspect=\"1\" noChangeArrowheads=\"1\"/>",
    "</pic:cNvPicPr></pic:nvPicPr>",
    "<pic:blipFill>",
    sprintf("<a:blip r:embed=\"%s\"/>", src),
    "<a:srcRect/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>",
    "<pic:spPr bwMode=\"auto\"><a:xfrm><a:off x=\"0\" y=\"0\"/>",
    sprintf("<a:ext cx=\"%.0f\" cy=\"%.0f\"/></a:xfrm><a:prstGeom prst=\"rect\"><a:avLst/></a:prstGeom><a:noFill/></pic:spPr>", width * 12700, height * 12700),
    "</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>"
  )
  str
}

with_openxml_quotes <- function(x) {
  if (length(x) < 1) {
    x <- ""
  } else if (length(x) > 1) {
    x <- paste(x, collapse = "\n")
  }

  paste("\n\n``````{=openxml}", x, "``````\n\n", sep = "\n")
}

