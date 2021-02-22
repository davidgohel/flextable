format_fun <- function( x, ... ){
  UseMethod("format_fun")
}

format_fun.default <-
  function(x, na_str = flextable_global$defaults$na_str,
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits,
           fmt_date = flextable_global$defaults$fmt_date,
           fmt_datetime = flextable_global$defaults$fmt_datetime,
           prefix = "", suffix = "", ...) {
    if(inherits(x, "Date")){
      out <- format_fun.Date(x, fmt_date = fmt_date, na_str = na_str, prefix = prefix, suffix = suffix)
    } else if(inherits(x, "POSIXt")){
      out <- format_fun.POSIXt(x, fmt_datetime = fmt_datetime, na_str = na_str, prefix = prefix, suffix = suffix)
    } else if(is.double(x)){
      out <- format_fun_defaultnum(x, na_str = na_str, big.mark = big.mark,
                               decimal.mark = decimal.mark,
                               digits = digits, prefix = prefix, suffix = suffix)
    } else if(is.integer(x)){
      out <- format_fun.integer(x, na_str = na_str, big.mark = big.mark,
                                digits = digits, prefix = prefix, suffix = suffix)
    } else if(is.character(x)){
      out <- format_fun.character(x, na_str = na_str, prefix = prefix, suffix = suffix)
    } else if(is.factor(x)){
      out <- format_fun.factor(x, na_str = na_str, prefix = prefix, suffix = suffix)
    } else {
      out <- format(x, trim = TRUE, big.mark = big.mark,
                    decimal.mark = decimal.mark, justify = "none",
                    scientific = FALSE,
                    digits = digits)
      out <- ifelse(is.na(x), na_str, out)
    }
    out
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
    out <- paste0(prefix, out, suffix)
    ifelse(is.na(x), na_str, out)
  }


format_fun_defaultnum <-
  function(x, na_str = flextable_global$defaults$na_str, prefix = "", suffix = "",
           big.mark = flextable_global$defaults$big.mark,
           decimal.mark = flextable_global$defaults$decimal.mark,
           digits = flextable_global$defaults$digits, ...) {
    out <- paste0(
      prefix,
      format(x, trim = TRUE, scientific = FALSE,
        big.mark = big.mark,
        decimal.mark = decimal.mark
      ),
      suffix
    )
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
