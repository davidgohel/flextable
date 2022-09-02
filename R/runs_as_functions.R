runs_as_html <- function(x, chunk_data = as_table_text(x)) {

  # data can be (1.) from a df computed by as_table_text
  # or (2.) a single paragraph from x$caption$value and there will be only seq_index
  order_columns <-
    intersect(x = colnames(chunk_data),
              y = c("part", "ft_row_id", "col_id", "seq_index"))

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(chunk_data), c("part", "ft_row_id", "col_id"))
  if(length(by_columns) < 1) by_columns <- NULL

  data_ref_text <- part_style_list(chunk_data, fun = fp_text_default)

  spans_dataset <- as.data.table(chunk_data)
  spans_dataset <- merge(spans_dataset, data_ref_text,
                         by = intersect(colnames(data_ref_text), colnames(chunk_data)))

  span_style_str <- text_css_styles(data_ref_text)

  is_soft_return <- spans_dataset$txt %in% "<br>"
  is_tab <- spans_dataset$txt %in% "<tab>"
  is_eq <- !is.na(spans_dataset$eq_data)
  is_hlink <- !is.na(spans_dataset$url)
  is_raster <- sapply(spans_dataset$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  # manage raster
  spans_dataset[is_raster==TRUE, c("txt") := list(img_as_html(img_data = .SD$img_data, width = .SD$width, height = .SD$height))]
  # manage txt
  spans_dataset[is_raster==FALSE, c("txt") := list(sprintf("<span class=\"%s\">%s</span>", .SD$classname, htmlize(.SD$txt)))]
  spans_dataset[is_soft_return==TRUE, c("txt") := list("<br>")]
  spans_dataset[is_tab==TRUE, c("txt") := list("&emsp;")]

  if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    spans_dataset[is_eq==TRUE, c("txt") := list(
      sprintf("<span class=\"%s\">%s</span>", .SD$classname, transform_mathjax(.SD$eq_data, to = "html"))
    )]
    katex_link <- "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://cdn.jsdelivr.net/npm/katex@0.15.2/dist/katex.min.css\" data-external=\"1\">"
    spans_dataset[which(is_eq==TRUE)[1], c("txt") := list(paste0(katex_link, .SD$txt))]
  }

  # manage hlinks
  spans_dataset[is_hlink==TRUE, c("txt") := list(paste0("<a href=\"", .SD$url, "\">", .SD$txt, "</a>"))]

  setorderv(spans_dataset, cols = order_columns)
  spans_dataset <- spans_dataset[, list(span_tag = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(spans_dataset, cols = by_columns)

  setDF(spans_dataset)
  attr(spans_dataset, "css") <- span_style_str
  spans_dataset
}
runs_as_text <- function(x, chunk_data = as_table_text(x)) {

  # data can be (1.) from a df computed by as_table_text
  # or (2.) a single paragraph from x$caption$value and there will be only seq_index
  order_columns <-
    intersect(x = colnames(chunk_data),
              y = c("part", "ft_row_id", "col_id", "seq_index"))

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(chunk_data), c("part", "ft_row_id", "col_id"))
  if(length(by_columns) < 1) by_columns <- NULL

  spans_dataset <- as.data.table(chunk_data)

  is_soft_return <- spans_dataset$txt %in% "<br>"
  is_tab <- spans_dataset$txt %in% "<tab>"
  is_eq <- !is.na(spans_dataset$eq_data)
  is_hlink <- !is.na(spans_dataset$url)
  is_raster <- sapply(spans_dataset$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  # manage raster
  spans_dataset[is_raster==TRUE, c("txt") := list("")]
  spans_dataset[is_soft_return==TRUE, c("txt") := list("\n")]
  spans_dataset[is_tab==TRUE, c("txt") := list("\t")]
  spans_dataset[which(is_eq==TRUE), c("txt") := list(paste("$", .SD$eq_data, "$"))]

  setorderv(spans_dataset, cols = order_columns)
  spans_dataset <- spans_dataset[, list(span_txt = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(spans_dataset, cols = by_columns)

  setDF(spans_dataset)
  spans_dataset
}

#' @importFrom data.table setkeyv
runs_as_latex <- function(x, chunk_data = as_table_text(x), ls_df = NULL) {
  txt_data <- chunk_data

  # data can be (1.) from a df computed by as_table_text
  # or (2.) a single paragraph from x$caption$value and there will be only seq_index
  order_columns <-
    intersect(x = colnames(txt_data),
              y = c("part", "ft_row_id", "col_id", "seq_index"))

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(txt_data), c("part", "ft_row_id", "col_id"))
  if(length(by_columns) < 1) by_columns <- NULL

  setDT(txt_data)

  if ("col_id" %in% colnames(txt_data)) {
    txt_data$col_id <- factor(txt_data$col_id, levels = x$col_keys)
  }

  if (!is.null(ls_df) &&
      all(c("part", "ft_row_id", "col_id") %in% colnames(txt_data))) {
    txt_data <- merge(txt_data, ls_df, by = c("part", "ft_row_id", "col_id"))
  } else {
    txt_data$line_spacing <- 1.2
  }

  data_ref_text <- part_style_list(as.data.frame(txt_data),
                                   fun = function(color = "black",
                                                  font.size = 10,
                                                  bold = FALSE,
                                                  italic = FALSE,
                                                  underlined = FALSE,
                                                  font.family = "Arial",
                                                  vertical.align = "baseline",
                                                  shading.color = "transparent",
                                                  line_spacing = 2) {}
  )


  txt_data <- merge(
    x = txt_data,
    y = data_ref_text,
    by = intersect(colnames(data_ref_text), colnames(txt_data))
  )

  span_latexstyle_lr <- as_table_latexstyle_lr(data_ref_text)

  dat <- merge(txt_data, span_latexstyle_lr, by = "classname" )
  setkeyv(dat, cols = NULL)

  dat[, c("txt") := list(sanitize_latex_str(.SD$txt))]

  is_soft_return <- dat$txt %in% "<br>"
  is_tab <- dat$txt %in% "<tab>"
  is_eq <- !is.na(dat$eq_data)
  dat[is_eq == TRUE, c("txt") := list(paste0("$", .SD$eq_data, "$"))]
  is_hlink <- !is.na(dat$url)
  is_raster <- sapply(dat$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  dat[is_hlink, c("txt") := list(paste0("\\href{", sanitize_latex_str(.SD$url), "}{", .SD$txt, "}"))]
  dat[is_raster == TRUE, c("txt") := list(img_to_latex(.SD$img_data, .SD$width, .SD$height))]
  dat[is_soft_return == TRUE, c("txt") := list("\\linebreak ")]
  dat[is_tab == TRUE, c("txt") := list("\\quad ")]

  dat[is_raster == TRUE, c("left", "right") := list("", "")]
  dat[, c("txt") := list(sprintf("%s%s%s", .SD$left, .SD$txt, .SD$right))]

  setorderv(dat, cols = order_columns)
  dat <- dat[, list(txt = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(dat, cols = by_columns)

  setDF(dat)
  dat
}


#' @importFrom htmltools urlEncodePath
runs_as_wml <- function(x, txt_data = as_table_text(x)) {

  # data can be (1.) from a df computed by as_table_text
  # or (2.) a single paragraph from x$caption$value and there will be only seq_index
  order_columns <-
    intersect(x = colnames(txt_data),
              y = c("part", "ft_row_id", "col_id", "seq_index"))

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(txt_data), c("part", "ft_row_id", "col_id"))
  if(length(by_columns) < 1) by_columns <- NULL


  data_ref_text <- part_style_list(
    as.data.frame(txt_data),
    fun = dummy_fp_text_fun
  )

  fp_text_wml <- sapply(
    split(data_ref_text[-ncol(data_ref_text)], data_ref_text$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "wml")
    }
  )
  style_dat <- data.frame(
    fp_text_wml = as.character(fp_text_wml),
    classname = data_ref_text$classname,
    stringsAsFactors = FALSE
  )

  setDT(txt_data)
  txt_data <- merge(txt_data, data_ref_text, by = colnames(data_ref_text)[-ncol(data_ref_text)])
  txt_data <- merge(txt_data, style_dat, by = "classname")

  is_soft_return <- txt_data$txt %in% "<br>"
  is_tab <- txt_data$txt %in% "<tab>"
  is_eq <- !is.na(txt_data$eq_data)
  is_word_field <- !is.na(txt_data$word_field_data)
  is_raster <- sapply(txt_data$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })
  is_hlink <- !is.na(txt_data$url)
  unique_url_key <- urls_to_keys(urls = txt_data$url, is_hlink = is_hlink)


  txt_data <- add_raster_as_filecolumn(txt_data)

  text_nodes_t <- paste0("<w:t xml:space=\"preserve\">", htmlEscape(txt_data$txt), "</w:t>")
  text_nodes_t[is_soft_return] <- "<w:br/>"
  text_nodes_t[is_tab] <- "<w:tab/>"

  run_openxml <- paste0(
    sprintf("<w:r %s>", base_ns),
    txt_data$fp_text_wml,
    text_nodes_t, "</w:r>"
  )

  run_openxml[is_raster] <- txt_data$img_str[is_raster]

  run_openxml[is_word_field] <- to_wml_word_field(txt_data$word_field_data[is_word_field], pr_txt = txt_data$fp_text_wml[is_word_field])

  # manage hlinks
  url_vals <- as.character(unique_url_key[txt_data$url[is_hlink]])
  run_openxml[is_hlink] <- paste0("<w:hyperlink r:id=\"", url_vals, "\">", run_openxml[is_hlink], "</w:hyperlink>")

  # manage formula
  if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    run_openxml[is_eq] <- transform_mathjax(txt_data$eq_data[is_eq], to = "mml")
  }

  txt_data$run_openxml <- run_openxml

  unique_img <- unique(na.omit(txt_data$file[is_raster]))

  setorderv(txt_data, cols = order_columns)
  txt_data <- txt_data[, lapply(.SD, function(x) paste0(x, collapse = "")), by = by_columns, .SDcols = "run_openxml"]
  setorderv(txt_data, cols = by_columns)

  setDF(txt_data)
  attr(txt_data, "hlinks") <- unique_url_key
  attr(txt_data, "imgs") <- unique_img
  txt_data
}

runs_as_pml <- function(value) {
  txt_data <- as_table_text(value)
  txt_data$col_id <- factor(txt_data$col_id, levels = value$col_keys)

  data_ref_text <- part_style_list(
    as.data.frame(txt_data),
    fun = dummy_fp_text_fun
  )

  fp_text_pml <- sapply(
    split(data_ref_text[-ncol(data_ref_text)], data_ref_text$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "pml")
    }
  )
  style_dat <- data.frame(
    fp_text_pml = as.character(fp_text_pml),
    classname = data_ref_text$classname,
    stringsAsFactors = FALSE
  )


  setDT(txt_data)
  txt_data <- merge(txt_data, data_ref_text, by = colnames(data_ref_text)[-ncol(data_ref_text)])
  txt_data <- merge(txt_data, style_dat, by = "classname")

  is_soft_return <- txt_data$txt %in% "<br>"
  is_tab <- txt_data$txt %in% "<tab>"
  is_eq <- !is.na(txt_data$eq_data)
  is_hlink <- !is.na(txt_data$url)
  is_raster <- sapply(txt_data$img_data, function(x) {inherits(x, "raster") || is.character(x)})

  unique_url_key <- urls_to_keys(urls = txt_data$url, is_hlink = is_hlink)

  txt_data[, c("text_nodes_str") := list(paste0("<a:t>", htmlEscape(.SD$txt), "</a:t>"))]

  txt_data[is_raster == TRUE, c("text_nodes_str") := list("<a:t></a:t>")]
  txt_data[is_soft_return == TRUE, c("text_nodes_str") := list("")]
  txt_data[is_tab == TRUE, c("text_nodes_str") := list("<a:t>\t</a:t>")]

  # manage hlinks
  txt_data[is_hlink == TRUE, c("url") := list(as.character(unique_url_key[.SD$url]))]
  link_pr <- ifelse(is_hlink, paste0("<a:hlinkClick r:id=\"", txt_data$url, "\"/>"), "")
  gmatch <- gregexpr(pattern = "</a:rPr>", txt_data$fp_text_pml, fixed = TRUE)
  end_tag <- paste0(link_pr, "</a:rPr>")
  regmatches(txt_data$fp_text_pml, gmatch) <- as.list(end_tag)

  # manage formula
  if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    txt_data[is_eq == TRUE, c("text_nodes_str") := list(
      paste0(
        "<mc:AlternateContent xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\"><mc:Choice xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\" Requires=\"a14\">",
        "<a14:m xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\"><m:oMathPara xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\"><m:oMathParaPr><m:jc m:val=\"centerGroup\"/></m:oMathParaPr>",
        transform_mathjax(.SD$eq_data, to = "mml"),
        "</m:oMathPara></a14:m>",
        "</mc:Choice></mc:AlternateContent>"
      )
    )]
  }

  txt_data[, c("opening_tag", "closing_tag") := list("<a:r>", "</a:r>")]
  txt_data[is_eq, c("opening_tag", "closing_tag") := list("", "")]
  txt_data[is_soft_return, c("opening_tag", "closing_tag") := list("<a:br>", "</a:br>")]

  txt_data[, c("par_nodes_str") := list(
    paste0(.SD$opening_tag, .SD$fp_text_pml, .SD$text_nodes_str, .SD$closing_tag)
  )]

  setorderv(txt_data, cols = c("part", "ft_row_id", "col_id", "seq_index"))

  txt_data <- txt_data[,
                       lapply(
                         .SD,
                         function(x) {paste0(x, collapse = "")}),
                       by = c("part", "ft_row_id", "col_id"),
                       .SDcols = "par_nodes_str"]
  setDF(txt_data)
  attr(txt_data, "url") <- unique_url_key
  txt_data
}
