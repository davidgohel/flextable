#' @export
#' @importFrom rlang eval_tidy enquo quo_name
#' @title Define displayed values and mixed content
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
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function [as_paragraph()].
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
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
#' dat <- iris[sample.int(n = 150, size = 10),]
#' dat <- dat[order(dat$Species),]
#'
#'
#' ft_2 <- flextable(dat)
#' ft_2 <- mk_par(ft_2, j = ~ . -Species,
#'   value = as_paragraph(
#'     minibar(., barcol = "white",
#'             height = .1)
#'   ), use_dot = TRUE
#'   )
#' ft_2 <- theme_vader(ft_2)
#' ft_2 <- autofit(ft_2)
#' ft_2
#' @export
#' @family functions for mixed content paragraphs
#' @seealso [fp_text_default()], [as_chunk()], [as_b()], [as_word_field()], [labelizor()]
compose <- function(x, i = NULL, j = NULL, value , part = "body", use_dot = FALSE){

  if( !inherits(x, "flextable") ) {
    stop(sprintf("Function `%s` supports only flextable objects.", "compose()"))
  }
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- compose(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  defused_value <- enquo(value)
  # call_label <- quo_name(defused_value)
  # if(!grepl("as_paragraph", call_label)){
  #   stop("argument `value` is expected to be a call to `as_paragraph()` but the value is: `", call_label, "`")
  # }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  tmp_data <- x[[part]]$dataset[i, , drop = FALSE]
  if( use_dot ){
    for(jcol in j){
      tmp_data$. <- tmp_data[,jcol]
      x[[part]]$content[i, jcol] <- eval_tidy(defused_value, data = tmp_data)
    }
  } else {
    x[[part]]$content[i, j] <- eval_tidy(defused_value, data = tmp_data)
  }

  x
}

#' @rdname compose
#' @export
mk_par <- compose


#' @export
#' @title Change displayed labels
#' @description The function replace text values
#' in a flextable with labels. The labels are defined
#' with character named vector.
#'
#' The function is not written to be fast but to be handy. It does
#' not replace the values in the underlying dataset but replace the defined
#' content in the flextable (as defined with [compose()]).
#' @param x a flextable object
#' @param j columns selection
#' @param labels a named vector whose names will be used to identify
#' values to replace and values will be used as labels.
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @seealso [mk_par()], [append_chunks()], [prepend_chunks()]
#' @examples
#' z <- summarizor(
#'   x = CO2[-c(1, 4)],
#'   by = "Treatment",
#'   overall_label = "Overall")
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
  if (!is.function(labels) && (is.null(names(labels)) || !is.character(labels))) {
    stop("`labels` must be a named character vector or a function.")
  }
  if (is.null(j)) {
    j <- x$col_keys
  }

  j <- as_col_keys(x[[part]], j)

  if (!is.function(labels)) {
    levs <- names(labels)
    labs <- as.character(labels)
    for (current_col in j) {
      curr_content_column <- x[[part]]$content$content$data[, current_col]
      curr_content_column <- lapply(curr_content_column, function(x) {
        x$txt[x$txt %in% levs] <- labs[match(x$txt, levs, nomatch = 0)]
        x
      })
      x[[part]]$content$content$data[, current_col] <- curr_content_column
    }
  } else {
    for (current_col in j) {
      curr_content_column <- x[[part]]$content$content$data[, current_col]
      curr_content_column <- lapply(curr_content_column, function(z) {
        z$txt <- labels(z$txt)
        z
      })
      x[[part]]$content$content$data[, current_col] <- curr_content_column
    }
  }

  x
}
