default_printers <- function(x){
  lapply(x$dataset[x$col_keys], function( x ) {
    if( is.character(x) ) function(x) {
      x[is.na(x)] <- ""
      x
    }
    else if( is.factor(x) ) function(x){
      x <- as.character(x)
      x[is.na(x)] <- ""
      x
    }
    else function(x) {
      x <- gsub("(^ | $)+", "", format(x))
      x[is.na(x)] <- ""
      x
    }
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

  pr_display_init <- create_display(data[col_keys], col_keys)

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






