default_printers <- function(x){
  map(x$dataset[x$col_keys], function( x ) {
    if( is.character(x) ) htmlEscape
    else if( is.factor(x) ) function(x) htmlEscape(as.character(x))
    else function(x) gsub("(^ | $)+", "", htmlEscape(format(x)))
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

#' @importFrom dplyr bind_rows
#' @importFrom utils tail
#' @importFrom utils head
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



get_text_data <- function(x){
  mapped_data <- x$styles$text$get_map()
  txt_data <- map2_df(x$dataset[x$col_keys], x$printers, function(x, f) f(x))
  txt_data$id <- seq_len(nrow(txt_data))
  txt_data <- tidyr::gather_(txt_data, "col_key", "str", gather_cols = x$col_keys)
  txt_data <- left_join( mapped_data, txt_data, by = c("id", "col_key"))
  txt_data
}

#' @importFrom gdtools raster_write raster_str
format.simple_tabpart <- function( x, type = "wml", header = FALSE, ... ){
  stopifnot(length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html") )

  text_fp <- x$styles$text$get_fp()
  pr_str_df <- map_df(text_fp, function(x){
    tibble( format = format(x, type = type))
  }, .id = "pr_id")

  txt_data <- get_text_data(x)

  run_as_str <- list(
    wml = function(format, str) paste0("<w:r>", format, "<w:t xml:space=\"preserve\">", htmlEscape(str), "</w:t></w:r>"),
    pml = function(format, str) paste0("<a:r>", format, "<a:t>", htmlEscape(str), "</a:t></a:r>"),
    html = function(format, str) paste0("<span style=\"", format, "\">", htmlEscape(str), "</span>")
  )
  txt_data$str <- run_as_str[[type]](format = pr_str_df$format[match(txt_data$pr_id, pr_str_df$pr_id)],
                                     str = txt_data$str )
  txt_data$pr_id <- NULL

  par_data <- x$styles$pars$get_map_format(type = type)
  tidy_content <- txt_data %>%
    complete_(c("col_key", "id")) %>%
    inner_join(par_data, by = c("id", "col_key")) %>%
    mutate( str = par_fun[[type]](format, str) ) %>%
    drop_column("format")
  tidy_content$col_key <- factor(tidy_content$col_key, levels = x$col_keys)
  #dat$col_key <- factor(dat$col_key, levels = x$col_keys)
  paragraphs <- tidy_content %>% spread_("col_key", "str") %>%
    drop_column("id") %>% as.matrix()

  cell_data <- x$styles$cells$get_map_format(type = type)
  cell_data$col_key <- factor(cell_data$col_key, levels = x$col_keys)
  cell_format <- cell_data %>% spread_("col_key", "format") %>%
    drop_column("id") %>% as.matrix()

  cells <- cell_fun[[type]](str = paragraphs, format=cell_format,
                            span_rows = x$span$rows,
                            span_columns = x$spans$columns, x$colwidths)

  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- row_fun[[type]](x$rowheights, cells, header)
  out <- paste0(rows, collapse = "")
  out
}



