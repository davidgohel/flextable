#' @importFrom officer fp_sign fp_cell fp_par fp_text fp_border
complex_tabpart <- function( data, col_keys = names(data),
                             default_pr_text = fp_text(),
                             default_pr_par = fp_par(),
                             default_pr_cell = fp_cell(border = fp_border(color = "transparent")),
                             cwidth = NULL, cheight = NULL ){

  pr_cell_init <- as_struct(nrow(data), col_keys, default_pr_cell, cell_struct)
  pr_par_init <- as_struct(nrow(data), col_keys, default_pr_par, par_struct)
  pr_text_init <- as_struct(nrow(data), col_keys, default_pr_text, text_struct)

  content <- chunkset_struct(nrow = nrow(data), keys = col_keys)
  if( nrow(data) > 0 ){

    newcontent <- lapply(data[col_keys], function(x)
      as_paragraph(as_chunk(x, formater = function(x) {
        if( is.character(x) || is.factor(x) ) format_fun(x)
        else format(x, trim = TRUE)

      } ) ) )
    content$content[,col_keys] <- Reduce(append, newcontent)
  }

  span_init <- matrix(1L, nrow = nrow(data), ncol = length(col_keys) )
  spans <- list( rows = span_init, columns = span_init )

  if( length(cwidth) == length(col_keys) )
    colwidths <- cwidth
  else colwidths <- rep(cwidth, length(col_keys))

  rowheights <- rep(cheight, nrow(data))

  out <- list( dataset = data,
               content = content,
               col_keys = col_keys,
               colwidths = colwidths,
               rowheights = rowheights,
               hrule = rep("exact", nrow(data)),
               spans = spans,
               styles = list(
                 cells = pr_cell_init, pars = pr_par_init,
                 text = pr_text_init
               )
  )
  class( out ) <- "complex_tabpart"
  out
}

