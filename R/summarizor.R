#' @title Data summary preparation
#' @description It performs a univariate statistical analysis of a dataset
#' by group and formats the results so that they can be used with
#' the [tabulator()] function or directly with [as_flextable][as_flextable.summarizor].
#' \if{html}{\out{
#' <img src="https://www.ardata.fr/img/flextable-imgs/flextable-018-square.png" alt="summarizor illustration" style="width:100\%;">
#' }}
#' @note
#' This is very first version of the function; be aware it
#' can evolve or change.
#' @param x dataset
#' @param by columns names to be used as grouping columns
#' @param overall_label label to use as overall label
#' @param num_stats available statistics for numerical columns
#' to show, available options are "mean_sd", "median_iqr" and "range".
#' @param hide_null_na if TRUE (default), NA counts will not be shown when 0.
#' @seealso [fmt_summarizor()], [labelizor()]
#' @examples
#' \dontshow{
#' OLD_OMP_THREAD_LIMIT <- Sys.getenv("OMP_THREAD_LIMIT")
#' Sys.setenv("OMP_THREAD_LIMIT" = 2)
#' }
#' z <- summarizor(CO2[-c(1, 4)],
#'                 by = "Treatment",
#'                 overall_label = "Overall"
#' )
#' ft_1 <- as_flextable(z)
#' ft_1
#'
#' ft_2 <- as_flextable(z, sep_w = 0, spread_first_col=TRUE)
#' ft_2
#'
#' z <- summarizor(CO2[-c(1, 4)])
#' ft_3 <- as_flextable(z, sep_w = 0, spread_first_col=TRUE)
#' ft_3
#' \dontshow{
#' Sys.setenv("OMP_THREAD_LIMIT" = OLD_OMP_THREAD_LIMIT)
#' }
#' @export
summarizor <- function(
    x, by = character(),
    overall_label = NULL,
    num_stats = c("mean_sd", "median_iqr", "range"),
    hide_null_na = TRUE
    ){

  if (length(by) < 1) {
    by <- ".overall"
    x[[by]] <- by
    last_by <- character()
  } else {
    last_by <- by[length(by)]
  }

  x <- as.data.frame(x)

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
  datn <- dtx[, list(n = .N), by = by]
  setDF(datn)
  dat <- dtx[, list(data=list(.SD)), by = by, .SDcols = cols]
  dat$data <- lapply(dat$data, dataset_describe)

  dat$data = lapply(dat$data, function(dat, drop_stats) {
    dat <- dat[!dat$stat %in% drop_stats,]
    if (hide_null_na) {
      dat <- dat[!(dat$stat %in% "missing" & dat$cts < 1),]
    }
    dat
  }, drop_stats = setdiff(c("mean_sd", "median_iqr", "range"), num_stats))

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

  dat$variable <- factor(dat$variable, levels = cols)
  setDF(dat)
  attr(dat, "use_labels") <- list(
    stat = c(stat = "", mean_sd = "Mean (SD)", median_iqr = "Median (IQR)",
             range = "Range", missing = "Missing"),
    variable = c(variable = "")
  )
  class(dat) <- c("summarizor", class(dat))
  attr(dat, "n_by") <- datn
  attr(dat, "by") <- by
  dat
}

#' @export
#' @title Transform a 'summarizor' object into a flextable
#' @description `summarizor` object should be transformed into a flextable
#' with method [as_flextable()].
#' @param x result from [summarizor()]
#' @param ... arguments for [as_flextable.tabulator()]
#' @family as_flextable methods
#' @examples
#' \dontshow{
#' OLD_OMP_THREAD_LIMIT <- Sys.getenv("OMP_THREAD_LIMIT")
#' Sys.setenv("OMP_THREAD_LIMIT" = 2)
#' }
#' z <- summarizor(CO2[-c(1, 4)],
#'   by = "Treatment",
#'   overall_label = "Overall"
#' )
#' ft_1 <- as_flextable(z, spread_first_col = TRUE)
#' ft_1 <- prepend_chunks(ft_1,
#'   i = ~ is.na(variable), j = 1,
#'   as_chunk("\t"))
#' ft_1 <- autofit(ft_1)
#' ft_1
#' \dontshow{
#' Sys.setenv("OMP_THREAD_LIMIT" = OLD_OMP_THREAD_LIMIT)
#' }
as_flextable.summarizor <- function(x, ...) {

  tab <- tabulator(
    x = x,
    rows = c("variable", "stat"),
    columns = attr(x, "by"),
    blah = as_paragraph(
      as_chunk(
        fmt_summarizor(
          stat = !!sym("stat"),
          num1 = !!sym("value1"), num2 = !!sym("value2"),
          cts = !!sym("cts"), pcts = !!sym("percent")
        )
      )
    )
  )
  ft <- as_flextable(tab, ...)
  ft <- labelizor(ft, labels = c(".overall" = "Statistic"), part = "header")

  ft
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
#' @title Format content for data generated with summarizor()
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
#' @family text formatter functions
#' @examples
#' library(flextable)
#' z <- summarizor(iris, by = "Species")
#'
#' tab_1 <- tabulator(
#'   x = z,
#'   rows = c("variable", "stat"),
#'   columns = "Species",
#'   blah = as_paragraph(
#'     as_chunk(
#'       fmt_summarizor(
#'         stat = stat,
#'         num1 = value1, num2 = value2,
#'         cts = cts, pcts = percent
#'       )
#'     )
#'   )
#' )
#'
#' ft_1 <- as_flextable(x = tab_1, separate_with = "variable")
#' ft_1 <- labelizor(
#'   x = ft_1, j = "stat",
#'   labels = c(mean_sd = "Moyenne (ecart-type)",
#'              median_iqr = "Mediane (IQR)",
#'              range = "Etendue",
#'              missing = "Valeurs manquantes"
#'              )
#' )
#' ft_1 <- autofit(ft_1)
#' ft_1
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
#' @title Format content for count data
#' @description The function formats counts and
#' percentages as `n (xx.x%)`. If percentages are
#' missing, they are not printed.
#' @param n count values
#' @param pct percent values
#' @param digit number of digits for the percentages
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- structure(
#'   list(
#'     cut = structure(
#'       .Data = 1:5, levels = c(
#'         "Fair", "Good", "Very Good", "Premium", "Ideal"),
#'       class = c("ordered", "factor")),
#'     n = c(1610L, 4906L, 12082L, 13791L, 21551L),
#'     pct = c(0.0299, 0.0909, 0.2239, 0.2557, 0.3995)
#'   ),
#'   row.names = c(NA, -5L),
#'   class = "data.frame")
#'
#' ft_1 <- flextable(df, col_keys = c("cut", "txt"))
#' ft_1 <- mk_par(
#'   x = ft_1, j = "txt",
#'   value = as_paragraph(fmt_n_percent(n, pct)))
#' ft_1 <- align(ft_1, j = "txt", part = "all", align = "right")
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_n_percent <- function(n, pct, digit = 1){
  z1 <- character(length(n))
  z2 <- character(length(n))
  z1[!is.na(n)] <- sprintf("%s", fmt_int(n[!is.na(n)]))
  z2[!is.na(pct)] <- paste0(" (", fmt_pct(pct[!is.na(pct)]), ")")
  paste0(z1, z2)
}

#' @export
#' @title Format count data for headers
#' @description The function formats counts as `\n(N=XX)`. This helper
#' function is used to add counts in columns titles.
#' @param n count values
#' @param newline indicates to prefix the text with a new line
#' (sof return).
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- data.frame(zz = 1)
#'
#' ft_1 <- flextable(df)
#' ft_1 <- append_chunks(
#'   x = ft_1, j = 1, part = "header",
#'   value = as_chunk(fmt_header_n(200)))
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_header_n <- function(n, newline = TRUE){
  z1 <- character(length(n))

  mask <- "\n(N=%s)"
  if (!newline) {
    mask <- "(N=%s)"
  }

  z1[!is.na(n)] <- sprintf(mask, fmt_int(n[!is.na(n)]))
  z1
}

#' @export
#' @title Format numerical data as integer
#' @description The function formats numeric vectors as integer.
#' @param x numeric values
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- data.frame(zz = 1.23)
#'
#' ft_1 <- flextable(df)
#' ft_1 <- mk_par(
#'   x = ft_1, j = 1, part = "body",
#'   value = as_paragraph(as_chunk(zz, formatter = fmt_int)))
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_int <- function(x){
  big.mark <- get_flextable_defaults()$big.mark
  na_str <- get_flextable_defaults()$na_str
  nan_str <- get_flextable_defaults()$nan_str
  format_fun.integer(x, big.mark = big.mark, na_str = na_str, nan_str = nan_str)
}

#' @export
#' @title Format numerical data as percentages
#' @description The function formats numeric vectors as percentages.
#' @param x numeric values
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- data.frame(zz = .45)
#'
#' ft_1 <- flextable(df)
#' ft_1 <- mk_par(
#'   x = ft_1, j = 1, part = "body",
#'   value = as_paragraph(as_chunk(zz, formatter = fmt_pct)))
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_pct <- function(x) {

  big.mark <- get_flextable_defaults()$big.mark
  decimal.mark <- get_flextable_defaults()$decimal.mark
  pct_digits <- get_flextable_defaults()$pct_digits
  na_str <- get_flextable_defaults()$na_str
  nan_str <- get_flextable_defaults()$nan_str
  format_fun.pct(x,
    big.mark = big.mark, decimal.mark = decimal.mark,
    pct_digits = pct_digits, na_str = na_str, nan_str = nan_str)
}

#' @export
#' @title Format numerical data as percentages
#' @description The function formats numeric vectors as percentages.
#' @param x numeric values
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- data.frame(zz = .45)
#'
#' ft_1 <- flextable(df)
#' ft_1 <- mk_par(
#'   x = ft_1, j = 1, part = "body",
#'   value = as_paragraph(as_chunk(zz, formatter = fmt_dbl)))
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_dbl <- function(x) {

  big.mark <- get_flextable_defaults()$big.mark
  decimal.mark <- get_flextable_defaults()$decimal.mark
  digits <- get_flextable_defaults()$digits
  na_str <- get_flextable_defaults()$na_str
  nan_str <- get_flextable_defaults()$nan_str

  format_fun.double(x,
    big.mark = big.mark, decimal.mark = decimal.mark,
    digits = digits, na_str = na_str, nan_str = nan_str)
}


#' @export
#' @title Format content for mean and sd
#' @description The function formats means and
#' standard deviations as `mean (sd)`.
#' @param avg,dev mean and sd values
#' @param digit1,digit2 number of digits to show when printing 'mean' and 'sd'.
#' @seealso [tabulator()], [mk_par()]
#' @family text formatter functions
#' @examples
#' library(flextable)
#'
#' df <- data.frame(avg = 1:3*3, sd = 1:3)
#'
#' ft_1 <- flextable(df, col_keys = "avg")
#' ft_1 <- mk_par(
#'   x = ft_1, j = 1, part = "body",
#'   value = as_paragraph(fmt_avg_dev(avg = avg, dev = sd)))
#' ft_1 <- autofit(ft_1)
#' ft_1
fmt_avg_dev <- function(avg, dev, digit1 = 1, digit2 = 1){
  z1 <- character(length(avg))
  z2 <- character(length(avg))
  z1[!is.na(avg)] <- sprintf(paste0("%.", digit1, "f"), avg[!is.na(avg)])
  z2[!is.na(dev)] <- sprintf(paste0(" (%.", digit2, "f)"), dev[!is.na(dev)])
  paste0(z1, z2)
}

