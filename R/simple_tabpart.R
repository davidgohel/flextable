default_printers <- function(x){
  lapply(x$dataset[x$col_keys], function( x ) {
    if( is.character(x) ) function(x) x
    else if( is.factor(x) ) function(x) as.character(x)
    else function(x) gsub("(^ | $)+", "", format(x))
  })
}


#' @importFrom officer fp_sign fp_cell fp_par fp_text

simple_tabpart <- function( data, col_keys = names(data),
                        default_pr_text = fp_text(),
                        default_pr_par = fp_par(),
                        default_pr_cell = fp_cell(),
                        cwidth = NULL, cheight = NULL ){

  stopifnot(is.data.frame(data))

  pr_cell_init <- fp_structure$new(nrow(data), col_keys, default_pr_cell )
  pr_par_init <- fp_structure$new(nrow(data), col_keys, default_pr_par )
  pr_text_init <- fp_structure$new(nrow(data), col_keys, default_pr_text )

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
                 text = pr_text_init
               )
  )
  class( out ) <- "simple_tabpart"
  out$printers <- default_printers(out)
  out
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
    data <- rbind(data, rows, stringsAsFactors = FALSE )
    spans$rows <- rbind( spans$rows, span_new )
    spans$columns <- rbind( spans$columns, span_new )
    rowheights <- c(rowheights, rep(0.6, nrow(rows)))
  } else {
    data <- rbind(rows, data, stringsAsFactors = FALSE)
    spans$rows <- rbind( span_new, spans$rows )
    spans$columns <- rbind( span_new, spans$columns )
    rowheights <- c(rep(0.6, nrow(rows)), rowheights)

  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x
}


#' @importFrom stats reshape
get_text_data <- function(x){
  mapped_data <- x$styles$text$get_map()
  txt_data <- mapply(function(x, f) f(x), x$dataset[x$col_keys], x$printers, SIMPLIFY = FALSE)
  txt_data <- do.call(cbind, txt_data)
  txt_data <- as.data.frame(txt_data, stringsAsFactors = FALSE )
  txt_data$id <- seq_len(nrow(txt_data))
  txt_data <- reshape(data = as.data.frame(txt_data, stringsAsFactors = FALSE),
          idvar = "id", new.row.names = NULL, timevar = "col_key",
          times = x$col_keys,
          varying = x$col_keys,
          v.names = "str", direction = "long")
  row.names(txt_data) <- NULL

  txt_data <- merge(mapped_data, txt_data, by = c("id", "col_key"),
                all.x = TRUE, all.y = FALSE, sort = FALSE )
  txt_data
}

#' @importFrom gdtools raster_write raster_str
format.simple_tabpart <- function( x, type = "wml", header = FALSE, ... ){
  stopifnot(length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html") )

  text_fp <- x$styles$text$get_fp()
  pr_str_format <- sapply(text_fp, format, type = type)
  txt_data <- get_text_data(x)

  run_as_str <- list(
    wml = function(format, str) paste0("<w:r>", format, "<w:t xml:space=\"preserve\">", htmlEscape(str), "</w:t></w:r>"),
    pml = function(format, str) paste0("<a:r>", format, "<a:t>", htmlEscape(str), "</a:t></a:r>"),
    html = function(format, str) paste0("<span style=\"", format, "\">", htmlEscape(str), "</span>")
  )
  txt_data$str <- run_as_str[[type]](format = pr_str_format[match(txt_data$pr_id, names(text_fp))],
                                     str = txt_data$str )
  txt_data$pr_id <- NULL

  par_data <- x$styles$pars$get_map_format(type = type)

  tidy_content <- expand.grid(col_key = x$col_key,
                              id = seq_len(nrow(x$dataset)),
                              stringsAsFactors = FALSE)
  tidy_content <- merge(tidy_content, txt_data, by = c("col_key", "id"), all.x = TRUE, all.y = FALSE, sort = FALSE)
  tidy_content <- merge(tidy_content, par_data, by = c("id", "col_key"),
                        all.x = FALSE, all.y = FALSE, sort = FALSE)
  tidy_content$str <- par_fun[[type]](tidy_content$format, tidy_content$str)
  tidy_content$format <- NULL

  tidy_content$col_key <- factor(tidy_content$col_key, levels = x$col_keys)
  paragraphs <- as_wide_matrix_(as.data.frame(tidy_content[, c("col_key", "str", "id")]))

  cell_data <- x$styles$cells$get_map_format(type = type)
  cell_data$col_key <- factor(cell_data$col_key, levels = x$col_keys)
  cell_format <- as_wide_matrix_(as.data.frame(cell_data[, c("col_key", "format", "id")]))

  cells <- cell_fun[[type]](str = paragraphs, format=cell_format,
                            span_rows = x$span$rows,
                            span_columns = x$spans$columns, x$colwidths)

  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- row_fun[[type]](x$rowheights, cells, header)
  out <- paste0(rows, collapse = "")
  out
}



