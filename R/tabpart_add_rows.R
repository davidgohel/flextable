add_rows <- function(doc, rows, first = FALSE){
  UseMethod("add_rows")
}

#' @importFrom utils tail head
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
    data <- rbind(data, rows )
    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )
    rowheights <- c(rowheights, rep(0.6, nrow(rows)))
  } else {
    data <- rbind(rows, data )
    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )
    rowheights <- c(rep(0.6, nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x
}

add_rows.simple_tabpart <- function( x, rows, first = FALSE ){

  data <- x$dataset
  spans <- x$spans
  ncol <- length(x$col_keys)
  nrow <- nrow(rows)


  x$styles$cells$add_rows(nrow, first)
  x$styles$pars$add_rows(nrow, first)
  x$styles$text$add_rows(nrow, first)

  span_new <- matrix( 1, ncol = ncol, nrow = nrow )
  rowheights <- x$rowheights

  if( !first ){
    data <- rbind(data, rows )
    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )
    rowheights <- c(rowheights, rep(0.6, nrow(rows)))
  } else {
    data <- rbind(rows, data)
    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )
    rowheights <- c(rep(0.6, nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x
}
