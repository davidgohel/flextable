#' @title data summary preparation
#' @description It performs a univariate statistical analysis of a dataset
#' by group and formats the results so that they can be used with
#' the [tabulator()] function.
#' @note
#' This is very first version of the function; be aware it
#' can evolve or change.
#' @param x dataset
#' @param by columns names to be used as grouping columns
#' @param overall_label label to use as overall label
#' @seealso [fmt_2stats()], [labelizor()]
#' @examples
#' z <- summarizor(CO2[-c(1, 4)],
#'   by = "Treatment",
#'   overall_label = "Overall"
#' )
#'
#'
#' # version 1 ----
#' tab_1 <- tabulator(
#'   x = z,
#'   rows = c("variable", "stat"),
#'   columns = "Treatment",
#'   blah = as_paragraph(
#'     as_chunk(
#'       fmt_2stats(
#'         stat = stat,
#'         num1 = value1, num2 = value2,
#'         cts = cts, pcts = percent
#'       )
#'     )
#'   )
#' )
#'
#' ft_1 <- as_flextable(tab_1, separate_with = "variable")
#' ft_1
#'
#' # version 2 with your own functions ----
#' n_format <- function(n, percent) {
#'   z <- character(length = length(n))
#'   wcts <- !is.na(n)
#'   z[wcts] <- sprintf("%.0f (%.01f %%)", n[wcts], percent[wcts] * 100)
#'   z
#' }
#' stat_format <- function(num1, num2, stat) {
#'   num1_mask <- "%.01f"
#'   num2_mask <- "(%.01f)"
#'
#'   z_num <- character(length = length(num1))
#'
#'   is_mean_sd <- !is.na(num1) & !is.na(num2) & stat %in% "mean_sd"
#'   is_range <- !is.na(num1) & !is.na(num2) & stat %in% "range"
#'   is_num_1 <- !is.na(num1) & is.na(num2)
#'
#'   z_num[is_num_1] <- sprintf(num1_mask, num1[is_num_1])
#'
#'   z_num[is_mean_sd] <- paste0(
#'     sprintf(num1_mask, num1[is_mean_sd]),
#'     " ",
#'     sprintf(num2_mask, num2[is_mean_sd])
#'   )
#'   z_num[is_range] <- paste0(
#'     sprintf(num1_mask, num1[is_range]),
#'     " - ",
#'     sprintf(num1_mask, num2[is_range])
#'   )
#'   z_num
#' }
#'
#' tab_2 <- tabulator(z,
#'   rows = c("variable", "stat"),
#'   columns = "Treatment",
#'   `Est.` = as_paragraph(as_chunk(stat_format(value1, value2, stat))),
#'   `N` = as_paragraph(as_chunk(n_format(cts, percent)))
#' )
#'
#' ft_2 <- as_flextable(tab_2, separate_with = "variable")
#' ft_2
#' @section Illustrations:
#' ft_1 appears as:
#'
#' \if{html}{\figure{fig_summarizor_1.png}{options: width="500"}}
#'
#' ft_2 appears as:
#'
#' \if{html}{\figure{fig_summarizor_2.png}{options: width="500"}}
#'
#' @export
summarizor <- function(
    x, by = character(),
    overall_label = NULL
    ){

  stopifnot(`by can not be empty` = length(by)>0)

  x <- as.data.frame(x)

  last_by <- by[length(by)]
  if(length(last_by) > 0 && !is.null(overall_label) ){
    xoverall <- x
    z <- xoverall[[last_by]]
    levels_ <- if(is.factor(z)){
      c(levels(z), overall_label)
    } else {
      c(sort(unique(z)), overall_label)
    }
    z <- rep(overall_label, nrow(xoverall))
    xoverall[[last_by]] <- z
    x <- rbind(x, xoverall)

    x[[last_by]] <- factor(x[[last_by]], levels = levels_)
  }

  cols <- setdiff(colnames(x), by)
  dtx <- as.data.table(x)
  dat <- dtx[, list(data=list(.SD)), by = by, .SDcols = cols]
  dat$data <- lapply(dat$data, dataset_describe)

  for(i in seq_len(nrow(dat))){
    w <- as.data.frame(dat$data[[i]])
    w[by] <- lapply(dat[i, .SD, .SDcols = by], function(z) {
      rep(z, length.out = nrow(w))
    })
    dat$data[[i]] <- w
  }
  dat <- rbindlist(dat$data)

  first_levels <- c("n", "mean_sd", "median_iqr", "range")
  last_levels <- c("missing")
  levs <- c(first_levels, setdiff(unique(dat$stat), c(first_levels, last_levels)), last_levels)
  labs <- levs
  dat$stat <- factor(dat$stat, levels = levs, labels = labs)
  setDF(dat)
  dat
}

#' @importFrom stats sd IQR median
dataset_describe <- function(dataset){

  w <- lapply(dataset, function(x){

    if(is.factor(x) || is.character(x)){
      z <- table(x, useNA = "always")
      names(z)[is.na(names(z))] <- "missing"
      z <- as.data.frame(z)
      colnames(z) <- c("stat", "cts")
      z$percent <- z$cts / sum(z$cts)
      z$data_type <- "discrete"
      z
    } else if(is.numeric(x)){

      z <- data.frame(
        stat = c("mean_sd", "median_iqr", "range", "missing"),
        value1 = c(mean(x, na.rm = TRUE), as.double(median(x, na.rm = TRUE)), min(x, na.rm = TRUE), NA_real_),
        value2 = c(sd(x, na.rm = TRUE), as.double(IQR(x, na.rm = TRUE)), max(x, na.rm = TRUE), NA_real_),
        cts = NA_real_, percent = NA_real_)

      z$cts[z$stat %in% "missing"] <- sum(is.na(x))
      z$percent[z$stat %in% "missing"] <- sum(is.na(x)) / length(x)
      z$data_type <- "continuous"
      z
    }
  })
  w <- rbindlist(w, use.names = TRUE, fill = TRUE, idcol = "variable")
  setDF(w)
  w
}

#' @export
#' @title format content for data generated with [summarizor()]
#' @description This function was written to allow easy demonstrations
#' of flextable's ability to produce table summaries (with [summarizor()]).
#' It assumes that we have either a quantitative variable, in which
#' case we will display the mean and the standard deviation, or a
#' qualitative variable, in which case we will display the count and the
#' percentage corresponding to each modality.
#' @param stat a character column containing the name of statictics
#' @param num1 a numeric statistic to display such as a mean or a median
#' @param num2 a numeric statistic to display such as a standard
#' deviation or a median absolute deviation.
#' @param cts a count to display
#' @param pcts a percentage to display
#' @param num1_mask format associated with `num1`, a format string
#' used by [sprintf()].
#' @param num2_mask format associated with `num2`, a format string
#' used by [sprintf()].
#' @param cts_mask format associated with `cts`, a format string
#' used by [sprintf()].
#' @param pcts_mask format associated with `pcts`, a format string
#' used by [sprintf()].
#' @seealso [summarizor()], [tabulator()], [mk_par()]
#' @family other text formatter functions
fmt_2stats <- function(stat, num1, num2, cts, pcts,
                       num1_mask = "%.01f", num2_mask = "(%.01f)",
                       cts_mask = "%.0f", pcts_mask = "(%.02f%%)"){

  z_num <- character(length = length(num1))
  z_cts <- character(length = length(num1))

  is_mean_sd <- !is.na(num1) & !is.na(num2) & stat %in% "mean_sd"
  is_median_iqr <- !is.na(num1) & !is.na(num2) & stat %in% "median_iqr"
  is_range <- !is.na(num1) & !is.na(num2) & stat %in% "range"
  is_num_1 <- !is.na(num1) & is.na(num2)
  is_cts_2 <- !is.na(cts) & !is.na(pcts)
  is_cts_1 <- !is.na(cts) & is.na(pcts)

  z_num[is_num_1] <- sprintf(num1_mask, num1[is_num_1])

  z_num[is_mean_sd] <- paste0(
    sprintf(num1_mask, num1[is_mean_sd]),
    " ",
    sprintf(num2_mask, num2[is_mean_sd])
  )
  z_num[is_median_iqr] <- paste0(
    sprintf(num1_mask, num1[is_median_iqr]),
    " ",
    sprintf(num2_mask, num2[is_median_iqr])
  )
  z_num[is_range] <- paste0(
    sprintf(num1_mask, num1[is_range]),
    " - ",
    sprintf(num1_mask, num2[is_range])
  )

  z_cts[is_cts_2] <- paste0(
    sprintf(cts_mask, cts[is_cts_2]),
    " ",
    sprintf(pcts_mask, pcts[is_cts_2]*100)
  )
  z_cts[is_cts_1] <- sprintf(cts_mask, cts[is_cts_1])

  paste0(z_num, z_cts)

}
#' @export
#' @rdname fmt_2stats
fmt_summarizor <- fmt_2stats


#' @export
#' @title format content for count data
#' @description The function formats counts and
#' percentages as `n (xx.x%)`. If percentages are
#' missing, they are not printed.
#' @param n count values
#' @param pct percent values
#' @param digit number of digits for the percentages
#' @seealso [tabulator()], [mk_par()]
#' @family other text formatter functions
fmt_n_percent <- function(n, pct, digit = 1){
  z1 <- character(length(n))
  z2 <- character(length(n))
  z1[!is.na(n)] <- sprintf("%.0f", n[!is.na(n)])
  z2[!is.na(pct)] <- sprintf(paste0("(%.", digit, "f%%)"), pct[!is.na(pct)])
  paste0(z1, z2)
}

#' @export
#' @title format count data for headers
#' @description The function formats counts as `\n(N=XX)`. This helper
#' function is used to add counts in columns titles.
#' @param n count values
#' @seealso [tabulator()], [mk_par()]
#' @family other text formatter functions
fmt_header_n <- function(n){
  z1 <- character(length(n))
  z1[!is.na(n)] <- sprintf("\n(N=%.0f)", n[!is.na(n)])
  z1
}
