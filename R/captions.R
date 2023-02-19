# Word ----
#' @importFrom officer run_bookmark ftext
caption_bookdown_docx_md <- function(x, tab_props = opts_current_table()) {
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
  if (!has_caption(x)) {
    return("")
  }
  style_start <- "::: {custom-style=\"Table Caption\"}\n"
  style_end <- "\n:::\n"

  caption_chunks_str <- caption_chunks_wml(x)
  caption_chunks_str <- paste("`", caption_chunks_str, "`{=openxml}", sep = "")

  caption_id <- if (!is.null(x$caption$autonum$bookmark)) {
    paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
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

caption_default_docx_openxml <- function(x, keep_with_next = FALSE,
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
  if (!has_caption(x)) {
    return("")
  }

  p_pr <- ""
  x <- process_caption_fp_par(x, keep_with_next = keep_with_next)
  if (!is.null(x$caption$fp_p)) {
    p_pr <- format(x$caption$fp_p, type = "wml")
  } else {
    cap_style_id <- gsub("[^a-zA-Z0-9]", "", x$caption$word_stylename)
    p_pr <- paste0(
      "<w:pPr>",
      sprintf("<w:pStyle w:val=\"%s\"/>", cap_style_id),
      sprintf("<w:jc w:val=\"%s\"/>", x$properties$align),
      if (keep_with_next) "<w:keepNext/>",
      "</w:pPr>"
    )
  }

  caption_chunks_str <- caption_chunks_wml(x)

  autonum <- ""
  if (has_autonum(x) && allow_autonum) {
    autonum <- to_wml(x$caption$autonum)
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

  if (!has_caption(x)) {
    return("")
  }
  x <- process_caption_fp_par(x, keep_with_next = FALSE)

  reference_label <- ""
  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(
      " style=\"%s\"",
      format(x$caption$fp_p, type = "html"))
  }

  if (is.null(x$caption$html_classes)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", x$caption$html_classes)
  }

  html_caption <- caption_chunks_html(x)
  caption_chunks_str <- html_caption$html
  css <- html_caption$css
  caption_str <- paste0(
    sprintf("<caption%s%s>", inline_css, caption_class),
    reference_label,
    caption_chunks_str,
    "</caption>"
  )
  caption_str <- with_html_unquotes(caption_str)

  attr(caption_str, "css") <- css
  caption_str
}


caption_quarto_html <- function(x) {
  if (!has_caption(x)) {
    return("")
  }

  x <- process_caption_fp_par(x, keep_with_next = FALSE)
  if (is.null(x$caption$html_classes)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", x$caption$html_classes)
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(" style=\"%s\"", format(x$caption$fp_p, type = "html"))
  }

  reference_label <- ""
  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
  }

  caption_str <- paste0(sprintf("<caption%s%s>%s", inline_css, caption_class, reference_label), "</caption>")
  caption_str
}



caption_default_html <- function(x) {

  if (!has_caption(x)) {
    caption_str <- ""
    attr(caption_str, "css") <- ""
    return(caption_str)
  }

  x <- process_caption_fp_par(x, keep_with_next = FALSE)
  reference_label <- ""

  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- sprintf(" id=\"%s\"", x$caption$autonum$bookmark)
  }

  inline_css <- ""
  if (!is.null(x$caption$fp_p)) {
    inline_css <- sprintf(
      " style=\"%s\"",
      format(x$caption$fp_p, type = "html"))
  }

  if (is.null(x$caption$html_classes)) {
    caption_class <- ""
  } else {
    caption_class <- sprintf(" class=\"%s\"", x$caption$html_classes)
  }

  html_caption <- caption_chunks_html(x)
  caption_chunks_str <- html_caption$html
  has_caption_label <- !is.null(caption_chunks_str)
  css <- html_caption$css

  caption_str <- paste0(
    sprintf("<caption%s%s%s>", inline_css, caption_class, reference_label),
    caption_chunks_str,
    "</caption>"
  )
  attr(caption_str, "css") <- css

  caption_str
}

# PDF ----

caption_quarto_latex <- function(x) {
  if (!has_caption(x)) {
    return("")
  }
  x <- process_caption_fp_par(x, keep_with_next = FALSE)
  "\\caption{} \\\\ \n"
}

caption_default_latex <- function(x) {

  if (!has_caption(x)) {
    return("")
  }
  caption_chunks_str <- caption_chunks_latex(x)

  caption <- paste0(
    "\\caption{", caption_chunks_str, "}",
    "\\\\"
  )
  caption
}

caption_bookdown_latex <- function(x) {

  if (!has_caption(x)) {
    return("")
  }

  reference_label <- ""
  if (!is.null(x$caption$autonum$bookmark)) {
    reference_label <- paste0("(\\#", x$caption$autonum$seq_id, ":", x$caption$autonum$bookmark, ")")
  }

  caption_chunks_str <- caption_chunks_latex(x)

  caption <- paste0(
    "\\caption{", caption_chunks_str, "}",
    reference_label,
    "\\\\"
  )
  caption
}

# utils -----
wp_ns_yes <- "<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\">"
wp_ns_no <- "<w:p>"
has_caption <- function(x) {
  has_it <- FALSE
  if (!is.null(x$caption$value)) {
    has_it <- TRUE
  }
  has_it
}

has_autonum <- function(x) {
  has_it <- FALSE
  if (!is.null(x$caption$autonum$bookmark)) {
    has_it <- TRUE
  }
  has_it
}
process_caption_fp_par <- function(x, keep_with_next) {
  if (!is.null(x$caption$fp_p)) {
    fp_p <- x$caption$fp_p
    if (x$caption$align_with_table) {
      fp_p <- update(fp_p, text.align = x$properties$align)
    }
    fp_p <- update(fp_p, word_style = x$caption$word_stylename)
    if (keep_with_next) {
      fp_p <- update(fp_p, keep_with_next = TRUE)
    }
    x$caption$fp_p <- fp_p
  }
  x
}

caption_chunks_wml <- function(x) {
  if (!x$caption$simple_caption) {
    spans <- runs_as_wml(x, txt_data = x$caption$value)
    caption_chunks_str <- paste(spans$run_openxml, collapse = "")
  } else {
    caption_chunks_str <- paste0(
      "<w:r><w:t xml:space=\"preserve\">",
      htmlEscape(x$caption$value),
      "</w:t></w:r>")
  }
  caption_chunks_str
}

caption_chunks_html <- function(x) {
  if (!x$caption$simple_caption) {
    caption_df <- x$caption$value
    caption_spans <- runs_as_html(x, chunk_data = caption_df)
    css <- attr(caption_spans, "css")
    caption_chunks_str <- paste0(caption_spans$span_tag, collapse = "")
  } else {
    css <- ""
    caption_chunks_str <- paste0(
      "<span>",
      htmlize(x$caption$value),
      "</span>")
  }
  list(html = caption_chunks_str, css = css)
}

caption_chunks_latex <- function(x) {
  if (!x$caption$simple_caption) {
    caption_str <- runs_as_latex(x = x, chunk_data = x$caption$value)
    caption_chunks_str <- paste(caption_str$txt, collapse = "")
  } else {
    caption_chunks_str <- sanitize_latex_str(x$caption$value)
  }
  caption_chunks_str
}
