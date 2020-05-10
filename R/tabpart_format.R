# utils -----
css_px <- function(x, format = "%.0fpx"){
  ifelse( is.na(x), "inherit",
          ifelse( x < 0.001, "0", sprintf(format, x)) )
}

css_pt <- function(x){
  ifelse( is.na(x), "inherit",
          ifelse( x < 0.001, "0", sprintf("%.0fpt", x)) )
}

border_css <- function(color, width, style, side){
  style[!style %in% c("dotted", "dashed", "solid")] <- "solid"
  sprintf("border-%s: %s %s %s;", side, css_px(width, "%.2fpx"), style, colcodecss(color))
}
border_wml <- function(color, width, style, side){
  width[style %in% c("none")] <- 0
  style[!style %in% c("dotted", "dashed", "solid")] <- "single"
  style[style %in% c("solid")] <- "single"

  out <- sprintf('<w:%s w:val="%s" w:sz="%.0f" w:space="0" w:color="%s" />', side, style, width * 8, colcode0(color))
  out[width < 0.001 | color %in% "transparent"] <- ""
  out
}
border_pml <- function(color, width, style, side){
  color[width < 0.001] <- "transparent"
  color <- paste0("<a:solidFill>",
                  sprintf("<a:srgbClr val=\"%s\">", colcode0(color) ),
                  sprintf("<a:alpha val=\"%.0f\"/>", colalpha(color) ),
                  "</a:srgbClr>", "</a:solidFill>" )
  style <- ifelse(
    style %in% "dotted", "<a:prstDash val=\"sysDot\"/>",
    ifelse( style %in% "dashed", "<a:prstDash val=\"sysDash\"/>",
            "<a:prstDash val=\"solid\"/>") )
  attrs <- " algn=\"ctr\" cap=\"flat\""
  out <- paste0(
    sprintf('<a:ln%s w="%.0f" cmpd=\"sng\" %s>', side, width * 12700, attrs),
    color,
    style,
    sprintf('</a:ln%s>', side)
  )
  out
}

# main -----

#' @importFrom htmltools htmlEscape
#' @importFrom gdtools raster_write raster_str
#' @importFrom xml2 as_xml_document xml_find_all xml_attr
format.complex_tabpart <- function( x, type = "wml", header = FALSE,
                                    split = FALSE, colwidth = TRUE, ... ){
  stopifnot(length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html") )

  if(!colwidth){
    x$colwidths[] <- NA_real_
  }

  if( nrow(x$dataset) < 1 ) return("")
  img_data <- list(
    image_src = character(0)
  )
  hl_data <- list(
    href = character(0)
  )

  txt_data <- fortify_content(x$content, default_chunk_fmt = x$styles$text)
  txt_data <- run_data(txt_data, type = type)

  if( type == "wml"){
    pic_ns <- " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\""
    xml_ <- paste0("<any ", base_ns, pic_ns, ">", paste(txt_data$par_nodes_str, collapse = ""), "</any>")
    nodecontent <- as_xml_document(xml_ )
    blipnodes <- xml_find_all(nodecontent, "//pic:blipFill/a:blip")

    img_data <- list(
      image_src = as.character( xml_attr(blipnodes, "embed") )
    )

    hyperlinknodes <- xml_find_all(nodecontent, "//w:hyperlink")
    hl_data <- list(
      href = as.character( xml_attr(hyperlinknodes, "id") )
    )

  }
  if( type == "pml"){
    pic_ns <- " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\""
    xml_ <- paste0("<any ", base_ns, pic_ns, ">", paste(txt_data$par_nodes_str, collapse = ""), "</any>")
    nodecontent <- as_xml_document(xml_ )

    hyperlinknodes <- xml_find_all(nodecontent, "//a:hlinkClick")
    hl_data <- list(
      href = as.character( xml_attr(hyperlinknodes, "id") )
    )

  }

  paragraphs <- par_data(x$styles$pars, txt_data, type = type,
                         text.direction = x$styles$cells$text.direction$data, valign = x$styles$cells$vertical.align$data)
  cells <- cell_data(x$styles$cells, paragraphs, type = type,
                     span_rows = x$spans$rows,
                     span_columns = x$spans$columns, x$colwidths, x$rowheights, x$hrule, text.align=x$styles$pars$text.align$data)
  setDT(cells)
  cells <- dcast(cells, row_id ~ col_id, drop=FALSE, fill="", value.var = "cell_str", fun.aggregate = I)
  cells$row_id <- NULL
  cells <- apply(as.matrix(cells), 1, paste0, collapse = "")

  if( type == "html"){
    rows <- paste0(sprintf("<tr%s>", ifelse(x$hrule %in% "exact", "", " style=\"overflow-wrap:break-word;\"")), cells, "</tr>")
  } else if( type == "wml"){
    rows <- paste0( "<w:tr><w:trPr>",
            ifelse(split, "", "<w:cantSplit/>"),
            "<w:trHeight w:val=",
            shQuote( round(x$rowheights * 72*20, 0 ), type = "cmd"), " w:hRule=\"", ifelse(x$hrule %in% "atleast", "atLeast", x$hrule) ,"\"/>",
            ifelse( header, "<w:tblHeader/>", ""),
            "</w:trPr>", cells, "</w:tr>")
  } else if( type == "pml"){
    rows <- paste0( "<a:tr h=\"", round(x$rowheights * 914400, 0 ), "\">",
                    cells, "</a:tr>")
  } else stop("pas fait")

  out <- paste0(rows, collapse = "")
  attr(out, "imgs") <- as.data.frame(img_data, stringsAsFactors = FALSE)
  attr(out, "htxt") <- as.data.frame(hl_data, stringsAsFactors = FALSE)

  out
}
