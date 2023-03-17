gen_raw_html <- function(x,
                         class = "tabwid",
                         caption = "",
                         topcaption = TRUE,
                         manual_css = "") {

  align <- x$properties$align
  # for ubiquity and other packages that dump old flextable
  if(is.null(align)) align <- "center"

  fixed_layout <- x$properties$layout %in% "fixed"
  if (!fixed_layout) {
    if (x$properties$width > 0) {
      # setting width will contraint columns'widths and make word breaks
      tbl_width <- paste0("width:", formatC(x$properties$width * 100), "%;")
    } else {
      tbl_width <- ""
    }
    tabcss <- paste0("table-layout:auto;", tbl_width)
  } else {
    tabcss <- ""
  }

  codes <- html_content_strs(x)

  classname <- UUIDgenerate(n = 1, use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  tabcss <- paste0(".", classname, "{", tabcss, "}")

  if (is.null(manual_css) || "" %in% manual_css) {
    manual_css_str <- ""
  } else {
    manual_css_str <- manual_css
  }

  if (!is.null(x$properties$opts_html$scroll)) {

    freeze_first_column <- x$properties$opts_html$scroll$freeze_first_column
    if (isTRUE(freeze_first_column)) {
      freeze_first_css_th <- paste0(
        ".", classname, " thead > tr > th:first-child {position:sticky;left:0;z-index:5;}")
      freeze_first_css_td <- paste0(
        ".", classname, " tbody > tr > td:first-child {position:sticky;left:0;z-index:3;}")
      freeze_first_css <- paste0(
        c(freeze_first_css_th, freeze_first_css_td),
        collapse = "")

      x$properties$opts_html$extra_css <- paste0(
        freeze_first_css,
        x$properties$opts_html$extra_css
      )
    }

    if (!is.null(x$properties$opts_html$scroll$height)) {
      x$properties$opts_html$extra_css <- paste0(
        ".", classname, " th {position: sticky;top: 0;z-index: 4;}.", classname, " {border-collapse: separate !important;}",
        x$properties$opts_html$extra_css
      )
    }

  }

  html <- paste0(
    "<style>",
    tabcss,
    codes$css,
    x$properties$opts_html$extra_css,
    manual_css_str,
    "</style>",
    sprintf("<table data-quarto-disable-processing='true' class='%s'>", classname),
    caption,
    codes$html,
    "</table>"
  )

  if (is.null(align)) align <- "center"
  if ("left" %in% align) {
    tab_class <- paste0(class, " tabwid_left")
  } else if ("right" %in% align) {
    tab_class <- paste0(class, " tabwid_right")
  } else {
    tab_class <- class
  }

  if (!topcaption) {
    tab_class <- paste0(tab_class, " tabwid-caption-bottom")
  }

  style_div <- ""
  if(!is.null(x$properties$opts_html$scroll)) {
    style_div <- do.call(scrollbox, x$properties$opts_html$scroll)
    style_div <- paste0(" style=\"", style_div, "\"")
  }

  html <- paste0("<div class=\"", tab_class, "\"", style_div, ">", html, "</div>")
  html
}


scrollbox <- function(height = NULL, add_css = "", ...) {
  str <- "overflow-x:auto;width:100%;"
  if (!is.null(height)) {
    if (is.numeric(height)) {
      height <- sprintf("%.0fpx", height)
    }
    str <- paste0(str, "overflow-y:auto;height:", height, ";")
  }
  str <- paste0(str, add_css)
  str
}

# to html/css  ----
#' @importFrom data.table setnames setorderv := setcolorder setDT setDF dcast
html_content_strs <- function(x){

  cell_data_f <- fortify_style(x, "cells")
  setDT(cell_data_f)
  par_data_f <- fortify_style(x, "pars")
  setDT(par_data_f)

  txt_data <- runs_as_html(x, chunk_data = fortify_run(x))
  span_style_str <- attr(txt_data, "css")
  setDT(txt_data)

  cell_data <- merge(x = cell_data_f,
                     y = par_data_f[, c("part", "ft_row_id", "col_id", "text.align")],
                     by = c("part", "ft_row_id", "col_id"))
  par_data <- merge(x = par_data_f,
                    y = cell_data_f[, c("part", "ft_row_id", "col_id", "text.direction", "vertical.align")],
                    by = c("part", "ft_row_id", "col_id"))

  # get rid of originals that are empty
  cell_data[, c("width", "height", "hrule") := list(NULL, NULL, NULL)]
  cell_data <- merge(cell_data, fortify_width(x), by = "col_id")
  cell_data <- merge(cell_data, fortify_height(x), by = c("part", "ft_row_id"))
  cell_data <- merge(cell_data, fortify_hrule(x), by = c("part", "ft_row_id"))

  span_data <- fortify_span(x)

  data_ref_pars <- distinct_paragraphs_properties(par_data)
  setDT(data_ref_pars)
  data_ref_cells <- distinct_cells_properties(cell_data)
  setDT(data_ref_cells)

  par_data <- merge(par_data, data_ref_pars, by = setdiff(colnames(data_ref_pars), "classname"))
  par_data <- par_data[, list(p_tag = paste0("<p class=\"", get("classname"), "\">")), by = c("part", "ft_row_id", "col_id")]

  by_columns <- intersect(colnames(cell_data), colnames(data_ref_cells))
  cell_data <- merge(cell_data, data_ref_cells, by = by_columns)
  cell_data <- merge(cell_data, span_data, by = c("part", "ft_row_id", "col_id"))

  cell_data <- cell_data[, list(
    td_tag = paste0(
      ifelse(get("part") %in% "header", "<th ", "<td "),
      paste0(
        ifelse(get("rowspan") > 1,
          paste0(" colspan=\"", get("rowspan"), "\""),
          ""),
        ifelse(get("colspan") > 1,
          paste0(" rowspan=\"", get("colspan"), "\""),
          "")
      ),
      "class=\"", get("classname"), "\">"
    )
  ),
  by = c("part", "ft_row_id", "col_id")
  ]

  dat <- merge(txt_data, par_data , by = c("part", "ft_row_id", "col_id"))
  dat$p_tag <- paste0(dat$p_tag, dat$span_tag, "</p>")
  dat <- merge(dat, cell_data , by = c("part", "ft_row_id", "col_id"))
  dat$td_tag <- paste0(dat$td_tag, dat$p_tag,
                       ifelse(dat$part %in% "header", "</th>", "</td>"))

  data_hrule <- fortify_hrule(x)
  data_hrule$tr_tag <- "<tr>"
  data_hrule$tr_tag[!data_hrule$hrule %in% "exact"] <- "<tr style=\"overflow-wrap:break-word;\">"

  rows_data <- data_hrule[c("part", "ft_row_id",  "tr_tag")]

  dat <- merge(dat, span_data, by = c("part", "ft_row_id", "col_id"))
  dat$td_tag[dat$rowspan < 1 | dat$colspan < 1] <- ""

  z <- dcast(dat, part + ft_row_id ~ col_id, drop=TRUE, fill="", value.var = "td_tag", fun.aggregate = I)
  z <- merge(z, rows_data, by = c("part", "ft_row_id"))
  setorderv(z, c("part", "ft_row_id"))
  z$tr_end <- "</tr>"

  parts <- z$part
  header_start <- head(which(parts %in% "header"), n = 1)
  header_end <- tail(which(parts %in% "header"), n = 1)
  body_start <- head(which(parts %in% "body"), n = 1)
  body_end <- tail(which(parts %in% "body"), n = 1)
  footer_start <- head(which(parts %in% "footer"), n = 1)
  footer_end <- tail(which(parts %in% "footer"), n = 1)

  z$tpart_start <- ""
  z$tpart_end <- ""
  z$tpart_start[header_start] <- "<thead>"
  z$tpart_end[header_end] <- "</thead>"
  z$tpart_start[body_start] <- "<tbody>"
  z$tpart_end[body_end] <- "</tbody>"
  z$tpart_start[footer_start] <- "<tfoot>"
  z$tpart_end[footer_end] <- "</tfoot>"
  setcolorder(z, neworder = c("tpart_start", "tr_tag"))

  z[, c("part", "ft_row_id") := NULL]

  html <- apply(as.matrix(z), 1, paste0, collapse = "")
  html <- paste0(html, collapse = "")

  par_style_str <- par_css_styles(data_ref_pars)
  cell_style_str <- cell_css_styles(data_ref_cells, add_widths = x$properties$layout %in% "fixed")
  list(
    html = html,
    css = paste0(span_style_str, par_style_str, cell_style_str)
  )
}



# html chunks ----
htmlize <- function(x){
  x <-  htmlEscape(x)
  x <-  gsub("\t", "&emsp;", x)
  x
}

#' @importFrom officer image_to_base64
img_as_html <- function(img_data, width, height){
  img_data <- str_raster <- mapply(function(img_raster, width, height ){
    if(inherits(img_raster, "raster")){
      outfile <- tempfile(fileext = ".png")
      agg_png(filename = outfile, units = "in", res = 300, background = "transparent", width = width, height = height)
      op <- par(mar=rep(0, 4))
      plot(img_raster, interpolate = FALSE, asp=NA)
      par(op)
      dev.off()
      img_raster <- outfile
    }
    img_raster
  }, img_data, width, height,
  SIMPLIFY = TRUE, USE.NAMES = FALSE)
  base64_strings <- image_to_base64(img_data)
  sprintf("<img style=\"vertical-align:baseline;width:%.0fpx;height:%.0fpx;\" src=\"%s\" />", width*72, height*72, base64_strings)
}

# css ----

css_pt <- function(x, digits = 1){
  x <- ifelse( is.na(x), "inherit",
               ifelse( x < 0.001, "0",
                       paste0(format_double(x, digits = digits),"pt")))
  x
}
css_no_unit <- function(x, digits = 0){
  x <- ifelse( is.na(x), "inherit",
               ifelse( x < 0.001, "0",
                       format_double(x, digits = digits)))
  x
}

border_css <- function(color, width, style, side){
  style[!style %in% c("dotted", "dashed", "solid")] <- "solid"
  x <- sprintf("border-%s: %s %s %s;", side, css_pt(width, 2), style, colcodecss(color))
  x
}



css_align <- function(text.direction, align) {

  textdir <- rep("", length(text.direction))
  textdir[text.direction %in% "btlr"] <- "writing-mode: vertical-rl;transform: rotate(180deg);-ms-writing-mode:bt-lr;-webkit-writing-mode:vertical-rl;"
  textdir[text.direction %in% "tbrl"] <- "writing-mode: vertical-rl;-ms-writing-mode:tb-rl;-webkit-writing-mode:vertical-rl;"

  textalign <- sprintf("text-align:%s;", align )

  textalign_margins <- rep("", length(text.direction))
  textalign_margins[text.direction %in% "tbrl" & align %in% "center"] <- "margin-left:auto;margin-right:auto;"
  textalign_margins[text.direction %in% "tbrl" & align %in% "left"] <-"margin-right:auto;"
  textalign_margins[text.direction %in% "tbrl" & align %in% "right"] <- "margin-left:auto;"

  textalign_margins[text.direction %in% "btlr" & align %in% "center"] <- "margin-left:auto;margin-right:auto;"
  textalign_margins[text.direction %in% "btlr" & align %in% "left"] <- "margin-right:auto;"
  textalign_margins[text.direction %in% "btlr" & align %in% "right"] <- "margin-left:auto;"

  paste0(textalign, textalign_margins, textdir)
}

par_css_styles <- function(x){

  shading <- rep("background-color:transparent;", nrow(x))
  has_shading <- colalpha(x$shading.color) > 0
  shading[has_shading] <- sprintf("background-color:%s;", colcodecss(x$shading.color[has_shading]))

  textalign <- css_align(x$text.direction, x$text.align)

  bb <- border_css(
    color = x$border.color.bottom, width = x$border.width.bottom,
    style = x$border.style.bottom, side = "bottom")
  bt <- border_css(
    color = x$border.color.top, width = x$border.width.top,
    style = x$border.style.top, side = "top")
  bl <- border_css(
    color = x$border.color.left, width = x$border.width.left,
    style = x$border.style.left, side = "left")
  br <- border_css(
    color = x$border.color.right, width = x$border.width.right,
    style = x$border.style.right, side = "right")

  padding.bottom <- sprintf("padding-bottom:%s;", css_pt(x$padding.bottom) )
  padding.top <- sprintf("padding-top:%s;", css_pt(x$padding.top) )
  padding.left <- sprintf("padding-left:%s;", css_pt(x$padding.left) )
  padding.right <- sprintf("padding-right:%s;", css_pt(x$padding.right) )

  line_spacing <- sprintf("line-height: %s;", css_no_unit(x$line_spacing, 2) )

  style_column <- paste0("margin:0;", textalign, bb, bt, bl, br,
                         padding.bottom, padding.top, padding.left, padding.right,
                         line_spacing, shading )
  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}

cell_css_styles <- function(x, add_widths = TRUE){

  background.color <- ifelse( colalpha(x$background.color) > 0,
                              sprintf("background-color:%s;", colcodecss(x$background.color) ),
                              "background-color:transparent;")
  width <- rep("", nrow(x))
  if (add_widths) {
    width[!is.na(x$width)] <- sprintf("width:%sin;", css_no_unit(x$width[!is.na(x$width)], digits = 3))
  }

  height <- rep("", nrow(x))
  hsel <- !is.na(x$height) & x$hrule %in% c("exact", "atleast")
  height[hsel] <- sprintf("height:%sin;", css_no_unit(x$height[hsel], digits = 3))

  vertical.align <- rep("vertical-align: middle;", nrow(x))
  vertical.align[x$vertical.align %in% "top"] <- "vertical-align: top;"
  vertical.align[x$vertical.align %in% "bottom"] <- "vertical-align: bottom;"

  bb <- border_css(
    color = x$border.color.bottom, width = x$border.width.bottom,
    style = x$border.style.bottom, side = "bottom")
  bt <- border_css(
    color = x$border.color.top, width = x$border.width.top,
    style = x$border.style.top, side = "top")
  bl <- border_css(
    color = x$border.color.left, width = x$border.width.left,
    style = x$border.style.left, side = "left")
  br <- border_css(
    color = x$border.color.right, width = x$border.width.right,
    style = x$border.style.right, side = "right")

  margin.bottom <- sprintf("margin-bottom:%s;", css_pt(x$margin.bottom) )
  margin.top <- sprintf("margin-top:%s;", css_pt(x$margin.top) )
  margin.left <- sprintf("margin-left:%s;", css_pt(x$margin.left) )
  margin.right <- sprintf("margin-right:%s;", css_pt(x$margin.right) )

  style_column <- paste0(width, height, background.color, vertical.align, bb, bt, bl, br,
                         margin.bottom, margin.top, margin.left, margin.right)
  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}

# htmlDependency ----
#' @importFrom htmltools htmlDependency
#' @export
#' @title htmlDependency for flextable objects
#' @description When using loops in an R Markdown for HTML document, the
#' htmlDependency object for flextable must also be added at least once.
#' @examples
#' if(require("htmltools"))
#'   div(flextable_html_dependency())
#' @keywords internal
flextable_html_dependency <- function(){
  htmlDependency("tabwid",
                 "1.1.3",
                 src = system.file(package="flextable", "web_1.1.3"),
                 stylesheet = "tabwid.css",
                 script = "tabwid.js"
                 )

}

#' @importFrom htmltools attachDependencies tags
flextable_html_dependencies <- function(x) {
  list_deps <- list(flextable_html_dependency())
  if (gdtools::has_internet())
    list_deps <- append(list_deps, lapply(avail_gfonts(x), gdtools::gfontHtmlDependency))
  attachDependencies(
    x = tags$style(""),
    list_deps
  )
}

#' @importFrom gdtools installed_gfonts
avail_gfonts <- function(x){
  z <- character()
  if( nrow_part(x, part = "body") > 0 )
    z <- append(z, unique(as.vector(x$body$styles$text$font.family$data)))
  if( nrow_part(x, part = "footer") > 0 )
    z <- append(z, unique(as.vector(x$footer$styles$text$font.family$data)))
  if( nrow_part(x, part = "header") > 0 )
    z <- append(z, unique(as.vector(x$header$styles$text$font.family$data)))
  families <- unique(as.character(z))
  intersect(families, installed_gfonts())
}

#' @importFrom rmarkdown html_document render pandoc_available
render_htmltag <- function(x, path, title, lang = "en") {
  sucess <- FALSE
  rmd_file <- tmp_rmd(title = paste0(title, collapse = "\n"), lang = lang)
  html_file <- gsub("\\.Rmd$", ".html", rmd_file)
  tryCatch(
    {
      render(rmd_file,
             output_format = html_document(self_contained = TRUE, theme = NULL,
                                           mathjax = NULL),
             # output_file = basename(path),
             envir = new.env(),
             quiet = TRUE,
             params = list(x = x)
      )
      sucess <- file.copy(html_file, path, overwrite = TRUE)
    },
    warning = function(e) {
    },
    error = function(e) {
    }
  )
  sucess
}

tmp_rmd <- function(title, lang = "en") {
  stopifnot(pandoc_available())
  file <- tempfile(fileext = ".Rmd")
  writeLines(
    c("---",
      sprintf("title: %s", title),
      sprintf("lang: %s", lang),
      "params:",
      "  x: ''",
      "---",
      "```{r include=FALSE}",
      "library(knitr)",
      "opts_chunk$set(echo = FALSE)",
      "```",
      "",
      "```{r}",
      "params$x",
      "```"),
    file, useBytes = TRUE)
  file
}
