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


#' @importFrom stats as.formula
#' @importFrom officer fp_sign fp_cell fp_par fp_text
complex_tabpart <- function( data, col_keys = names(data),
                             default_pr_text = fp_text(),
                             default_pr_par = fp_par(),
                             default_pr_cell = fp_cell(),
                             cwidth = NULL, cheight = NULL ){


  pr_cell_init <- fp_structure$new(nrow(data), col_keys, default_pr_cell )
  pr_par_init <- fp_structure$new(nrow(data), col_keys, default_pr_par )
  pr_text_init <- fp_structure$new(nrow(data), col_keys, default_pr_text )

  set_formatter_type_formals <- formals(set_formatter_type)
  formatters <- mapply(function(x, varname){
    if( is.double(x) ) paste0(varname, " ~ sprintf(", shQuote(set_formatter_type_formals$fmt_double), ", `", varname ,"`)")
    else if( is.integer(x) ) paste0(varname, " ~ sprintf(", shQuote(set_formatter_type_formals$fmt_integer), ", `", varname ,"`)")
    else if( is.factor(x) ) paste0(varname, " ~ as.character(`", varname ,"`)")
    else if( is.character(x) ) paste0(varname, " ~ as.character(`", varname ,"`)")
    else if( inherits(x, "Date") ) paste0(varname, " ~ format(`", varname ,"`, ", shQuote(set_formatter_type_formals$fmt_date), ")")
    else if( inherits(x, "POSIXt") ) paste0(varname, " ~ format(`", varname ,"`, ", shQuote(set_formatter_type_formals$fmt_datetime), ")")
    else paste0(varname, " ~ ", set_formatter_type_formals$fun_any, "(`", varname ,"`)")
  }, data[col_keys], col_keys, SIMPLIFY = FALSE)
  formatters <- mapply(function(f, varname){
    display_parser$new(x = paste0("{{", varname, "}}"),
                       formatters = list( as.formula( f ) ),
                       fprops = list() )
  }, formatters, col_keys )


  pr_display_init <- display_structure$new(nrow(data), col_keys, formatters )

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






