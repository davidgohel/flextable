#' @importFrom purrr pmap_chr
get_cell_styles_m <- function(x, type){
  datalist <- list(
    ref = as.character(x$styles$cells),
    cspan = as.integer(x$spans$columns),
    rspan = as.integer(x$spans$rows)
  )
  get_xml <- function( ref, cspan, rspan, styles){
    pr_cell_ <- styles[[ref]]
    pr_cell_$row_span <- rspan
    pr_cell_$column_span <- cspan
    format(pr_cell_, type = type )
  }
  cell_styles <- pmap_chr(datalist, get_xml, styles = x$style_ref_table$cells )
  cell_styles <- matrix( cell_styles, ncol = length(x$col_keys) )

  cell_styles
}




format_tp_wml <- function(x, header = TRUE, rids ){
  cell_styles <- get_cell_styles_m( x, type = "wml" )

  runs <- cot_to_matrix(x, type = "wml")
  imgs <- attr( runs, "imgs" )
  runs <- paste0("<w:tc>", cell_styles, runs, "</w:tc>")
  runs[x$spans$rows < 1] <- ""

  runs <- matrix(runs, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  runs <- apply(runs, 1, paste0, collapse = "")
  runs <- paste0( "<w:tr><w:trPr>",
                  "<w:trHeight w:val=",
                    shQuote( round(x$rowheights * 72*20, 0 ), type = "cmd"), "/>",
                  ifelse( header, "<w:tblHeader/>", ""),
                  "</w:trPr>",
                  runs,
                  "</w:tr>")
  runs <- paste0(runs, collapse = "")
  attr( runs, "imgs" ) <- imgs
  runs
}

format_tp_pml <- function(x, header = TRUE){
  cell_styles <- get_cell_styles_m( x, type = "pml" )
  paragraphs <- cot_to_matrix(x, type = "pml")
  tc_attr_1 <- ifelse(x$spans$rows == 1, "",
                      ifelse(x$spans$rows > 1, paste0(" gridSpan=\"", x$spans$rows,"\""), " hMerge=\"true\"")
  )
  tc_attr_2 <- ifelse(x$spans$columns == 1, "",
                      ifelse(x$spans$columns > 1, paste0(" rowSpan=\"", x$spans$columns,"\""), " vMerge=\"true\"")
  )
  tc_attr <- paste0(tc_attr_1, tc_attr_2)
  cells <- paste0("<a:tc", tc_attr,">",
                  paste0( "<a:txBody><a:bodyPr/><a:lstStyle/>",
                          paragraphs, "</a:txBody>" ),
                  cell_styles, "</a:tc>")
  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- paste0( "<a:tr h=\"", round(x$rowheights * 914400, 0 ), "\">",
                  cells,
                  "</a:tr>")
  paste0(rows, collapse = "")
}

format_tp_html <- function(x, header = TRUE){
  paragraphs <- cot_to_matrix(x, type = "html")
  tc_attr_1 <- ifelse(x$spans$rows > 1, paste0(" colspan=\"", x$spans$rows,"\""), "")
  tc_attr_2 <- ifelse(x$spans$columns > 1, paste0(" rowspan=\"", x$spans$columns,"\""), "")
  tc_attr <- paste0(tc_attr_1, tc_attr_2)

  rowheights <- rep( round(x$rowheights * 72, 0 ),
       length( x$col_keys ) )

  if(header) tag <- "th"
  else tag <- "td"

  cells <- paste0("<", tag, tc_attr," class=\"c", x$styles$cells, "\" style=\"height:",
                  rowheights,"pt;\">",
                  ifelse(x$spans$rows < 1 | x$spans$columns < 1, "",
                         paragraphs),
                  "</", tag, ">")

  cells[x$spans$rows < 1 | x$spans$columns < 1] <- ""
  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- paste0( "<tr>", cells, "</tr>")
  paste0(rows, collapse = "")
}

#' @importFrom purrr map_chr
format_tp_css <- function(x, header = TRUE){
  cells_ <- map_chr(x$style_ref_table$cells, format, type = "html")

  btlrcss <- ""
  which_rotate <- map_chr(x$style_ref_table$cells, "text.direction") == "btlr"
  if( any(which_rotate) ){
    cellclass_ <- names(cells_)[which_rotate]
    btlrcss <- '{-moz-transform:rotate(-90deg);-webkit-transform: rotate(-90deg);-o-transform: rotate(-90deg);position:relative;}'
    btlrcss <- rep(btlrcss, sum(which_rotate))
    btlrcss <- paste0(".c", cellclass_, " > p", btlrcss, collapse = "")
  }
  tbrlcss <- ""
  which_rotate <- map_chr(x$style_ref_table$cells, "text.direction") == "tbrl"
  if( any(which_rotate) ){
    cellclass_ <- names(cells_)[which_rotate]
    tbrlcss <- '{-moz-transform:rotate(-270deg);-webkit-transform: rotate(-270deg);-o-transform: rotate(-270deg);position:relative;}'
    tbrlcss <- rep(tbrlcss, sum(which_rotate))
    tbrlcss <- paste0(".c", cellclass_, " > p", tbrlcss, collapse = "")
  }
  css_ <- paste0(".c", names(cells_), "{", cells_, "}", collapse = "")

  paste0( css_, btlrcss, tbrlcss )
}


#' @importFrom purrr pmap_chr
format.table_part <- function( x, type = "wml", header = FALSE, ... ){
  stopifnot(length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html") )

  if( type == "wml" ){
    out <- format_tp_wml(x, header = header )
  } else if( type == "pml" ){
    out <- format_tp_pml(x, header = header )
  } else if( type == "html" ){
    css <- format_tp_css(x )
    out <- format_tp_html(x, header = header )

    attr(out, "css") <- css
  }
  out
}

