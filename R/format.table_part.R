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


get_paragraph_at <- function(x, i, j){
  fid <- x$styles$formats[i, j]
  args <- x$style_ref_table$formats[[fid]]

  args_update <- list()
  pr_par_ <- x$style_ref_table$pars[[x$styles$pars[i,j]]]
  args_update[["fp_p"]] <- pr_par_
  pr_text_ <- x$style_ref_table$text[[x$styles$text[i,j]]]
  args_update[["fp_t"]] <- pr_text_

  if( x$spans$columns[i,j] > 0 && x$spans$rows[i,j] > 0 ){
    p <- lazy_eval(args, x$dataset[i,, drop = FALSE])
  } else p <- fpar()

  args_update$object <- p
  p <- do.call(update, args_update)

  p
}




format_as_paragraph <- function(x, type = "pml"){
  text <- matrix("", ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  dimnames(text) <- list( NULL, x$col_keys)

  col_id <- setNames(seq_along(x$col_keys), nm = x$col_keys )
  imgs <- character(0)
  for(j in x$col_keys){
    for( i in seq_len(nrow(x$dataset))){

      p <- get_paragraph_at(x, i, col_id[j])
      imgs <- append( imgs, get_imgs(p) )
      text[i, j] <- format(p, type = type)
    }
  }
  attr( text, "imgs" ) <- unique(imgs)
  text
}


format_tp_wml <- function(x, header = TRUE, rids ){
  cell_styles <- get_cell_styles_m( x, type = "wml" )

  runs <- format_as_paragraph(x, type = "wml")
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
  paragraphs <- format_as_paragraph(x, type = "pml")
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
  paragraphs <- format_as_paragraph(x, type = "html")
  tc_attr_1 <- ifelse(x$spans$rows > 1, paste0(" colspan=\"", x$spans$rows,"\""), "")
  tc_attr_2 <- ifelse(x$spans$columns > 1, paste0(" rowspan=\"", x$spans$columns,"\""), "")
  tc_attr <- paste0(tc_attr_1, tc_attr_2)

  if(header)
    tag <- "th"
  else tag <- "td"
  cells <- paste0("<", tag, tc_attr," class=\"c", x$styles$cells, "\">",
                  ifelse(x$spans$rows < 1 | x$spans$columns < 1, "", paragraphs),
                  "</", tag, ">")

  cells[x$spans$rows < 1 | x$spans$columns < 1] <- ""
  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- paste0( "<tr>", cells, "</tr>")
  paste0(rows, collapse = "")
}

#' @importFrom purrr map_chr
format_tp_css <- function(x, header = TRUE){
  text_ <- map_chr(x$style_ref_table$text, format, type = "html")
  pars_ <- map_chr(x$style_ref_table$pars, format, type = "html")
  cells_ <- map_chr(x$style_ref_table$cells, format, type = "html")

  text_ <- paste0(".t", names(text_), "{", text_, "}", collapse = "")
  pars_ <- paste0(".p", names(pars_), "{", pars_, "}", collapse = "")
  cells_ <- paste0(".c", names(cells_), "{", cells_, "}", collapse = "")

  cells_
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

