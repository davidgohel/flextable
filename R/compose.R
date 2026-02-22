#' @export
#' @importFrom rlang eval_tidy enquo quo_name
#' @title Set cell content from paragraph chunks
#' @description Modify flextable displayed values with eventually
#' mixed content paragraphs.
#'
#' Function is handling complex formatting as image insertion with
#' [as_image()], superscript with [as_sup()], formated
#' text with [as_chunk()] and several other *chunk* functions.
#'
#' Function `mk_par` is another name for `compose` as
#' there is an unwanted **conflict with package 'purrr'**.
#'
#' If you only need to add some content at the end
#' or the beginning of paragraphs and keep existing
#' content as it is, functions [append_chunks()] and
#' [prepend_chunks()] should be prefered.
#'
#' @inheritParams args_selectors_with_all
#' @param value a call to function [as_paragraph()].
#' @param use_dot by default `use_dot=FALSE`; if `use_dot=TRUE`,
#' `value` is evaluated within a data.frame augmented of a column named `.`
#' containing the `j`th column.
#' @examples
#' ft_1 <- flextable(head(cars, n = 5), col_keys = c("speed", "dist", "comment"))
#' ft_1 <- mk_par(
#'   x = ft_1, j = "comment",
#'   i = ~ dist > 9,
#'   value = as_paragraph(
#'     colorize(as_i("speed: "), color = "gray"),
#'     as_sup(sprintf("%.0f", speed))
#'   )
#' )
#' ft_1 <- set_table_properties(ft_1, layout = "autofit")
#' ft_1
#'
#' # using `use_dot = TRUE` ----
#' set.seed(8)
#' dat <- iris[sample.int(n = 150, size = 10), ]
#' dat <- dat[order(dat$Species), ]
#'
#'
#' ft_2 <- flextable(dat)
#' ft_2 <- mk_par(ft_2,
#'   j = ~ . - Species,
#'   value = as_paragraph(
#'     minibar(.,
#'       barcol = "white",
#'       height = .1
#'     )
#'   ), use_dot = TRUE
#' )
#' ft_2 <- theme_vader(ft_2)
#' ft_2 <- autofit(ft_2)
#' ft_2
#' @export
#' @family cell_content_composition
#' @seealso [fp_text_default()], [as_chunk()], [as_b()], [as_word_field()], [labelizor()]
compose <- function(x, i = NULL, j = NULL, value, part = "body", use_dot = FALSE) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "compose()"))
  }
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- compose(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  defused_value <- enquo(value)
  # call_label <- quo_name(defused_value)
  # if(!grepl("as_paragraph", call_label)){
  #   stop("argument `value` is expected to be a call to `as_paragraph()` but the value is: `", call_label, "`")
  # }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  tmp_data <- x[[part]]$dataset[i, , drop = FALSE]
  if (use_dot) {
    for (jcol in x$col_keys[j]) {
      tmp_data$. <- tmp_data[, jcol]
      newcontent <- eval_tidy(defused_value, data = tmp_data)
      newcontent <- as_chunkset_struct(
        l_paragraph = newcontent,
        keys = jcol, i = i)
      x[[part]]$content <- set_chunkset_struct_element(
        x = x[[part]]$content,
        i = i,
        j = jcol,
        value = newcontent
      )
    }
  } else {
    newcontent <- eval_tidy(defused_value, data = tmp_data)
    newcontent <- as_chunkset_struct(
      l_paragraph = newcontent, keys = x$col_keys[j],
      i = i)
    x[[part]]$content <- set_chunkset_struct_element(
      x = x[[part]]$content,
      i = i,
      j = j,
      value = newcontent
    )
  }

  x
}

#' @rdname compose
#' @export
mk_par <- compose


#' @export
#' @title Replace displayed text with labels
#' @description
#' `labelizor()` substitutes text values shown in a flextable
#' with human-readable labels. This is useful to turn column
#' values such as variable names, factor levels or coded strings
#' into presentation-ready wording (e.g. `"Sepal.Length"` to
#' `"Sepal Length"`).
#'
#' `labels` can be either a **named character vector** (names
#' identify values to find, values are the replacement labels)
#' or a **function** applied to every text chunk (e.g. [toupper()]).
#'
#' Only the displayed content is affected; the underlying data
#' of the flextable is unchanged.
#' @inheritParams args_selectors_with_all
#' @param labels a named vector whose names will be used to identify
#' values to replace and values will be used as labels.
#' @seealso [mk_par()], [append_chunks()], [prepend_chunks()]
#' @examples
#' \dontshow{
#' data.table::setDTthreads(1)
#' }
#' z <- summarizor(
#'   x = CO2[-c(1, 4)],
#'   by = "Treatment",
#'   overall_label = "Overall"
#' )
#'
#' ft_1 <- as_flextable(z, separate_with = "variable")
#'
#' ft_1 <- labelizor(
#'   x = ft_1, j = c("stat"),
#'   labels = c(Missing = "Kouign amann")
#' )
#'
#' ft_1 <- labelizor(
#'   x = ft_1, j = c("variable"),
#'   labels = toupper
#' )
#'
#' ft_1
#' @family cell_content_composition
labelizor <- function(x, j = NULL, labels, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "labelizor()"))
  }

  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- labelizor(x = x, j = j, labels = labels, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part = part) < 1) {
    return(x)
  }

  if (!is.function(labels) && (is.null(names(labels)) || !is.character(labels))) {
    stop("`labels` must be a named character vector or a function.")
  }
  if (is.null(j)) {
    j <- x$col_keys
  }

  j <- as_col_keys(x[[part]], j)

  curr_content_columns <- get_fpstruct_elements(
    x = x[[part]]$content,
    j = j
  )

  if (!is.function(labels)) {
    levs <- names(labels)
    labs <- as.character(labels)
    newcontent <- apply(curr_content_columns, 2, function(x) {
      lapply(x, function(x) {
        x$txt[x$txt %in% levs] <- labs[match(x$txt, levs, nomatch = 0)]
        x
      })
    })
  } else {
    newcontent <- apply(curr_content_columns, 2, function(x) {
      lapply(x, function(x) {
        x$txt <- labels(x$txt)
        x
      })
    })
  }
  newcontent <- as_chunkset_struct(
    l_paragraph = do.call(c, newcontent),
    keys = j)

  x[[part]]$content <- set_chunkset_struct_element(
    x = x[[part]]$content,
    j = j,
    value = newcontent
  )

  x
}
