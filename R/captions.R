# Word ----
#' @importFrom officer run_bookmark ftext
caption_docx_bookdown <- function(x){
  tab_props <- opts_current_table()

  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get('label'))
  tab_props$cap <- mcoalesce_options(x$caption$value, tab_props$cap)
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  has_caption_label <- !is.null(tab_props$cap)
  has_caption_style <- !is.null(tab_props$cap.style)
  style_start <- ""
  style_end <- ""

  if(has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }

  if(!has_caption_label) return("")

  caption <- tab_props$cap

  zz <- if(!is.null(tab_props$id) && !is.null(tab_props$tab.lp)){
    paste0("(\\#", tab_props$tab.lp, tab_props$id,")")
  } else {
    ""
  }

  caption <- paste(
    style_start,
    paste0("<caption>", zz, caption, "</caption>"),
    style_end,
    "", sep = "\n")

  caption
}

caption_docx_default <- function(x){
  tab_props <- opts_current_table()

  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get('label'))
  tab_props$cap <- mcoalesce_options(x$caption$value, tab_props$cap)
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  has_caption_label <- !is.null(tab_props$cap)
  has_caption_style <- !is.null(tab_props$cap.style)
  style_start <- ""
  style_end <- ""

  if(has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }

  if(!has_caption_label) return("")

  caption <- tab_props$cap

  caption <- paste(
    style_start,
    caption,
    style_end,
    "", sep = "\n")

  caption
}

# caption_docx_standard <- function(x){
#   tab_props <- opts_current_table()
#
#   caption_label <- mcoalesce_options(x$caption$value, tab_props$cap)
#   caption_style <- mcoalesce_options(x$caption$style, tab_props$cap.style)
#   caption_id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id)
#   caption_lp <- mcoalesce_options(
#     x$caption$autonum$seq_id,
#     if( !is.null(tab_props$tab.lp) ) gsub(":$", "", tab_props$tab.lp) else NULL,
#     "tab")
#   caption_pre_label <- mcoalesce_options(tab_props$cap.pre, x$caption$autonum$pre_label)
#   caption_post_label <- mcoalesce_options(tab_props$cap.sep, x$caption$autonum$post_label)
#   caption_tnd <- mcoalesce_options(tab_props$cap.tnd, x$caption$autonum$tnd)
#   caption_tns <- mcoalesce_options(tab_props$cap.tns, x$caption$autonum$tns)
#   caption_fp_text <- mcoalesce_options(tab_props$cap.fp_text, x$caption$autonum$pr)
#
#   if (!is.null(caption_label) && !is.null(caption_id)) {
#     autonum <- run_autonum(
#       seq_id = caption_lp,
#       pre_label = caption_pre_label,
#       post_label = caption_post_label,
#       bkm = caption_id, bkm_all = FALSE,
#       tnd = caption_tnd,
#       tns = caption_tns,
#       prop = caption_fp_text
#     )
#   } else {
#     autonum <- NULL
#   }
#
#   bc <- block_caption(label = caption_label, style = caption_style, autonum = autonum)
#   caption <- to_wml(bc, knitting = TRUE)
#   caption
# }
caption_docx_quarto <- function(x){
  tab_props <- opts_current_table()

  caption_label <- mcoalesce_options(tab_props$cap, x$caption$value)
  caption_style <- mcoalesce_options(tab_props$cap.style, x$caption$style)
  caption_id <- mcoalesce_options(tab_props$id, x$caption$autonum$bookmark)
  caption_pre_label <- mcoalesce_options(tab_props$cap.pre, x$caption$autonum$pre_label)
  caption_post_label <- mcoalesce_options(tab_props$cap.sep, x$caption$autonum$post_label)
  caption_tnd <- mcoalesce_options(tab_props$cap.tnd, x$caption$autonum$tnd)
  caption_tns <- mcoalesce_options(tab_props$cap.tns, x$caption$autonum$tns)
  caption_fp_text <- mcoalesce_options(tab_props$cap.fp_text, x$caption$autonum$pr)

  autonum <- run_autonum(
    seq_id = "tab",
    pre_label = caption_pre_label,
    post_label = caption_post_label,
    bkm = caption_id, bkm_all = FALSE,
    tnd = caption_tnd,
    tns = caption_tns,
    prop = caption_fp_text
  )


  paste0(
    paste0("\n\n::::: {custom-style=\"", caption_style, "\"}"),
    "\n",
    "`", to_wml(autonum), "`{=openxml}",
    htmlEscape(caption_label),
    paste0("\n:::::\n"),
    "\n\n"
  )
}


# HTML ----
caption_html_bookdown <- function(x){

  tab_props <- opts_current_table()

  reference_label <- ""

  if(!is.null(x$caption$autonum$bookmark)){
    reference_label <- paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
  } else if(!is.null(tab_props$id)){
    reference_label <- paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  }

  caption_class <- tab_props$style
  if(!is.null(x$caption$html_classes)){
    caption_class <- x$caption$html_classes
  }

  if(is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf("class=\"%s\"", caption_class)
  }

  caption_label <- tab_props$cap
  if(!is.null(x$caption$value)){
    caption_label <- x$caption$value
  }

  has_caption_label <- !is.null(caption_label)
  if(has_caption_label) {
    caption_label <- pandoc_html_chunks(caption_label)
    caption_str <- paste0(
      sprintf("<caption %s>", caption_class),
      reference_label,
      caption_label,
      "</caption>")
    caption_str <- paste0("\n```\n", caption_str, "\n```{=html}\n")
  } else {
    caption_str <- ""
  }
  caption_str
}
caption_html_default <- function(x){

  tab_props <- opts_current_table()

  reference_label <- ""

  if(!is.null(x$caption$autonum$bookmark)){
    reference_label <- sprintf(" id=\"%s\"", x$caption$autonum$bookmark)
  } else if(!is.null(tab_props$id)){
    reference_label <- sprintf(" id=\"%s\"", tab_props$id)
  }

  caption_class <- tab_props$style
  if(!is.null(x$caption$html_classes)){
    caption_class <- x$caption$html_classes
  }

  if(is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", caption_class)
  }

  caption_label <- tab_props$cap
  if(!is.null(x$caption$value)){
    caption_label <- x$caption$value
  }

  has_caption_label <- !is.null(caption_label)
  if(has_caption_label) {
    caption_label <- pandoc_html_chunks(caption_label)
    caption_str <- paste0(
      sprintf("<caption%s%s>", caption_class, reference_label),
      caption_label,
      "</caption>")
  } else {
    caption_str <- ""
  }
  caption_str
}
caption_html_quarto <- function(x){

  tab_props <- opts_current_table()

  reference_label <- ""
  if(!is.null(x$caption$autonum$bookmark)){
    reference_label <- paste0(" {#tbl-", x$caption$autonum$bookmark, "}")
  } else if(!is.null(tab_props$id)){
    reference_label <- paste0(" {#", tab_props$id, "}")
  }

  caption_class <- tab_props$style
  if(!is.null(x$caption$html_classes)){
    caption_class <- x$caption$html_classes
  }

  if(is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf("class=\"%s\"", caption_class)
  }

  caption_label <- tab_props$cap
  if(!is.null(x$caption$value)){
    caption_label <- x$caption$value
  }
  caption_str <- ""
  has_caption_label <- !is.null(caption_label)
  if(has_caption_label) {
    caption_label <- pandoc_html_chunks(caption_label)
    caption_str <- paste0(caption_label, reference_label)
    caption_str <- paste0(sprintf("<caption %s>", caption_class), caption_str, "</caption>")
  }
  caption_str
}

# PDF ----

caption_to_latex <- function(caption_label) {
  if (requireNamespace("commonmark", quietly = TRUE)) {
    gmatch <- gregexpr(pattern = "\\$[^\\$]+\\$", caption_label)
    equations <- regmatches(caption_label, gmatch)[[1]]
    names(equations) <- sprintf("EQUATIONN%.0f", seq_along(equations))
    regmatches(caption_label, gmatch) <- list(names(equations))
    caption_label <- commonmark::markdown_latex(caption_label)
    for(eq in names(equations)){
      caption_label <- gsub(eq, equations[eq], caption_label)
    }
  }
  caption_label
}


caption_latex_quarto <- function(x){
  tab_props <- opts_current_table()

  caption_label <- tab_props$cap
  if(!is.null(x$caption$value)){
    caption_label <- x$caption$value
  }

  caption_str <- ""
  has_caption_label <- !is.null(caption_label)
  if(has_caption_label) {
    caption_label <- caption_to_latex(caption_label)
    caption_str <- paste0("\\caption{", caption_label, "} \\\\\n")
  }
  caption_str
}
caption_latex_default <- function(x){
  tab_props <- opts_current_table()

  caption_label <- tab_props$cap
  if (!is.null(x$caption$value)) {
    caption_label <- x$caption$value
  }
  caption <- ""
  if (!is.null(caption_label)) {
    caption_label <- caption_to_latex(caption_label)
    caption <- paste0(
      "\\caption{", caption_label, "}",
      "\\\\"
    )
  }
  caption
}
caption_latex_bookdown <- function(x){
  tab_props <- opts_current_table()

  # caption str value
  bookdown_ref_label <- ref_label()
  if(!is.null(x$caption$autonum$bookmark)){
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, x$caption$autonum$bookmark, ")")
  } else if(!is.null(tab_props$id)){
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  }

  caption_label <- tab_props$cap
  if (!is.null(x$caption$value)) {
    caption_label <- x$caption$value
  }
  caption <- ""
  if (!is.null(caption_label)) {
    caption_label <- caption_to_latex(caption_label)
    caption <- paste0(
      "\\caption{", caption_label, "}",
      bookdown_ref_label,
      "\\\\"
    )
  }
  caption
}
