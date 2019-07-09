# fpstruct ------

fpstruct <- function(nrow, keys, default){
  ncol <- length(keys)
  data <- rep(default, length.out = nrow*ncol)
  map_data <- matrix(data = data,nrow = nrow, ncol = ncol, dimnames = list(NULL, keys))

  x <- list( data = map_data, keys = keys, nrow = nrow, ncol = ncol, default = default )
  class(x) <- "fpstruct"
  x
}
`[<-.fpstruct` <- function( x, i, j, value ){
  x$data[i, j] <- value
  x
}


`[.fpstruct` <- function( x, i, j ){
  x$data[i, j]
}
print.fpstruct <- function( x, ... ){
  print(x$data)
}



add_rows.fpstruct <- function(x, nrows, first, default = x$default, ...){

  new <- matrix( rep(default, x$ncol * nrows), ncol = x$ncol)

  if( first ){
    x$data <- rbind(new, x$data)
  } else {
    x$data <- rbind(x$data, new)
  }
  x$nrow <- nrow(x$data)
  x
}

# text_struct ------
text_struct <- function( nrow, keys,
                        color = "black", font.size = 10,
                        bold = FALSE, italic = FALSE, underlined = FALSE,
                        font.family = "Arial",
                        vertical.align = "baseline",
                        shading.color = "transparent" ){
  x <- list(
    color = fpstruct(nrow = nrow, keys = keys, default = color),
    font.size = fpstruct(nrow = nrow, keys = keys, default = font.size),
    bold = fpstruct(nrow = nrow, keys = keys, default = bold),
    italic = fpstruct(nrow = nrow, keys = keys, default = italic),
    underlined = fpstruct(nrow = nrow, keys = keys, default = underlined),
    font.family = fpstruct(nrow = nrow, keys = keys, default = font.family),
    vertical.align = fpstruct(nrow = nrow, keys = keys, default = vertical.align),
    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color)
  )
  class(x) <- "text_struct"
  x
}

`[<-.text_struct` <- function( x, i, j, property, value ){
  if( inherits(value, "fp_text")) {
    for(property in names(value)){
      x[[property]][i, j] <- value[[property]]
    }
  } else {
    x[[property]][i, j] <- value
  }

  x
}
`[.text_struct` <- function( x, i, j, property, value ){
  x[[property]][i, j]
}

print.text_struct <- function(x, ...){
  dims <- dim(x$color$data)
  cat("a text_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

add_rows.text_struct <- function(x, nrows, first, ...){

  for(i in seq_len(length(x)) ){
    x[[i]] <- add_rows(x[[i]], nrows, first = first)
  }
  x
}

as.data.frame.text_struct <- function(object, ...){
  data <- lapply( object, function(x){
    as.vector(x$data)
  })
  data$row_id <- rep( seq_len(nrow(object$color$data)), ncol(object$color$data) )
  data$col_id <- rep( object$color$keys, each = nrow(object$color$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$color$keys)
  data
}
as_fp_text_list <- function(x, i, j){
  props_split <- mapply(function(z, colname, i, j){
    out <- as.vector(z$data[i, z$keys[j] , drop = FALSE])
    as.list(out)
  }, x, names(x), MoreArgs = list( i = i, j = j ), SIMPLIFY = FALSE)
  props_split$FUN <- fp_text
  props_split$SIMPLIFY <- FALSE
  props_split$USE.NAMES <- TRUE
  do.call(mapply, props_split)
}



# par_struct -----
par_struct <- function( nrow, keys,
                        text.align = "left",
                        padding.bottom = 0, padding.top = 0,
                        padding.left = 0, padding.right = 0,
                        border.width.bottom = 0, border.width.top = 0, border.width.left = 0, border.width.right = 0,
                        border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                        border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                        shading.color = "transparent" ){

  x <- list(
    text.align = fpstruct(nrow = nrow, keys = keys, default = text.align),

    padding.bottom = fpstruct(nrow = nrow, keys = keys, default = padding.bottom),
    padding.top = fpstruct(nrow = nrow, keys = keys, default = padding.top),
    padding.left = fpstruct(nrow = nrow, keys = keys, default = padding.left),
    padding.right = fpstruct(nrow = nrow, keys = keys, default = padding.right),

    border.width.bottom = fpstruct(nrow = nrow, keys = keys, default = border.width.bottom),
    border.width.top = fpstruct(nrow = nrow, keys = keys, default = border.width.top),
    border.width.left = fpstruct(nrow = nrow, keys = keys, default = border.width.left),
    border.width.right = fpstruct(nrow = nrow, keys = keys, default = border.width.right),

    border.color.bottom = fpstruct(nrow = nrow, keys = keys, default = border.color.bottom),
    border.color.top = fpstruct(nrow = nrow, keys = keys, default = border.color.top),
    border.color.left = fpstruct(nrow = nrow, keys = keys, default = border.color.left),
    border.color.right = fpstruct(nrow = nrow, keys = keys, default = border.color.right),

    border.style.bottom = fpstruct(nrow = nrow, keys = keys, default = border.style.bottom),
    border.style.top = fpstruct(nrow = nrow, keys = keys, default = border.style.top),
    border.style.left = fpstruct(nrow = nrow, keys = keys, default = border.style.left),
    border.style.right = fpstruct(nrow = nrow, keys = keys, default = border.style.right),

    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color)
  )
  class(x) <- "par_struct"
  x
}


print.par_struct <- function(x, ...){
  dims <- dim(x$text.align$data)
  cat("a par_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}


add_rows.par_struct <- function(x, nrows, first, ...){

  for(i in seq_len(length(x)) ){
    x[[i]] <- add_rows(x[[i]], nrows, first = first)
  }
  x
}


`[<-.par_struct` <- function( x, i, j, property, value ){
  if( inherits(value, "fp_par")) {
    value <- cast_borders(value)
    for(property in names(value)){
      x[[property]][i, j] <- value[[property]]
    }
  } else {
    x[[property]][i, j] <- value
  }

  x
}


`[.par_struct` <- function( x, i, j, property ){
  x[[property]][i, j]
}

as.data.frame.par_struct <- function(object, ...){
  data <- lapply( object, function(x){
    as.vector(x$data)
  })
  data$row_id <- rep( seq_len(nrow(object$text.align$data)), ncol(object$text.align$data) )
  data$col_id <- rep( object$text.align$keys, each = nrow(object$text.align$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$text.align$keys)
  data
}


add_parstyle_column <- function(x, type = "html"){

  if( type %in% "html"){
    shading <- ifelse( colalpha(x$shading.color) > 0,
                       sprintf("background-color:%s;", colcodecss(x$shading.color) ),
                       "background-color:transparent;")

    textalign <- sprintf("text-align:%s;", x$text.align )

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

    padding.bottom <- sprintf("padding-bottom:%s;", css_px(x$padding.bottom) )
    padding.top <- sprintf("padding-top:%s;", css_px(x$padding.top) )
    padding.left <- sprintf("padding-left:%s;", css_px(x$padding.left) )
    padding.right <- sprintf("padding-right:%s;", css_px(x$padding.right) )

    style_column <- paste0("style=\"margin:0;", textalign, bb, bt, bl, br,
                           padding.bottom, padding.top, padding.left, padding.right, shading, "\"" )
  } else if( type %in% "wml"){

    shading <- ifelse( colalpha(x$shading.color) > 0,
            sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$shading.color) ),
            "")

    # shading <- sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$shading.color) )

    textalign <- ifelse( x$text.align %in% "justify", "<w:jc w:val=\"both\"/>", sprintf("<w:jc w:val=\"%s\"/>", x$text.align) )

    bb <- border_wml(
      color = x$border.color.bottom, width = x$border.width.bottom,
      style = x$border.style.bottom, side = "bottom")
    bt <- border_wml(
      color = x$border.color.top, width = x$border.width.top,
      style = x$border.style.top, side = "top")
    bl <- border_wml(
      color = x$border.color.left, width = x$border.width.left,
      style = x$border.style.left, side = "left")
    br <- border_wml(
      color = x$border.color.right, width = x$border.width.right,
      style = x$border.style.right, side = "right")

    padding <- sprintf("<w:spacing w:after=\"%.0f\" w:before=\"%.0f\"/><w:ind w:firstLine=\"0\" w:left=\"%.0f\" w:right=\"%.0f\"/>",
                       x$padding.bottom*20, x$padding.top*20, x$padding.left*20, x$padding.right*20 )

    style_column <- paste0("<w:pPr>", textalign, bb, bt, bl, br,
                           padding, shading, "</w:pPr>" )
  } else if( type %in% "pml"){

    textalign <- ifelse( x$text.align %in% "left", " algn=\"l\"",
                         ifelse( x$text.align %in% "center", " algn=\"ctr\"",
                                 ifelse( x$text.align %in% "justify", " algn=\"just\"",
                                         " algn=\"r\"") ) )

    padding <- sprintf(" marL=\"%.0f\" marR=\"%.0f\"><a:spcBef><a:spcPts val=\"%.0f\" /></a:spcBef><a:spcAft><a:spcPts val=\"%.0f\" /></a:spcAft>",
                       x$padding.left*12700, x$padding.right*12700, x$padding.top*100, x$padding.bottom*100 )

    style_column <- paste0("<a:pPr", textalign, padding, "<a:buNone/>", "</a:pPr>" )
  }

  x$style_str <- style_column
  x[, c("row_id", "col_id", "style_str")]
}

par_data <- function(x, run_data, type){
  paragraphs <- as.data.frame(x)
  paragraphs <- add_parstyle_column(paragraphs, type = type)
  setDT(paragraphs)
  dat <- merge(paragraphs, run_data, by = c("row_id", "col_id"), all.x = TRUE)
  setDF(paragraphs)

  if( type %in% "wml" ){
    dat$par_str <- paste0("<w:p>", dat$style_str, dat$par_nodes_str, "</w:p>")
  } else if( type %in% "pml" ){
    dat$par_str <- paste0("<a:p>", dat$style_str, dat$par_nodes_str, "</a:p>")
  } else if( type %in% "html" ){
    dat$par_str <- sprintf("<p %s>%s</p>", dat$style_str, dat$par_nodes_str)
  }
  dat$col_id <- factor(dat$col_id, levels = x$text.align$keys)

  dat <- dat[order(dat$row_id, dat$col_id), ]
  dat[, c("row_id", "col_id", "par_str")]
}


# cell_struct -----
cell_struct <- function( nrow, keys,
                         vertical.align = "top", text.direction = "lrtb",
                         margin.bottom = 0, margin.top = 0,
                         margin.left = 0, margin.right = 0,
                         border.width.bottom = 1, border.width.top = 1, border.width.left = 1, border.width.right = 1,
                         border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                         border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                         background.color = "#34CC27", width = NA_real_, height = NA_real_ ){

  check_choice( value = vertical.align, choices = c( "top", "center", "bottom" ) )
  check_choice( value = text.direction, choices = c( "lrtb", "tbrl", "btlr" ) )

  x <- list(
    vertical.align = fpstruct(nrow = nrow, keys = keys, default = vertical.align),
    width = fpstruct(nrow = nrow, keys = keys, default = width),
    height = fpstruct(nrow = nrow, keys = keys, default = height),

    margin.bottom = fpstruct(nrow = nrow, keys = keys, default = margin.bottom),
    margin.top = fpstruct(nrow = nrow, keys = keys, default = margin.top),
    margin.left = fpstruct(nrow = nrow, keys = keys, default = margin.left),
    margin.right = fpstruct(nrow = nrow, keys = keys, default = margin.right),

    border.width.bottom = fpstruct(nrow = nrow, keys = keys, default = border.width.bottom),
    border.width.top = fpstruct(nrow = nrow, keys = keys, default = border.width.top),
    border.width.left = fpstruct(nrow = nrow, keys = keys, default = border.width.left),
    border.width.right = fpstruct(nrow = nrow, keys = keys, default = border.width.right),

    border.color.bottom = fpstruct(nrow = nrow, keys = keys, default = border.color.bottom),
    border.color.top = fpstruct(nrow = nrow, keys = keys, default = border.color.top),
    border.color.left = fpstruct(nrow = nrow, keys = keys, default = border.color.left),
    border.color.right = fpstruct(nrow = nrow, keys = keys, default = border.color.right),

    border.style.bottom = fpstruct(nrow = nrow, keys = keys, default = border.style.bottom),
    border.style.top = fpstruct(nrow = nrow, keys = keys, default = border.style.top),
    border.style.left = fpstruct(nrow = nrow, keys = keys, default = border.style.left),
    border.style.right = fpstruct(nrow = nrow, keys = keys, default = border.style.right),


    text.direction = fpstruct(nrow = nrow, keys = keys, default = text.direction),
    background.color = fpstruct(nrow = nrow, keys = keys, default = background.color)
  )
  class(x) <- "cell_struct"
  x
}

add_rows.cell_struct <- function(x, nrows, first, ...){
  for(i in seq_len(length(x)) ){
    x[[i]] <- add_rows(x[[i]], nrows, first = first)
  }
  x
}

`[<-.cell_struct` <- function( x, i, j, property, value ){

  if( inherits(value, "fp_cell")) {
    value <- cast_borders(value)
    for(property in names(value)){
      x[[property]][i, j] <- value[[property]]
    }
  } else {
    x[[property]][i, j] <- value
  }

  x
}
`[.cell_struct` <- function( x, i, j, property ){
  x[[property]][i, j]
}
print.cell_struct <- function(x, ...){
  dims <- dim(x$background.color$data)
  cat("a cell_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

as.data.frame.cell_struct <- function(object, ...){
  data <- lapply( object, function(x){
    as.vector(x$data)
  })

  data$row_id <- rep( seq_len(nrow(object$background.color$data)), ncol(object$background.color$data) )
  data$col_id <- rep( object$background.color$keys, each = nrow(object$background.color$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$background.color$keys)
  data
}

add_cellstyle_column <- function(x, type = "html"){

  if( type %in% "html"){
    background.color <- ifelse( colalpha(x$background.color) > 0,
                       sprintf("background-clip: padding-box;background-color:%s;", colcodecss(x$background.color) ),
                       "background-color:transparent;")

    width <- ifelse( is.na(x$width), "", sprintf("width:%s;", css_px(x$width * 72) ) )
    height <- ifelse( is.na(x$height), "", sprintf("height:%s;", css_px(x$height * 72 ) ) )
    vertical.align <- ifelse(
      x$vertical.align %in% "center", "vertical-align: middle;",
      ifelse(x$vertical.align %in% "top", "vertical-align: top;", "vertical-align: bottom;") )
    text.direction <- ifelse(
      x$text.direction %in% "btlr", "transform: rotate(-90deg);",
      ifelse(x$text.direction %in% "tbrl", "transform: rotate(-270deg);", "transform: rotate(0deg);") )

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

    margin.bottom <- sprintf("margin-bottom:%s;", css_px(x$margin.bottom) )
    margin.top <- sprintf("margin-top:%s;", css_px(x$margin.top) )
    margin.left <- sprintf("margin-left:%s;", css_px(x$margin.left) )
    margin.right <- sprintf("margin-right:%s;", css_px(x$margin.right) )

    style_column <- paste0(width, height, background.color, vertical.align, text.direction, bb, bt, bl, br,
                           margin.bottom, margin.top, margin.left, margin.right)
  } else if( type %in% "wml"){

    background.color <- sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$background.color) )
    vertical.align <- ifelse( x$vertical.align %in% c("center", "top"), sprintf("<w:vAlign w:val=\"%s\"/>", x$vertical.align), "<w:vAlign w:val=\"bottom\"/>" )
    text.direction <- ifelse(
      x$text.direction %in% "btlr", "<w:textDirection w:val=\"btLr\"/>",
      ifelse(x$text.direction %in% "tbrl", "<w:textDirection w:val=\"tbRl\"/>", "") )

    bb <- border_wml(
      color = x$border.color.bottom, width = x$border.width.bottom,
      style = x$border.style.bottom, side = "bottom")
    bt <- border_wml(
      color = x$border.color.top, width = x$border.width.top,
      style = x$border.style.top, side = "top")
    bl <- border_wml(
      color = x$border.color.left, width = x$border.width.left,
      style = x$border.style.left, side = "left")
    br <- border_wml(
      color = x$border.color.right, width = x$border.width.right,
      style = x$border.style.right, side = "right")

    margin.bottom <- sprintf("<w:bottom w:w=\"%.0f\" w:type=\"dxa\"/>", x$margin.bottom * 20 )
    margin.top <- sprintf("<w:top w:w=\"%.0f\" w:type=\"dxa\"/>", x$margin.top * 20 )
    margin.left <- sprintf("<w:left w:w=\"%.0f\" w:type=\"dxa\"/>", x$margin.left * 20 )
    margin.right <- sprintf("<w:right w:w=\"%.0f\" w:type=\"dxa\"/>", x$margin.right * 20 )

    style_column <- paste0("<w:tcBorders>", bb, bt, bl, br, "</w:tcBorders>",
                           background.color,
                           "<w:tcMar>", margin.top, margin.bottom, margin.left, margin.right, "</w:tcMar>",
                           text.direction, vertical.align )
  } else if( type %in% "pml"){

    text.direction <- ifelse(
      x$text.direction %in% "btlr", " vert=\"vert270\"",
      ifelse(x$text.direction %in% "tbrl", " vert=\"vert\"", "") )
    vertical.align <- ifelse(
      x$vertical.align %in% "center", " anchor=\"ctr\"",
      ifelse( x$vertical.align %in% "top", " anchor=\"t\"", " anchor=\"b\"") )
    margins <- sprintf(" marB=\"%.0f\" marT=\"%.0f\" marR=\"%.0f\" marL=\"%.0f\"",
                       x$margin.bottom * 12700, x$margin.top * 12700,
                       x$margin.right * 12700, x$margin.left * 12700)

    background.color <- ifelse( colalpha(x$background.color) > 0,
                                paste0(
                                  sprintf("<a:solidFill><a:srgbClr val=\"%s\">", colcode0(x$background.color) ),
                                  sprintf("<a:alpha val=\"%.0f\"/>", colalpha(x$background.color) ),
                                  "</a:srgbClr></a:solidFill>" ),
                                "")

    bb <- border_pml(
      color = x$border.color.bottom, width = x$border.width.bottom,
      style = x$border.style.bottom, side = "B")
    bt <- border_pml(
      color = x$border.color.top, width = x$border.width.top,
      style = x$border.style.top, side = "T")
    bl <- border_pml(
      color = x$border.color.left, width = x$border.width.left,
      style = x$border.style.left, side = "L")
    br <- border_pml(
      color = x$border.color.right, width = x$border.width.right,
      style = x$border.style.right, side = "R")
    pml_attrs <- paste0(text.direction, vertical.align, margins)
    style_column <- paste0("<a:tcPr", pml_attrs, ">", bl, br, bt, bb,
                           background.color, "</a:tcPr>" )
  }

  x$style_str <- style_column
  x[, c("row_id", "col_id", "style_str")]
}

cell_data <- function(x, par_data, type, span_rows, span_columns, colwidths, rowheights){
  x[,, "width"] <- rep(colwidths, each = x$vertical.align$nrow)
  x[,, "height"] <- rep(rowheights, x$vertical.align$ncol)
  cells <- as.data.frame(x)
  cells <- add_cellstyle_column(cells, type = type)
  setDT(cells)
  dat <- merge(cells, par_data, by = c("row_id", "col_id"), all.x = TRUE)

  setorderv(dat, cols = c("col_id", "row_id"))
  setDF(dat)
  if( type %in% "wml" ){

    gridspan <- ifelse(span_rows > 1, paste0("<w:gridSpan w:val=\"", span_rows, "\"/>"), "")
    vmerge <- ifelse(span_columns > 1,"<w:vMerge w:val=\"restart\"/>",
                     ifelse(span_columns < 1, "<w:vMerge/>", "" )
    )

    str <- dat$par_str

    str[span_columns < 1] <- gsub("<w:r\\b[^<]*>[^<]*(?:<[^<]*)*</w:r>", "", str[span_columns < 1])
    str <- paste0("<w:tc>",
                  "<w:tcPr>", gridspan, vmerge, dat$style_str, "</w:tcPr>",
                  str,
                  "</w:tc>")
    str[span_rows < 1] <- ""

    dat$cell_str <- str
  } else if( type %in% "pml" ){


    gridspan <- ifelse(span_rows == 1, "",
                       ifelse(span_rows > 1, paste0(" gridSpan=\"", span_rows,"\""), " hMerge=\"true\"") )
    rowspan <- ifelse(span_columns == 1, "",
                      ifelse(span_columns > 1, paste0(" rowSpan=\"", span_columns,"\""),
                             " vMerge=\"true\"")
    )

    dat$cell_str <- paste0("<a:tc", gridspan, rowspan,">",
                           paste0( "<a:txBody><a:bodyPr/><a:lstStyle/>",
                                   dat$par_str, "</a:txBody>" ),
                           dat$style_str, "</a:tc>")
  } else if( type %in% "html" ){

    tc_attr <- paste0(
      ifelse(span_rows > 1, paste0(" colspan=\"", span_rows,"\""), ""),
      ifelse(span_columns > 1, paste0(" rowspan=\"", span_columns,"\""), "")
    )
    str <- paste0("<td", tc_attr, " style=\"", dat$style_str ,"\">", dat$par_str, "</td>")
    str[span_rows < 1 | span_columns < 1] <- ""
    dat$cell_str <- str
  }
  dat <- dat[order(dat$row_id, dat$col_id), ]
  dat <- dat[, c("row_id", "col_id", "cell_str")]
  dat$col_id <- factor(dat$col_id, levels = x$vertical.align$keys)

  dat
}



# chunkset_struct ---------------------------------------------------------

chunkset_struct <- function( nrow, keys ){
  x <- list(
    content = fpstruct(nrow = nrow, keys = keys, default = as_paragraph(as_chunk("")))
  )
  class(x) <- "chunkset_struct"
  x
}

add_rows.chunkset_struct <- function(x, nrows, first, data, ...){
  old_nrow <- x$content$nrow
  x$content <- add_rows(x$content, nrows, first = first, default = as_paragraph(as_chunk("")) )
  if(first){
    id <- seq_len(nrows)
  } else {
    id <- rev(rev(seq_len(x$content$nrow) )[seq_len(nrows)] )
  }

  newcontent <- lapply(data[x$content$keys], function(x) as_paragraph(as_chunk(x, formater = format_fun)) )
  x$content[id,x$content$keys] <- Reduce(append, newcontent)
  x
}


length.chunkset_struct <- function(x){
  length(x$content$data)
}

print.chunkset_struct <- function(x, ...){
  dims <- dim(x$content$data)
  cat("a chunkset_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

`[<-.chunkset_struct` <- function( x, i, j, value ){
  x$content[i, j] <- value
  x
}


`[.chunkset_struct` <- function( x, i, j ){
  x$content[i, j]
}



replace_missing_fptext_by_default <- function(x, default){
  by_columns <- c("font.size", "italic", "bold", "underlined", "color", "shading.color", "font.family", "vertical.align")

  keys <- default[, setdiff(names(default), by_columns), drop = FALSE]
  values <- default[, by_columns, drop = FALSE]
  names(values) <- paste0(by_columns, "_default")
  defdata <- cbind(keys, values)

  newx <- x
  setDT(newx)
  setDT(defdata)
  newx <- newx[defdata, on=names(keys)]
  setDF(newx)
  for( j in by_columns){
    newx[[j]] <- ifelse(is.na(newx[[j]]), newx[[paste0(j, "_default")]], newx[[j]])
    newx[[paste0(j, "_default")]] <- NULL
  }
  newx

}


fortify_content <- function(x, default_chunk_fmt, ...){

  row_id <- unlist( mapply( function(rows, data){
    rep(rows, nrow(data) )
  },
  rows = rep( seq_len(nrow(x$content$data)), ncol(x$content$data) ),
  x$content$data, SIMPLIFY = FALSE, USE.NAMES = FALSE ) )

  col_id <- unlist( mapply( function(columns, data){
    rep(columns, nrow(data) )
  },
  columns = rep( x$content$keys, each = nrow(x$content$data) ),
  x$content$data, SIMPLIFY = FALSE, USE.NAMES = FALSE ) )

  out <- rbindlist( apply(x$content$data, 2, rbindlist))
  out$row_id <- row_id
  out$col_id <- col_id
  setDF(out)

  default_props <- as.data.frame(default_chunk_fmt, stringsAsFactors = FALSE)
  out <- replace_missing_fptext_by_default(out, default_props)

  out$col_id <- factor( out$col_id, levels = default_chunk_fmt$color$keys )
  out <- out[order(out$col_id, out$row_id, out$seq_index) ,]
  out

}

add_runstyle_column <- function(x, type = "html"){

  if( type %in% "html"){
    shading <- ifelse(
      colalpha(x$shading.color) > 0,
      sprintf("background-color:%s;", colcodecss(x$shading.color) ),
      "background-color:transparent;")
    color <- ifelse(
      colalpha(x$color) > 0,
      sprintf("color:%s;", colcodecss(x$color) ),
      "")

    family <- sprintf("font-family:'%s';", x$font.family )

    positioning_val <- ifelse( x$vertical.align %in% "superscript", .3,
                               ifelse(x$vertical.align %in% "subscript", .3, NA_real_ ) )
    positioning_what <- ifelse( x$vertical.align %in% "superscript", "bottom",
                                ifelse(x$vertical.align %in% "subscript", "top", NA_character_ ) )
    vertical.align <- sprintf("position: relative;%s:%s;", positioning_what,
                              css_px(x$font.size * positioning_val))
    vertical.align <- ifelse(is.na(positioning_val), "", vertical.align)

    font.size <- sprintf(
      "font-size:%s;", css_pt(x$font.size * ifelse(
        x$vertical.align %in% "superscript", .6,
        ifelse(x$vertical.align %in% "subscript", .6, 1.0 )
      ) )
    )

    bold <- ifelse(x$bold, "font-weight:bold;", "font-weight:normal;" )
    italic <- ifelse(x$italic, "font-style:italic;", "font-style:normal;" )
    underline <- ifelse(x$underlined, "text-decoration:underline;", "text-decoration:none;" )


    style_column <- paste0("style=\"", family, font.size, bold, italic, underline,
                           color, shading, vertical.align, "\"")
  } else if( type %in% "wml"){

    family <- sprintf("<w:rFonts w:ascii=\"%s\" w:hAnsi=\"%s\" w:eastAsia=\"%s\" w:cs=\"%s\"/>",
                      x$font.family, x$font.family, x$font.family, x$font.family )
    bold <- ifelse(x$bold, "<w:b/>", "" )
    italic <- ifelse(x$italic, "<w:i/>", "" )
    underline <- ifelse(x$underlined, "<w:u w:val=\"single\"/>", "" )
    color <- sprintf("<w:color w:val=\"%s\"/>", colcode0(x$color) )

    shading <- ifelse( colalpha(x$shading.color) > 0,
                       sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$shading.color) ),
                       "")

    font.size <- sprintf("<w:sz w:val=\"%.0f\"/><w:szCs w:val=\"%.0f\"/>", 2*x$font.size, 2*x$font.size )


    vertical.align <- ifelse(
      x$vertical.align %in% "superscript", "<w:vertAlign w:val=\"superscript\"/>",
      ifelse(x$vertical.align %in% "subscript","<w:vertAlign w:val=\"subscript\"/>", "") )

    style_column <- paste0("<w:rPr>",
                           family, bold, italic, underline, vertical.align, font.size,
                           color, shading, "</w:rPr>" )
  } else if( type %in% "pml"){

    family <- sprintf("<a:latin typeface=\"%s\"/><a:cs typeface=\"%s\"/>", x$font.family, x$font.family )
    bold <- ifelse(x$bold, " b=\"1\"", "" )
    italic <- ifelse(x$italic, " i=\"1\"", "" )
    underline <- ifelse(x$underlined, " u=\"1\"", "" )
    font.size <- sprintf(" sz=\"%.0f\"", 100*x$font.size )

    vertical.align <- ifelse(
      x$vertical.align %in% "superscript", " baseline=\"40000\"",
      ifelse(x$vertical.align %in% "subscript"," baseline=\"-40000\"", "") )


    shading <- sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$shading.color) )

    color <- paste0(
      sprintf("<a:solidFill><a:srgbClr val=\"%s\">", colcode0(x$color) ),
      sprintf("<a:alpha val=\"%.0f\"/>", colalpha(x$color) ),
      "</a:srgbClr></a:solidFill>" )
    shading.color <- paste0(
      sprintf("<a:highlight><a:srgbClr val=\"%s\">", colcode0(x$shading.color) ),
      sprintf("<a:alpha val=\"%.0f\"/>", colalpha(x$shading.color) ),
      "</a:srgbClr></a:highlight>" )

    style_column <- paste0("<a:rPr", font.size, italic, bold, underline, vertical.align, ">",
                           color, family, shading.color, "%s",
                           "</a:rPr>" )
  }

  x$style_str <- style_column
  x
}

#' @importFrom gdtools raster_write
#' @import data.table
add_raster_as_filecolumn <- function(x){

  whichs_ <- which( !sapply(x$img_data, is.null) & !is.na(x$img_data) )
  files <- mapply(function(x, width, height){
    if(inherits(x, "raster")){
      file <- tempfile(fileext = ".png")
      raster_write(x, width = width*72, height = height*72, path = file)
    } else if(is.character(x)){
      file <- x
    } else {
      stop("unknown image format")
    }


    data.frame( file = file,
                img_str = wml_image(file, width, height),
                stringsAsFactors = FALSE)
  }, x$img_data[whichs_], x$width[whichs_], x$height[whichs_], SIMPLIFY = FALSE, USE.NAMES = FALSE)
  files <- rbindlist(files)
  setDF(files)

  x$file <- rep(NA_character_, nrow(x))
  x$img_str <- rep(NA_character_, nrow(x))

  x[whichs_, c("file", "img_str")] <- files

  x

}
#' @importFrom base64enc dataURI
run_data <- function(x, type){

  is_hlink <- !is.na(x$url)
  is_raster <- sapply(x$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  x <- add_runstyle_column(x, type)
  if( type %in% "wml" ){
    x <- add_raster_as_filecolumn(x)

    # manage text
    text_nodes_str <- paste0("<w:t xml:space=\"preserve\">",
                             gsub("\n", "</w:t><w:br/><w:t xml:space=\"preserve\">",
                                  htmlEscape(x$txt)), "</w:t>")

    text_nodes_str <- ifelse(
      !is_raster,
      paste0(sprintf("<w:r %s>", base_ns), x$style_str, text_nodes_str, "</w:r>"),
      x$img_str )
    # manage hlinks
    text_nodes_str[is_hlink] <- paste0("<w:hyperlink r:id=\"", htmlEscape(x$url[is_hlink]), "\">", text_nodes_str[is_hlink], "</w:hyperlink>")
    x$par_nodes_str <- text_nodes_str

  } else if( type %in% "pml" ){
    text_nodes_str <- ifelse( !is_raster, paste0("<a:t>", htmlEscape(x$txt), "</a:t>"), "<a:t></a:t>")

    # manage hlinks
    link_pr <- ifelse(is_hlink, paste0("<a:hlinkClick r:id=\"", htmlEscape(x$url), "\"/>"), "" )

    x$par_nodes_str <- paste0("<a:r>", sprintf(x$style_str, link_pr), text_nodes_str, "</a:r>")
  } else if( type %in% "html" ){

    text_nodes_str <-  gsub("\n", "<br>", htmlEscape(x$txt))

    # manage text
    str <- character(nrow(x))
    str[!is_raster] <- sprintf("<span %s>%s</span>", x$style_str[!is_raster], text_nodes_str[!is_raster])

    # manage images

    str_raster <- mapply(function(img_raster, width, height ){
      if(inherits(img_raster, "raster")){
        img_raster <- paste("data:image/png;base64,", gdtools::raster_str(img_raster, width*72, height*72))
      } else if(is.character(img_raster)){

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
        img_raster <- base64enc::dataURI(file = img_raster, mime = mime )

      } else  {
        stop("unknown image format")
      }
      sprintf("<img style=\"vertical-align:middle;width:%.0fpx;height:%.0fpx;\" src=\"%s\" />", width*72, height*72, img_raster)
    }, x$img_data[is_raster], x$width[is_raster], x$height[is_raster], SIMPLIFY = FALSE, USE.NAMES = FALSE)
    str_raster <- as.character(unlist(str_raster))
    str[is_raster] <- str_raster

    # manage hlinks
    str[is_hlink] <- paste0("<a href=\"", x$url[is_hlink], "\">", str[is_hlink], "</a>")

    x$par_nodes_str <- str
  }

  z <- as.data.table(x)
  setorderv(z, cols = c("row_id", "col_id", "seq_index") )
  z <- z[, lapply(.SD, function(x) paste0(x, collapse = "")), by = c("row_id", "col_id"), .SDcols = "par_nodes_str"]
  setDF(z)
  z
}

