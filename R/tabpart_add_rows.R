#' @importFrom utils head
add_rows.complex_tabpart <- function( x, rows, first = FALSE ){

  data <- x$dataset
  spans <- x$spans
  ncol <- length(x$col_keys)
  nrow <- nrow(rows)

  x$styles$cells <- add_rows(x$styles$cells, nrows = nrow, first = first)
  x$styles$pars <- add_rows(x$styles$pars, nrows = nrow, first = first)
  x$styles$text <- add_rows(x$styles$text, nrows = nrow, first = first)
  x$content <- add_rows(x$content, nrows = nrow, first = first, rows)

  span_new <- matrix( 1, ncol = ncol, nrow = nrow )
  rowheights <- x$rowheights

  if( !first ){
    data <- rbind(data, rows )
    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )
    rowheights <- c(rowheights, rep(rev(rowheights)[1], nrow(rows)))
  } else {
    data <- rbind(rows, data )
    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )
    rowheights <- c(rep(rowheights[1], nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x
}

