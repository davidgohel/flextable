html_str <- function( x ){
  UseMethod("html_str")
}


html_str.flextable <- function( x ){

  dims <- dim(x)

  out <- "<table>"

  if( nrow_part(x, "header") > 0 ){
    x$header <- correct_h_border(x$header)
    x$header <- correct_v_border(x$header)
    tmp <- format(x$header, type = "html", header = TRUE)
    out = paste0(out, "<thead>", tmp, "</thead>" )
  }
  if( nrow_part(x, "body") > 0 ){
    x$body <- correct_h_border(x$body)
    x$body <- correct_v_border(x$body)
    tmp <- format(x$body, type = "html", header = FALSE)
    out = paste0(out, "<tbody>", tmp, "</tbody>" )
  }
  if( nrow_part(x, "footer") > 0 ){
    x$footer <- correct_h_border(x$footer)
    x$footer <- correct_v_border(x$footer)
    tmp <- format(x$footer, type = "html", header = FALSE)
    out = paste0(out, "<tfoot>", tmp, "</tfoot>" )
  }

  out = paste0(out,  "</table>" )
  out
}

