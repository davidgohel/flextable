#' @importFrom rmarkdown pandoc_exec
html_chunkify <- function(x, engine = "none"){
  stopifnot(length(x) == 1, is.character(x))

  engi <- match.arg(engine, c("commonmark", "pandoc", "none"), several.ok = FALSE)
  if("pandoc" %in% engi){
    mdfile <- tempfile(fileext = ".md")
    writeLines(enc2utf8(x), mdfile, useBytes = TRUE)
    out <- system2(rmarkdown::pandoc_exec(),
            args = c(mdfile, "--mathjax", "--katex", "-t", "html"),
            stdout = TRUE
            )
    out <- paste0(out, collapse = "")
    out <- gsub("(<p>|</p>)", "", out)
  } else if("commonmark" %in% engi){
    if (requireNamespace("commonmark", quietly = TRUE)) {
      out <- commonmark::markdown_html(x)
      out <- gsub("(<p>|</p>|\\n)", "", out)
    } else {
      stop("package 'commonmark' must be installed to use option 'commonmark'.")
    }
  } else out <- x

  enc2utf8(out)
}


html_str <- function(x, ft.align = NULL, class = "tabwid",
                     caption = "", shadow = TRUE, topcaption = TRUE,
                     manual_css = ""){

  fixed_layout <- x$properties$layout %in% "fixed"
  if(!fixed_layout){
    if (x$properties$width > 0) {
      # setting width will contraint columns'widths and make word breaks
      tbl_width <- paste0("width:", formatC(x$properties$width*100), "%;")
    } else {
      tbl_width <- ""
    }
    tabcss <- paste0("table-layout:auto;", tbl_width)
  } else {
    tabcss <- ""
  }

  codes <- html_gen(x)

  classname <- UUIDgenerate(n = 1, use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  tabcss <- paste0(".", classname, "{", tabcss, "}")

  if(topcaption) str <- paste0(caption, codes$html)
  else str <- paste0(codes$html, caption)
  codes <- sprintf("<style>%s%s%s</style><table class='%s'>%s</table>",
          tabcss, codes$css, flextable_global$defaults$extra_css, classname, str)

  if( is.null(ft.align) ) ft.align <- "center"

  if( "left" %in% ft.align )
    tab_class <- paste0(class, " tabwid_left")
  else if( "right" %in% ft.align )
    tab_class <- paste0(class, " tabwid_right")
  else tab_class <- class

  html <- paste0("<div class=\"", tab_class, "\">",
         as.character(codes),
         "</div>")
  if(shadow){
    uid <- UUIDgenerate(n = 2L)

    tabwid_css <- paste(c("<style>", readLines(system.file(package="flextable", "web_1.1.0", "tabwid.css"), encoding = "UTF-8"), "</style>"), collapse = "\n")

    html <- paste0("<template id=\"", uid[1], "\">",
                   tabwid_css,
                   html,
           "</template>",
           "\n<div class=\"flextable-shadow-host\" id=\"", uid[2], "\"></div>",
           to_shadow_dom(uid1 = uid[1], uid2 = uid[2], topcaption = topcaption)
    )
  }
  if(is.null(manual_css) || "" %in% manual_css){
    html
  } else {
    paste0(sprintf("<style>%s</style>", manual_css), html)
  }

}

to_shadow_dom <- function(uid1, uid2, topcaption = TRUE){

  if(topcaption){
    move_inst <- "  dest.parentNode.insertBefore(caption, dest.previousSibling);"
  } else {
    move_inst <- "  dest.parentNode.insertBefore(caption, dest.nextSibling);"
  }
  script_commands <- c("", "<script>",
    paste0("var dest = document.getElementById(\"", uid2, "\");"),
    paste0("var template = document.getElementById(\"", uid1, "\");"),
    "var caption = template.content.querySelector(\"caption\");",
    "if(caption) {",
    "  caption.style.cssText = caption.style.cssText+\"display:block;\";",
    move_inst,
    "}",
    "var fantome = dest.attachShadow({mode: 'open'});",
    "var templateContent = template.content;",
    "fantome.appendChild(templateContent);",
    "</script>", "")
  paste(script_commands, collapse = "\n")
}

# to html/css  ----
#' @importFrom data.table setnames setorderv := setcolorder setDT setDF dcast
html_gen <- function(x){

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
      "<td ",
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
  dat$td_tag <- paste0(dat$td_tag, dat$p_tag, "</td>")

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
  cell_style_str <- cell_css_styles(data_ref_cells)
  if(!x$properties$layout %in% "fixed") {
    cell_style_str <- gsub("width:[ ]*[0-9\\.]+pt;", "", cell_style_str)
  }
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

#' @importFrom base64enc dataURI
img_as_html <- function(img_data, width, height){
  str_raster <- mapply(function(img_raster, width, height ){

    if(inherits(img_raster, "raster")){
      outfile <- tempfile(fileext = ".png")
      png(filename = outfile, units = "in", res = 300, bg = "transparent", width = width, height = height)
      op <- par(mar=rep(0, 4))
      plot(img_raster, interpolate = FALSE, asp=NA)
      par(op)
      dev.off()
      img_raster <- outfile
    }

    if(is.character(img_raster)){

      if( grepl("\\.png", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/png"
      } else if( grepl("\\.gif", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/gif"
      } else if( grepl("\\.jpg", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/jpeg"
      } else if( grepl("\\.jpeg", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/jpeg"
      } else if( grepl("\\.svg", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/svg+xml"
      } else if( grepl("\\.tiff", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/tiff"
      } else if( grepl("\\.webp", ignore.case = TRUE, x = img_raster) ){
        mime <- "image/webp"
      } else {
        stop("this format is not implemented")
      }
      if(!file.exists(img_raster)){
        stop("file ", shQuote(img_raster), " can not be found.")
      }
      img_raster <- base64enc::dataURI(file = img_raster, mime = mime )

    } else  {
      stop("unknown image format")
    }
    sprintf("<img style=\"vertical-align:baseline;width:%.0fpx;height:%.0fpx;\" src=\"%s\" />", width*72, height*72, img_raster)
  }, img_data, width, height, SIMPLIFY = FALSE, USE.NAMES = FALSE)
  str_raster <- as.character(unlist(str_raster))
  str_raster
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

cell_css_styles <- function(x){

  background.color <- ifelse( colalpha(x$background.color) > 0,
                              sprintf("background-color:%s;", colcodecss(x$background.color) ),
                              "background-color:transparent;")

  width <- ifelse( is.na(x$width), "", sprintf("width:%s;", css_pt(x$width * 72) ) )
  height <- ifelse( !is.na(x$height) & x$hrule %in% c("exact", "atleast"), sprintf("height:%s;", css_pt(x$height * 72 ) ), "" )

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
#' @param htmlscroll add a scroll if table is too big to fit
#' into its HTML container, default to TRUE.
#' @examples
#' if(require("htmltools"))
#'   div(flextable_html_dependency())
flextable_html_dependency <- function(htmlscroll = TRUE){
  if (isTRUE(htmlscroll)) {
    stylesheet <- c("tabwid.css", "scrool.css")
  } else {
    stylesheet <- "tabwid.css"
  }
  htmlDependency("tabwid",
                 "1.1.0",
                 src = system.file(package="flextable", "web_1.1.0"),
                 stylesheet = stylesheet)

}

