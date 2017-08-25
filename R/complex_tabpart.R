#' @importFrom officer fp_sign fp_cell fp_par fp_text
complex_tabpart <- function( data, col_keys = names(data),
                        default_pr_text = fp_text(),
                        default_pr_par = fp_par(),
                        default_pr_cell = fp_cell(),
                        cwidth = NULL, cheight = NULL ){


  pr_cell_init <- fp_structure$new(nrow(data), col_keys, default_pr_cell )
  pr_par_init <- fp_structure$new(nrow(data), col_keys, default_pr_par )
  pr_text_init <- fp_structure$new(nrow(data), col_keys, default_pr_text )
  pr_display_init <- display_structure$new(nrow(data), col_keys )

  span_init <- matrix(1L, nrow = nrow(data), ncol = length(col_keys) )
  spans <- list( rows = span_init, columns = span_init )

  colwidths <- rep(cwidth, length(col_keys))
  rowheights <- rep(cheight, nrow(data))

  out <- list( dataset = data,
               col_keys = col_keys,
               colwidths = colwidths,
               rowheights = rowheights,
               spans = spans,
               styles = list(
                 cells = pr_cell_init, pars = pr_par_init,
                 text = pr_text_init, formats = pr_display_init
                 )
               )
  class( out ) <- "complex_tabpart"
  out
}

add_rows <- function(doc, rows, first = FALSE){
  UseMethod("add_rows")
}

#' @importFrom dplyr bind_rows
#' @importFrom utils tail
#' @importFrom utils head
add_rows.complex_tabpart <- function( x, rows, first = FALSE ){

  data <- x$dataset
  spans <- x$spans
  ncol <- length(x$col_keys)
  nrow <- nrow(rows)


  x$styles$cells$add_rows(nrow, first)
  x$styles$pars$add_rows(nrow, first)
  x$styles$text$add_rows(nrow, first)
  x$styles$formats$add_rows(nrow, first)


  span_new <- matrix( 1, ncol = ncol, nrow = nrow )
  rowheights <- x$rowheights


  if( !first ){
    data <- bind_rows(data, rows )
    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )
    rowheights <- c(rowheights, rep(0.6, nrow(rows)))
  } else {
    data <- bind_rows(rows, data )
    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )
    rowheights <- c(rep(0.6, nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
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

check_merge <- function(x){
  row_check <- all(rowSums(x$spans$rows) == ncol(x$spans$rows) )
  col_check <- all(colSums(x$spans$columns) == nrow(x$spans$columns) )

  if( !row_check || !col_check )
    stop("invalid merging instructions", call. = FALSE)
  x
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
  check_merge(x)
}

span_cells_at <- function( x, columns = NULL, rows = NULL ){

  if( is.null(columns) )
    columns <- x$col_keys
  if( is.null(rows) )
    rows <- get_rows_id( x, i = rows )

  stopifnot(all( columns %in% x$col_keys ) )

  row_id <- match(rows, seq_len(nrow(x$dataset)))
  col_id <- match(columns, x$col_keys)

  test_valid_r <- (length(row_id) > 1 && all( diff(row_id) == 1 )) || length(row_id) == 1
  test_valid_c <- (length(col_id) > 1 && all( diff(col_id) == 1 )) || length(col_id) == 1

  if( !test_valid_r )
    stop("selected rows should all be consecutive")
  if( !test_valid_c )
    stop("selected columns should all be consecutive")

  x$spans$columns[ row_id, col_id] <- 0
  x$spans$rows[ row_id, col_id] <- 0
  x$spans$columns[ row_id[1], col_id] <- length(row_id)
  x$spans$rows[ row_id, col_id[1]] <- length(col_id)

  check_merge(x)
}

span_rows <- function( x, rows = NULL ){
  row_id <- get_rows_id( x, i = rows )

  spans <- lapply( row_id,
                   function(k, x )
                     merge_index(x, what = k, byrow = TRUE ),
                   x = x )
  spans <- do.call( rbind, spans )
  x$spans$rows[match(row_id, seq_len(nrow(x$dataset))), ] <- spans

  check_merge(x)
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

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }

  if( is.numeric (j) ){

    if( all(j < 0 ) ){
      j <- setdiff(seq_along(x$col_keys), -j )
    }

    if( any( j < 1 | j > maxcol ) )
      stop("invalid columns selection: out of range 1:", maxcol )
  } else if( is.logical (j) ){
    if( length( j ) != maxcol ) stop("invalid columns selection: j should be of length ", maxcol)
    else j = which(j)

  } else if( is.character (j) ){
    j <- gsub("(^`|`$)", "", j)
    if( any( is.na( j ) ) ) stop("invalid columns selection: NA in selection")
    else if( !all( is.element(j, x$col_keys )) )
      stop("invalid columns selection:", paste(j[!is.element(j, x$col_keys )], collapse = ",") )
    else j = match(j, x$col_keys)
  } else stop("invalid columns selection: unknown selection type")

  j
}


get_rows_id <- function( x, i = NULL ){
  maxrow <- nrow(x$dataset)

  if( is.null(i) ) {
    i <- seq_len(maxrow)
  }
  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x$dataset)
  }

  if( is.numeric (i) ){

    if( all(i < 0 ) ){
      i <- setdiff(-i, seq_len(maxrow))
    }

    if( any( i < 1 | i > maxrow ) )
      stop("invalid row selection: out of range selection")

  } else if( is.logical (i) ){

    if( length( i ) != maxrow )
      stop("invalid row selection: length(i) [",length( i ),"] != nrow(dataset) [",maxrow,"]")
    else i = which(i)

  } else if( is.character (i) ){
    any( is.na( i ) )
    rn <- row.names(x$dataset)
    if( any( is.na( i ) ) )
      stop("invalid row selection: NA in selection")
    else if( !all( is.element(i, rn ) ) )
      stop("invalid row selection: unknown rownames")
    else i = match(i, rn )
  } else stop("invalid row selection: unknown selection type")

  i
}


set_formatting_properties <- function( x, i = NULL, j = NULL, value ){

  i <- get_rows_id(x = x, i = i)
  j <- get_columns_id(x = x, j = j)
  if( inherits(value, "fp_text" ) ){
    x$styles$text$set_fp(i = i, j = x$col_keys[j], fp = value )
  }
  if( inherits(value, "fp_par" ) ){
    x$styles$pars$set_fp(i = i, j = x$col_keys[j], fp = value )
  }
  if( inherits(value, "fp_cell" ) ){
    x$styles$cells$set_fp(i = i, j = x$col_keys[j], fp = value )
  }

  x
}


