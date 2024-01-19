# fpstruct ------

fpstruct <- function(nrow, keys, default) {
  ncol <- length(keys)
  data <- rep(default, length.out = nrow * ncol)
  map_data <- matrix(data = data, nrow = nrow, ncol = ncol, dimnames = list(NULL, keys))

  x <- list(data = map_data, keys = keys, nrow = nrow, ncol = ncol, default = default)
  class(x) <- "fpstruct"
  x
}
`[<-.fpstruct` <- function(x, i, j, value) {
  x$data[i, j] <- value
  x
}

delete_row_from_fpstruct <- function(x, i) {
  x$data <- x$data[-i, , drop = FALSE]
  x$nrow <- x$nrow - length(i)
  x
}
delete_col_from_fpstruct <- function(x, j) {

  if(is.null(x$data)) stop("unexpected error, could not find any data to drop")
  x$data <- x$data[, !colnames(x$data) %in% j, drop = FALSE]
  x$ncol <- x$ncol - length(j)
  x$keys <- setdiff(x$keys, j)

  x
}

`[.fpstruct` <- function(x, i, j) {
  get_fpstruct_elements(x = x, i = i, j = j)
}
get_fpstruct_elements <- function(x, i, j) {
  if (is.null(x$data)) {
    stop("data coumpound does not exits.")
  }
  x$data[i, j, drop = FALSE]
}


#' @importFrom utils head tail
add_rows_fpstruct <- function(x, nrows, first, default = x$default, ...) {
  if (nrow(x$data) < 1) {
    new <- matrix(rep(default, x$ncol * nrows), ncol = x$ncol)
  } else if (first) {
    default <- as.vector(head(x$data, n = 1))
    new <- matrix(rep(default, each = nrows), ncol = x$ncol)
  } else {
    default <- as.vector(tail(x$data, n = 1))
    new <- matrix(rep(default, each = nrows), ncol = x$ncol)
  }
  if (first) {
    x$data <- rbind(new, x$data)
  } else {
    x$data <- rbind(x$data, new)
  }
  x$nrow <- nrow(x$data)
  x
}

# text_struct ------
text_struct <- function(nrow, keys,
                        color = "black", font.size = 10,
                        bold = FALSE, italic = FALSE, underlined = FALSE,
                        font.family = "Arial",
                        hansi.family = "Arial", eastasia.family = "Arial", cs.family = "Arial",
                        vertical.align = "baseline",
                        shading.color = "transparent", ...) {
  x <- list(
    color = fpstruct(nrow = nrow, keys = keys, default = color),
    font.size = fpstruct(nrow = nrow, keys = keys, default = font.size),
    bold = fpstruct(nrow = nrow, keys = keys, default = bold),
    italic = fpstruct(nrow = nrow, keys = keys, default = italic),
    underlined = fpstruct(nrow = nrow, keys = keys, default = underlined),
    font.family = fpstruct(nrow = nrow, keys = keys, default = font.family),
    hansi.family = fpstruct(nrow = nrow, keys = keys, default = hansi.family),
    eastasia.family = fpstruct(nrow = nrow, keys = keys, default = eastasia.family),
    cs.family = fpstruct(nrow = nrow, keys = keys, default = cs.family),
    vertical.align = fpstruct(nrow = nrow, keys = keys, default = vertical.align),
    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color)
  )
  class(x) <- "text_struct"
  x
}

`[<-.text_struct` <- function(x, i, j, property, value) {
  if (inherits(value, "fp_text")) {
    for (property in intersect(names(value), names(x))) {
      x[[property]][i, j] <- value[[property]]
    }
  } else if (property %in% names(x)) {
    x[[property]][i, j] <- value
  }

  x
}
`[.text_struct` <- function(x, i, j, property, value) {
  x[[property]][i, j]
}

delete_style_row <- function(x, i) {
  for (property in names(x)) {
    x[[property]] <- delete_row_from_fpstruct(x[[property]], i)
  }
  x
}
delete_style_col <- function(x, j) {
  for (property in names(x)) {
    x[[property]] <- delete_col_from_fpstruct(x[[property]], j)
  }
  x
}

print.text_struct <- function(x, ...) {
  dims <- dim(x$color$data)
  cat("a text_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

add_rows_to_struct <- function(x, nrows, first, ...) {
  for (i in seq_len(length(x))) {
    x[[i]] <- add_rows_fpstruct(x[[i]], nrows, first = first)
  }
  x
}

text_struct_to_df <- function(object, ...) {
  data <- lapply(object, function(x) {
    as.vector(x$data)
  })
  data$.row_id <- rep(seq_len(nrow(object$color$data)), ncol(object$color$data))
  data$.col_id <- rep(object$color$keys, each = nrow(object$color$data))
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$.col_id <- factor(data$.col_id, levels = object$color$keys)
  data
}


# par_struct -----
par_struct <- function(nrow, keys,
                       text.align = "left",
                       line_spacing = 1,
                       padding.bottom = 0, padding.top = 0,
                       padding.left = 0, padding.right = 0,
                       border.width.bottom = 0, border.width.top = 0, border.width.left = 0, border.width.right = 0,
                       border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                       border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                       keep_with_next = FALSE,
                       shading.color = "transparent", ...) {
  x <- list(
    text.align = fpstruct(nrow = nrow, keys = keys, default = text.align),
    padding.bottom = fpstruct(nrow = nrow, keys = keys, default = padding.bottom),
    padding.top = fpstruct(nrow = nrow, keys = keys, default = padding.top),
    padding.left = fpstruct(nrow = nrow, keys = keys, default = padding.left),
    padding.right = fpstruct(nrow = nrow, keys = keys, default = padding.right),
    line_spacing = fpstruct(nrow = nrow, keys = keys, default = line_spacing),
    border.width.bottom = fpstruct(nrow = nrow, keys = keys, default = border.width.bottom),
    border.width.top = fpstruct(nrow = nrow, keys = keys, default = border.width.top),
    border.width.left = fpstruct(nrow = nrow, keys = keys, default = border.width.left),
    border.width.right = fpstruct(nrow = nrow, keys = keys, default = border.width.right),
    border.color.bottom = fpstruct(nrow = nrow, keys = keys, default = border.color.bottom),
    border.color.top = fpstruct(nrow = nrow, keys = keys, default = border.color.top),
    border.color.left = fpstruct(nrow = nrow, keys = keys, default = border.color.left),
    border.color.right = fpstruct(nrow = nrow, keys = keys, default = border.color.right),
    border.style.bottom = fpstruct(nrow = nrow, keys = keys, default = border.style.bottom),
    border.style.top = fpstruct(nrow = nrow, keys = keys, default = border.style.top),
    border.style.left = fpstruct(nrow = nrow, keys = keys, default = border.style.left),
    border.style.right = fpstruct(nrow = nrow, keys = keys, default = border.style.right),
    shading.color = fpstruct(nrow = nrow, keys = keys, default = shading.color),
    keep_with_next = fpstruct(nrow = nrow, keys = keys, default = keep_with_next)
  )
  class(x) <- "par_struct"
  x
}


print.par_struct <- function(x, ...) {
  dims <- dim(x$text.align$data)
  cat("a par_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

`[<-.par_struct` <- function(x, i, j, property, value) {
  if (inherits(value, "fp_par")) {
    value <- cast_borders(value)
    for (property in intersect(names(value), names(x))) {
      x[[property]][i, j] <- value[[property]]
    }
  } else if (property %in% names(x)) {
    x[[property]][i, j] <- value
  }

  x
}


`[.par_struct` <- function(x, i, j, property) {
  x[[property]][i, j]
}

par_struct_to_df <- function(object, ...) {
  data <- lapply(object, function(x) {
    as.vector(x$data)
  })
  data$.row_id <- rep(seq_len(nrow(object$text.align$data)), ncol(object$text.align$data))
  data$.col_id <- rep(object$text.align$keys, each = nrow(object$text.align$data))
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$.col_id <- factor(data$.col_id, levels = object$text.align$keys)
  data
}


# cell_struct -----
cell_struct <- function(nrow, keys,
                        vertical.align = "top", text.direction = "lrtb",
                        margin.bottom = 0, margin.top = 0,
                        margin.left = 0, margin.right = 0,
                        border.width.bottom = 1, border.width.top = 1, border.width.left = 1, border.width.right = 1,
                        border.color.bottom = "transparent", border.color.top = "transparent", border.color.left = "transparent", border.color.right = "transparent",
                        border.style.bottom = "solid", border.style.top = "solid", border.style.left = "solid", border.style.right = "solid",
                        background.color = "#34CC27", width = NA_real_, height = NA_real_, hrule = "auto",
                        ...) {
  check_choice(value = vertical.align, choices = c("top", "center", "bottom"))
  check_choice(value = text.direction, choices = c("lrtb", "tbrl", "btlr"))

  x <- list(
    vertical.align = fpstruct(nrow = nrow, keys = keys, default = vertical.align),
    width = fpstruct(nrow = nrow, keys = keys, default = width),
    height = fpstruct(nrow = nrow, keys = keys, default = height),
    margin.bottom = fpstruct(nrow = nrow, keys = keys, default = margin.bottom),
    margin.top = fpstruct(nrow = nrow, keys = keys, default = margin.top),
    margin.left = fpstruct(nrow = nrow, keys = keys, default = margin.left),
    margin.right = fpstruct(nrow = nrow, keys = keys, default = margin.right),
    border.width.bottom = fpstruct(nrow = nrow, keys = keys, default = border.width.bottom),
    border.width.top = fpstruct(nrow = nrow, keys = keys, default = border.width.top),
    border.width.left = fpstruct(nrow = nrow, keys = keys, default = border.width.left),
    border.width.right = fpstruct(nrow = nrow, keys = keys, default = border.width.right),
    border.color.bottom = fpstruct(nrow = nrow, keys = keys, default = border.color.bottom),
    border.color.top = fpstruct(nrow = nrow, keys = keys, default = border.color.top),
    border.color.left = fpstruct(nrow = nrow, keys = keys, default = border.color.left),
    border.color.right = fpstruct(nrow = nrow, keys = keys, default = border.color.right),
    border.style.bottom = fpstruct(nrow = nrow, keys = keys, default = border.style.bottom),
    border.style.top = fpstruct(nrow = nrow, keys = keys, default = border.style.top),
    border.style.left = fpstruct(nrow = nrow, keys = keys, default = border.style.left),
    border.style.right = fpstruct(nrow = nrow, keys = keys, default = border.style.right),
    text.direction = fpstruct(nrow = nrow, keys = keys, default = text.direction),
    background.color = fpstruct(nrow = nrow, keys = keys, default = background.color),
    hrule = fpstruct(nrow = nrow, keys = keys, default = hrule)
  )
  class(x) <- "cell_struct"
  x
}

`[<-.cell_struct` <- function(x, i, j, property, value) {
  if (inherits(value, "fp_cell")) {
    value <- cast_borders(value)
    for (property in intersect(names(value), names(x))) {
      x[[property]][i, j] <- value[[property]]
    }
  } else if (property %in% names(x)) {
    x[[property]][i, j] <- value
  }

  x
}
`[.cell_struct` <- function(x, i, j, property) {
  x[[property]][i, j]
}

print.cell_struct <- function(x, ...) {
  dims <- dim(x$background.color$data)
  cat("a cell_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

cell_struct_to_df <- function(object, ...) {
  data <- lapply(object, function(x) {
    as.vector(x$data)
  })

  data$.row_id <- rep(seq_len(nrow(object$background.color$data)), ncol(object$background.color$data))
  data$.col_id <- rep(object$background.color$keys, each = nrow(object$background.color$data))
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data$.col_id <- factor(data$.col_id, levels = object$background.color$keys)
  data
}


# chunkset_struct ---------------------------------------------------------

# This object is used to capture paragraphs of a part of a flextable
# It is a matrix, each column is a colkey, each row is a row
# It contains paragraphs, paragraphs are made of chunks
new_chunkset_struct <- function(col_keys, data) {
  chunkdata <- fpstruct(nrow = nrow(data), keys = col_keys, default = as_paragraph(as_chunk("")))
  class(chunkdata) <- c("chunkset_struct")

  if (nrow(data) > 0) {
    newchunkdata <- lapply(
      data[col_keys],
      function(x) {
        as_paragraph(as_chunk(x, formatter = format_fun.default))
      }
    )
    newchunkdata <- matrix(
      do.call(c, newchunkdata),
      ncol = length(col_keys),
      dimnames = list(NULL, col_keys))
    chunkdata <- set_chunkset_struct_element(
      x = chunkdata,
      i = seq_len(nrow(data)),
      j = col_keys,
      value = newchunkdata)
  }
  chunkdata
}

add_rows_to_chunkset_struct <- function(x, nrows, first, data, ...) {
  names_ <- names(data)
  stopifnot(!is.null(names_))

  x <- add_rows_fpstruct(x, nrows, first = first, default = as_paragraph(as_chunk("")))
  if (first) {
    id <- seq_len(nrows)
  } else {
    id <- rev(rev(seq_len(x$nrow))[seq_len(nrows)])
  }

  newchunkdata <- lapply(data[x$keys], function(x) as_paragraph(as_chunk(x, formatter = format_fun.default)))
  newchunkdata <- matrix(
    do.call(c, newchunkdata),
    ncol = length(x$keys),
    dimnames = list(NULL, x$keys))

  x <- set_chunkset_struct_element(
    x = x,
    i = id, j = x$keys, value = newchunkdata)
  x
}

print.chunkset_struct <- function(x, ...) {
  dims <- dim(x$data)
  cat("a chunkset_struct with ", dims[1], " rows and ", dims[2], " columns", sep = "")
}

as_chunkset_struct <- function(l_paragraph, keys, i = NULL) {
  if (!is.null(i) &&
      length(l_paragraph) == length(i) &&
      length(keys) > 1) {
    l_paragraph <- rep(l_paragraph, length(keys))
  }
  matrix(
    data = l_paragraph,
    ncol = length(keys),
    dimnames = list(NULL, keys)
  )
}

is_paragraph <- function(x) {
  chunk_str_names <- c("txt", "font.size", "italic", "bold", "underlined", "color",
                       "shading.color", "font.family", "hansi.family", "eastasia.family",
                       "cs.family", "vertical.align", "width", "height", "url", "eq_data",
                       "word_field_data", "img_data",
                       ".chunk_index")
  is.data.frame(x) &&
    all(colnames(x) %in% chunk_str_names)

}
set_chunkset_struct_element <- function(x, i, j, value) {

  names_ <- colnames(value)
  stopifnot(
    is.matrix(value),
    !is.null(names_),
    mode(value) == "list",
    all(sapply(value, is_paragraph)),
    all(names_ %in% x$keys)
  )

  x$data[i, j] <- value
  x
}

append_chunkset_struct_element <- function(x, i, j, chunk_data, last = TRUE) {
  chunk_str_names <- c("txt", "font.size", "italic", "bold", "underlined", "color",
                   "shading.color", "font.family", "hansi.family", "eastasia.family",
                   "cs.family", "vertical.align", "width", "height", "url", "eq_data",
                   "word_field_data", "img_data")
  stopifnot(
    is.data.frame(chunk_data),
    all(chunk_str_names %in% colnames(chunk_data))
  )
  chunk_data <- chunk_data[, chunk_str_names, drop = FALSE]

  chunk_data_length <- nrow(chunk_data)
  i_length <- length(i)
  j_length <- length(j)
  expected_length <- j_length * i_length

  if (chunk_data_length == 1L && i_length != chunk_data_length) {
    chunk_data <- rep(list(chunk_data), i_length)
    chunk_data <- rbind_match_columns(chunk_data)
  }

  if (expected_length / nrow(chunk_data) == j_length) {
    chunk_data <- rep(list(chunk_data), j_length)
    chunk_data <- rbind_match_columns(chunk_data)
  }

  stopifnot(nrow(chunk_data) == expected_length)

  if (nrow(chunk_data) == 1) {
    chunk_data <- list(chunk_data)
  } else {
    chunk_data <- split(chunk_data, seq_len(expected_length))
    names(chunk_data) <- NULL
  }

  values <- get_chunkset_struct_element(x, i = i, j = j)
  values <- do.call(c, apply(values, 2, function(x) x))
  names(values) <- NULL

  values <- mapply(
    function(x, y, last = TRUE) {
      if (last) {
        y$.chunk_index <- max(x$.chunk_index, na.rm = TRUE) + 1
        x <- rbind_match_columns(list(x, y))
      } else {
        y$.chunk_index <- min(x$.chunk_index, na.rm = TRUE) - 1
        x <- rbind_match_columns(list(y, x))
      }
      x$.chunk_index <- rleid(x$.chunk_index)
      x
    },
    x = values,
    y = chunk_data, SIMPLIFY = FALSE,
    MoreArgs = list(last = last)
  )

  x$data[i, j] <- values
  x
}

get_chunkset_struct_element <- function(x, i, j) {
  x$data[i, j, drop = FALSE]
}

`[.chunkset_struct` <- function(x, i, j) {
  stop("you should not see this message")
  x$data[i, j]
}

replace_missing_fptext_by_default <- function(x, default) {
  by_columns <- c(
    "font.size", "italic", "bold", "underlined", "color", "shading.color",
    "font.family", "hansi.family", "eastasia.family", "cs.family",
    "vertical.align"
  )

  keys <- default[, setdiff(names(default), by_columns), drop = FALSE]
  values <- default[, by_columns, drop = FALSE]
  names(values) <- paste0(by_columns, "_default")
  defdata <- cbind(keys, values)

  newx <- x
  setDT(newx)
  setDT(defdata)
  newx <- newx[defdata, on = names(keys)]
  setDF(newx)
  for (j in by_columns) {
    if (!is.null(newx[[j]])) {
      newx[[j]] <- ifelse(is.na(newx[[j]]), newx[[paste0(j, "_default")]], newx[[j]])
    } else {
      newx[[j]] <- newx[[paste0(j, "_default")]]
    }
    newx[[paste0(j, "_default")]] <- NULL
  }
  newx
}
