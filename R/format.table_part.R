#' @importFrom htmltools htmlEscape
run_fun <- list(
  wml = function(format, str, str_is_run) ifelse( str_is_run, str, paste0("<w:r>", format, "<w:t xml:space=\"preserve\">", htmlEscape(str), "</w:t></w:r>") ),
  pml = function(format, str, str_is_run) ifelse( str_is_run, str, paste0("<a:r>", format, "<a:t>", htmlEscape(str), "</a:t></a:r>") ),
  html = function(format, str, str_is_run) ifelse( str_is_run, str, paste0("<span style=\"", format, "\">", htmlEscape(str), "</span>") )
)
par_fun <- list(
  wml = function(format, str) paste0("<w:p>", format, str, "</w:p>"),
  pml = function(format, str) paste0("<a:p>", format, str, "</a:p>"),
  html = function(format, str) paste0("<p style=\"", format, "\">", str, "</p>")
)

cell_fun <- list(
  wml = function(str, format, span_rows, span_columns, colwidths){
    format <- str_replace_all(format, "<w:tcPr>",
         ifelse(span_rows > 1,
                paste0("<w:tcPr><w:gridSpan w:val=\"", span_rows, "\"/>"),
                "<w:tcPr>"
                ) )
    format <- str_replace_all(format, "<w:tcPr>",
         ifelse(span_columns > 1,
                "<w:tcPr><w:vMerge w:val=\"restart\"/>",
                ifelse(span_columns < 1,
                       "<w:tcPr><w:vMerge/>",
                        "<w:tcPr>" )
         ) )

    str <- paste0("<w:tc>", format, str, "</w:tc>")

    str[span_rows < 1] <- ""
    str
  },
  pml = function(str, format, span_rows, span_columns, colwidths){
    tc_attr_1 <- ifelse(
      span_rows == 1, "",
      ifelse(span_rows > 1,
             paste0(" gridSpan=\"", span_rows,"\""), " hMerge=\"true\"")
      )

    tc_attr_2 <- ifelse(
      span_columns == 1, "",
      ifelse(span_columns > 1, paste0(" rowSpan=\"", span_columns,"\""), " vMerge=\"true\"")
      )

    tc_attr <- paste0(tc_attr_1, tc_attr_2)

    paste0("<a:tc", tc_attr,">",
                    paste0( "<a:txBody><a:bodyPr/><a:lstStyle/>",
                            str, "</a:txBody>" ),
                    format, "</a:tc>")
  },
  html = function(str, format, span_rows, span_columns, colwidths){
    colwidths <- matrix( rep(colwidths, each = dim(str)[1]), nrow = dim(str)[1])
    tc_attr_1 <- ifelse(span_rows > 1, paste0(" colspan=\"", span_rows,"\""), "")
    tc_attr_2 <- ifelse(span_columns > 1, paste0(" rowspan=\"", span_columns,"\""), "")
    tc_attr <- paste0(tc_attr_1, tc_attr_2)
    str <- paste0("<td", tc_attr, " style=\"", sprintf("width:%.0fpx;", colwidths*72), format ,"\">", str, "</td>")
    str[span_rows < 1 | span_columns < 1] <- ""
    str
  } )

# row_fun ----
row_fun <- list(
  wml = function(rowheights, str, header)
    paste0( "<w:tr><w:trPr><w:trHeight w:val=",
            shQuote( round(rowheights * 72*20, 0 ), type = "cmd"), "/>",
            ifelse( header, "<w:tblHeader/>", ""),
            "</w:trPr>", str, "</w:tr>"),
  pml = function(rowheights, str, header)
    paste0( "<a:tr h=\"", round(rowheights * 914400, 0 ), "\">",
            str, "</a:tr>"),
  html = function(rowheights, str, header) {
    str <- str_replace_all(str, pattern = "<td style=\"",
                    replacement = paste0("<td style=\"height:",
                                         round(72*rowheights), "px;"))

    paste0("<tr>", str, "</tr>")
  }
)

#' @importFrom gdtools raster_write raster_str
format.table_part <- function( x, type = "wml", header = FALSE, ... ){
  stopifnot(length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html") )

  txt_data <- x$styles$formats$get_map(x$styles$text, x$dataset)
  txt_data$str_is_run <- rep(FALSE, nrow(txt_data))
  img_data <- txt_data[txt_data$type_out %in% "image",]
  txt_data <- txt_data[txt_data$type_out %in% "text",]
  if( nrow( img_data ) && type %in% c("wml", "html") ){
    img_data$str_is_run <- rep(TRUE, nrow(img_data))
    as_img <- img_data[, c("image_src", "width", "height")]
    class(as_img) <- c("image_entry", class(as_img))
    img_data$str <- format(as_img, type = type)
    txt_data <- bind_rows(txt_data, img_data)
  }
  txt_data <- txt_data[order(txt_data$col_key, txt_data$id, txt_data$pos),]


  text_fp <- x$styles$text$get_fp()
  text_fp <- append( text_fp, x$styles$formats$get_all_fp() )

  pr_str_df <- map_df(text_fp, function(x){
    tibble( format = format(x, type = type))
  }, .id = "pr_id")

  txt_data <- txt_data %>% group_by(!!!syms(c("col_key", "id")) ) %>% do({
    non_empty <- which( .$str != "" | .$type_out %in% "image_entry" )
    if(length(non_empty)) .[non_empty,]
    else .[1,]
  })

  dat <- txt_data %>% ungroup() %>%
    inner_join(pr_str_df, by = "pr_id") %>%
    mutate( str = run_fun[[type]](format, str, str_is_run) ) %>%
    group_by(!!!syms(c("col_key", "id"))) %>%
    summarise(str = paste(str, collapse = "") ) %>%
    ungroup()

  par_data <- x$styles$pars$get_map_format(type = type)
  par_data$col_key <- factor(par_data$col_key, levels = x$col_keys)
  dat$col_key <- factor(dat$col_key, levels = x$col_keys)
  tidy_content <- dat %>%
    complete_(c("col_key", "id")) %>%
    inner_join(par_data, by = c("id", "col_key")) %>%
    mutate( str = par_fun[[type]](format, str) ) %>%
    drop_column("format")
  paragraphs <- tidy_content %>% spread_("col_key", "str") %>%
    drop_column("id") %>% as.matrix()

  cell_data <- x$styles$cells$get_map_format(type = type)
  cell_data$col_key <- factor(cell_data$col_key, levels = x$col_keys)
  cell_format <- cell_data %>% spread_("col_key", "format") %>%
    drop_column("id") %>% as.matrix()

  cells <- cell_fun[[type]](str = paragraphs, format=cell_format,
                   span_rows = x$span$rows,
                   span_columns = x$spans$columns, x$colwidths)

  cells <- matrix(cells, ncol = length(x$col_keys), nrow = nrow(x$dataset) )
  cells <- apply(cells, 1, paste0, collapse = "")
  rows <- row_fun[[type]](x$rowheights, cells, header)
  out <- paste0(rows, collapse = "")

  attr(out, "imgs") <- as.data.frame(img_data)
  out
}

