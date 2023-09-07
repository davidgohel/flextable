merge_rle <- function(values) {
  rle_ <- rle(x = values)

  vout <- lapply(rle_$lengths, function(l) {
    out <- rep(0L, l)
    out[1] <- l
    out
  })
  as.integer(unlist(x = vout))
}

check_merge <- function(x) {
  row_check <- all(rowSums(x$spans$rows) == ncol(x$spans$rows))
  col_check <- all(colSums(x$spans$columns) == nrow(x$spans$columns))

  if (!row_check || !col_check) {
    stop("invalid merging instructions", call. = FALSE)
  }
  x
}
span_columns <- function(x, columns = NULL, target = columns, combine = FALSE) {
  if (!all(columns %in% colnames(x$dataset))) {
    wrong_col <- columns[!columns %in% colnames(x$dataset)]
    stop(
      sprintf(
        "`%s` is using unknown variable(s): %s",
        "columns",
        paste0("`", wrong_col, "`", collapse = ",")
      ),
      call. = FALSE
    )
  }
  if (!all(target %in% x$col_keys)) {
    wrong_col <- target[!target %in% x$col_keys]
    stop(
      sprintf(
        "`%s` is using unknown variable(s): %s",
        "target",
        paste0("`", wrong_col, "`", collapse = ",")
      ),
      call. = FALSE
    )
  }

  if (length(target) == 1) {
    target <- rep(target, length(columns))
  }
  if (length(columns) == 1) {
    columns <- rep(columns, length(target))
  }

  if (combine) {
    temp <- rep(list(NULL), length(columns))
    for (k in seq_along(columns)) {
      column <- columns[k]
      if (column %in% x$col_keys) {
        values <- sapply(x$content[, columns[k]], function(x) {
          paste(x$txt, collapse = "")
        })
      } else {
        values <- format(x$dataset[[column]], trim = TRUE, justify = "left")
      }
      temp[[k]] <- values
    }
    values <- do.call(cbind, temp)
    values <- apply(values, 1, paste0, collapse = "_")
    x$spans$columns[, match(target, x$col_keys)] <- merge_rle(values)
  } else {
    for (k in seq_along(columns)) {
      column <- columns[k]
      if (column %in% x$col_keys) {
        values <- sapply(x$content[, columns[k]], function(x) {
          paste(x$txt, collapse = "")
        })
      } else {
        values <- format(x$dataset[[column]], trim = TRUE, justify = "left")
      }
      x$spans$columns[, match(target[k], x$col_keys)] <- merge_rle(values)
    }
  }

  check_merge(x)
}

span_cells_at <- function(x, columns = NULL, rows = NULL) {
  if (is.null(columns)) {
    columns <- x$col_keys
  }
  if (is.null(rows)) {
    rows <- get_rows_id(x, i = rows)
  }

  stopifnot(all(columns %in% x$col_keys))

  row_id <- match(rows, seq_len(nrow(x$dataset)))
  col_id <- match(columns, x$col_keys)

  test_valid_r <- (length(row_id) > 1 && all(diff(row_id) == 1)) || length(row_id) == 1
  test_valid_c <- (length(col_id) > 1 && all(diff(col_id) == 1)) || length(col_id) == 1

  if (!test_valid_r) {
    stop("selected rows should all be consecutive")
  }
  if (!test_valid_c) {
    stop("selected columns should all be consecutive")
  }

  x$spans$columns[row_id, col_id] <- 0
  x$spans$rows[row_id, col_id] <- 0
  x$spans$columns[row_id[1], col_id] <- length(row_id)
  x$spans$rows[row_id, col_id[1]] <- length(col_id)

  check_merge(x)
}

span_rows <- function(x, rows = NULL) {
  row_id <- get_rows_id(x, i = rows)

  for (rowi in row_id) {
    values <- sapply(x$content[rowi, ], function(x) {
      paste(x$txt, collapse = "")
    })
    x$spans$rows[rowi, ] <- merge_rle(values)
  }

  check_merge(x)
}

span_free <- function(x) {
  x$spans$rows[] <- 1
  x$spans$columns[] <- 1
  x
}

#' @param x a complex_tabpart object
#' @noRd
as_col_keys <- function(x, j = NULL, blanks = character()) {
  candidates <- setdiff(colnames(x$dataset), blanks)

  if (is.null(j)) {
    j <- candidates
  } else if (inherits(j, "formula")) {
    tmp_dat <- as.list(candidates)
    names(tmp_dat) <- candidates
    tmp_dat <- as.data.frame(tmp_dat, check.names = FALSE)
    j <- get_j_from_formula(j, tmp_dat)
  } else if (is.logical(j)) {
    if (length(j) != length(candidates)) {
      stop("j (as logical) is expected to have the same length than the original 'data.frame' used in call to `flextable()`.")
    }
    j <- candidates[j]
  } else if (is.character(j)) {
    if (!all(j %in% candidates)) {
      wrong_col <- j[!j %in% candidates]
      wrong_col <- paste0(shQuote(wrong_col), collapse = ",")
      warning(sprintf("Some column(s) can not be found in the original data.frame: %s.", wrong_col),
        call. = FALSE
      )
    }
    j <- intersect(candidates, j)
  } else if (is.numeric(j) & all(j > 0)) {
    j <- candidates[intersect(seq_along(candidates), j)]
  } else if (is.numeric(j) & all(j < 0)) {
    j <- candidates[setdiff(seq_along(candidates), -j)]
  }

  j
}

get_columns_id <- function(x, j = NULL) {
  maxcol <- length(x$col_keys)

  if (is.null(j)) {
    j <- seq_along(x$col_keys)
  }

  if (inherits(j, "formula")) {
    tmp_dat <- as.list(x$col_keys)
    names(tmp_dat) <- x$col_keys
    tmp_dat <- as.data.frame(tmp_dat, check.names = FALSE)
    j <- get_j_from_formula(j, tmp_dat)
  }

  if (is.numeric(j)) {
    if (length(j) > 0 && all(j < 0)) {
      j <- setdiff(seq_along(x$col_keys), -j)
    }

    if (any(j < 1 | j > maxcol)) {
      stop(
        sprintf(
          "invalid columns selection\navailable range: [%s]\nissues: %s",
          paste0(range(seq_len(maxcol)), collapse = ", "),
          paste0(setdiff(j, seq_len(maxcol)), collapse = ", ")
        )
      )
    }
  } else if (is.logical(j)) {
    if (length(j) != maxcol) {
      stop(
        sprintf(
          "invalid columns selection\n`j` should have a length of %.0f.",
          maxcol
        )
      )
    } else {
      j <- which(j)
    }
  } else if (is.character(j)) {
    j <- gsub("(^`|`$)", "", j)
    if (any(is.na(j))) {
      stop("invalid columns selection: NA in selection")
    } else if (!all(is.element(j, x$col_keys))) {
      stop(
        sprintf(
          "`%s` is using unknown variable(s): %s",
          "i",
          paste0("`", j[!is.element(j, x$col_keys)], "`", collapse = ",")
        )
      )
    } else {
      j <- match(j, x$col_keys)
    }
  } else {
    stop("invalid columns selection: unknown selection type")
  }

  j
}

get_rows_id <- function(x, i = NULL) {
  maxrow <- nrow(x$dataset)

  if (is.null(i)) {
    i <- seq_len(maxrow)
  }
  if (inherits(i, "formula")) {
    i <- get_i_from_formula(i, x$dataset)
  }

  if (is.numeric(i)) {
    if (length(i) > 0 && all(i < 0)) {
      i <- setdiff(-i, seq_len(maxrow))
    }

    if (any(i < 1 | i > maxrow)) {
      stop("invalid row selection: out of range selection")
    }
  } else if (is.logical(i)) {
    if (length(i) != maxrow) {
      stop(
        sprintf(
          "invalid row selection. `length(i)` [%.0f] != `nrow(dataset)` [%.0f].",
          length(i), maxrow
        )
      )
    } else {
      i <- which(i)
    }
  } else if (is.character(i)) {
    any(is.na(i))
    rn <- row.names(x$dataset)
    if (any(is.na(i))) {
      stop("invalid row selection: NA in selection")
    } else if (!all(is.element(i, rn))) {
      stop("invalid row selection: unknown rownames")
    } else {
      i <- match(i, rn)
    }
  } else {
    stop("invalid row selection: unknown selection type")
  }

  i
}

# formula tools -----
get_i_from_formula <- function(f, data) {
  if (length(f) > 2) {
    stop("formula selection is not as expected ( ~ condition )", call. = FALSE)
  }
  i <- eval(as.call(f[[2]]), envir = data)
  if (!is.logical(i)) {
    stop("formula selection should return a logical vector", call. = FALSE)
  }
  i
}
get_j_from_formula <- function(f, data) {
  if (length(f) > 2) {
    stop("formula selection is not as expected ( ~ variables )", call. = FALSE)
  }
  j <- attr(terms(f, data = data), "term.labels")
  j <- gsub("(^`|`$)", "", j)
  names_ <- names(data)

  invalid_names <- (!j %in% names_)
  if (any(invalid_names)) {
    invalid_names <- paste0("`", j[invalid_names], "`", collapse = ", ")
    stop(
      sprintf(
        "`%s` is using unknown variable(s): %s",
        format(f),
        invalid_names
      ),
      call. = FALSE
    )
  }
  j
}
