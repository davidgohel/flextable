format_fun <- function(x, ...) {
  UseMethod("format_fun")
}

#' @export
format_fun.default <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits,
           fmt_date = flextable_global$defaults$fmt_date,
           fmt_datetime = flextable_global$defaults$fmt_datetime,
           prefix = "", suffix = "", ...) {
    if (inherits(x, "Date")) {
      out <- format_fun.Date(x,
        fmt_date = fmt_date, na_str = na_str,
        nan_str = nan_str,
        prefix = prefix, suffix = suffix
      )
    } else if (inherits(x, "POSIXt")) {
      out <- format_fun.POSIXt(x,
        fmt_datetime = fmt_datetime,
        na_str = na_str,
        nan_str = nan_str,
        prefix = prefix, suffix = suffix
      )
    } else if (is.double(x)) {
      out <- format_fun_defaultnum(x,
        na_str = na_str,
        nan_str = nan_str,
        big.mark = big.mark,
        decimal.mark = decimal.mark,
        digits = digits,
        prefix = prefix, suffix = suffix,
        ...
      )
    } else if (is.integer(x)) {
      out <- format_fun.integer(x,
        na_str = na_str,
        nan_str = nan_str,
        big.mark = big.mark,
        digits = digits, prefix = prefix, suffix = suffix
      )
    } else if (is.character(x)) {
      out <- format_fun.character(x,
        na_str = na_str,
        nan_str = nan_str,
        prefix = prefix, suffix = suffix
      )
    } else if (is.factor(x)) {
      out <- format_fun.factor(x,
        na_str = na_str,
        nan_str = nan_str,
        prefix = prefix, suffix = suffix
      )
    } else if (is.logical(x)) {
      out <- format_fun.logical(x,
        na_str = na_str,
        nan_str = nan_str,
        prefix = prefix, suffix = suffix
      )
    } else if (is.list(x)) {
      what <- sapply(x, function(x) head(class(x), n = 1))
      out <- sprintf("[[%s]]", what)
    } else {
      out <- format(x,
        trim = TRUE, big.mark = big.mark,
        decimal.mark = decimal.mark, justify = "none",
        scientific = FALSE,
        digits = digits, ...
      )
      out[is.na(x)] <- na_str
      out[is.nan(x)] <- nan_str
    }
    out
  }

#' @export
format_fun.character <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "", ...) {
    out <- paste0(prefix, as.character(x), suffix)
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }

#' @export
format_fun.factor <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "", ...) {
    out <- paste0(prefix, as.character(x), suffix)
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }

#' @export
format_fun.logical <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           true = "true", false = "false", ...) {
    out <- ifelse(x, true, false)
    out <- paste0(prefix, out, suffix)
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }


format_fun_defaultnum <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits, ...) {
    out <- paste0(
      prefix,
      format(x,
        trim = TRUE, scientific = FALSE,
        big.mark = big.mark,
        decimal.mark = decimal.mark,
        ...
      ),
      suffix
    )
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }

#' @export
format_fun.double <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits, ...) {
    out <- paste0(
      prefix,
      formatC(x,
        format = "f", big.mark = big.mark, digits = digits,
        decimal.mark = decimal.mark
      ),
      suffix
    )
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }
#' @export
format_fun.pct <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           pct_digits = flextable_global$defaults$pct_digits, ...) {
    if (is.null(x)) {
      return("")
    }
    wisna <- is.na(x)
    wisnan <- is.nan(x)
    out <- paste0(
      formatC(x * 100,
        format = "f", big.mark = big.mark, digits = pct_digits,
        decimal.mark = decimal.mark
      ),
      "%"
    )
    out[wisna] <- na_str
    out[wisnan] <- nan_str
    out
  }

#' @export
format_fun.integer <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           big.mark = flextable_global$defaults$big.mark, ...) {
    out <- paste0(
      prefix,
      formatC(x, format = "f", big.mark = big.mark, digits = 0),
      suffix
    )
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }

#' @export
format_fun.Date <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           fmt_date = flextable_global$defaults$fmt_date, ...) {
    out <- paste0(prefix, format(x, fmt_date), suffix)
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }

#' @export
format_fun.POSIXt <-
  function(x,
           na_str = flextable_global$defaults$na_str,
           nan_str = flextable_global$defaults$nan_str,
           prefix = "", suffix = "",
           fmt_datetime = flextable_global$defaults$fmt_datetime, ...) {
    out <- paste0(prefix, format(x, fmt_datetime), suffix)
    out[is.na(x)] <- na_str
    out[is.nan(x)] <- nan_str
    out
  }
