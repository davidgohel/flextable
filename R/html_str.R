html_str <- function( x ){
  UseMethod("html_str")
}


html_str.flextable <- function( x ){

  dims <- dim(x)

  out <- "<table style='border-collapse:collapse;'>"
  if(!is.null(x$caption$value)){
    out <- paste0(out, "<caption>", htmlEscape(x$caption$value), "</caption>" )
  }

  if( nrow_part(x, "header") > 0 ){
    tmp <- format(x$header, type = "html", header = TRUE)
    out = paste0(out, "<thead>", tmp, "</thead>" )
  }
  if( nrow_part(x, "body") > 0 ){
    tmp <- format(x$body, type = "html", header = FALSE)
    out = paste0(out, "<tbody>", tmp, "</tbody>" )
  }
  if( nrow_part(x, "footer") > 0 ){
    tmp <- format(x$footer, type = "html", header = FALSE)
    out = paste0(out, "<tfoot>", tmp, "</tfoot>" )
  }

  out = paste0(out,  "</table>" )
  out
}

