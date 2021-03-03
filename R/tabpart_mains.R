#' @importFrom officer fp_cell fp_par fp_text fp_border
complex_tabpart <- function( data, col_keys = names(data),
                             default_pr_text = fp_text(
                               font.family = flextable_global$defaults$font.family,
                               cs.family = flextable_global$defaults$cs.family,
                               eastasia.family = flextable_global$defaults$eastasia.family,
                               hansi.family = flextable_global$defaults$hansi.family,
                               font.size = flextable_global$defaults$font.size,
                               color = flextable_global$defaults$font.color
                             ),
                             default_pr_par = fp_par(
                               text.align = flextable_global$defaults$text.align,
                               padding.left = flextable_global$defaults$padding.left,
                               padding.right = flextable_global$defaults$padding.right,
                               padding.bottom = flextable_global$defaults$padding.bottom,
                               padding.top = flextable_global$defaults$padding.top
                             ),
                             default_pr_cell = fp_cell(
                               background.color = flextable_global$defaults$background.color,
                               border = fp_border(color = "transparent", width = 0)
                             ),
                             cwidth = NULL, cheight = NULL ){

  pr_cell_init <- as_struct(nrow(data), col_keys, default_pr_cell, cell_struct)
  pr_par_init <- as_struct(nrow(data), col_keys, default_pr_par, par_struct)
  pr_text_init <- as_struct(nrow(data), col_keys, default_pr_text, text_struct)

  content <- chunkset_struct(nrow = nrow(data), keys = col_keys)
  if( nrow(data) > 0 ){
    newcontent <- lapply(
      data[col_keys],
      function(x) {
        as_paragraph(as_chunk(x, formatter = format_fun.default) )
      })
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
               hrule = rep("auto", nrow(data)),
               spans = spans,
               styles = list(
                 cells = pr_cell_init, pars = pr_par_init,
                 text = pr_text_init
               )
  )
  class( out ) <- "complex_tabpart"
  out
}

