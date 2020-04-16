html_str <- function( x, ... ){
  UseMethod("html_str")
}


html_str.flextable <- function( x, bookdown = FALSE ){

  dims <- dim(x)


  # out <- paste0("<table style='border-collapse:collapse;", sprintf("width:%s;", css_px(sum(dims$widths) * 72) ), "'>")
  out <- "<table style='border-collapse:collapse;'>"
  cap = x$caption$value
  if(!is.null(cap)){
    out <- paste0(
      out, if ( bookdown ) "<!--/html_preserve-->", "<caption>",
      if ( bookdown && !has_label(cap)) ref_label(),
      pandoc_chunks_html(x, bookdown),
      if ( bookdown ) "<!--html_preserve-->", "</caption>"
    )
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

