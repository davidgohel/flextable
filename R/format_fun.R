format_fun <- function( x, ... ){
  UseMethod("format_fun")
}

format_fun.default <-
  function(x, na_str = flextable_global$defaults$na_str,
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits,
           prefix = "", suffix = "", ...) {
    out <- format(x, trim = TRUE, big.mark = big.mark,
                  decimal.mark = decimal.mark, justify = "none",
                  digits = digits)
    ifelse(is.na(x), na_str, out)
  }

format_fun.character <-
  function(x, na_str = flextable_global$defaults$na_str,
           prefix = "", suffix = "", ...) {
    out <- paste0(prefix, as.character(x), suffix)
    ifelse(is.na(x), na_str, out)
  }

format_fun.factor <-
  function(x, na_str = flextable_global$defaults$na_str,
           prefix = "", suffix = "", ...) {
    out <- paste0(prefix, as.character(x), suffix)
    ifelse(is.na(x), na_str, out)
  }

format_fun.logical <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
           true = "true", false = "false", ...) {
    out <- ifelse(x, true, false)
    ifelse(is.na(x), na_str, out)
  }


format_fun.double <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
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
    ifelse(is.na(x), na_str, out)
  }

format_fun.integer <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
           big.mark = flextable_global$defaults$big.mark, ...) {
    out <- paste0(
      prefix,
      formatC(x, format = "f", big.mark = big.mark, digits = 0),
      suffix
    )
    ifelse(is.na(x), na_str, out)
  }

format_fun.Date <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
           fmt_date = flextable_global$defaults$fmt_date, ...) {
    out <- paste0(prefix, format(x, fmt_date), suffix)
    ifelse(is.na(x), na_str, out)
  }

format_fun.POSIXt <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
           fmt_datetime = flextable_global$defaults$fmt_datetime, ...) {
    out <- paste0(prefix, format(x, fmt_datetime), suffix)
    ifelse(is.na(x), na_str, out)
  }
