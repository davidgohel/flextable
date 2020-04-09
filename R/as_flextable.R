#' @title method to convert object to flextable
#' @description This is a convenient function
#' to let users create flextable bindings
#' from any objects.
#' @param x object to be transformed as flextable
#' @param ... arguments for custom methods
#' @export
as_flextable <- function( x, ... ){
  UseMethod("as_flextable")
}


#' @title grouped data transformation
#'
#' @description Repeated consecutive values of group columns will
#' be used to define the title of the groups and will
#' be added as a row title.
#'
#' @param x dataset
#' @param groups columns names to be used as row separators.
#' @param columns columns names to keep
#' @examples
#' # as_grouped_data -----
#' library(data.table)
#' CO2 <- CO2
#' setDT(CO2)
#' CO2$conc <- as.integer(CO2$conc)
#'
#' data_co2 <- dcast(CO2, Treatment + conc ~ Type,
#'   value.var = "uptake", fun.aggregate = mean)
#' data_co2
#' data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"))
#' data_co2
#' @seealso \code{\link{as_flextable}}
#' @export
as_grouped_data <- function( x, groups, columns = NULL ){

  if( inherits(x, "data.table") || inherits(x, "tbl_df") || inherits(x, "tbl") || is.matrix(x) )
    x <- as.data.frame(x, stringsAsFactors = FALSE)

  stopifnot(is.data.frame(x), ncol(x) > 0 )

  if( is.null(columns))
    columns <- setdiff(names(x), groups)

  x <- x[, c(groups, columns), drop = FALSE]

  x$fake_order___ <- seq_len(nrow(x))
  values <- lapply(x[groups], function(x) rle(x = format(x) ) )

  vout <- lapply(values, function(x){
    out <- lapply(x$lengths, function(l){
      out <- rep(0L, l)
      out[1] <- l
      out
    } )
    out <- unlist(x = out)
    which(as.integer( out ) > 0)
  })

  new_rows <- mapply(function(i, column, decay_order){
    na_cols <- setdiff(names(x), c( column, "fake_order___") )
    dat <- x[i,,drop = FALSE]
    dat$fake_order___ <- dat$fake_order___ - decay_order
    dat[, na_cols] <- NA
    dat
  }, vout, groups, length(groups) / seq_along(groups) * .1, SIMPLIFY = FALSE)

  # should this be made col by col?
  x[,groups] <- NA

  new_rows <- append( new_rows, list(x) )
  x <- rbind.match.columns(new_rows)
  x <- x[order(x$fake_order___),,drop = FALSE]
  x$fake_order___ <- NULL
  class(x) <- c("grouped_data", class(x))
  attr(x, "groups") <- groups
  attr(x, "columns") <- columns
  x
}

#' @export
#' @rdname as_flextable
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param hide_grouplabel if TRUE, group label will not be rendered, only
#' level/value will be rendered.
#' @examples
#'
#' # as_flextable and as_grouped_data -----
#' if( require("magrittr")){
#'   library(data.table)
#'   CO2 <- CO2
#'   setDT(CO2)
#'   CO2$conc <- as.integer(CO2$conc)
#'
#'   data_co2 <- dcast(CO2, Treatment + conc ~ Type,
#'                     value.var = "uptake", fun.aggregate = mean)
#'   data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"))
#'
#'   zz <- as_flextable( data_co2 ) %>%
#'     add_footer_lines("dataset CO2 has been used for this flextable") %>%
#'     add_header_lines("mean of carbon dioxide uptake in grass plants") %>%
#'     set_header_labels(conc = "Concentration") %>%
#'     autofit() %>%
#'     width(width = c(1, 1, 1))
#'   zz
#' }
as_flextable.grouped_data <- function(x, col_keys = NULL, hide_grouplabel = FALSE, ... ){

  if( is.null(col_keys))
    col_keys <- attr(x, "columns")
  groups <- attr(x, "groups")

  z <- flextable(x, col_keys = col_keys )

  j2 <- length(col_keys)
  for( group in groups){
    i <- !is.na(x[[group]])
    gnames <- x[[group]][i]
    if(!hide_grouplabel){
      z <- compose(z, i = i, j = 1, value = as_paragraph(as_chunk(group), ": ", as_chunk(gnames)))
    } else {
      z <- compose(z, i = i, j = 1, value = as_paragraph(as_chunk(gnames)))
    }

    z <- merge_h_range(z, i = i, j1 = 1, j2 = j2)
    z <- align(z, i = i, align = "left")
  }

  z
}




pvalue_format <- function(x){
  z <- cut(x, breaks = c(-Inf, 0.001, 0.01, 0.05, 0.1, Inf), labels = c("***", "**", "*", ".", ""))
  as.character(z)
}

#' @export
#' @importFrom stats naprint quantile
#' @importFrom utils tail
#' @title tabular summary for lm object
#' @description produce a flextable describing a
#' generalized linear model produced by function `glm`.
#' @param x glm model
#' @param ... unused argument
#' @examples
#' if(require("broom")){
#'   dat <- attitude
#'   dat$high.rating <- (dat$rating > 70)
#'   probit.model <- glm(high.rating ~ learning + critical +
#'      advance, data=dat, family = binomial(link = "probit"))
#'   ft <- as_flextable(probit.model)
#'   ft
#' }
as_flextable.glm <- function(x, ...){


  if( !requireNamespace("broom", quietly = TRUE) ){
    stop("broom package should be install to create a flextable from a glm object.")
  }

  data_t <- broom::tidy(x)
  data_g <- broom::glance(x)
  sum_obj <- summary(x)

  ft <- flextable(data_t, col_keys = c("term", "estimate", "std.error", "statistic", "p.value", "signif"))
  ft <- colformat_num(ft, j = c("estimate", "std.error", "statistic"), digits = 3)
  ft <- colformat_num(ft, j = c("p.value"), digits = 4)
  ft <- mk_par(ft, j = "signif", value = as_paragraph(pvalue_format(p.value)) )

  ft <- set_header_labels(ft, term = "", estimate = "Estimate",
                          std.error = "Standard Error", statistic = "z value",
                          p.value = "Pr(>|z|)", signif = "Signif." )
  dimpretty <- dim_pretty(ft, part = "all")

  digits <- max(3L, getOption("digits") - 3L)

  ft <- add_footer_lines(ft, values = c(
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05 < '.' < 0.1 < '' < 1",
    " ",
    paste("(Dispersion parameter for ", x$family$family, " family taken to be ", format(sum_obj$dispersion), ")", sep = ""),
    sprintf("Null deviance: %s on %s degrees of freedom", format(sum_obj$null.deviance), format(sum_obj$df.null)),
    sprintf("Residual deviance: %s on %s degrees of freedom", format(sum_obj$deviance), format(sum_obj$df.residual)),
    {
      if (nzchar(mess <- naprint(sum_obj$na.action)))
        paste("  (", mess, ")\n", sep = "")
      else character(0)
    },
    paste("AIC: ", formatC(sum_obj$aic), sep = ""),
    " ",
    paste("Number of Fisher Scoring iterations: ", sum_obj$iter, sep = ""),
    "Deviance Residuals:"
  ))
  ft <- align(ft, i = 1, align = "right", part = "footer")
  ft <- italic(ft, i = 1, italic = TRUE, part = "footer")
  quant_ <- as.list( quantile(broom::augment(x)$.resid, probs = c(0, .25, .5, .75, 1)) )
  names(quant_) <- c(names(data_t)[2:5], "signif")
  ft <- add_footer_row(ft,
                       values = c("", "Min", "1Q", "Median", "3Q", "Max"),
                       colwidths = rep(1,6), top = FALSE)
  ft <- add_footer(ft, values = quant_, top = FALSE)

  ft <- align(ft, i = tail(seq_len(nrow_part(ft)), n = 2), align = "center", part="footer")

  width_ <- max(dimpretty$widths[-1])
  height_ <- max(dimpretty$heights)
  ft <- width(ft, j = NULL, width = dimpretty$widths)
  ft <- height_all(ft, height = height_)
  ft
}


#' @export
#' @title tabular summary for lm object
#' @description produce a flextable describing a
#' linear model produced by function `lm`.
#' @param x lm model
#' @param ... unused argument
#' @examples
#' if(require("broom")){
#'   lmod <- lm(rating ~ complaints + privileges +
#'     learning + raises + critical, data=attitude)
#'   as_flextable(lmod)
#' }
as_flextable.lm <- function(x, ...){

  if( !requireNamespace("broom", quietly = TRUE) ){
    stop("broom package should be install to create a flextable from a glm object.")
  }

  data_t <- broom::tidy(x)
  data_g <- broom::glance(x)

  ft <- flextable(data_t, col_keys = c("term", "estimate", "std.error", "statistic", "p.value", "signif"))

  ft <- compose(ft, j = "signif", value = as_paragraph(pvalue_format(p.value)) )

  ft <- set_header_labels(ft, term = "", estimate = "Estimate",
                          std.error = "Standard Error", statistic = "t value",
                          p.value = "Pr(>|t|)", signif = "" )
  ft <- autofit(ft)

  ft <- add_footer_lines(ft, values = c(
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05 < '.' < 0.1 < '' < 1",
    "",
    sprintf("Residual standard error: %s on %.0f degrees of freedom", formatC(data_g$sigma), data_g$df.residual),
    sprintf("Multiple R-squared: %s, Adjusted R-squared: %s", formatC(data_g$r.squared), formatC(data_g$adj.r.squared)),
    sprintf("F-statistic: %s on %.0f and %.0f DF, p-value: %.4f", formatC(data_g$statistic), data_g$df.residual, data_g$df, data_g$p.value),
    "Residuals:"
  ))
  ft <- align(ft, i = 1, align = "right", part = "footer")
  ft <- italic(ft, i = 1, italic = TRUE, part = "footer")
  quant_ <- as.list( quantile(broom::augment(x)$.resid, probs = c(0, .25, .5, .75, 1)) )
  names(quant_) <- c(names(data_t)[2:5], "signif")
  ft <- add_footer_row(ft,
                       values = c("", "Min", "1Q", "Median", "3Q", "Max"),
                       colwidths = rep(1,6), top = FALSE)
  ft <- add_footer(ft, values = quant_, top = FALSE)
  width_ <- max(dim_pretty(ft)$widths[-1])
  ft <- width(ft, j = NULL, width = width_)
  ft
}

#' @export
#' @title continuous columns summary
#' @description create a data.frame summary for continuous variables
#' @param dat a data.frame
#' @param columns continuous variables to be summarized. If NULL all
#' continuous variables are summarized.
#' @param by discrete variables to use as groups when summarizing.
#' @param hide_grouplabel if TRUE, group label will not be rendered, only
#' level/value will be rendered.
#' @param digits the desired number of digits after the decimal point
#' @examples
#' ft_1 <- continuous_summary(iris, names(iris)[1:4], by = "Species",
#'   hide_grouplabel = FALSE)
#' ft_1
#' @section Figures:
#' \if{html}{\figure{man_continuous_summary_1.png}{options: width=100\%}}
continuous_summary <- function(dat, columns = NULL,
                               by = character(0),
                               hide_grouplabel = TRUE,
                               digits = 3){

  if(!is.data.table(dat)){
    x <- as.data.table(dat)
  }
  if(is.null(columns)){
    columns <- colnames(dat)[sapply(dat, function(z) is.double(z) || is.integer(z))]
  }

  fun_list <- c("N", "MIN", "Q1", "MEDIAN",
               "Q3", "MAX", "MEAN", "SD", "MAD", "NAS")
  agg <- x[,
           c(
             lapply(.SD, N),
             lapply(.SD, MIN),
             lapply(.SD, Q1),
             lapply(.SD, MEDIAN),
             lapply(.SD, Q3),
             lapply(.SD, MAX),
             lapply(.SD, MEAN),
             lapply(.SD, SD),
             lapply(.SD, MAD),
             lapply(.SD, NAS)
           ),
           .SDcols = columns,
           by = by]

  gen_cn <- lapply(fun_list, function(fun, col) paste0( col, "_", fun ), columns)
  colnames(agg) <- c(by, unlist(gen_cn))

  agg <- melt(agg, measure = c(gen_cn), value.name = fun_list)
  levels(x = agg[["variable"]] ) <- columns
  z <- as_grouped_data( agg, groups = "variable", columns = setdiff(names(agg), "variable") )
  is_label <- !is.na(z$variable)
  ft <- as_flextable(z, hide_grouplabel = hide_grouplabel)


  ft <- colformat_int(ft, j = c("N", "NAS"))
  ft <- colformat_num(ft, j = setdiff(fun_list, c("N", "NAS")), digits = digits)
  ft <- set_header_labels(ft, values = c("MIN" = "min.", "MAX" = "max.",
                                         "Q1" = "q1", "Q3" = "q3",
                                         "MEDIAN" = "median", "MEAN" = "mean", "SD" = "sd",
                                         "MAD" = "mad",
                                         "NAS" = "# na"))
  ft <- hline(ft, i = is_label, border = officer::fp_border(width = .5))
  ft <- italic(ft, italic = TRUE, i = is_label)
  ft <- merge_v(ft, j = by)
  ft <- valign(ft, j = by, valign = "top")
  ft <- vline(ft, j = length(by), border = officer::fp_border(width = .5), part = "body")
  ft <- vline(ft, j = length(by), border = officer::fp_border(width = .5), part = "header")
  fix_border_issues(ft)
}


utils::globalVariables(c("p.value"))

