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
format.complex_tabpart <- function( x, type = "wml", header = FALSE, ... ){
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
    txt_data <- rbind(txt_data, img_data)
  }


  text_fp <- x$styles$text$get_fp()
  text_fp <- append( text_fp, x$styles$formats$get_all_fp() )

  pr_str_df <- map_df(text_fp, function(x){
    tibble( format = format(x, type = type))
  }, .id = "pr_id")

  txt_data <- drop_useless_blank(txt_data)
  dat <- merge(txt_data, pr_str_df, by = "pr_id", all.x = TRUE, all.y = FALSE, sort = FALSE)
  dat <- dat[order(dat$col_key, dat$id, dat$pos),]

  dat$str <- run_fun[[type]](dat$format, dat$str, dat$str_is_run)

  group_ref_ <- group_ref(dat, c("id", "col_key"))
  str_ <- tapply(dat$str, group_index(dat, c("id", "col_key")), paste, collapse = "")
  str_ <- data.frame(index_ = names(str_), str = as.character(str_), stringsAsFactors = FALSE )
  dat <- merge( group_ref_, str_, by = "index_", all.x = TRUE, all.y = TRUE, sort = FALSE)
  dat$index_ <- NULL

  par_data <- x$styles$pars$get_map_format(type = type)

  tidy_content <- expand.grid(col_key = x$col_key,
                              id = seq_len(nrow(x$dataset)),
                              stringsAsFactors = FALSE)
  tidy_content <- merge(tidy_content, dat, by = c("col_key", "id"), all.x = TRUE, all.y = FALSE, sort = FALSE)
  tidy_content <- merge(tidy_content, par_data, by = c("id", "col_key"), all.x = TRUE, all.y = FALSE, sort = FALSE)
  tidy_content$str <- par_fun[[type]](tidy_content$format, tidy_content$str)
  tidy_content$format <- NULL
  # browser()
  paragraphs <- as_wide_matrix_(as.data.frame(tidy_content[, c("col_key", "str", "id")]))

  cell_data <- x$styles$cells$get_map_format(type = type)
  cell_data$col_key <- factor(cell_data$col_key, levels = x$col_keys)
  cell_format <- as_wide_matrix_(as.data.frame(cell_data[, c("col_key", "format", "id")]))

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

