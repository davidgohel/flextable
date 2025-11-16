#' @title Merge flextable cells vertically
#'
#' @description Merge flextable cells vertically when consecutive cells have
#' identical values. Text of formatted values are used to compare
#' values if available.
#'
#' Two options are available, either a column-by-column algorithm or an
#' algorithm where the combinations of these columns are used once for all
#' target columns.
#'
#' @inheritParams args_x_j_part_no_all
#' @param target columns names where cells have to be merged.
#' @param combine If the value is TRUE, the columns defined by `j` will
#' be combined into a single column/value and the consecutive values of
#' this result will be used. Otherwise, the columns are inspected one
#' by one to perform cell merges.
#' @examples
#' ft_merge <- flextable(mtcars)
#' ft_merge <- merge_v(ft_merge, j = c("gear", "carb"))
#' ft_merge
#'
#' data_ex <- structure(list(srdr_id = c(
#'   "175124", "175124", "172525", "172525",
#'   "172545", "172545", "172609", "172609", "172609"
#' ), substances = c(
#'   "alcohol",
#'   "alcohol", "alcohol", "alcohol", "cannabis",
#'   "cannabis", "alcohol\n cannabis\n other drugs",
#'   "alcohol\n cannabis\n other drugs",
#'   "alcohol\n cannabis\n other drugs"
#' ), full_name = c(
#'   "TAU", "MI", "TAU", "MI (parent)", "TAU", "MI",
#'   "TAU", "MI", "MI"
#' ), article_arm_name = c(
#'   "Control", "WISEteens",
#'   "Treatment as usual", "Brief MI (b-MI)", "Assessed control",
#'   "Intervention", "Control", "Computer BI", "Therapist BI"
#' )), row.names = c(
#'   NA,
#'   -9L
#' ), class = c("tbl_df", "tbl", "data.frame"))
#'
#'
#' ft_1 <- flextable(data_ex)
#' ft_1 <- theme_box(ft_1)
#' ft_2 <- merge_v(ft_1,
#'   j = "srdr_id",
#'   target = c("srdr_id", "substances")
#' )
#' ft_2
#' @family flextable merging function
#' @export
merge_v <- function(x, j = NULL, target = NULL, part = "body", combine = FALSE) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "merge_v()"))
  }
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)

  j <- as_col_keys(x[[part]], j, blanks = x$blanks)

  if (!is.null(target)) {
    target <- as_col_keys(x[[part]], target, blanks = character())
  } else {
    target <- as_col_keys(x[[part]], j, blanks = character())
  }

  x[[part]] <- span_columns(x = x[[part]], columns = j, target = target, combine = combine)

  x
}



#' @title Merge flextable cells horizontally
#'
#' @description Merge flextable cells horizontally when consecutive cells have
#' identical values. Text of formatted values are used to compare
#' values.
#'
#' @inheritParams args_x_i_part_no_all
#' @family flextable merging function
#' @examples
#' dummy_df <- data.frame(
#'   col1 = letters,
#'   col2 = letters, stringsAsFactors = FALSE
#' )
#' ft_merge <- flextable(dummy_df)
#' ft_merge <- merge_h(x = ft_merge)
#' ft_merge
#' @export
merge_h <- function(x, i = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "merge_h()"))
  }
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)

  i <- get_rows_id(x[[part]], i)
  x[[part]] <- span_rows(x = x[[part]], rows = i)

  x
}


#' @title Delete flextable merging informations
#'
#' @description Delete all merging informations from a flextable.
#'
#' @inheritParams args_x_part
#' @family flextable merging function
#' @export
#' @examples
#' typology <- data.frame(
#'   col_keys = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species"),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE
#' )
#'
#' ft <- flextable(head(iris))
#' ft <- set_header_df(ft, mapping = typology, key = "col_keys")
#' ft <- merge_v(ft, j = c("Species"))
#'
#' ft <- theme_tron_legacy(merge_none(ft))
#' ft
merge_none <- function(x, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "merge_none()"))
  }
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    args <- list()
    for (p in c("header", "footer", "body")) {
      x <- merge_none(x = x, part = p)
    }
  }

  x[[part]] <- span_free(x[[part]])

  x
}





#' @title Merge flextable cells into a single one
#'
#' @description Merge flextable cells into a single one. All
#' rows and columns must be consecutive.
#'
#' @inheritParams args_selectors_without_all
#' @family flextable merging function
#' @examples
#' ft_merge <- flextable(head(mtcars), cwidth = .5)
#' ft_merge <- merge_at(ft_merge, i = 1:2, j = 1:2)
#' ft_merge
#' @export
merge_at <- function(x, i = NULL, j = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "merge_at()"))
  }
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)

  j <- get_columns_id(x[[part]], j = j)
  j <- x$col_keys[j]

  i <- get_rows_id(x[[part]], i)

  x[[part]] <- span_cells_at(x = x[[part]], columns = j, rows = i)

  x
}


#' @title Rowwise merge of a range of columns
#'
#' @description Merge flextable columns into a single one for each selected rows. All
#' columns must be consecutive.
#'
#' @inheritParams args_x_i_part_no_all
#' @param j1,j2 selected columns that will define the range of columns to merge.
#' @family flextable merging function
#' @examples
#' ft <- flextable(head(mtcars), cwidth = .5)
#' ft <- theme_box(ft)
#' ft <- merge_h_range(ft, i = ~ cyl == 6, j1 = "am", j2 = "carb")
#' ft <- flextable::align(ft, i = ~ cyl == 6, align = "center")
#' ft
#' @export
merge_h_range <- function(x, i = NULL, j1 = NULL, j2 = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "merge_h_range()"))
  }
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)

  j1 <- get_columns_id(x[[part]], j = j1)
  j2 <- get_columns_id(x[[part]], j = j2)

  seq_cols <- j1:j2

  i <- get_rows_id(x[[part]], i)
  x[[part]]$spans$rows[i, seq_cols] <- 0
  x[[part]]$spans$rows[i, j1] <- length(seq_cols)
  check_merge(x[[part]])


  x
}
