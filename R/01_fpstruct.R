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


#' @importFrom utils head tail
add_rows.fpstruct <- function(x, nrows, first, default = x$default, ...){

  if(nrow(x$data) < 1)
    new <- matrix( rep(default, x$ncol * nrows), ncol = x$ncol)
  else if( first ){
    default <- as.vector(head(x$data, n = 1))
    new <- matrix( rep(default, each=nrows), ncol = x$ncol)
  }
  else {
    default <- as.vector(tail(x$data, n = 1))
    new <- matrix( rep(default, each=nrows), ncol = x$ncol)
  }
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
                        keep_with_next = FALSE,
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

    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color),
    keep_with_next = fpstruct(nrow = nrow, keys = keys, default = keep_with_next)
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


