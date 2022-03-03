#' @export
#' @title tabular summary for gam object
#' @description produce a flextable describing a
#' generalized additive model produced by function `mgcv::gam`.
#' @param x gam model
#' @param ... unused argument
#' @examples
#' if (require("mgcv")) {
#'   set.seed(2)
#'
#'   # Simulated data
#'   dat <- gamSim(1, n = 400, dist = "normal", scale = 2)
#'
#'   # basic GAM model
#'   b <- gam(y ~ s(x0) + s(x1) + s(x2) + s(x3), data = dat)
#'
#'   ft <- as_flextable(b)
#'   ft
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_flextable.gam_1.png}{options: width="400"}}
#' @family as_flextable methods
as_flextable.gam <- function(x, ...) {
  data_t <- tidy_gam(x)
  data_g <- glance_gam(x)

  std_border <- fp_border(color = flextable_global$defaults$border.color, style = "solid", ...)

  param.head <- c("Component", "Term", "Estimate", "Std Error", "t-value", "p-value")
  smooth.head <- c("Component", "Term", "edf", "Ref. df", "F-value", "p-value")
  names(param.head) <- names(data_t$parametric)
  names(smooth.head) <- names(data_t$parametric)

  ft <- flextable(data_t$parametric)
  ft <- border_remove(ft)
  ft <- set_header_labels(ft, values = param.head)

  if(nrow(data_t$smooth)>0){
    ft <- add_body(ft, Component = NA_character_, top = FALSE)
    ft <- add_body(ft, values = setNames(data_t$smooth, names(data_t$parametric)), top = FALSE)
  }
  ft <- compose(ft, j = "p.value", value = as_paragraph(pvalue_format(p.value)))
  ft <- colformat_double(ft, j = 3:5, digits = 3)

  if(nrow(data_t$smooth)>0){
    ft <- compose(ft, i = nrow(data_t$parametric) + 1, value = as_paragraph(smooth.head))
    ft <- hline(ft, i = nrow(data_t$parametric) + c(0, 1), border = std_border)
    ft <- bold(ft, i = nrow(data_t$parametric) + 1)
  }


  ft <- hline_bottom(ft, border = std_border)
  ft <- bold(ft, part = "header")
  ft <- hline_top(ft, border = std_border, part = "header")
  ft <- hline(ft, border = std_border, part = "header")
  ft <- merge_v(ft, j = 1)
  ft <- valign(ft, j = 1, valign = "top")
  ft <- align_nottext_col(ft)
  ft <- align_text_col(ft)
  ft <- fix_border_issues(ft)
  ft <- add_footer_lines(ft, values = c(
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05 < '.' < 0.1 < '' < 1",
    # "p-values for smooth terms are approximate.",
    "",
    sprintf("Adjusted R-squared: %s, Deviance explained %s", format(data_g$adj.r.squared, digits = 3, format = "f", nsmall = 3), format(data_g$deviance, digits = 3, format = "f", nsmall = 3)),
    sprintf("%s : %s, Scale est: %s, N: %d", data_g$method, format(data_g$sp.crit, format = "f", digits = 3, nsmall = 3), format(data_g$scale.est, digits = 3, nsmall = 3), data_g$nobs)
  ))
  ft <- autofit(ft, part = c("header", "body"))
  ft
}


#' Summarize a(n) gam object
#' @description summarizes information about the components of a model
#' @noRd
tidy_gam <- function(model) {
  ptab <- data.frame(summary(model)$p.table)
  ptab$term <- rownames(ptab)
  rownames(ptab) <- NULL
  ptab$Component <- "A. parametric coefficients"
  ptab <- ptab[, c(6, 5, 1:4)]
  colnames(ptab) <- c("Component", "Term", "Estimate", "Std.Error", "t.value", "p.value")

  stab <- data.frame(summary(model)$s.table)
  if(nrow(stab)>0){
    stab$term <- rownames(stab)
    stab$Component <- "B. smooth terms"
    stab <- stab[, c(6, 5, 1:4)]
    colnames(stab) <- c("Component", "Term", "edf", "Ref. df", "F.value", "p.value")
    rownames(stab) <- NULL
  }

  list(parametric = ptab, smooth = stab)
}

#' Summarize a(n) gam object
#' @description provides model summaries in one line
#' @noRd
#' @importFrom stats AIC BIC logLik df.residual nobs
glance_gam <- function(model) {
  data.frame(
    df = sum(model$edf),
    df.residual = df.residual(model),
    logLik = as.numeric(logLik(model)),
    AIC = AIC(model),
    BIC = BIC(model),
    adj.r.squared = summary(model)$r.sq,
    deviance = summary(model)$dev.expl,
    nobs = nobs(model),
    method = as.character(summary(model)$method),
    sp.crit = as.numeric(summary(model)$sp.criterion),
    scale.est = summary(model)$scale,
    stringsAsFactors = FALSE
  )
}
