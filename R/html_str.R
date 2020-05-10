html_str <- function( x, ... ){
  UseMethod("html_str")
}

html_str.flextable <- function( x, bookdown = FALSE ){

  dims <- dim(x)
  tab_props <- opts_current_table()

  # caption str value ----
  bookdown_ref_label <- ref_label()
  if(!is.null(tab_props$id)){
    bookdown_ref_label <- paste0("(\\#tab:", tab_props$id, ")")
  }
  caption_label <- tab_props$cap
  if(!is.null(x$caption$value)){
    caption_label <- x$caption$value
  }
  caption <- ""
  if(!is.null(caption_label)){
    caption <- paste0(
      if ( bookdown ) "<!--/html_preserve-->",
      "<caption>",
      if(bookdown) bookdown_ref_label,
      caption_label,
      "</caption>",
      if ( bookdown ) "<!--html_preserve-->"
    )
  }

  # out <- paste0("<table style='border-collapse:collapse;", sprintf("width:%s;", css_px(sum(dims$widths) * 72) ), "'>")
  out <- "<table style='border-collapse:collapse;'>"
  out <- paste0(out, caption)

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

