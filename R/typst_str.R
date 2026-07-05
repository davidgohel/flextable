# Typst backend for flextable -----------------------------------
# Modeled on R/html_str.R and runs_as_html(); reuses the same format-agnostic
# helpers: information_data_*, fortify_*, runs_types, colcode0, colalpha,
# format_double.
#
# -- small formatting helpers ------------------------------------------------

typst_pt <- function(x, digits = 1) {
  ifelse(
    is.na(x) | x < 0.001,
    "0pt",
    paste0(format_double(x, digits = digits), "pt")
  )
}

# Typst content-mode escaping. One PCRE pass: a character class + backreference
# prefixes every special char with `\` (`\X` is a literal X in Typst). The class
# must also list the markup *triggers* `. - ' " = + /`, else Typst rewrites cell
# text: `--`/`...` to dashes/ellipsis, `-` before a digit to a minus sign,
# quotes to curly quotes, and a leading `= + /` to a heading/enum/term marker
# (`/` even fails to compile). `-` is last in the class so it is not a range.
typst_escape <- function(x) {
  x <- gsub("([]#$*_`<>@~[.'\"=+/\\\\-])", "\\\\\\1", x, perl = TRUE)
  x <- gsub("\t", "#h(1em)", x, fixed = TRUE)
  x
}

# Directory where path-mode images are written. In a knitr/Quarto run this is
# the chunk figure dir, so the emitted relative path resolves at compile time
# (Typst root = doc dir); outside knitr we fall back to a tempdir.
typst_fig_dir <- function() {
  fp <- tryCatch(fig_path("png"), error = function(e) NULL)
  if (is.null(fp)) {
    return(tempdir())
  }
  d <- dirname(fp)
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  d
}

# `embed = FALSE` (Quarto/knitr): copy the file under the chunk figure dir and
# emit `#image("relative/path", ...)` (path resolves at compile time).
# `embed = TRUE` (standalone): base64-encode the bytes and emit
# `#image(ft-b64-decode("..."), ...)`, decoded inline by the preamble decoder.
img_as_typst <- function(img_data, width, height, alt = "", embed = FALSE) {
  fig_dir <- if (!embed) typst_fig_dir() else NULL
  mapply(
    function(img, w, h) {
      # obtain a file on disk for this image (render raster, or external path)
      if (inherits(img, "raster")) {
        src <- plot_in_png(
          code = {
            op <- par(mar = rep(0, 4))
            plot(img, interpolate = FALSE, asp = NA)
            par(op)
          },
          width = w,
          height = h,
          res = 300,
          units = "in",
          path = tempfile(pattern = "ftimg", fileext = ".png")
        )
      } else if (is.character(img)) {
        src <- img
      } else {
        stop("unknown image format")
      }

      if (embed) {
        # officer::image_to_base64 returns a data URI; strip it to raw base64.
        # No `format:` is emitted: with a `bytes` source Typst auto-detects the
        # format from the decoded data. The MIME subtype is NOT a valid Typst
        # format string (e.g. "jpeg"/"svg+xml" would be rejected at compile).
        duri <- officer::image_to_base64(src)
        b64 <- sub("^data:[^;]+;base64,", "", duri)
        sprintf(
          '#image(ft-b64-decode("%s"), width: %sin, height: %sin)',
          b64,
          format_double(w, digits = 3),
          format_double(h, digits = 3)
        )
      } else {
        file <- file.path(
          fig_dir,
          basename(tempfile(
            pattern = "ftimg",
            fileext = paste0(".", tools::file_ext(src))
          ))
        )
        file.copy(src, file, overwrite = TRUE)
        sprintf(
          '#image("%s", width: %sin, height: %sin)',
          file,
          format_double(w, digits = 3),
          format_double(h, digits = 3)
        )
      }
    },
    img_data,
    width,
    height,
    SIMPLIFY = TRUE,
    USE.NAMES = FALSE
  )
}

typst_halign <- function(text.align) {
  out <- text.align
  out[text.align %in% "justify"] <- "left"
  out[!text.align %in% c("left", "center", "right")] <- "left"
  out
}

typst_valign <- function(vertical.align) {
  out <- rep("horizon", length(vertical.align))
  out[vertical.align %in% "top"] <- "top"
  out[vertical.align %in% "bottom"] <- "bottom"
  out
}

# one stroke side -> 'top: 1pt + rgb("000000")' or 'top: none'
typst_stroke_side <- function(color, width, style, side) {
  has <- !is.na(width) & width > 0.001 & colalpha(color) > 0
  dash <- rep("", length(width))
  dash[style %in% "dashed"] <- ', dash: "dashed"'
  dash[style %in% "dotted"] <- ', dash: "dotted"'
  ifelse(
    has,
    ifelse(
      nzchar(dash),
      sprintf(
        '%s: (paint: rgb("%s"), thickness: %s%s)',
        side,
        colcode0(color),
        typst_pt(width, 2),
        dash
      ),
      sprintf('%s: %s + rgb("%s")', side, typst_pt(width, 2), colcode0(color))
    ),
    sprintf("%s: none", side)
  )
}

# -- text runs ---------------------------------------------------------------

runs_as_typst <- function(
  x,
  chunk_data = information_data_chunk(x),
  image_mode = c("path", "embed")
) {
  image_mode <- match.arg(image_mode)
  order_columns <- intersect(
    colnames(chunk_data),
    c(".part", ".row_id", ".col_id", ".chunk_index")
  )
  by_columns <- intersect(
    colnames(chunk_data),
    c(".part", ".row_id", ".col_id")
  )
  if (length(by_columns) < 1) {
    by_columns <- NULL
  }

  dat <- as.data.table(chunk_data)
  runs_types_lst <- runs_types(dat)

  # build a #text(...) wrapper from the per-chunk text properties
  text_args <- function(d) {
    weight <- ifelse(d$bold, ', weight: "bold"', "")
    style <- ifelse(d$italic, ', style: "italic"', "")
    size <- d$font.size
    has_supsub <- d$vertical.align %in% c("superscript", "subscript")
    size[has_supsub] <- size[has_supsub] * 0.6
    sizearg <- sprintf(", size: %s", typst_pt(size))
    fill <- ifelse(
      colalpha(d$color) > 0,
      sprintf(', fill: rgb("%s")', colcode0(d$color)),
      ""
    )
    font <- sprintf(', font: "%s"', d$font.family)
    inner <- paste0(weight, style, sizearg, fill, font)
    inner <- sub("^, ", "", inner) # drop leading comma
    sprintf("#text(%s)[%s]", inner, d$.body)
  }

  dat[
    runs_types_lst$is_text == TRUE,
    c(".body") := list(typst_escape(.SD$txt))
  ]
  dat[runs_types_lst$is_soft_return == TRUE, c(".body") := list("#linebreak()")]
  dat[runs_types_lst$is_tab == TRUE, c(".body") := list("#h(1em)")]
  # equations: eq_data is LaTeX math -> mitex inline #mi(`...`).
  # Requires `#import "@preview/mitex:0.2.x": *` in the document preamble.
  dat[
    runs_types_lst$is_equation == TRUE,
    c(".body") := list(sprintf("#mi(`%s`)", .SD$eq_data))
  ]
  # Word fields are an OOXML/RTF-native feature; like HTML/LaTeX/PPTX, Typst
  # degrades them to an empty string (see header comment).
  dat[runs_types_lst$is_word_field == TRUE, c(".body") := list("")]
  # as_qmd: emit a base64 marker resolved by the flextable-qmd Lua filter.
  # `/* ... */` is a Typst comment, so it degrades to nothing if the filter
  # is absent; base64 never contains `*`, so `*/` cannot occur inside it.
  dat[
    runs_types_lst$is_qmd == TRUE,
    c(".body") := list(sprintf(
      "/*tblqmd:%s*/",
      officer::as_base64(.SD$qmd_data)
    ))
  ]
  if (any(runs_types_lst$is_raster)) {
    dat[
      runs_types_lst$is_raster == TRUE,
      c(".body") := list(img_as_typst(
        img_data = .SD$img_data,
        width = .SD$width,
        height = .SD$height,
        alt = .SD$alt,
        embed = identical(image_mode, "embed")
      ))
    ]
  }

  # text run wrapping applies to plain text runs only; qmd markers, images,
  # equations, breaks and tabs pass through unwrapped.
  is_textual <- runs_types_lst$is_text
  dat[is_textual, c("txt") := list(text_args(.SD))]
  # leave the non-textual bodies (markers, linebreak, h, ...) as-is
  dat[!is_textual, c("txt") := list(.SD$.body)]

  # decorations that wrap the #text node
  dat[
    is_textual & dat$underlined,
    c("txt") := list(sprintf("#underline[%s]", .SD$txt))
  ]
  dat[
    is_textual & !is.na(dat$strike) & dat$strike,
    c("txt") := list(sprintf("#strike[%s]", .SD$txt))
  ]
  dat[
    is_textual & dat$vertical.align %in% "superscript",
    c("txt") := list(sprintf("#super[%s]", .SD$txt))
  ]
  dat[
    is_textual & dat$vertical.align %in% "subscript",
    c("txt") := list(sprintf("#sub[%s]", .SD$txt))
  ]
  # links wrap whatever was produced
  dat[
    runs_types_lst$is_hlink == TRUE,
    c("txt") := list(sprintf('#link("%s")[%s]', .SD$url, .SD$txt))
  ]

  setorderv(dat, cols = order_columns)
  dat <- dat[,
    list(span_tag = paste0(get("txt"), collapse = "")),
    by = by_columns
  ]
  setorderv(dat, cols = by_columns)
  setDF(dat)
  dat
}

# -- cells -------------------------------------------------------------------

typst_content_strs <- function(x, image_mode = "path") {
  cell_data <- information_data_cell(x)
  setDT(cell_data)
  par_data <- information_data_paragraph(x)
  setDT(par_data)

  txt_data <- runs_as_typst(
    x,
    chunk_data = information_data_chunk(x),
    image_mode = image_mode
  )
  setDT(txt_data)

  # bring paragraph text.align + padding into the cell record
  cell_data <- merge(
    cell_data,
    par_data[, c(
      ".part",
      ".row_id",
      ".col_id",
      "text.align",
      "padding.top",
      "padding.bottom",
      "padding.left",
      "padding.right",
      "first_line",
      "hanging"
    )],
    by = c(".part", ".row_id", ".col_id")
  )

  # first-line/hanging indents (hanging wins, as in officer). Typst
  # `hanging-indent` indents lines 2+, so the Word semantics (all lines
  # at padding.left, first line outdented by `hanging`) translate to
  # inset left = padding.left - hanging plus par(hanging-indent:).
  cell_data[,
    c("hanging_pt", "first_line_pt") := list(
      fifelse(!is.na(.SD$hanging) & .SD$hanging > 0, .SD$hanging, 0),
      fifelse(
        (is.na(.SD$hanging) | .SD$hanging <= 0) &
          !is.na(.SD$first_line) &
          .SD$first_line > 0,
        .SD$first_line,
        0
      )
    )
  ]
  cell_data[,
    c("padding.left") := list(pmax(0, .SD$padding.left - .SD$hanging_pt))
  ]

  cell_data[, c("width", "height", "hrule") := list(NULL, NULL, NULL)]
  cell_data <- merge(cell_data, fortify_width(x), by = ".col_id")
  span_data <- fortify_span(x)
  cell_data <- merge(
    cell_data,
    span_data,
    by = c(".part", ".row_id", ".col_id")
  )

  # build each table.cell(...)[ ... ]
  align <- sprintf(
    "align: %s + %s",
    typst_halign(cell_data$text.align),
    typst_valign(cell_data$vertical.align)
  )

  fill <- ifelse(
    colalpha(cell_data$background.color) > 0,
    sprintf(', fill: rgb("%s")', colcode0(cell_data$background.color)),
    ""
  )

  inset <- sprintf(
    ", inset: (left: %s, right: %s, top: %s, bottom: %s)",
    typst_pt(cell_data$padding.left),
    typst_pt(cell_data$padding.right),
    typst_pt(cell_data$padding.top),
    typst_pt(cell_data$padding.bottom)
  )

  stroke <- sprintf(
    ", stroke: (%s, %s, %s, %s)",
    typst_stroke_side(
      cell_data$border.color.top,
      cell_data$border.width.top,
      cell_data$border.style.top,
      "top"
    ),
    typst_stroke_side(
      cell_data$border.color.bottom,
      cell_data$border.width.bottom,
      cell_data$border.style.bottom,
      "bottom"
    ),
    typst_stroke_side(
      cell_data$border.color.left,
      cell_data$border.width.left,
      cell_data$border.style.left,
      "left"
    ),
    typst_stroke_side(
      cell_data$border.color.right,
      cell_data$border.width.right,
      cell_data$border.style.right,
      "right"
    )
  )

  # flextable naming: `rowspan` = horizontal extent (Typst colspan),
  # `colspan` = vertical extent (Typst rowspan). Mirrors html_str.R.
  colspan_str <- ifelse(
    cell_data$rowspan > 1,
    sprintf(", colspan: %.0f", cell_data$rowspan),
    ""
  )
  rowspan_str <- ifelse(
    cell_data$colspan > 1,
    sprintf(", rowspan: %.0f", cell_data$colspan),
    ""
  )

  cell_data[,
    c("cell_open") := list(paste0(
      "table.cell(",
      align,
      fill,
      inset,
      stroke,
      colspan_str,
      rowspan_str,
      ")"
    ))
  ]
  # covered cells produce nothing (Typst auto-skips spanned positions)
  cell_data[
    cell_data$rowspan < 1 | cell_data$colspan < 1,
    c("cell_open") := list("")
  ]

  dat <- merge(txt_data, cell_data, by = c(".part", ".row_id", ".col_id"))

  # paragraph properties needing an explicit par() constructor: the
  # inline content of a table cell is not a real `par` element, so a
  # `#set par()` rule has no effect on it. `hanging-indent` implements
  # `hanging`; `justify: true` re-enables justification (disabled at
  # table level, see gen_raw_typst) when text.align is "justify".
  # `first_line` is a #h() shift of the first line.
  par_args_indent <- ifelse(
    dat$hanging_pt > 0,
    sprintf("hanging-indent: %s", typst_pt(dat$hanging_pt)),
    ""
  )
  par_args_justify <- ifelse(dat$text.align %in% "justify", "justify: true", "")
  par_args <- ifelse(
    nzchar(par_args_indent) & nzchar(par_args_justify),
    paste0(par_args_justify, ", ", par_args_indent),
    paste0(par_args_justify, par_args_indent)
  )
  span_tag <- ifelse(
    nzchar(par_args),
    sprintf("#par(%s)[%s]", par_args, dat$span_tag),
    dat$span_tag
  )
  span_tag <- ifelse(
    dat$first_line_pt > 0,
    paste0(sprintf("#h(%s)", typst_pt(dat$first_line_pt)), span_tag),
    span_tag
  )

  # rotated text -> wrap the content in #rotate(..., reflow: true)[ ... ] so
  # the cell sizes to the rotated box. tbrl: top->bottom (90deg clockwise);
  # btlr: bottom->top (counter-clockwise). reflow expands row height/col width.
  rot_open <- ifelse(
    dat$text.direction %in% "tbrl",
    "#rotate(90deg, reflow: true)[",
    ifelse(
      dat$text.direction %in% "btlr",
      "#rotate(-90deg, reflow: true)[",
      ""
    )
  )
  content <- ifelse(
    nzchar(rot_open),
    paste0(rot_open, span_tag, "]"),
    span_tag
  )
  dat[,
    c("cell_str") := list(ifelse(
      nzchar(.SD$cell_open),
      sprintf("%s[%s],", .SD$cell_open, content),
      ""
    ))
  ]

  dat[, c(".col_id") := list(factor(.SD$.col_id, levels = x$col_keys))]
  setorderv(dat, c(".part", ".row_id", ".col_id"))

  # assemble rows then parts
  rows <- dat[,
    list(
      row_str = paste0(
        get("cell_str")[nzchar(get("cell_str"))],
        collapse = "\n  "
      )
    ),
    by = c(".part", ".row_id")
  ]
  setorderv(rows, c(".part", ".row_id"))

  build_part <- function(part) {
    sub <- rows[rows$.part == part, ]
    if (nrow(sub) < 1) {
      return("")
    }
    paste0("  ", sub$row_str, collapse = "\n")
  }
  list(
    header = build_part("header"),
    body = build_part("body"),
    footer = build_part("footer"),
    widths = fortify_width(x)
  )
}

# -- top-level entry point ---------------------------------------------------

gen_raw_typst <- function(x, image_mode = "path") {
  codes <- typst_content_strs(x, image_mode = image_mode)

  widths <- codes$widths
  widths <- widths[match(x$col_keys, widths$.col_id), ]
  fixed <- isTRUE(x$properties$layout %in% "fixed")
  if (fixed) {
    cols <- sprintf(
      "(%s)",
      paste0(
        sprintf("%sin", format_double(widths$width, digits = 3)),
        collapse = ", "
      )
    )
  } else {
    cols <- sprintf("(%s)", paste0(rep("auto", nrow(widths)), collapse = ", "))
  }

  parts <- character()
  if (nzchar(codes$header)) {
    parts <- c(parts, sprintf("  table.header(\n%s\n  ),", codes$header))
  }
  if (nzchar(codes$body)) {
    parts <- c(parts, codes$body)
  }
  if (nzchar(codes$footer)) {
    parts <- c(parts, sprintf("  table.footer(\n%s\n  ),", codes$footer))
  }

  # flextable's text.align semantics: "left" is not "justify". Quarto's
  # Typst template sets `par(justify: true)` document-wide, which would
  # justify (and hyphenate) every cell; scope it off around the table.
  # Cells with text.align "justify" opt back in with a per-cell
  # `#par(justify: true)` (see typst_content_strs).
  paste0(
    "#[\n",
    "#set par(justify: false)\n",
    "#table(\n",
    sprintf("  columns: %s,\n", cols),
    "  stroke: none,\n",
    paste0(parts, collapse = "\n"),
    "\n)\n",
    "]\n"
  )
}

# -- standalone document -----------------------------------------------------

# Pure-Typst base64 decoder, injected in the preamble by save_as_typst() when
# images are embedded. No package, so the generated .typ compiles offline.
typst_b64_decoder <- function() {
  paste(
    "#let ft-b64-decode(s) = {",
    '  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"',
    "  let lookup = (:)",
    "  let chars = alphabet.clusters()",
    "  for i in range(chars.len()) { lookup.insert(chars.at(i), i) }",
    '  let npad = if s.ends-with("==") { 2 } else if s.ends-with("=") { 1 } else { 0 }',
    '  let cl = s.replace("=", "A").replace("\\n", "").replace("\\r", "").clusters()',
    "  let out = ()",
    "  let i = 0",
    "  while i < cl.len() {",
    "    let a = lookup.at(cl.at(i))",
    "    let b = lookup.at(cl.at(i + 1))",
    "    let c = lookup.at(cl.at(i + 2))",
    "    let d = lookup.at(cl.at(i + 3))",
    "    out.push(a * 4 + calc.quo(b, 16))",
    "    out.push(calc.rem(b, 16) * 16 + calc.quo(c, 4))",
    "    out.push(calc.rem(c, 4) * 64 + d)",
    "    i = i + 4",
    "  }",
    "  if npad > 0 { out = out.slice(0, out.len() - npad) }",
    "  bytes(out)",
    "}",
    sep = "\n"
  )
}

#' @export
#' @title Save flextable objects in a Typst file
#' @description Writes one or more flextables to a standalone Typst
#' (`.typ`) document. Images are embedded as base64 (decoded inline at
#' compile time), so the file is self-contained and compiles offline with
#' `typst compile`. Equations require the `mitex` Typst package, which is
#' fetched from the Typst package registry on first compilation.
#' @param ... flextable objects, possibly named.
#' @param values a list of flextable objects. If provided, `...` is ignored.
#' @param path Typst file to be created.
#' @param page a Typst `#set page(...)` rule used as document setup. The
#' default produces a tightly cropped page fitting the table(s).
#' @return the path to the generated file, invisibly.
#' @examples
#' ft <- flextable(head(iris))
#' tf <- tempfile(fileext = ".typ")
#' save_as_typst(ft, path = tf)
save_as_typst <- function(
  ...,
  values = NULL,
  path,
  page = "#set page(width: auto, height: auto, margin: 12pt)"
) {
  if (is.null(values)) {
    values <- list(...)
  }
  values <- Filter(function(z) inherits(z, "flextable"), values)
  if (length(values) < 1) {
    stop("no flextable object to save")
  }

  bodies <- vapply(
    values,
    function(z) gen_raw_typst(z, image_mode = "embed"),
    NA_character_
  )

  need_eq <- any(vapply(values, has_equation, logical(1)))
  need_img <- any(vapply(values, has_raster, logical(1)))

  preamble <- c(
    if (need_eq) '#import "@preview/mitex:0.2.7": *',
    if (need_img) typst_b64_decoder(),
    page
  )

  writeLines(c(preamble, "", bodies), con = path)
  invisible(path)
}
