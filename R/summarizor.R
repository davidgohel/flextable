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
#' @seealso [fmt_2stats()]
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
#'         num1 = stat, num2 = value, cts = cts, pcts = percent
#'       )
#'     )
#'   )
#' )
#'
#' ft_1 <- as_flextable(tab_1, separate_with = "variable")
#' ft_1
#'
#' # version 2 ----
#' n_format <- function(n, percent) {
#'   z <- character(length = length(n))
#'   wcts <- !is.na(n)
#'   z[wcts] <- sprintf("%.0f (%.01f %%)", n[wcts], percent[wcts] * 100)
#'   z
#' }
#' stat_format <- function(value) {
#'   z <- character(length = length(value))
#'   wnum <- !is.na(value)
#'   z[wnum] <- sprintf("%.01f", value[wnum])
#'   z
#' }
#'
#' tab_2 <- tabulator(z,
#'   rows = c("variable", "stat"),
#'   columns = "Treatment",
#'   `Est.` = as_paragraph(as_chunk(value)),
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
summarizor <- function(x, by = character(), overall_label = NULL){

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

  first_levels <- c("Min.", "1st Qu.", "Mean", "Median", "3rd Qu.",
                    "Max.")
  last_levels <- c("Missing")
  levs <- c(first_levels, setdiff(unique(dat$stat), c(first_levels, last_levels)), last_levels)
  dat$stat <- factor(dat$stat, levels = levs)
  setDF(dat)
  dat
}

dataset_describe <- function(dataset){

  w <- lapply(dataset, function(x){

    if(is.factor(x) || is.character(x)){
      z <- table(x, useNA = "always")
      names(z)[is.na(names(z))] <- "Missing"
      z <- as.data.frame(z)
      colnames(z) <- c("stat", "cts")
      z$percent <- z$cts / sum(z$cts)
      z$data_type <- "discrete"
      z
    } else if(is.numeric(x)){
      z <- c(
        "Min." = min(x, na.rm = TRUE),
        "Max." = max(x, na.rm = TRUE),
        "1st Qu." = as.double(quantile(x, probs = .25, na.rm = TRUE)),
        "3rd Qu." = as.double(quantile(x, probs = .75, na.rm = TRUE)),
        "Median" = as.double(quantile(x, probs = .5, na.rm = TRUE)),
        "Mean" = mean(x, na.rm = TRUE),
        "Missing" = NA_real_
      )
      z <- data.frame(stat = names(z), value = as.double(z),
                      cts = NA_real_, percent = NA_real_)
      z$cts[z$stat %in% "Missing"] <- sum(is.na(x))
      z$percent[z$stat %in% "Missing"] <- sum(is.na(x)) / length(x)
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
fmt_2stats <- function(num1, num2, cts, pcts,
                       num1_mask = "%.01f", num2_mask = "(%.01f)",
                       cts_mask = "%.0f", pcts_mask = "(%.02f %%)"){
  z_num <- character(length = length(num1))
  z_cts <- character(length = length(num1))

  wcts <- !is.na(cts)
  wpcts <- !is.na(pcts)
  z_1 <- z_2 <- z_cts
  z_1[wcts] <- sprintf(cts_mask, cts[wcts])
  z_2[wpcts] <- sprintf(pcts_mask, pcts[wpcts])
  z_cts <- paste0(
    z_1,
    ifelse(wcts & wpcts, " ", ""),
    z_2
  )

  wnum1 <- !is.na(num1)
  wnum2 <- !is.na(num2)
  z_1 <- z_2 <- z_num
  z_1[wnum1] <- sprintf(num1_mask, num1[wnum1])
  z_2[wnum2] <- sprintf(num2_mask, num2[wnum2])
  z_num <- paste0(
    z_1,
    ifelse(wnum1 & wnum2, " ", ""),
    z_2
  )

  paste0(z_num, z_cts)
}

