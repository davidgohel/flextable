#' @export
#' @title Paginate tables
#' @description
#' Prevents breaks between tables rows you want to stay together.
#' This feature only applies to Word and RTF output.
#' @param x flextable object
#' @param init init value for keep_with_next property, it default
#' value is `get_flextable_defaults()$keep_with_next`.
#' @param hdr_ftr if TRUE (default), prevent breaks between table body
#' and header and between table body and footer.
#' @param group name of a column to use for finding groups
#' @param group_def algorithm to be used to identify groups
#' that should not be split into two pages, one of 'rle', 'nonempty':
#'
#' - 'rle': runs of equal values are used to define the groups,
#' to be used with [tabulator()].
#' - 'nonempty': non empty value start a new group,
#' to be used with [as_flextable.tabular()].
#' @return updated flextable object
#' @details
#' The pagination of tables allows you to control their position
#' in relation to page breaks.
#'
#' For small tables, a simple setting is usually used that indicates
#' that all rows should be displayed together:
#'
#' ```
#' paginate(x, init = TRUE, hdr_ftr = TRUE)
#' ```
#'
#' For large tables, it is recommended to use a setting that
#' indicates that all rows of the header should be bound to
#' the first row of the table to avoid the case where the header
#' is displayed alone at the bottom of the page and then repeated
#' on the next one:
#'
#' ```
#' paginate(x, init = FALSE, hdr_ftr = TRUE)
#' ```
#'
#' For tables that present groups that you don't want to be presented
#' on two pages, you must use a parameterization involving the notion
#' of group and an algorithm for determining the groups.
#'
#'
#' ```
#' paginate(x, group = "grp", group_def = "rle")
#' ```
#'
#' @examples
#' \dontshow{
#' data.table::setDTthreads(1)
#' }
#' library(data.table)
#' library(flextable)
#'
#' init_flextable_defaults()
#'
#' multi_fun <- function(x) {
#'   list(mean = mean(x), sd = sd(x))
#' }
#'
#' dat <- as.data.table(ggplot2::diamonds)
#' dat <- dat[clarity %in% c("I1", "SI1", "VS2")]
#'
#' dat <- dat[, unlist(lapply(.SD, multi_fun),
#'                     recursive = FALSE),
#'            .SDcols = c("z", "y"),
#'            by = c("cut", "color", "clarity")]
#'
#' tab <- tabulator(
#'   x = dat, rows = c("cut", "color"),
#'   columns = "clarity",
#'   `z stats` = as_paragraph(as_chunk(fmt_avg_dev(z.mean, z.sd, digit2 = 2))),
#'   `y stats` = as_paragraph(as_chunk(fmt_avg_dev(y.mean, y.sd, digit2 = 2)))
#' )
#'
#' ft_1 <- as_flextable(tab)
#' ft_1 <- autofit(x = ft_1, add_w = .05) |>
#'   paginate(group = "cut", group_def = "rle")
#'
#' save_as_docx(ft_1, path = tempfile(fileext = ".docx"))
#' save_as_rtf(ft_1, path = tempfile(fileext = ".rtf"))
paginate <- function(
    x,
    init = NULL,
    hdr_ftr = TRUE,
    group = character(),
    group_def = c("rle", "nonempty")
    ) {

  if (is.null(init)) {
    init <- get_flextable_defaults()$keep_with_next
  }
  x <- keep_with_next(x, value = init, part = "all")

  if (hdr_ftr) {
    x <- paginate_hdr_ftr(x)
  }

  g_algo <- match.arg(group_def, several.ok = FALSE)
  if (length(group) == 1 && is.character(group)) {
    if ("nonempty" %in% g_algo) {
      x <- paginate_nonempty(x = x, group = group)
    } else if ("rle" %in% g_algo) {
      x <- paginate_rleid(x = x, group = group)
    }
  }

  x
}

paginate_hdr_ftr <- function(x) {
  nrow_footer <- nrow_part(x, "footer")
  nrow_header <- nrow_part(x, "header")
  if (nrow_part(x, "header")) {
    x <- keep_with_next(x, value = TRUE, part = "header")
  }
  if (nrow_footer > 0 && nrow_part(x, "body")) {
    x <- keep_with_next(x, value = TRUE, part = "body", i = nrow_part(x, "body"))
  }
  if (nrow_footer > 0) {
    x <- keep_with_next(x, value = TRUE, part = "footer")
    x <- keep_with_next(x, i = nrow_footer, value = FALSE, part = "footer")
  }
  x
}

paginate_nonempty <- function(x, group) {

  if (nrow_part(x, "body") < 1) return(x)

  if (!group %in% colnames(x$body$dataset)) {
    stop("could not find ", shQuote(group))
  }
  grp_val <- x$body$dataset[[group]]
  index_false <- c( which(!is.na(grp_val) & !grp_val %in% ""), length(grp_val)+1)
  index_false <- index_false-1
  index_false <- index_false[index_false > 0]
  x <- keep_with_next(x, value = TRUE, part = "body")
  x <- keep_with_next(x, i = index_false, value = FALSE, part = "body")
  x
}

paginate_rleid <- function(x, group) {

  if (nrow_part(x, "body") < 1) return(x)

  if (!group %in% colnames(x$body$dataset)) {
    stop("could not find ", shQuote(group))
  }
  grp_val <- x$body$dataset[[group]]
  index_false <- as.integer(tapply(seq_along(grp_val), rleid(grp_val), function(z) z[length(z)]))
  x <- keep_with_next(x, value = TRUE, part = "body")
  x <- keep_with_next(x, i = index_false, value = FALSE, part = "body")
  x
}

