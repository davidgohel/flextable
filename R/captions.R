# Word ----
#' @importFrom officer run_bookmark ftext
caption_bookdown_docx_md <- function(x) {
  # for bookdown::word_document2.
  # 'bookdown' wants a table reference as (#tab:bookmark) to enable cross-references
  # in a non raw block. It is then only possible to format chunk of text but
  # it is not possible to add paragraph settings as keep_with_next or ft.align.
  #
  # So, this caption use Word style name ('Table Caption' by default) as only
  # solution to control paragraph formattings. The chunks of text can be made
  # with `set_caption(caption=as_paragraph(...))`. It is defined with a custom
  # raw bloc (surrounded with ::::).
  #
  # Table captions formattings should be defined in the reference_docx file
  # and ft.align should be defined with the same value than the alignement
  # of the 'Table caption' paragraph properties
  tab_props <- opts_current_table()

  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get("label"))
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    return("")
  }

  style_start <- ""
  style_end <- ""

  has_caption_style <- !is.null(tab_props$cap.style)
  if (has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }
  caption_chunks_str <- caption_chunks_wml(x, knitr_caption = tab_props$cap)
  caption_chunks_str <- paste("`", caption_chunks_str, "`{=openxml}", sep = "")

  caption_id <- if (!is.null(tab_props$id) && !is.null(tab_props$tab.lp)) {
    paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  } else {
    ""
  }

  caption <- paste(
    style_start,
    paste0("<caption>", caption_id, caption_chunks_str, "</caption>"),
    style_end,
    "",
    sep = "\n"
  )

  caption
}

caption_default_docx_openxml <- function(x, align = "center",
                                         keep_with_next = FALSE,
                                         tab_props = opts_current_table(),
                                         allow_autonum = TRUE) {
  # for rmarkdown::word_document
  # There is no table reference and no cross-references.
  # It is possible to format chunk of text and also define
  # paragraph settings as keep_with_next or ft.align.
  #
  # So, this caption use Word style name ('Table Caption' by default)
  # The chunks of text can be made
  # with `set_caption(caption=as_paragraph(...))`. The paragraph properties
  # can be defined with `set_caption(fp_p=fp_par(...))`.
  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    return("")
  }

  cap_style <- mcoalesce_options(x$caption$word_stylename, tab_props$cap.style, "Table Caption")
  cap_style_id <- gsub("[^a-zA-Z0-9]", "", cap_style)

  p_pr <- ""
  if (!is.null(x$caption$fp_p)) {
    fp_p <- x$caption$fp_p
    fp_p <- update(fp_p,
      style_id = cap_style_id,
      text.align = align,
      keep_with_next = keep_with_next
    )
    p_pr <- format(x$caption$fp_p, type = "wml")
  } else {
    p_pr <- paste0(
      "<w:pPr>",
      sprintf("<w:pStyle w:val=\"%s\"/>", cap_style_id),
      sprintf("<w:jc w:val=\"%s\"/>", align),
      if (keep_with_next) "<w:keepNext/>",
      "</w:pPr>"
    )
  }

  caption_chunks_str <- caption_chunks_wml(x, knitr_caption = tab_props$cap)

  autonum <- ""
  if (allow_autonum) {
    run_autonum <- get_word_autonum(x, tab_props = tab_props)
    if (!is.null(run_autonum)) {
      autonum <- to_wml(run_autonum)
    }
  }

  caption_str <- paste0(
    c(
      wp_ns_yes,
      p_pr,
      autonum,
      caption_chunks_str,
      "</w:p>"
    ),
    collapse = ""
  )
  caption_str
}

caption_default_rdocx_md <- function(x) {
  tab_props <- opts_current_table()

  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get("label"))
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    return("")
  }

  style_start <- ""
  style_end <- ""

  has_caption_style <- !is.null(tab_props$cap.style)
  if (has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }

  run_autonum <- get_word_autonum(x, tab_props)
  autonum <- ""
  if (!is.null(run_autonum)) {
    autonum <- paste("`", to_wml(run_autonum), "`{=openxml}", sep = "")
  }

  caption_chunks_str <- caption_chunks_text(x = x, knitr_caption = tab_props$cap)

  caption <- paste(
    style_start,
    paste0("<caption>", autonum, caption_chunks_str, "</caption>"),
    style_end,
    "",
    sep = "\n"
  )

  caption
}

# HTML ----



caption_bookdown_html <- function(x) {
  # for bookdown::html_document2.
  # 'bookdown' wants a table reference as (#tab:bookmark) to enable cross-references
  # in a non raw block. It is then only possible to format chunk of text but
  # it is not possible to add paragraph settings as keep_with_next or ft.align.
  #
  # So, this caption use Word style name ('Table Caption' by default) as only
  # solution to control paragraph formattings. The chunks of text can be made
  # with `set_caption(caption=as_paragraph(...))`. It is defined with a custom
  # raw bloc (surrounded with ::::).
  #
  # Table captions formattings should be defined in the reference_docx file
  # and ft.align should be defined with the same value than the alignement
  # of the 'Table caption' paragraph properties
  tab_props <- opts_current_table()

  reference_label <- ""

  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
  } else if (!is.null(tab_props$id)) {
    reference_label <- paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(" style=\"%s\"", format(x$caption$fp_p, type = "html"))
  }

  caption_class <- tab_props$style
  if (!is.null(x$caption$html_classes)) {
    caption_class <- x$caption$html_classes
  }

  if (is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", caption_class)
  }

  html_caption <- caption_chunks_html(x, knitr_caption = tab_props$cap)
  caption_chunks_str <- html_caption$html
  css <- html_caption$css
  has_caption_label <- !is.null(caption_chunks_str)

  if (has_caption_label) {
    caption_str <- paste0(
      sprintf("<caption%s%s>", inline_css, caption_class),
      reference_label,
      caption_chunks_str,
      "</caption>"
    )
    caption_str <- with_html_unquotes(caption_str)
  } else {
    caption_str <- ""
  }
  attr(caption_str, "css") <- css
  caption_str
}



caption_default_html <- function(x) {
  tab_props <- opts_current_table()

  reference_label <- ""

  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- sprintf(" id=\"%s\"", x$caption$autonum$bookmark)
  } else if (!is.null(tab_props$id)) {
    reference_label <- sprintf(" id=\"%s\"", tab_props$id)
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(" style=\"%s\"", format(x$caption$fp_p, type = "html"))
  }

  caption_class <- tab_props$style
  if (!is.null(x$caption$html_classes)) {
    caption_class <- x$caption$html_classes
  }

  if (is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", caption_class)
  }

  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    caption_str <- ""
    attr(caption_str, "css") <- ""
    return(caption_str)
  }

  html_caption <- caption_chunks_html(x, knitr_caption = tab_props$cap)
  caption_chunks_str <- html_caption$html
  has_caption_label <- !is.null(caption_chunks_str)
  css <- html_caption$css

  if (has_caption_label) {
    caption_str <- paste0(
      sprintf("<caption%s%s%s>", inline_css, caption_class, reference_label),
      caption_chunks_str,
      "</caption>"
    )
  } else {
    caption_str <- ""
  }
  attr(caption_str, "css") <- css

  caption_str
}

caption_quarto_html <- function(x) {
  tab_props <- opts_current_table()

  caption_class <- tab_props$style
  if (!is.null(x$caption$html_classes)) {
    caption_class <- x$caption$html_classes
  }

  if (is.null(caption_class)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", caption_class)
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(" style=\"%s\"", format(x$caption$fp_p, type = "html"))
  }

  caption_str <- ""
  if (has_caption(x, knitr_caption = tab_props$cap)) {
    caption_str <- paste0(sprintf("<caption%s%s>", inline_css, caption_class), "</caption>")
  }
  caption_str
}

# PDF ----



caption_quarto_latex <- function(x) {
  tab_props <- opts_current_table()
  caption_label <- tab_props$cap
  has_caption_label <- !is.null(caption_label)
  caption_str <- ""
  if (has_caption_label) {
    caption_str <- "\\caption{} \\\\ \n"
  }
  caption_str
}

caption_default_latex <- function(x, tab_props = opts_current_table()) {

  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    return("")
  }
  caption_chunks_str <- caption_chunks_latex(x, knitr_caption = tab_props$cap)

  caption <- paste0(
    "\\caption{", caption_chunks_str, "}",
    "\\\\"
  )
  caption
}

caption_bookdown_latex <- function(x) {
  tab_props <- opts_current_table()

  if (!has_caption(x, knitr_caption = tab_props$cap)) {
    return("")
  }

  # caption str value
  bookdown_ref_label <- ref_label()
  if (!is.null(x$caption$autonum$bookmark)) {
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, x$caption$autonum$bookmark, ")")
  } else if (!is.null(tab_props$id)) {
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  }

  caption_chunks_str <- caption_chunks_latex(x, knitr_caption = tab_props$cap)

  caption <- paste0(
    "\\caption{", caption_chunks_str, "}",
    bookdown_ref_label,
    "\\\\"
  )
  caption
}

# utils -----
wp_ns_yes <- "<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\">"
wp_ns_no <- "<w:p>"
has_caption <- function(x, knitr_caption = NULL) {
  has_it <- FALSE
  if (!is.null(x$caption$value) || !is.null(knitr_caption)) {
    has_it <- TRUE
  }
  has_it
}

caption_chunks_wml <- function(x, knitr_caption = NULL) {
  caption_chunks_str <- knitr_caption
  if (!is.null(x$caption$value)) {
    spans <- runs_as_wml(x, txt_data = x$caption$value)
    caption_chunks_str <- paste(spans$run_openxml, collapse = "")
  } else if (!is.null(caption_chunks_str)) {
    spans <- runs_as_wml(
      x = x,
      txt_data = as_paragraph(
        as_chunk(caption_chunks_str, props = fp_text_default())
      )[[1]]
    )
    caption_chunks_str <- paste(spans$run_openxml, collapse = "")
  }
  caption_chunks_str
}
caption_chunks_text <- function(x, knitr_caption = NULL) {
  caption_chunks_str <- knitr_caption
  if (!is.null(x$caption$value)) {
    spans <- runs_as_text(x, chunk_data = x$caption$value)
    caption_chunks_str <- paste(spans$span_txt, collapse = "")
  }
  caption_chunks_str
}

caption_chunks_html <- function(x, knitr_caption = NULL) {
  caption_chunks_str <- knitr_caption
  css <- ""
  if (!is.null(x$caption$value)) {
    caption_df <- x$caption$value
    caption_spans <- runs_as_html(x, chunk_data = caption_df)
    css <- attr(caption_spans, "css")
    caption_chunks_str <- paste0(caption_spans$span_tag, collapse = "")
  } else if (!is.null(caption_chunks_str)) {
    caption_spans <- runs_as_html(
      x = x,
      chunk_data = as_paragraph(
        as_chunk(caption_chunks_str, props = fp_text_default())
      )[[1]]
    )
    css <- attr(caption_spans, "css")
    caption_chunks_str <- paste0(caption_spans$span_tag, collapse = "")
  }
  list(html = caption_chunks_str, css = css)
}

caption_chunks_latex <- function(x, knitr_caption = NULL) {
  caption_chunks_str <- knitr_caption

  if (!is.null(x$caption$value)) {
    caption_str <- runs_as_latex(x = x, chunk_data = x$caption$value)
    caption_chunks_str <- paste(caption_str$txt, collapse = "")
  } else if (!is.null(caption_chunks_str)) {
    caption_str <- runs_as_latex(
      x = x,
      chunk_data = as_paragraph(
        as_chunk(caption_chunks_str, props = fp_text_default())
      )[[1]]
    )
    caption_chunks_str <- paste0(caption_str$txt, collapse = "")
  }
  caption_chunks_str
}

caption_as_latex_str <- function(caption_label) {
  if (requireNamespace("commonmark", quietly = TRUE)) {
    gmatch <- gregexpr(pattern = "\\$[^\\$]+\\$", caption_label)
    equations <- regmatches(caption_label, gmatch)[[1]]
    names(equations) <- sprintf("EQUATIONN%.0f", seq_along(equations))
    regmatches(caption_label, gmatch) <- list(names(equations))
    caption_label <- vapply(caption_label, commonmark::markdown_latex, FUN.VALUE = "", USE.NAMES = FALSE)
    for (eq in names(equations)) {
      caption_label <- gsub(eq, equations[eq], caption_label)
    }
    caption_label <- gsub("\\n$", "", caption_label)
  }
  caption_label
}

get_word_autonum <- function(x, tab_props) {
  caption_id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id)

  if (!is.null(tab_props$tab.lp)) {
    tab_props$tab.lp <- gsub(":$", "", tab_props$tab.lp)
  }
  caption_lp <- mcoalesce_options(x$caption$autonum$seq_id, tab_props$tab.lp, "tab")

  caption_pre_label <- mcoalesce_options(tab_props$cap.pre, x$caption$autonum$pre_label)
  caption_post_label <- mcoalesce_options(tab_props$cap.sep, x$caption$autonum$post_label)
  caption_tnd <- mcoalesce_options(tab_props$cap.tnd, x$caption$autonum$tnd)
  caption_tns <- mcoalesce_options(tab_props$cap.tns, x$caption$autonum$tns)


  if(!is.null(tab_props$cap.fp_text)) caption_fp_text <- tab_props$cap.fp_text
  else if(!is.null(x$caption$autonum$pr)) caption_fp_text <- x$caption$autonum$pr
  else caption_fp_text <- fp_text_default()

  autonum <- NULL
  if (!is.null(caption_id)) {
    autonum <- run_autonum(
      seq_id = caption_lp,
      pre_label = caption_pre_label,
      post_label = caption_post_label,
      bkm = caption_id, bkm_all = FALSE,
      tnd = caption_tnd,
      tns = caption_tns,
      prop = caption_fp_text
    )
  }
  autonum
}
