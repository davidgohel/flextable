add_rows <- function(x, ...){
  UseMethod("add_rows")
}

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
                        hansi.family = "Arial", eastasia.family = "Arial", cs.family = "Arial",
                        vertical.align = "baseline",
                        shading.color = "transparent", ... ){
  x <- list(
    color = fpstruct(nrow = nrow, keys = keys, default = color),
    font.size = fpstruct(nrow = nrow, keys = keys, default = font.size),
    bold = fpstruct(nrow = nrow, keys = keys, default = bold),
    italic = fpstruct(nrow = nrow, keys = keys, default = italic),
    underlined = fpstruct(nrow = nrow, keys = keys, default = underlined),
    font.family = fpstruct(nrow = nrow, keys = keys, default = font.family),
    hansi.family = fpstruct(nrow = nrow, keys = keys, default = hansi.family),
    eastasia.family = fpstruct(nrow = nrow, keys = keys, default = eastasia.family),
    cs.family = fpstruct(nrow = nrow, keys = keys, default = cs.family),
    vertical.align = fpstruct(nrow = nrow, keys = keys, default = vertical.align),
    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color)
  )
  class(x) <- "text_struct"
  x
}

`[<-.text_struct` <- function( x, i, j, property, value ){
  if( inherits(value, "fp_text")) {
    for(property in intersect(names(value), names(x))){
      x[[property]][i, j] <- value[[property]]
    }
  } else if(property %in% names(x)) {
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
  data$ft_row_id <- rep( seq_len(nrow(object$color$data)), ncol(object$color$data) )
  data$col_id <- rep( object$color$keys, each = nrow(object$color$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$color$keys)
  data
}


# par_struct -----
par_struct <- function( nrow, keys,
                        text.align = "left",
                        line_spacing = 1,
                        padding.bottom = 0, padding.top = 0,
                        padding.left = 0, padding.right = 0,
                        border.width.bottom = 0, border.width.top = 0, border.width.left = 0, border.width.right = 0,
                        border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                        border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                        shading.color = "transparent", ... ){

  x <- list(
    text.align = fpstruct(nrow = nrow, keys = keys, default = text.align),

    padding.bottom = fpstruct(nrow = nrow, keys = keys, default = padding.bottom),
    padding.top = fpstruct(nrow = nrow, keys = keys, default = padding.top),
    padding.left = fpstruct(nrow = nrow, keys = keys, default = padding.left),
    padding.right = fpstruct(nrow = nrow, keys = keys, default = padding.right),

    line_spacing = fpstruct(nrow = nrow, keys = keys, default = line_spacing),

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
    for(property in intersect(names(value), names(x))){
      x[[property]][i, j] <- value[[property]]
    }
  } else if(property %in% names(x)) {
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
  data$ft_row_id <- rep( seq_len(nrow(object$text.align$data)), ncol(object$text.align$data) )
  data$col_id <- rep( object$text.align$keys, each = nrow(object$text.align$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$text.align$keys)
  data
}


add_parstyle_column <- function(x, type = "wml", text.direction, valign){

  if( type %in% "wml"){

    shading <- ifelse( colalpha(x$shading.color) > 0,
            sprintf("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"%s\"/>", colcode0(x$shading.color) ),
            "")

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

    padding <- sprintf("<w:spacing w:after=\"%.0f\" w:before=\"%.0f\" w:line=\"%.0f\"/><w:ind w:firstLine=\"0\" w:left=\"%.0f\" w:right=\"%.0f\"/>",
                       x$padding.bottom*20, x$padding.top*20,
                       x$line_spacing*240,
                       x$padding.left*20, x$padding.right*20 )

    style_column <- paste0("<w:pPr>", textalign, bb, bt, bl, br,
                           padding, shading, "</w:pPr>" )
  } else if( type %in% "pml"){

    textalign <- ifelse( x$text.align %in% "left", " algn=\"l\"",
                         ifelse( x$text.align %in% "center", " algn=\"ctr\"",
                                 ifelse( x$text.align %in% "justify", " algn=\"just\"",
                                         " algn=\"r\"") ) )

    padding <- sprintf(" marL=\"%.0f\" marR=\"%.0f\"><a:lnSpc><a:spcPct val=\"%.0f\"/></a:lnSpc><a:spcBef><a:spcPts val=\"%.0f\" /></a:spcBef><a:spcAft><a:spcPts val=\"%.0f\" /></a:spcAft>",
                       x$padding.left*12700, x$padding.right*12700, x$line_spacing*100000, x$padding.top*100, x$padding.bottom*100 )

    style_column <- paste0("<a:pPr", textalign, padding, "<a:buNone/>", "</a:pPr>" )
  }

  x$style_str <- style_column
  x[, c("ft_row_id", "col_id", "style_str")]
}

par_data <- function(x, run_data, type, text.direction, valign){
  paragraphs <- as.data.frame(x)
  paragraphs <- add_parstyle_column(paragraphs, type = type, text.direction = text.direction, valign = valign)
  setDT(paragraphs)
  dat <- merge(paragraphs, run_data, by = c("ft_row_id", "col_id"), all.x = TRUE)
  setDF(paragraphs)

  if( type %in% "wml" ){
    dat$par_str <- paste0("<w:p>", dat$style_str, dat$par_nodes_str, "</w:p>")
  } else if( type %in% "pml" ){
    dat$par_str <- paste0("<a:p>", dat$style_str, dat$par_nodes_str, "</a:p>")
  }
  dat$col_id <- factor(dat$col_id, levels = x$text.align$keys)

  dat <- dat[order(dat$ft_row_id, dat$col_id), ]
  dat[, c("ft_row_id", "col_id", "par_str")]
}


# cell_struct -----
cell_struct <- function( nrow, keys,
                         vertical.align = "top", text.direction = "lrtb",
                         margin.bottom = 0, margin.top = 0,
                         margin.left = 0, margin.right = 0,
                         border.width.bottom = 1, border.width.top = 1, border.width.left = 1, border.width.right = 1,
                         border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                         border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                         background.color = "#34CC27", width = NA_real_, height = NA_real_, hrule = "auto",
                         ...){

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
    background.color = fpstruct(nrow = nrow, keys = keys, default = background.color),
    hrule = fpstruct(nrow = nrow, keys = keys, default = hrule)
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
    for(property in intersect(names(value), names(x))){
      x[[property]][i, j] <- value[[property]]
    }
  } else if(property %in% names(x)) {
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

  data$ft_row_id <- rep( seq_len(nrow(object$background.color$data)), ncol(object$background.color$data) )
  data$col_id <- rep( object$background.color$keys, each = nrow(object$background.color$data) )
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$col_id <- factor(data$col_id, levels = object$background.color$keys)
  data
}

add_cellstyle_column <- function(x, type = "wml", text.align ){

  if( type %in% "wml"){

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
  x[, c("ft_row_id", "col_id", "style_str")]
}

cell_data <- function(x, par_data, type, span_rows, span_columns, colwidths, rowheights, hrule, text.align){
  x[,, "width"] <- rep(colwidths, each = x$vertical.align$nrow)
  x[,, "height"] <- rep(rowheights, x$vertical.align$ncol)
  x[,, "hrule"] <- rep(hrule, x$vertical.align$ncol)
  cells <- as.data.frame(x)
  cells <- add_cellstyle_column(cells, type = type, text.align = text.align)
  setDT(cells)
  dat <- merge(cells, par_data, by = c("ft_row_id", "col_id"), all.x = TRUE)

  setorderv(dat, cols = c("col_id", "ft_row_id"))
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
  }

  dat <- dat[order(dat$ft_row_id, dat$col_id), ]
  dat <- dat[, c("ft_row_id", "col_id", "cell_str")]
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

  newcontent <- lapply(data[x$content$keys], function(x) as_paragraph(as_chunk(x, formatter = format_fun)) )
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
  by_columns <- c("font.size", "italic", "bold", "underlined", "color", "shading.color",
                  "font.family", "hansi.family", "eastasia.family", "cs.family",
                  "vertical.align")

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
    if(!is.null(newx[[j]]))
      newx[[j]] <- ifelse(is.na(newx[[j]]), newx[[paste0(j, "_default")]], newx[[j]])
    else newx[[j]] <- newx[[paste0(j, "_default")]]
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

  out <- rbindlist( apply(x$content$data, 2, rbindlist), use.names=TRUE, fill=TRUE)
  out$ft_row_id <- row_id
  out$col_id <- col_id
  setDF(out)

  default_props <- as.data.frame(default_chunk_fmt, stringsAsFactors = FALSE)
  out <- replace_missing_fptext_by_default(out, default_props)

  out$col_id <- factor( out$col_id, levels = default_chunk_fmt$color$keys )
  out <- out[order(out$col_id, out$ft_row_id, out$seq_index) ,]
  out

}

add_runstyle_column <- function(x, type = "wml"){

  if( type %in% "wml"){
    family <- sprintf("<w:rFonts w:ascii=\"%s\" w:hAnsi=\"%s\" w:eastAsia=\"%s\" w:cs=\"%s\"/>",
                      x$font.family, x$hansi.family, x$eastasia.family, x$cs.family )
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

    family <- sprintf("<a:latin typeface=\"%s\"/><a:cs typeface=\"%s\"/><a:ea typeface=\"%s\"/><a:sym typeface=\"%s\"/>",
                      x$font.family, x$cs.family, x$eastasia.family, x$hansi.family)
    bold <- ifelse(x$bold, " b=\"1\"", "" )
    italic <- ifelse(x$italic, " i=\"1\"", "" )
    underline <- ifelse(x$underlined, " u=\"1\"", "" )
    font.size <- sprintf(" sz=\"%.0f\"", 100*x$font.size )

    vertical.align <- ifelse(
      x$vertical.align %in% "superscript", " baseline=\"40000\"",
      ifelse(x$vertical.align %in% "subscript"," baseline=\"-40000\"", "") )

    color <- paste0(
      sprintf("<a:solidFill><a:srgbClr val=\"%s\">", colcode0(x$color) ),
      sprintf("<a:alpha val=\"%.0f\"/>", colalpha(x$color) ),
      "</a:srgbClr></a:solidFill>" )
    shading.color <- paste0(
      sprintf("<a:highlight><a:srgbClr val=\"%s\">", colcode0(x$shading.color) ),
      sprintf("<a:alpha val=\"%.0f\"/>", colalpha(x$shading.color) ),
      "</a:srgbClr></a:highlight>" )
    shading.color[colalpha(x$shading.color) < 1] <- ""

    style_column <- paste0("<a:rPr", font.size, italic, bold, underline, vertical.align, ">",
                           color, shading.color, family, "%s",
                           "</a:rPr>" )
  }

  x$style_str <- style_column
  x
}

#' @import data.table
add_raster_as_filecolumn <- function(x){

  whichs_ <- which( !sapply(x$img_data, is.null) & !is.na(x$img_data) )
  files <- mapply(function(x, width, height){
    if(inherits(x, "raster")){
      file <- tempfile(fileext = ".png")
      png(filename = file, units = "in", res = 300, bg = "transparent", width = width, height = height)
      op <- par(mar=rep(0, 4))
      plot(x, interpolate = FALSE, asp=NA)
      par(op)
      dev.off()
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
#' @importFrom htmltools urlEncodePath
run_data <- function(x, type){

  is_eq <- !is.na(x$eq_data)
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
    url_vals <- vapply(x$url[is_hlink], urlEncodePath, FUN.VALUE = "", USE.NAMES = FALSE)
    text_nodes_str[is_hlink] <- paste0("<w:hyperlink r:id=\"", url_vals, "\">", text_nodes_str[is_hlink], "</w:hyperlink>")
    if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
      transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
      text_nodes_str[is_eq] <- transform_mathjax(x$eq_data[is_eq], to = "mml")
    }

    x$par_nodes_str <- text_nodes_str

  } else if( type %in% "pml" ){
    text_nodes_str <- ifelse( !is_raster, paste0("<a:t>", htmlEscape(x$txt), "</a:t>"), "<a:t></a:t>")

    # manage hlinks
    x$url[is_hlink] <- vapply(x$url[is_hlink], urlEncodePath, FUN.VALUE = "", USE.NAMES = FALSE)
    link_pr <- ifelse(is_hlink, paste0("<a:hlinkClick r:id=\"", x$url, "\"/>"), "" )
    if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
      transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
      text_nodes_str[is_eq] <-
        paste0("<mc:AlternateContent xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\"><mc:Choice xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\" Requires=\"a14\">",
               "<a14:m xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\"><m:oMathPara xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\"><m:oMathParaPr><m:jc m:val=\"centerGroup\"/></m:oMathParaPr>",
               transform_mathjax(x$eq_data[is_eq], to = "mml"),
               "</m:oMathPara></a14:m>",
               "</mc:Choice></mc:AlternateContent>")
    }

    x$par_nodes_str <- paste0(ifelse(is_eq, "", "<a:r>"),
                              sprintf(x$style_str, link_pr), text_nodes_str,
                              ifelse(is_eq, "", "</a:r>")
                              )
  }

  z <- as.data.table(x)
  setorderv(z, cols = c("ft_row_id", "col_id", "seq_index") )
  z <- z[, lapply(.SD, function(x) paste0(x, collapse = "")), by = c("ft_row_id", "col_id"), .SDcols = "par_nodes_str"]
  setDF(z)
  z
}

