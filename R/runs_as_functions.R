text_css_styles <- function(x) {
  shading <- rep("background-color:transparent;", nrow(x))
  has_shading <- colalpha(x$shading.color) > 0
  shading[has_shading] <- sprintf("background-color:%s;", colcodecss(x$shading.color[has_shading]))

  color <- rep("", nrow(x))
  has_color <- colalpha(x$color) > 0
  color[has_color] <- sprintf("color:%s;", colcodecss(x$color[has_color]))

  family <- sprintf("font-family:'%s';", x$font.family)

  vertical.align <- rep("", nrow(x))
  has_vertical_align <- x$vertical.align %in% c("superscript", "subscript")
  positioning_val <- rep(0, nrow(x))
  positioning_val[has_vertical_align] <- .3
  positioning_what <- rep("", nrow(x))
  positioning_what[x$vertical.align %in% "superscript"] <- "bottom"
  positioning_what[x$vertical.align %in% "subscript"] <- "top"
  vertical.align[has_vertical_align] <-
    sprintf(
      "position: relative;%s:%s;",
      positioning_what[has_vertical_align],
      css_pt(x$font.size[has_vertical_align] *
        positioning_val[has_vertical_align])
    )
  font.size <- sprintf("font-size:%s;", css_pt(x$font.size))
  font.size[has_vertical_align] <- sprintf("font-size:%s;", css_pt(x$font.size[has_vertical_align] * .6))

  bold <- rep("font-weight:normal;", nrow(x))
  bold[x$bold] <- "font-weight:bold;"
  italic <- rep("font-style:normal;", nrow(x))
  italic[x$italic] <- "font-style:italic;"
  underline <- rep("text-decoration:none;", nrow(x))
  underline[x$underlined] <- "text-decoration:underline;"

  style_column <- paste0(
    family, font.size, bold, italic, underline,
    color, shading, vertical.align
  )

  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}
runs_as_html <- function(x, chunk_data = information_data_chunk(x)) {
  # data can be (1.) from a df computed by information_data_chunk
  # or (2.) a single paragraph from x$caption$value and there will be only .chunk_index
  order_columns <-
    intersect(
      x = colnames(chunk_data),
      y = c(".part", ".row_id", ".col_id", ".chunk_index")
    )

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(chunk_data), c(".part", ".row_id", ".col_id"))
  if (length(by_columns) < 1) by_columns <- NULL

  unique_text_props <- distinct_text_properties(chunk_data)

  spans_dataset <- as.data.table(chunk_data)
  spans_dataset <- merge(spans_dataset, unique_text_props,
    by = intersect(colnames(unique_text_props), colnames(chunk_data))
  )

  span_style_str <- text_css_styles(unique_text_props)

  runs_types_lst <- runs_types(spans_dataset)
  spans_dataset[runs_types_lst$is_text == TRUE, c("txt") := list(sprintf("<span class=\"%s\">%s</span>", .SD$classname, htmlize(.SD$txt)))]
  spans_dataset[runs_types_lst$is_raster == TRUE, c("txt") := list(img_as_html(img_data = .SD$img_data, width = .SD$width, height = .SD$height))]
  spans_dataset[runs_types_lst$is_word_field == TRUE, c("txt") := list("")]
  spans_dataset[runs_types_lst$is_soft_return == TRUE, c("txt") := list("<br>")]
  spans_dataset[runs_types_lst$is_tab == TRUE, c("txt") := list("&emsp;")]
  spans_dataset[runs_types_lst$is_hlink == TRUE, c("txt") := list(paste0("<a href=\"", .SD$url, "\">", .SD$txt, "</a>"))]

  if (requireNamespace("equatags", quietly = TRUE) && any(runs_types_lst$is_equation)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    spans_dataset[runs_types_lst$is_equation == TRUE, c("txt") := list(
      sprintf("<span class=\"%s\">%s</span>", .SD$classname, transform_mathjax(.SD$eq_data, to = "html"))
    )]
    katex_link <- "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://cdn.jsdelivr.net/npm/katex@0.15.2/dist/katex.min.css\" data-external=\"1\">"
    spans_dataset[which(runs_types_lst$is_equation == TRUE)[1], c("txt") := list(paste0(katex_link, .SD$txt))]
  }

  setorderv(spans_dataset, cols = order_columns)
  spans_dataset <- spans_dataset[, list(span_tag = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(spans_dataset, cols = by_columns)

  setDF(spans_dataset)
  attr(spans_dataset, "css") <- span_style_str
  spans_dataset
}
runs_as_text <- function(x, chunk_data = information_data_chunk(x)) {
  # data can be (1.) from a df computed by information_data_chunk
  # or (2.) a single paragraph from x$caption$value and there will be only .chunk_index
  order_columns <-
    intersect(
      x = colnames(chunk_data),
      y = c(".part", ".row_id", ".col_id", ".chunk_index")
    )

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(chunk_data), c(".part", ".row_id", ".col_id"))
  if (length(by_columns) < 1) by_columns <- NULL

  spans_dataset <- as.data.table(chunk_data)

  runs_types_lst <- runs_types(spans_dataset)

  spans_dataset[runs_types_lst$is_word_field == TRUE, c("txt") := list("")]
  spans_dataset[runs_types_lst$is_raster == TRUE, c("txt") := list("")]
  spans_dataset[runs_types_lst$is_soft_return == TRUE, c("txt") := list("\n")]
  spans_dataset[runs_types_lst$is_tab == TRUE, c("txt") := list("\t")]
  spans_dataset[which(runs_types_lst$is_equation == TRUE), c("txt") := list(paste("$", .SD$eq_data, "$"))]

  setorderv(spans_dataset, cols = order_columns)
  spans_dataset <- spans_dataset[, list(span_txt = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(spans_dataset, cols = by_columns)

  setDF(spans_dataset)
  spans_dataset
}

#' @importFrom data.table setkeyv
runs_as_latex <- function(x, chunk_data = information_data_chunk(x), ls_df = NULL) {
  txt_data <- chunk_data

  # data can be (1.) from a df computed by information_data_chunk
  # or (2.) a single paragraph from x$caption$value and there will be only .chunk_index
  order_columns <-
    intersect(
      x = colnames(txt_data),
      y = c(".part", ".row_id", ".col_id", ".chunk_index")
    )

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(txt_data), c(".part", ".row_id", ".col_id"))
  if (length(by_columns) < 1) by_columns <- NULL

  setDT(txt_data)

  if (".col_id" %in% colnames(txt_data)) {
    txt_data$.col_id <- factor(txt_data$.col_id, levels = x$col_keys)
  }

  if (!is.null(ls_df) &&
    all(c(".part", ".row_id", ".col_id") %in% colnames(txt_data))) {
    txt_data <- merge(txt_data, ls_df, by = c(".part", ".row_id", ".col_id"))
  } else {
    txt_data$line_spacing <- 1.2
  }

  unique_text_props <- distinct_text_properties(as.data.frame(txt_data), add_columns = "line_spacing")

  txt_data <- merge(
    x = txt_data,
    y = unique_text_props,
    by = intersect(colnames(unique_text_props), colnames(txt_data))
  )

  span_latexstyle_lr <- as_table_latexstyle_lr(unique_text_props)

  dat <- merge(txt_data, span_latexstyle_lr, by = "classname")
  setkeyv(dat, cols = NULL)

  runs_types_lst <- runs_types(dat)

  dat[runs_types_lst$is_text == TRUE, c("txt") := list(sanitize_latex_str(.SD$txt))]
  dat[runs_types_lst$is_equation == TRUE, c("txt") := list(paste0("$", .SD$eq_data, "$"))]
  dat[runs_types_lst$is_hlink & grepl("^#", dat$url), c("txt") := list(paste0("\\hyperref[", gsub("^#", "", .SD$url), "]{", .SD$txt, "}"))]
  dat[runs_types_lst$is_hlink & !grepl("^#", dat$url), c("txt") := list(paste0("\\href{", sanitize_latex_str(.SD$url), "}{", .SD$txt, "}"))]
  dat[runs_types_lst$is_raster == TRUE, c("txt", "left", "right") := list(img_to_latex(.SD$img_data, .SD$width, .SD$height), "", "")]
  dat[runs_types_lst$is_word_field == TRUE, c("left", "right", "txt") := list("", "", "")]
  dat[runs_types_lst$is_soft_return == TRUE, c("txt") := list("\\linebreak ")]
  dat[runs_types_lst$is_tab == TRUE, c("txt") := list("\\quad ")]

  dat[, c("txt") := list(sprintf("%s%s%s", .SD$left, .SD$txt, .SD$right))]

  setorderv(dat, cols = order_columns)
  dat <- dat[, list(txt = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(dat, cols = by_columns)

  setDF(dat)
  dat
}
#' @importFrom officer str_encode_to_rtf
runs_as_rtf <- function(x, chunk_data = information_data_chunk(x)) {
  txt_data <- chunk_data

  # data can be (1.) from a df computed by information_data_chunk
  # or (2.) a single paragraph from x$caption$value and there will be only .chunk_index
  order_columns <-
    intersect(
      x = colnames(txt_data),
      y = c(".part", ".row_id", ".col_id", ".chunk_index")
    )

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(txt_data), c(".part", ".row_id", ".col_id"))
  if (length(by_columns) < 1) by_columns <- NULL

  setDT(txt_data)

  if (".col_id" %in% colnames(txt_data)) {
    txt_data$.col_id <- factor(txt_data$.col_id, levels = x$col_keys)
  }

  unique_text_props <- distinct_text_properties(as.data.frame(txt_data))

  txt_data <- merge(
    x = txt_data,
    y = unique_text_props,
    by = intersect(colnames(unique_text_props), colnames(txt_data))
  )
  span_rtfstyle <- vapply(
    split(unique_text_props[setdiff(colnames(unique_text_props), "classname")], unique_text_props$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "rtf")
    },
    FUN.VALUE = "", USE.NAMES = FALSE
  )
  span_rtfstyle <- data.frame(
    rpr_rtf = span_rtfstyle,
    classname = unique_text_props$classname,
    stringsAsFactors = FALSE
  )

  dat <- merge(txt_data, span_rtfstyle, by = "classname")
  setkeyv(dat, cols = NULL)
  runs_types_lst <- runs_types(dat)

  image_fun <- function(img_data, width, height) {
    mapply(function(src, w, h) {
      to_rtf(officer::external_img(src = src, width = w, height = h))
    }, img_data, width, height, SIMPLIFY = TRUE)
  }
  dat[runs_types_lst$is_text, c("txt") := list(str_encode_to_rtf(.SD$txt))]
  dat[runs_types_lst$is_raster == TRUE, c("txt") := list(image_fun(img_data = .SD$img_data, width = .SD$width, height = .SD$height))]
  dat[runs_types_lst$is_soft_return == TRUE, c("txt") := list("\\line")]
  dat[runs_types_lst$is_tab == TRUE, c("txt") := list("\\tab")]
  dat[runs_types_lst$is_equation == TRUE, c("txt") := list("")]
  dat[runs_types_lst$is_word_field == TRUE, c("txt") := list(sprintf("{\\field{\\*\\fldinst %s}}", .SD$word_field_data))]

  dat[, c("shadingl", "shadingr") := list("", "")]
  dat[!dat$shading.color %in% "transparent", c("shadingl", "shadingr") := list(
    paste0("%ftshading:", .SD$shading.color, "%"), "\\highlight0"
  )]

  dat[, c("txt") := list(sprintf("{%s%s%s%s}", .SD$shadingl, .SD$rpr_rtf, .SD$txt, .SD$shadingr))]
  dat[runs_types_lst$is_hlink, c("txt") := list(sprintf(
    "{\\field{\\*\\fldinst HYPERLINK \"%s\"}{\\fldrslt %s}}",
    .SD$url, .SD$txt
  ))]

  setorderv(dat, cols = order_columns)
  dat <- dat[, list(txt = paste0(get("txt"), collapse = "")), by = by_columns]
  setorderv(dat, cols = by_columns)

  setDF(dat)
  dat
}


#' @importFrom officer officer_url_encode
runs_as_wml <- function(x, txt_data = information_data_chunk(x)) {
  # data can be (1.) from a df computed by information_data_chunk
  # or (2.) a single paragraph from x$caption$value and there will be only .chunk_index
  order_columns <-
    intersect(
      x = colnames(txt_data),
      y = c(".part", ".row_id", ".col_id", ".chunk_index")
    )

  # prepare the by col for aggregation
  by_columns <- intersect(colnames(txt_data), c(".part", ".row_id", ".col_id"))
  if (length(by_columns) < 1) by_columns <- NULL

  unique_text_props <- distinct_text_properties(as.data.frame(txt_data))

  rpr <- vapply(
    split(unique_text_props[setdiff(colnames(unique_text_props), "classname")], unique_text_props$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "wml")
    },
    FUN.VALUE = "", USE.NAMES = FALSE
  )

  style_dat <- data.frame(
    rpr = rpr,
    classname = unique_text_props$classname,
    stringsAsFactors = FALSE
  )

  txt_data <- merge(as.data.table(txt_data), unique_text_props, by = colnames(unique_text_props)[-ncol(unique_text_props)])
  txt_data <- merge(txt_data, style_dat, by = "classname")

  runs_types_lst <- runs_types(txt_data)

  txt_data <- add_raster_as_filecolumn(txt_data, runs_types_lst$is_raster)

  txt_data[runs_types_lst$is_raster, c("run_openxml") := list(.SD$img_str)]
  txt_data[runs_types_lst$is_text, c("run_openxml") := list(
    paste0("<w:t xml:space=\"preserve\">", htmlEscape(.SD$txt), "</w:t>")
  )]
  txt_data[runs_types_lst$is_soft_return, c("run_openxml") := list("<w:br/>")]
  txt_data[runs_types_lst$is_tab, c("run_openxml") := list("<w:tab/>")]
  txt_data[
    runs_types_lst$is_text |
      runs_types_lst$is_tab |
      runs_types_lst$is_soft_return,
    c("run_openxml") := list(
      paste0(sprintf("<w:r %s>", base_ns), .SD$rpr, .SD$run_openxml, "</w:r>")
    )
  ]
  txt_data[runs_types_lst$is_word_field, c("run_openxml") := list(to_wml_word_field(.SD$word_field_data, pr_txt = .SD$rpr))]
  txt_data[runs_types_lst$is_hlink, c("run_openxml") := list(paste0("<w:hyperlink r:id=\"", officer_url_encode(.SD$url), "\">", .SD$run_openxml, "</w:hyperlink>"))]
  if (requireNamespace("equatags", quietly = TRUE) && any(runs_types_lst$is_equation)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    txt_data[runs_types_lst$is_equation, c("run_openxml") := list(transform_mathjax(.SD$eq_data, to = "mml"))]
  }
  setorderv(txt_data, cols = order_columns)
  txt_data <- txt_data[, lapply(.SD, function(x) paste0(x, collapse = "")), by = by_columns, .SDcols = "run_openxml"]
  setorderv(txt_data, cols = by_columns)

  setDF(txt_data)
  txt_data
}

runs_as_pml <- function(value) {
  txt_data <- information_data_chunk(value)
  txt_data$.col_id <- factor(txt_data$.col_id, levels = value$col_keys)

  unique_text_props <- distinct_text_properties(as.data.frame(txt_data))

  rpr <- sapply(
    split(unique_text_props[setdiff(colnames(unique_text_props), "classname")], unique_text_props$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "pml")
    }
  )
  style_dat <- data.frame(
    rpr = rpr,
    classname = unique_text_props$classname,
    stringsAsFactors = FALSE
  )


  setDT(txt_data)
  txt_data <- merge(txt_data, unique_text_props, by = colnames(unique_text_props)[-ncol(unique_text_props)])
  txt_data <- merge(txt_data, style_dat, by = "classname")

  runs_types_lst <- runs_types(txt_data)

  txt_data[, c("text_nodes_str") := list(paste0("<a:t>", htmlEscape(.SD$txt), "</a:t>"))]

  txt_data[runs_types_lst$is_word_field == TRUE, c("text_nodes_str") := list("<a:t></a:t>")]
  txt_data[runs_types_lst$is_raster == TRUE, c("text_nodes_str") := list("<a:t></a:t>")]
  txt_data[runs_types_lst$is_soft_return == TRUE, c("text_nodes_str") := list("")]
  txt_data[runs_types_lst$is_tab == TRUE, c("text_nodes_str") := list("<a:t>\t</a:t>")]

  # manage hlinks
  link_pr <- ifelse(runs_types_lst$is_hlink, paste0("<a:hlinkClick r:id=\"", officer_url_encode(txt_data$url), "\"/>"), "")
  gmatch <- gregexpr(pattern = "</a:rPr>", txt_data$rpr, fixed = TRUE)
  end_tag <- paste0(link_pr, "</a:rPr>")
  regmatches(txt_data$rpr, gmatch) <- as.list(end_tag)

  # manage formula
  if (requireNamespace("equatags", quietly = TRUE) && any(runs_types_lst$is_equation)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    txt_data[runs_types_lst$is_equation == TRUE, c("text_nodes_str") := list(
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
  txt_data[runs_types_lst$is_equation, c("opening_tag", "closing_tag") := list("", "")]
  txt_data[runs_types_lst$is_soft_return, c("opening_tag", "closing_tag") := list("<a:br>", "</a:br>")]

  txt_data_is_empty <- txt_data[, list(is_empty = all(.SD$text_nodes_str %in% "<a:t></a:t>")) ,by = c(".part", ".row_id", ".col_id")]
  txt_data[, c("par_nodes_str") := list(
    paste0(.SD$opening_tag, .SD$rpr, .SD$text_nodes_str, .SD$closing_tag)
  )]

  setorderv(txt_data, cols = c(".part", ".row_id", ".col_id", ".chunk_index"))

  txt_data <- txt_data[,
    lapply(
      .SD,
      function(x) {
        paste0(x, collapse = "")
      }
    ),
    by = c(".part", ".row_id", ".col_id"),
    .SDcols = "par_nodes_str"
  ]
  txt_data <- merge(txt_data, txt_data_is_empty, by = c(".part", ".row_id", ".col_id"))
  setDF(txt_data)
  txt_data
}

# utils ----
runs_types <- function(dat) {
  x <- list(
    is_soft_return = dat$txt %in% "<br>",
    is_tab = dat$txt %in% "<tab>",
    is_equation = !is.na(dat$eq_data),
    is_word_field = !is.na(dat$word_field_data),
    is_hlink = !is.na(dat$url),
    is_raster = sapply(dat$img_data, function(x) {
      inherits(x, "raster") || is.character(x)
    })
  )
  x$is_text <- Reduce(
    function(a, b) a & b,
    list(
      !x$is_soft_return,
      !x$is_tab,
      !x$is_equation,
      !x$is_word_field,
      !x$is_raster
    )
  )
  x
}

#' @import data.table
add_raster_as_filecolumn <- function(x, is_raster) {
  whichs_ <- which(is_raster)
  files <- mapply(function(x, width, height) {
    if (inherits(x, "raster")) {
      file <- tempfile(fileext = ".png")
      agg_png(filename = file, units = "in", res = 300, background = "transparent", width = width, height = height)
      op <- par(mar = rep(0, 4))
      plot(x, interpolate = FALSE, asp = NA)
      par(op)
      dev.off()
    } else if (is.character(x)) {
      file <- x
    } else {
      stop("unknown image format")
    }


    data.frame(
      file = file,
      img_str = wml_image(file, width, height),
      stringsAsFactors = FALSE
    )
  }, x$img_data[whichs_], x$width[whichs_], x$height[whichs_], SIMPLIFY = FALSE, USE.NAMES = FALSE)
  files <- rbindlist(files)
  setDF(files)

  x$file <- rep(NA_character_, nrow(x))
  x$img_str <- rep(NA_character_, nrow(x))

  x[whichs_, c("file", "img_str")] <- files

  x
}
