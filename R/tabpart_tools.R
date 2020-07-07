merge_rle <- function( values ){
  rle_ <- rle(x = values )

  vout <- lapply(rle_$lengths, function(l){
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
span_columns <- function( x, columns = NULL, target = columns){

  stopifnot(all( columns %in% colnames(x$dataset) ) )
  stopifnot(all( target %in% x$col_keys ) )

  if( length(target) == 1 ){
    target <- rep(target, length(columns))
  }
  if( length(columns) == 1 ){
    columns <- rep(columns, length(target))
  }

  for(k in seq_along(columns)){
    column <- columns[k]
    if(column %in% x$col_keys){
      values <- sapply(x$content[,columns[k]], function(x) {
        paste(x$txt, collapse = "")
      })
    } else {
      values <- format(x$dataset[[column]], trim = TRUE, justify = "left")
    }
    x$spans$columns[, match(target[k], x$col_keys)] <- merge_rle(values)
  }

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

  for( rowi in row_id){
    values <- sapply(x$content[rowi,], function(x) {
      paste(x$txt, collapse = "")
    })
    x$spans$rows[rowi, ] <- merge_rle(values)
  }

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
    j <- get_j_from_formula(j, x$dataset)
  }

  if( is.numeric (j) ){
    if( length(j)>0 && all(j < 0 ) ){
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

get_dataset_columns_id <- function( x, j = NULL ){
  maxcol <- ncol(x$dataset)

  if( is.null(j) ) {
    j <- seq_len(maxcol)
  }

  if( inherits(j, "formula") ){
    j <- get_j_from_formula(j, x$dataset)
  }

  if( is.numeric (j) ){

    if( all(j < 0 ) ){
      j <- setdiff(seq_along(x$dataset), -j )
    }

    if( any( j < 1 | j > maxcol ) )
      stop("invalid columns selection: out of range 1:", maxcol )
  } else if( is.logical (j) ){
    if( length( j ) != maxcol ) stop("invalid columns selection: j should be of length ", maxcol)
    else j = which(j)

  } else if( is.character (j) ){
    j <- gsub("(^`|`$)", "", j)
    if( any( is.na( j ) ) ) stop("invalid columns selection: NA in selection")
    else if( !all( is.element(j, colnames(x$dataset) )) )
      stop("invalid columns selection:", paste(j[!is.element(j, colnames(x$dataset) )], collapse = ",") )
    else j = match(j, colnames(x$dataset))
  } else stop("invalid columns selection: unknown selection type")

  j
}


get_rows_id <- function( x, i = NULL ){
  maxrow <- nrow(x$dataset)

  if( is.null(i) ) {
    i <- seq_len(maxrow)
  }
  if( inherits(i, "formula") ){
    i <- get_i_from_formula(i, x$dataset)
  }

  if( is.numeric (i) ){
    if( length(i)>0 && all(i < 0 ) ){
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



