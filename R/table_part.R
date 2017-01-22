#' @importFrom officer fp_sign fp_cell fp_par fp_text
#' @importFrom gdtools str_extents
table_part <- function( data, col_keys = names(data),
                        default_pr_text = fp_text(),
                        default_pr_par = fp_par() ){

  default_pr_cell <- fp_cell()
  default_pr_cell_id <- fp_sign(default_pr_cell)
  default_pr_par <- fp_par()
  default_pr_par_id <- fp_sign(default_pr_par)
  default_pr_text <- fp_text()
  default_pr_text_id <- fp_sign(default_pr_text)

  pr_cell_init <- matrix(default_pr_cell_id, nrow = nrow(data), ncol = length(col_keys) )
  pr_par_init <- matrix(default_pr_par_id, nrow = nrow(data), ncol = length(col_keys) )
  pr_text_init <- matrix(default_pr_text_id, nrow = nrow(data), ncol = length(col_keys) )

  span_init <- matrix(1L, nrow = nrow(data), ncol = length(col_keys) )
  spans <- list( rows = span_init, columns = span_init )

  lazy_f <- map(col_keys, lazy_format_simple )
  lazy_f_id <- map_chr(lazy_f, fp_sign)
  lazy_f_init <- matrix( rep.int(lazy_f_id, nrow(data)), nrow = nrow(data), ncol = length(col_keys), byrow = TRUE )

  style_ref_table <- list(
    cells = setNames(object = list(default_pr_cell), default_pr_cell_id),
    pars = setNames(object = list(default_pr_par), default_pr_par_id),
    text = setNames(object = list(default_pr_text), default_pr_text_id ),
    formats = setNames(lazy_f, lazy_f_id)
  )

  colwidths <- str_extents(x = col_keys, fontname = default_pr_text$font.family,
                       fontsize = default_pr_text$font.size,
                       bold = default_pr_text$bold,
                       italic = default_pr_text$italic)
  rowheights <- str_extents(x = "M", fontname = default_pr_text$font.family,
                            fontsize = default_pr_text$font.size,
                            bold = default_pr_text$bold,
                            italic = default_pr_text$italic)
  colwidths <- colwidths[,1] / 72
  rowheights <- rep( rowheights[,2] / 72, nrow(data) )

  out <- list( dataset = data,
               col_keys = col_keys,
               colwidths = colwidths,
               rowheights = rowheights,
               spans = spans,
               style_ref_table = style_ref_table,
               styles = list(
                 cells = pr_cell_init,
                 pars = pr_par_init,
                 text = pr_text_init,
                 formats = lazy_f_init
                 )
               )
  class( out ) <- "table_part"

  out
}


print.table_part <- function(x, ...){
  print(x$dataset)
}

#' @importFrom dplyr bind_rows
#' @importFrom utils tail
#' @importFrom utils head
add_rows <- function( x, rows, first = FALSE ){

  data <- x$dataset
  spans <- x$spans
  style_cells <- x$styles$cells
  style_pars <- x$styles$pars
  style_text <- x$styles$text
  format_f <- x$styles$formats

  ncol <- length(x$col_keys)
  nrow <- nrow(rows)

  # styles
  def_style_cell <- names(x$style_ref_table$cells)[1]
  def_style_par <- names(x$style_ref_table$pars)[1]
  def_style_text <- names(x$style_ref_table$text)[1]

  style_cell_new <- matrix( def_style_cell, ncol = ncol, nrow = nrow )
  style_par_new <- matrix( def_style_par, ncol = ncol, nrow = nrow )
  style_text_new <- matrix( def_style_text, ncol = ncol, nrow = nrow )

  model_id <- ifelse( first, 1, nrow(data))
  style_cell_new_line <- x$styles$cells[model_id, ,drop = FALSE]
  style_par_new_line <- x$styles$pars[model_id, , drop = FALSE]
  style_text_new_line <- x$styles$text[model_id, , drop = FALSE]
  style_cell_new[,] <- style_cell_new_line
  style_par_new[,] <- style_par_new_line
  style_text_new[,] <- style_text_new_line

  # format_new <- lapply( seq_len(nrow), function(x, fmt) tail(fmt, n = 1), x$styles$formats )
  # format_new <- do.call(rbind, format_new)
  line_fun <- ifelse( first, head, tail)
  format_new <- lapply( seq_len(nrow), function(x, fmt) line_fun(fmt, n = 1), x$styles$formats )
  format_new <- do.call(rbind, format_new)


  span_new <- matrix( 1, ncol = ncol, nrow = nrow )
  rowheights <- x$rowheights


  if( !first ){
    data <- bind_rows(data, rows )

    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )

    # add the styles rows
    style_cells <- rbind(style_cells, style_cell_new)
    style_pars <- rbind(style_pars, style_par_new)
    style_text <- rbind(style_text, style_text_new)
    format_f <- rbind(format_f, format_new)

    rowheights <- c(rowheights, rep(0.6, nrow(rows)))
  } else {
    data <- bind_rows(rows, data )

    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )

    # add the styles rows
    style_cells <- rbind(style_cell_new, style_cells)
    style_pars <- rbind(style_par_new, style_pars)
    style_text <- rbind(style_text_new, style_text)
    format_f <- rbind(format_new, format_f)

    rowheights <- c(rep(0.6, nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x$styles$cells <- style_cells
  x$styles$pars <- style_pars
  x$styles$text <- style_text
  x$styles$formats <- format_f
  x
}


#' @importFrom purrr map_chr
#' @importFrom purrr map
merge_index <- function( x, what, byrow = FALSE ){
  if( byrow ){
    values <- map_chr( x$dataset[what, ], format )
  } else {
    values <- format( x$dataset[[what]])
  }

  rle_ <- rle(x = values )

  vout <- map(.x = rle_$lengths,.f = function(l){
    out <- rep(0L, l)
    out[1] <- l
    out
  } )

  as.integer( unlist(x = vout) )
}

span_columns <- function( x, columns = NULL ){

  if( is.null(columns) )
    columns <- x$col_keys

  stopifnot(all( columns %in% x$col_keys ) )
  spans <- sapply( columns,
                   function(k, x )
                     merge_index(x, what = k, byrow = FALSE ),
                   x = x )
  x$spans$columns[, match(columns, x$col_keys)] <- spans

  merged.rows = which( x$spans$rows != 1 )
  merged.cols = which( x$spans$columns != 1 )
  overlaps = intersect(merged.rows, merged.cols)
  if( length( overlaps ) > 0 )
    stop("span overlappings, some merged cells are already merged with other cells.")

  x
}

span_rows <- function( x, rows = NULL ){
  row_id <- get_rows_id( x, i = rows )

  spans <- lapply( row_id,
                   function(k, x )
                     merge_index(x, what = k, byrow = TRUE ),
                   x = x )
  spans <- do.call( rbind, spans )
  x$spans$rows[match(row_id, seq_len(nrow(x$dataset))), ] <- spans

  merged.rows = which( x$spans$rows != 1 )
  merged.cols = which( x$spans$columns != 1 )
  overlaps = intersect(merged.rows, merged.cols)
  if( length( overlaps ) > 0 )
    stop("span overlappings, some merged cells are already merged with other cells.")


  x
}

span_free <- function( x  ){
  x$spans$rows[] <- 1
  x$spans$columns[] <- 1
  x
}


get_columns_id <- function( x, j = NULL ){
  maxcol <- length(x$col_keys)
  if( is.null(j) ) {
    j <- seq_along(x$col_keys)
  }

  if( is.numeric (j) ){

    if( all(j < 0 ) ){
      j <- setdiff(seq_along(x$col_keys), -j )
    }

    if( any( j < 1 | j > maxcol ) )
      stop("out of range columns selection 1:", maxcol)
  } else if( is.logical (j) ){
    if( length( j ) != maxcol ) stop("invalid columns subset")
    else j = which(j)

  } else if( is.character (j) ){
    if( any( is.na( j ) ) ) stop("NA in selection")
    else if( !all( is.element(j, x$col_keys )) )
      stop("invalid columns subset")
    else j = match(j, x$col_keys)
  } else stop("invalid columns subset")

  j
}


get_rows_id <- function( x, i = NULL ){
  maxrow <- nrow(x$dataset)

  if( is.null(i) ) {
    i <- seq_len(maxrow)
  }


  if( is.numeric (i) ){

    if( all(i < 0 ) ){
      i <- setdiff(seq_len(maxrow), -i )
    }

    if( any( i < 1 | i > maxrow ) )
      stop("invalid rows subset")

  } else if( is.logical (i) ){
    if( length( i ) != maxrow )
      stop("invalid rows subset")
    else i = which(i)

  } else if( is.character (i) ){
    any( is.na( i ) )
    rn <- row.names(x$dataset)
    if( any( is.na( i ) ) )
      stop("NA in selection")
    else if( !all( is.element(i, rn ) ) )
      stop("invalid rows subset")
    else i = match(i, rn )
  } else stop("unknown selection type")

  i
}



set_formatting_properties <- function( x, i = NULL, j = NULL, value ){

  i <- get_rows_id(x = x, i = i)
  j <- get_columns_id(x = x, j = j)
  if( inherits(value, "fp_text" ) ){
    signat_ <- fp_sign(value)
    x$styles$text[i, j] <- signat_

    if( ! signat_%in% names(x$style_ref_table$text) ){
      x$style_ref_table$text[[signat_]] <- value
    }

  }
  if( inherits(value, "fp_par" ) ){
    signat_ <- fp_sign(value)
    x$styles$pars[i, j] <- signat_

    if( ! signat_%in% names(x$style_ref_table$pars) ){
      x$style_ref_table$pars[[signat_]] <- value
    }

  }
  if( inherits(value, "fp_cell" ) ){
    signat_ <- fp_sign(value)
    x$styles$cells[i, j] <- signat_

    if( ! signat_%in% names(x$style_ref_table$cells) ){
      x$style_ref_table$cells[[signat_]] <- value
    }

  }

  x
}





get_pr_cell <- function( x, i, j ){
  signat_ <- x$styles$cells[i, j]
  x$style_ref_table$cells[[signat_]]
}






set_border_ <- function(x, i, j, border, side ){

  cp_ <- get_pr_cell(x, i = i, j = j)
  args <- list(object = cp_)
  args[[paste0("border.", side)]] <- border
  cp_ <- do.call( "update", args )
  x <- set_formatting_properties(x, i = i, j = j, cp_ )

  if( side == "top" && i > 1 ){
    cp_ <- get_pr_cell(x, i = i-1, j = j)
    args <- list(object = cp_)
    args[["border.bottom"]] <- border
    cp_ <- do.call( "update", args )
    x <- set_formatting_properties(x, i = i-1, j = j, cp_ )
  } else if( side == "right" && j < length(x$col_keys) ){
    cp_ <- get_pr_cell(x, i = i, j = j+1)
    args <- list(object = cp_)
    args[["border.left"]] <- border
    cp_ <- do.call( "update", args )
    x <- set_formatting_properties(x, i = i, j = j+1, cp_ )
  } else if( side == "bottom" && i < nrow(x$dataset) ){
    cp_ <- get_pr_cell(x, i = i+1, j = j)
    args <- list(object = cp_)
    args[["border.top"]] <- border
    cp_ <- do.call( "update", args )
    x <- set_formatting_properties(x, i = i+1, j = j, cp_ )
  } else if( side == "left" && j > 1 ){
    cp_ <- get_pr_cell(x, i = i, j = j-1)
    args <- list(object = cp_)
    args[["border.right"]] <- border
    cp_ <- do.call( "update", args )
    x <- set_formatting_properties(x, i = i, j = j-1, cp_ )
  }

  x
}


