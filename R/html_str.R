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

  fixed_layout <- x$properties$layout %in% "fixed"
  if(!fixed_layout){
    tbl_width <- paste0("width:", formatC(x$properties$width*100), "%;")
    tabcss <- paste0("table-layout:auto;border-collapse:collapse;", tbl_width)
  } else {
    tabcss <- "border-collapse:collapse;"
  }

  out <- sprintf("<table style='%s'>", tabcss)
  out <- paste0(out, caption)

  codes <- html_chunks(x)

  out <- paste0(out, codes$html)

  out = paste0(out,  "</table>" )

  paste0("<style>", codes$css, "</style>", out)
}

