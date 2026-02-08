# grid_data ---------------------------------------------------------------

#' @importFrom data.table data.table rbindlist rleid .SD .N first fcase fifelse
get_grid_data <- function(x, autowidths, wrapping) {
  parts <- c("header", "body", "footer")
  names(parts) <- parts
  grid_data <- rbindlist(lapply(parts, function(part) {
    nr <- nrow_part(x, part)
    if (nr > 0) {
      data.frame(
        .col_id = rep(x$col_keys, each = nr),
        .row_id = rep(seq_len(nr), length(x$col_keys)),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    }
  }), use.names = TRUE, idcol = ".part")

  grid_data$.part <- factor(grid_data$.part, levels = intersect(parts, grid_data$.part))
  grid_data$.col_id <- factor(grid_data$.col_id, levels = x$col_keys)
  keycols <- c(".part", ".row_id", ".col_id")
  setorderv(grid_data, cols = keycols)
  grid_data[, c("row_index", "col_index") := list(
    rleid(.SD$.part, .SD$.row_id), as.integer(.SD$.col_id)
  )]
  setorderv(grid_data, cols = c("row_index", "col_index"))

  # add column widths
  col_widths <- fortify_width(x)
  colnames(col_widths)[colnames(col_widths) == "width"] <- "col_width"
  grid_data <- merge(grid_data, col_widths, by = c(".col_id"))

  # add row heights
  row_heights <- fortify_height(x)
  colnames(row_heights)[colnames(row_heights) == "height"] <- "row_height"
  grid_data <- merge(grid_data, row_heights, by = c(".part", ".row_id"))

  # add hrule
  row_hrules <- fortify_hrule(x)
  grid_data <- merge(grid_data, row_hrules, by = c(".part", ".row_id"))

  # calculate minimum and maximum cell height according to hrule
  grid_data[, "row_min_height" := fcase(
    .SD$hrule %in% "exact", .SD$row_height,
    .SD$hrule %in% "atleast", .SD$row_height,
    default = NA_real_
  )]
  grid_data[, "row_max_height" := fcase(
    .SD$hrule %in% "exact", .SD$row_height,
    default = NA_real_
  )]

  # add spans
  spans <- fortify_span(x)
  grid_data <- merge(grid_data, spans, by = keycols)
  # create span groups
  setorderv(grid_data, cols = c("row_index", "col_index"))
  grid_data[, "rowspan_group" := calc_grid_span_group(.SD$rowspan)]
  setorderv(grid_data, cols = c("col_index", "row_index"))
  grid_data[, "colspan_group" := calc_grid_span_group(.SD$colspan)]

  # set cell width and height
  grid_data[, "cell_width" := safe_stat(.SD$col_width,
    FUN = sum, NA_value = NA_real_
  ), by = "rowspan_group"]
  grid_data[, "cell_height" := safe_stat(.SD$row_height,
    FUN = sum, NA_value = NA_real_
  ), by = "colspan_group"]
  grid_data[, "cell_min_height" := safe_stat(.SD$row_min_height,
    FUN = sum, NA_value = NA_real_
  ), by = "colspan_group"]
  grid_data[, "cell_max_height" := safe_stat_ext(.SD$row_max_height,
    FUN = sum, LENGTH = max(.SD$colspan), NA_value = NA_real_
  ), by = "colspan_group"]
  grid_data[, "cell_height" := safe_stat(
    safe_stat(.SD$cell_height, .SD$cell_min_height, FUN = max, NA_value = NA_real_),
    .SD$cell_max_height,
    FUN = min, NA_value = NA_real_
  ), by = c("col_index", "row_index")]

  # keep only active cells
  grid_data <- grid_data[grid_data$rowspan > 0 & grid_data$colspan > 0, , drop = FALSE]

  # generate argument list for creating the cell viewports
  setorderv(grid_data, cols = c("row_index", "col_index"))
  grid_data[, "cell_vp" := mapply(
    function(row, colspan, column, rowspan) {
      list(
        layout.pos.row = seq(row, length.out = colspan),
        layout.pos.col = seq(column, length.out = rowspan),
        clip = "on"
      )
    },
    row = .SD$row_index,
    colspan = .SD$colspan,
    column = .SD$col_index,
    rowspan = .SD$rowspan,
    SIMPLIFY = FALSE
  )]

  # drop unneeded columns
  grid_data[, c(
    "col_width", "row_height", "row_min_height", "row_max_height",
    "hrule", "rowspan_group", "colspan_group"
  ) := NULL]

  grid_data
}


grid_data_add_cell_info <- function(grid_data, x) {
  keycols <- c(".part", ".row_id", ".col_id")
  spans <- fortify_span(x) # redondant avec get_grid_data, pas bien
  cell_data <- merge(
    as.data.table(information_data_cell(x)),
    spans,
    by = keycols
  )

  fortify_borders_data <- fortify_latex_borders(cell_data)
  # apply a correction to borders for vert. merged cells
  last_bottom_borders_data <- fortify_borders_data[, list(
    border.width.bottom = last(.SD$border.width.bottom),
    border.color.bottom = last(.SD$border.color.bottom)
  ), by = c(".part", ".col_id", "vspan_id")]
  fortify_borders_data$border.width.bottom <- NULL
  fortify_borders_data$border.color.bottom <- NULL
  fortify_borders_data <- merge(fortify_borders_data, last_bottom_borders_data, by = c(".part", ".col_id", "vspan_id"))

  fortify_borders_data <- fortify_borders_data[
    , .SD,
    .SDcols = c(
      ".part", ".row_id", ".col_id", "border.color.top", "border.color.bottom",
      "border.width.left", "border.color.left", "border.width.right",
      "border.color.right", "border.width.top", "border.width.bottom"
    )
  ]
  # apply a correction to overlapping vert. borders
  setorderv(fortify_borders_data, cols = c(".part", ".row_id", ".col_id"))
  fortify_borders_data[
    fortify_borders_data$border.width.right == shift(fortify_borders_data$border.width.left, type = "lead", fill = -1) &
      fortify_borders_data$.col_id != tail(x$col_keys, 1),
     c("border.width.right") := 0, by = c(".part", ".row_id")]

  cell_data <- cell_data[, .SD,
    .SDcols =
      setdiff(
        colnames(cell_data),
        c(
          "border.color.top", "border.color.bottom",
          "border.width.left", "border.color.left", "border.width.right",
          "border.color.right", "border.width.top", "border.width.bottom"
        )
      )
  ]

  cell_data <- merge(cell_data, fortify_borders_data, by = keycols)

  # merge with grid_data to keep only active cells
  cell_data <- merge(grid_data[, keycols, with = FALSE], cell_data, by = keycols)

  # generate argument list for creating the cell background rect
  cell_data[, "background" := mapply(
    function(fill) {
      gp <- gpar_background(fill)
      if (length(gp) > 0) {
        list(gp = gp)
      }
    },
    fill = .SD$background.color,
    SIMPLIFY = FALSE
  )]

  # generate argument list for creating the border segments
  cell_data[, "borders" := mapply(
    function(t, l, b, r) {
      list(
        if (length(t) > 0) {
          list(x0 = 0, x1 = 1, y0 = 1, y1 = 1, gp = t)
        },
        if (length(l) > 0) {
          list(x0 = 0, x1 = 0, y0 = 0, y1 = 1, gp = l)
        },
        if (length(b) > 0) {
          list(x0 = 0, x1 = 1, y0 = 0, y1 = 0, gp = b)
        },
        if (length(r) > 0) {
          list(x0 = 1, x1 = 1, y0 = 0, y1 = 1, gp = r)
        }
      )
    },
    t = mapply(
      gpar_border,
      width = cell_data$border.width.top,
      color = cell_data$border.color.top,
      style = cell_data$border.style.top,
      SIMPLIFY = FALSE
    ),
    l = mapply(
      gpar_border,
      width = cell_data$border.width.left,
      color = cell_data$border.color.left,
      style = cell_data$border.style.left,
      SIMPLIFY = FALSE
    ),
    b = mapply(
      gpar_border,
      width = cell_data$border.width.bottom,
      color = cell_data$border.color.bottom,
      style = cell_data$border.style.bottom,
      SIMPLIFY = FALSE
    ),
    r = mapply(
      gpar_border,
      width = cell_data$border.width.right,
      color = cell_data$border.color.right,
      style = cell_data$border.style.right,
      SIMPLIFY = FALSE
    ),
    SIMPLIFY = FALSE
  )]

  # set rotation angle
  cell_data[, "angle" := fcase(
    .SD$text.direction == "tbrl", 270,
    .SD$text.direction == "btlr", 90,
    default = 0
  )]

  # merge needed columns
  cell_data <- cell_data[, c(
    keycols, "background", "borders", "angle", "vertical.align"
  ), with = FALSE]
  grid_data <- merge(grid_data, cell_data, by = keycols, all.x = TRUE)
  setorderv(grid_data, cols = c("row_index", "col_index"))
  grid_data
}

#' @importFrom grid unit
grid_data_add_par_info <- function(grid_data, x) {
  par_data <- information_data_paragraph(x)

  # merge with grid_data to keep only active cells
  keycols <- c(".part", ".row_id", ".col_id")
  par_data <- merge(grid_data[, c(
    keycols, "vertical.align", "angle"
  ), with = FALSE], par_data, by = keycols)

  # calculate justification
  par_data[, "just" := mapply(
    calc_grid_just,
    halign = .SD$text.align, valign = .SD$vertical.align,
    SIMPLIFY = FALSE
  )]
  # calculate rotated justification
  par_data[, "justr" := mapply(
    calc_grid_rotated_just,
    just = .SD$just, angle = .SD$angle,
    SIMPLIFY = FALSE
  )]

  # set padding as units
  par_data[, "padding.top" := .SD$padding.top / 72]
  par_data[, "padding.left" := .SD$padding.left / 72]
  par_data[, "padding.bottom" := .SD$padding.bottom / 72]
  par_data[, "padding.right" := .SD$padding.right / 72]
  par_data[, "paddingx" := .SD$padding.left + .SD$padding.right]
  par_data[, "paddingy" := .SD$padding.top + .SD$padding.bottom]

  # generate argument list for creating the contents viewport
  par_data[, "contents_vp" := mapply(
    function(just, justr, t, l, b, r, angle) {
      x <- unit(just[[1]], "npc")
      if (just[[1]] == 0) {
        x <- x + unit(l, "in")
      } else if (just[[1]] == 1) {
        x <- x - unit(r, "in")
      }
      y <- unit(just[[2]], "npc")
      if (just[[2]] == 0) {
        y <- y + unit(b, "in")
      } else if (just[[2]] == 1) {
        y <- y - unit(t, "in")
      }
      list(
        x = x,
        y = y,
        just = justr,
        angle = angle,
        width = unit(1, "npc") - unit(l + r, "in"),
        height = unit(1, "npc") - unit(t + b, "in"),
        clip = "inherit"
      )
    },
    just = .SD$just,
    justr = .SD$justr,
    t = .SD$padding.top,
    l = .SD$padding.left,
    b = .SD$padding.bottom,
    r = .SD$padding.right,
    angle = .SD$angle,
    SIMPLIFY = FALSE
  )]

  # merge needed columns
  par_data <- par_data[, c(
    keycols, "line_spacing", "just", "justr", "paddingx", "paddingy", "contents_vp"
  ), with = FALSE]
  grid_data <- merge(grid_data, par_data, by = keycols, all.x = TRUE)
  setorderv(grid_data, cols = c("row_index", "col_index"))

  # merge cell parameters
  grid_data[, "cell_params" := mapply(
    list,
    min_height = .SD$cell_min_height,
    max_height = .SD$cell_max_height,
    just = .SD$just,
    justr = .SD$justr,
    paddingx = .SD$paddingx,
    paddingy = .SD$paddingy,
    angle = .SD$angle,
    lineheight = .SD$line_spacing,
    SIMPLIFY = FALSE
  )]

  grid_data
}

#' @importFrom grDevices is.raster
grid_data_add_chunk_info <- function(grid_data, x, autowidths, wrapping) {
  chunk_data <- information_data_chunk(x, expand_special_chars = FALSE)

  # merge with grid_data to keep only active cells
  keycols <- c(".part", ".row_id", ".col_id")
  chunk_data <- merge(
    grid_data[, c(keycols, "line_spacing", "angle"), with = FALSE],
    chunk_data,
    by = keycols
  )

  # chunk types
  chunk_data[, "is_raster" :=
    sapply(.SD$img_data, is.raster) | sapply(.SD$img_data, is.character)]
  chunk_data[, "is_equation" := !is.na(.SD$eq_data)]
  chunk_data[, "is_text" := !.SD$is_raster & !.SD$is_equation]

  # avoid CMD check warnings
  is_raster <- is_text <- txt <- is_newline <- is_space <-
    is_superscript <- is_subscript <- angle <- NULL

  # remove empty text
  chunk_data <- chunk_data[!((is_text) & txt %in% ""), , drop = FALSE]

  # remove breaks and tabs from superscript/subscript
  chunk_data[, "is_superscript" := .SD$is_text & .SD$vertical.align %in% "superscript"]
  chunk_data[, "is_subscript" := .SD$is_text & .SD$vertical.align %in% "subscript"]
  chunk_data[(is_superscript | is_subscript), "txt" := gsub("[\n\t]", "", .SD$txt)]

  # set chunk index
  chunk_data[, "chunk_index" := 1:.N, by = keycols]
  setorderv(chunk_data, cols = c(keycols, "chunk_index"))

  # calculate fontface
  chunk_data[(is_text), "font.face" := fcase(
    .SD$bold & !.SD$italic, 2L,
    !.SD$bold & .SD$italic, 3L,
    .SD$bold & .SD$italic, 4L,
    default = 1L
  )]

  # create gpar
  chunk_data[, "gp" := mapply(
    function(is_text, ...) {
      if (is_text) {
        gpar_text(...)
      } else {
        gpar()
      }
    },
    is_text = .SD$is_text,
    color = .SD$color,
    fontfamily = .SD$font.family,
    fontsize = .SD$font.size,
    fontface = .SD$font.face,
    lineheight = .SD$line_spacing,
    SIMPLIFY = FALSE
  )]

  # resolve image data
  if (is.character(chunk_data$img_data)) {
    # fix to avoid data.table complaining about casting from char to list
    chunk_data$img_data <- as.list(chunk_data$img_data)
  }
  chunk_data[(is_raster), "img_data" := mapply(
    calc_grid_image,
    .SD$img_data,
    width = .SD$width,
    height = .SD$height,
    SIMPLIFY = FALSE
  )]

  # create chunk .part data (parts split by newline)
  part_data <- chunk_data[, c(
    ".part", ".row_id", ".col_id", "line_spacing", "angle",
    "font.family", "font.size", "italic", "bold",
    "txt", "is_text", "is_superscript", "is_subscript", "width", "height",
    ".chunk_index", "chunk_index"
  ), with = FALSE]
  # expand by newline
  part_data <- expand_special_char(part_data, what = "\n", with = NA)
  # set part_index per chunk
  setorderv(part_data, cols = c(keycols, "chunk_index", ".chunk_index"))
  part_data[, "part_index" := 1:.N, by = c(keycols, "chunk_index")]
  setorderv(part_data, cols = c(keycols, "chunk_index", "part_index"))
  # calculate metrics
  part_data <- calc_grid_text_metrics(part_data)

  # calculate now content dimensions if autowidths is TRUE and wrapping is FALSE
  if (autowidths && !wrapping) {
    # create line index per chunk
    part_data[, c("line_index") := fifelse(.SD$is_newline, 1L, 0L)]
    part_data[, c("line_index") := cumsum(.SD$line_index) + 1L, by = keycols]
    # calculate line metrics
    line_data <- part_data[, list(
      line_width = sum(.SD$width, na.rm = TRUE),
      line_height = max(.SD$ascent, na.rm = TRUE) + max(.SD$descent, na.rm = TRUE)
    ), by = c(keycols, "line_index")]
    line_data <- line_data[, list(
      content_width = max(.SD$line_width, na.rm = TRUE),
      content_height = sum(.SD$line_height, na.rm = TRUE)
    ), by = keycols]
    part_data <- merge(part_data, line_data, by = keycols)
    part_data[angle != 0, c("content_width", "content_height") :=
      list(.SD$content_height, .SD$content_width)]

    # merge content_width/content_height to grid data
    content_data <- part_data[, list(
      content_width = first(.SD$content_width),
      content_height = first(.SD$content_height)
    ), by = keycols]
    grid_data <- merge(grid_data, content_data, by = keycols, all.x = TRUE)

    # adjust column widths & row heights
    grid_data <- grid_data_adjust_widths(grid_data)
    grid_data <- grid_data_adjust_heights(grid_data)

    # drop unneeded columns
    part_data[, c("line_index", "content_width", "content_height") := NULL]
    line_data <- NULL
  }

  # handle wrapping
  if (wrapping) {
    # create chunk word data (parts split by whitespace)
    word_data <- part_data
    word_data[, "wrapping" := fifelse(
      .SD$is_text & !.SD$is_space & !.SD$is_newline &
        !.SD$is_superscript & !.SD$is_subscript, "whitespace", "none"
    )]
    # split by wrapping method
    split_list <- split(word_data, word_data$wrapping, drop = FALSE)
    if (is.data.table(split_list$whitespace)) {
      # expand by whitespace
      split_list$whitespace <- expand_special_char(
        split_list$whitespace,
        what = "[ \t]", with = NA
      )
    }
    # bind them together
    word_data <- rbindlist(split_list, use.names = TRUE, fill = TRUE)
    split_list <- NULL

    # set word_index and word_count per chunk part
    setorderv(word_data, cols = c(keycols, "chunk_index", "part_index", ".chunk_index"))
    word_data[, c("word_index", "word_count") := list(1:.N, .N),
      by = c(keycols, "chunk_index", "part_index")
    ]
    setorderv(word_data, cols = c(keycols, "chunk_index", "part_index", "word_index"))

    # calculate metrics
    word_data <- calc_grid_text_metrics(word_data)

    # calculate now content dimensions if autowidths is TRUE and wrapping is TRUE
    if (autowidths) {
      # don't take into account whitespace dimensions, except newline char in the beggining
      word_data[, "part_width" := fifelse(
        .SD$is_newline & .SD$part_index > 1 | .SD$is_space, 0, .SD$width
      )]
      word_data[, "part_ascent" := fifelse(
        .SD$is_newline & .SD$part_index > 1 | .SD$is_space, 0, .SD$ascent
      )]
      word_data[, "part_descent" := fifelse(
        .SD$is_newline & .SD$part_index > 1 | .SD$is_space, 0, .SD$descent
      )]

      # calculate content metrics
      word_data[, "content_width" := max(.SD$part_width, na.rm = TRUE), by = keycols]
      word_data[, "content_height" :=
        (sum(.SD$part_width, na.rm = TRUE) / .SD$content_width) *
          (max(.SD$part_ascent, na.rm = TRUE) + max(.SD$part_descent, na.rm = TRUE)), by = keycols]
      word_data[angle != 0, c("content_width", "content_height") :=
        list(.SD$content_height, .SD$content_width)]

      # merge content_width to grid data
      content_data <- word_data[, list(
        content_width = first(.SD$content_width)
      ), by = keycols]
      grid_data <- merge(grid_data, content_data, by = keycols, all.x = TRUE)
      # adjust column widths
      grid_data <- grid_data_adjust_widths(grid_data)
      # get back cell width
      content_data <- grid_data[, list(
        content_width = first(.SD$cell_width)
      ), by = keycols]
      word_data[, "content_width" := NULL]
      word_data <- merge(word_data, content_data, by = keycols, all.x = TRUE)
      # now recalculate the content height
      word_data[, "content_height" :=
        (sum(.SD$part_width, na.rm = TRUE) / .SD$content_width) *
          (max(.SD$part_ascent, na.rm = TRUE) + max(.SD$part_descent, na.rm = TRUE)), by = keycols]
      word_data[angle != 0, c("content_width", "content_height") :=
        list(.SD$content_height, .SD$content_width)]
      # merge content_height to grid data
      content_data <- word_data[, list(
        content_height = first(.SD$content_height)
      ), by = keycols]
      grid_data <- merge(grid_data, content_data, by = keycols, all.x = TRUE)
      # adjust row heights
      grid_data <- grid_data_adjust_heights(grid_data)

      # drop not needed columns
      word_data[, c(
        "content_width", "content_height", "wrapping",
        "part_width", "part_ascent", "part_descent"
      ) := NULL]
    }

    # create chunk word data (parts split by any character)
    char_data <- word_data[
      (is_text & !is_space & !is_newline & !is_superscript & !is_subscript), ,
      drop = FALSE
    ]
    # expand by character
    char_data <- expand_special_char(char_data, what = ".", with = NA)

    # set word_index and word_count per chunk part
    setorderv(char_data, cols = c(keycols, "chunk_index", "part_index", "word_index", ".chunk_index"))
    char_data[, c("char_index", "char_count") := list(seq_len(.N), .N),
      by = c(keycols, "chunk_index", "part_index", "word_index")
    ]

    # calculate metrics
    if (nrow(char_data) > 0) {
      char_data <- calc_grid_text_metrics(char_data)
    }

    # merge char_count to word data
    word_char_data <- char_data[, list(
      char_count = first(.SD$char_count)
    ), by = c(keycols, "chunk_index", "part_index", "word_index")]
    word_data <- merge(word_data, word_char_data,
      by = c(keycols, "chunk_index", "part_index", "word_index"), all.x = TRUE
    )

    # merge word_count to part data
    part_word_data <- word_data[, list(
      word_count = first(.SD$word_count),
      char_count = sum(.SD$char_count)
    ), by = c(keycols, "chunk_index", "part_index")]
    part_data <- merge(part_data, part_word_data,
      by = c(keycols, "chunk_index", "part_index"), all.x = TRUE
    )

    # merge part/word/char data together
    word_index <- word_count <- char_index <- char_count <- NULL
    part_data <- rbindlist(
      list(
        part_data,
        word_data[word_count > 1], # only multiple words
        char_data[char_count > 1] # only multiple chars
      ),
      use.names = TRUE, fill = TRUE,
      idcol = "wrap_level" # set idcol to know where data came from
    )
    part_data[is.na(word_index), "word_index" := 0L]
    part_data[is.na(word_count), "word_count" := 0L]
    part_data[is.na(char_index), "char_index" := 0L]
    part_data[is.na(char_count), "char_count" := 0L]
    setorderv(part_data, cols = c(
      keycols, "chunk_index", "part_index", "word_index", "char_index"
    ))
    # set .chunk_index unique for each cell
    part_data[, ".chunk_index" := 1:.N, by = keycols]

    # set wrap child count
    part_data[, "child_count" := fcase(
      .SD$wrap_level == 1 & .SD$word_count > 1, .SD$word_count,
      .SD$wrap_level == 1 & .SD$char_count > 1, .SD$char_count,
      .SD$wrap_level == 2, .SD$char_count,
      default = 0L
    )]
    # adjust wrap level
    part_data[, "wrap_level" := fcase(
      .SD$wrap_level == 1, 1L,
      .SD$wrap_level == 2, 2L,
      .SD$wrap_level == 3 & .SD$word_count == 1, 2L,
      default = 3L
    )]

    # calculate wrap children indices
    # for any row which has wrapped children
    part_data[, "children_index" := list(calc_grid_wrap_children(.SD)),
      by = c(keycols, "chunk_index")
    ]
  } else { # no wrapping
    part_data[, ".chunk_index" := 1:.N, by = keycols]
    part_data[, "child_count" := 0L]
    part_data[, "children_index" := integer(0)]
  }
  setorderv(part_data, cols = c(keycols, ".chunk_index"))

  # replace special chars
  part_data[(is_newline), "txt" := ""]
  part_data[(is_space), "txt" := " "]

  # merge chunk data
  grid_data <- merge(
    grid_data,
    chunk_data[,
      list(
        chunk_data = list(
          data.table(
            chunk_index = .SD$chunk_index,
            is_text = .SD$is_text,
            is_raster = .SD$is_raster,
            is_equation = .SD$is_equation,
            is_underlined = .SD$underlined,
            is_bold = .SD$bold,
            is_italic = .SD$italic,
            valign = .SD$vertical.align,
            width = .SD$width,
            height = .SD$height,
            gp = .SD$gp,
            txt_data = .SD$txt,
            img_data = .SD$img_data,
            eq_data = .SD$eq_data,
            shading_color = .SD$shading.color
          )
        )
      ),
      by = keycols
    ],
    by = keycols, all.x = TRUE
  )

  # merge part data
  grid_data <- merge(
    grid_data,
    part_data[,
      list(
        chunk_part_data = list(
          data.table(
            .chunk_index = .SD$.chunk_index,
            chunk_index = .SD$chunk_index,
            child_count = .SD$child_count,
            children_index = .SD$children_index,
            row_index = 0L,
            col_index = 0L,
            is_newline = .SD$is_newline,
            is_whitespace = .SD$is_space,
            width = .SD$width,
            height = .SD$height,
            ascent = .SD$ascent,
            descent = .SD$descent,
            txt_data = .SD$txt
          )
        )
      ),
      by = keycols
    ],
    by = keycols, all.x = TRUE
  )
  setorderv(grid_data, cols = c("row_index", "col_index"))

  # drop unneeded columns
  grid_data[, c(
    "cell_min_height", "cell_max_height",
    "just", "justr", "paddingx", "paddingy", "angle", "line_spacing", "vertical.align"
  ) := NULL]

  grid_data
}

#' @importFrom data.table fsetdiff
grid_data_adjust_widths <- function(grid_data) {
  # collect the minimum width of each cell
  dat <- grid_data[, list(
    content_min_width = max(
      .SD$cell_width,
      safe_stat(.SD$content_width + .SD$paddingx, FUN = max, NA_value = NA_real_),
      na.rm = TRUE
    )
  ), by = c("col_index", "rowspan")]
  # separate columns with minimum span
  dat_minspan <- dat[, .SD[which.min(.SD$rowspan), ], by = "col_index"]
  # separate columns with maximum span
  dat_maxspan <- fsetdiff(dat, dat_minspan)
  if (nrow(dat_maxspan) > 0) {
    col_index <- NULL
    # recalculate minimum width for spanned cells
    dat_maxspan[, c("prev_width", "content_min_width") := list(
      .SD$content_min_width,
      mapply(
        function(index, span, width) {
          sum(dat_minspan[col_index >= index & col_index < index + span]$content_min_width)
        },
        .SD$col_index, .SD$rowspan, .SD$content_min_width
      )
    )]
    # check the difference of new width vs the previous
    dat_maxspan[, "diff" := .SD$prev_width - .SD$content_min_width]
    # if there is a positive difference, it means that some spanned cells are wider than
    # the cummulative widths of their columns
    # in that case we need to re-adjust the column widths
    if (any(dat_maxspan$diff > 0)) {
      dat_overflow <- dat_maxspan[diff > 0, .SD[which.max(.SD$diff), ], by = "col_index"]
      dat_overflow[, "group" := .SD$col_index]
      dat_overflow <- dat_overflow[, list(
        col_index = seq.int(from = .SD$col_index, length.out = .SD$rowspan, by = 1L),
        diff = .SD$diff / .SD$rowspan
      ), by = "group"]
      dat_overflow <- dat_overflow[, .SD[which.max(.SD$diff), ], by = "col_index"]
      dat_overflow[, "group" := NULL]
      dat <- merge(
        dat,
        dat_overflow,
        by = "col_index",
        all.x = TRUE
      )
      dat[, "diff" := .SD$diff * .SD$rowspan]
      dat[, "content_min_width" := sum(
        .SD$content_min_width, .SD$diff,
        na.rm = TRUE
      ), by = c("col_index", "rowspan")]
      dat[, "diff" := NULL]
      dat_minspan <- dat[, .SD[which.min(.SD$rowspan), ], by = "col_index"]
      dat_maxspan <- fsetdiff(dat, dat_minspan)
      dat_maxspan[, c("prev_width", "content_min_width") := list(
        .SD$content_min_width,
        mapply(
          function(index, span, width) {
            sum(dat_minspan[col_index >= index & col_index < index + span]$content_min_width)
          },
          .SD$col_index, .SD$rowspan, .SD$content_min_width
        )
      )]
    }
    dat <- rbindlist(list(
      dat_minspan[, c("col_index", "rowspan", "content_min_width")],
      dat_maxspan[, c("col_index", "rowspan", "content_min_width")]
    ))
  }
  grid_data <- merge(grid_data, dat, by = c("col_index", "rowspan"), all.x = TRUE)
  grid_data[, "cell_width" := .SD$content_min_width]
  grid_data
}

grid_data_adjust_heights <- function(grid_data) {
  # collect the minimum height of each cell
  dat <- grid_data[, list(
    content_min_height = safe_stat(
      safe_stat(
        .SD$cell_min_height,
        safe_stat(.SD$cell_height, FUN = max, NA_value = NA_real_),
        safe_stat(.SD$content_height + .SD$paddingy, FUN = max, NA_value = NA_real_),
        FUN = max, NA_value = NA_real_
      ),
      .SD$cell_max_height,
      FUN = min, NA_value = NA_real_
    )
  ), by = c("row_index", "colspan")]
  # separate rows with minimum span
  dat_minspan <- dat[, .SD[which.min(.SD$colspan), ], by = "row_index"]
  # separate rows with maximum span
  dat_maxspan <- fsetdiff(dat, dat_minspan)
  if (nrow(dat_maxspan) > 0) {
    row_index <- NULL
    # recalculate minimum height for spanned cells
    dat_maxspan[, c("prev_height", "content_min_height") := list(
      .SD$content_min_height,
      mapply(
        function(index, span, height) {
          sum(dat_minspan[row_index >= index & row_index < index + span]$content_min_height)
        },
        .SD$row_index, .SD$colspan, .SD$content_min_height
      )
    )]
    # check the difference of new height vs the previous
    dat_maxspan[, "diff" := .SD$prev_height - .SD$content_min_height]
    # if there is a positive difference, it means that some spanned cells are taller than
    # the cummulative heights of their rows
    # in that case we need to re-adjust the row heights
    if (any(dat_maxspan$diff > 0)) {
      dat_overflow <- dat_maxspan[diff > 0, .SD[which.max(.SD$diff), ], by = "row_index"]
      dat_overflow[, "group" := .SD$row_index]
      dat_overflow <- dat_overflow[, list(
        row_index = seq.int(from = .SD$row_index, length.out = .SD$colspan, by = 1L),
        diff = diff / .SD$colspan
      ), by = "group"]
      dat_overflow <- dat_overflow[, .SD[which.max(.SD$diff), ], by = "row_index"]
      dat_overflow[, "group" := NULL]
      dat <- merge(
        dat,
        dat_overflow,
        by = "row_index",
        all.x = TRUE
      )
      dat[, "diff" := .SD$diff * .SD$colspan]
      dat[, "content_min_height" := sum(
        .SD$content_min_height, .SD$diff,
        na.rm = TRUE
      ), by = c("row_index", "colspan")]
      dat[, "diff" := NULL]
      dat_minspan <- dat[, .SD[which.min(.SD$colspan), ], by = "row_index"]
      dat_maxspan <- fsetdiff(dat, dat_minspan)
      dat_maxspan[, c("prev_height", "content_min_height") := list(
        .SD$content_min_height,
        mapply(
          function(index, span, height) {
            sum(dat_minspan[row_index >= index & row_index < index + span]$content_min_height)
          },
          .SD$row_index, .SD$colspan, .SD$content_min_height
        )
      )]
    }
    dat <- rbindlist(list(
      dat_minspan[, c("row_index", "colspan", "content_min_height")],
      dat_maxspan[, c("row_index", "colspan", "content_min_height")]
    ))
  }
  grid_data <- merge(grid_data, dat, by = c("row_index", "colspan"), all.x = TRUE)
  grid_data[, "cell_height" := .SD$content_min_height]
  grid_data
}

# gpar --------------------------------------------------------------------

#' @importFrom grid gpar
gpar_background <- function(fill) {
  if (isTRUE(!is.na(fill) && fill != "transparent")) {
    gpar(
      lwd = 0.5,
      fill = fill,
      col = fill
    )
  }
}

gpar_ltys <- c(solid = 1, dashed = 2, dotted = 3, dotdash = 4, longdash = 5, twodash = 6)

gpar_border <- function(width, color, style) {
  if (isTRUE(width > 0 && !is.na(color) && !color %in% "transparent" &&
    (style %in% gpar_ltys || style %in% names(gpar_ltys)))) {
    gpar(
      lwd = width * 72.27 / 25.4,
      col = color,
      lty = style
    )
  }
}

gpar_text <- function(color, fontfamily, fontsize, fontface, lineheight) {
  gpar(
    col = color,
    fontfamily = fontfamily,
    fontsize = fontsize,
    fontface = fontface,
    lineheight = lineheight
  )
}

# utils -------------------------------------------------------------------

# helper to create grouping by rowspan or colspan
calc_grid_span_group <- function(x) {
  x <- x[x > 0]
  inverse.rle(structure(
    list(lengths = x, values = seq_along(x)),
    class = "rle"
  ))
}

calc_grid_just <- function(halign, valign) {
  c(
    # hjust
    fcase(
      halign == "left", 0,
      halign == "right", 1,
      default = 0.5
    ),
    # vjust
    fcase(
      valign == "bottom", 0,
      valign == "top", 1,
      default = 0.5
    )
  )
}

calc_grid_rotated_just <- function(just, angle) {
  hjust <- just[[1]]
  vjust <- just[[2]]
  c(
    # hjust
    fcase(
      0 <= angle & angle < 90, hjust,
      90 <= angle & angle < 180,
      fifelse(vjust == 0, 0, fifelse(vjust == 1, 1, 1 - vjust)),
      180 <= angle & angle < 270, 1 - hjust,
      270 <= angle & angle < 360,
      fifelse(vjust == 0, 1, fifelse(vjust == 1, 0, vjust))
    ),
    # vjust
    fcase(
      0 <= angle & angle < 90, vjust,
      90 <= angle & angle < 180,
      fifelse(hjust == 0, 1, fifelse(hjust == 1, 0, hjust)),
      180 <= angle & angle < 270, 1 - vjust,
      270 <= angle & angle < 360,
      fifelse(hjust == 0, 0, fifelse(hjust == 1, 1, 1 - hjust))
    )
  )
}

#' @importFrom gdtools strings_sizes
calc_grid_text_metrics <- function(dat) {
  # avoid CMD check warnings
  is_text <- is_newline <- is_space <- is_superscript <- is_subscript <- NULL

  # handle special chars
  dat[, "is_newline" := .SD$is_text & .SD$txt %in% "\n"]
  dat[, "txt" := gsub("\t", "\u020\u020\u020\u020", .SD$txt)]
  dat[, "is_space" := .SD$is_text & .SD$txt %in% " "]
  # temporarily replace these, so that they get some height
  dat[(is_newline), "txt" := "."]

  # calculate string metrics
  txt_metrics <- gdtools::strings_sizes(
    dat$txt,
    fontname = dat$font.family,
    fontsize = dat$font.size,
    bold = dat$bold,
    italic = dat$italic
  )
  colnames(txt_metrics) <- c("part_width", "part_ascent", "part_descent")
  dat <- cbind(dat, txt_metrics)

  # set width/ascent/descent/height
  dat[(is_text), "width" := .SD$part_width]
  dat[(is_superscript | is_subscript), "width" := .SD$width * 0.75]
  dat[(is_text), "ascent" := .SD$part_ascent * .SD$line_spacing]
  dat[(is_text), "descent" := .SD$part_descent * .SD$line_spacing]
  dat[(is_text), "height" := .SD$ascent + .SD$descent]
  dat[!(is_text), c("ascent", "descent") := list(.SD$height, 0)]
  dat[(is_newline), "txt" := "\n"]

  # drop not needed columns
  dat[, c("part_width", "part_ascent", "part_descent") := NULL]

  # done
  dat
}

calc_grid_wrap_children <- function(dat) {
  wrap_level <- .chunk_index <- NULL
  mapply(
    function(level, index, child_count) {
      if (child_count > 0) {
        head(
          dat[wrap_level == (level + 1) & .chunk_index > index, , drop = FALSE],
          n = child_count
        )$.chunk_index
      } else {
        integer(0)
      }
    },
    dat$wrap_level,
    dat$.chunk_index,
    dat$child_count,
    SIMPLIFY = FALSE
  )
}

calc_grid_label <- function(x,
                            valign = "baseline",
                            is_underlined = FALSE,
                            is_bold = FALSE,
                            is_italic = FALSE) {
  if (valign %in% c("superscript", "subscript") || isTRUE(is_underlined)) {
    x <- paste0("\"", x, "\"")
    if (valign %in% "superscript") {
      x <- paste0("\"\"^", x)
    } else if (valign %in% "subscript") {
      x <- paste0("\"\"[", x, "]")
    }
    if (isTRUE(is_underlined)) {
      x <- paste0("underline(", x, ")")
    }
    if (isTRUE(is_bold) && isTRUE(is_italic)) {
      x <- paste0("bolditalic(", x, ")")
    } else if (isTRUE(is_bold)) {
      x <- paste0("bold(", x, ")")
    } else if (isTRUE(is_italic)) {
      x <- paste0("italic(", x, ")")
    }
    parse(text = x)
  } else {
    x
  }
}

blank_raster_image <- as.raster(matrix("transparent", nrow = 1, ncol = 1))

calc_grid_image <- function(img_data, width = NULL, height = NULL) {
  image <- blank_raster_image
  if (is.raster(img_data)) {
    image <- img_data
    class(image) <- c("flextableRasterChunk", class(image))
  } else if (is.character(img_data)) {
    if (!file.exists(img_data)) {
      warning(sprintf("file '%s' can not be found.", img_data))
    } else if (requireNamespace("magick", quietly = TRUE)) {
      tryCatch(
        {
          if (grepl("\\.svg$", ignore.case = TRUE, x = img_data)) {
            image <- magick::image_read_svg(img_data, width * 72, height * 72)
          } else {
            image <- magick::image_read(img_data)
          }
          image <- as.raster(image)
        },
        error = function(e) {
          warning("error reading image: ", e)
        }
      )
    } else {
      warning(sprintf("package 'magick' is required to read image files"))
    }
  }
  image
}
