
#' @export
#' @title tabular summary for gam object
#' @description produce a flextable describing a
#' generalized additive model produced by function `mgcv::gam`.
#' @param x gam model
#' @param ... unused argument
#' @examples
#' library(mgcv)
#' set.seed(2)
#'
#' # Simulated data
#' dat <- gamSim(1,n=400,dist="normal",scale=2)
#'
#' # basic GAM model
#' b <- gam(y~s(x0)+s(x1)+s(x2)+s(x3),data=dat)
#'
#' ft <- as_flextable(b)
#' ft
#'
#' @family as_flextable methods


as_flextable.gam<-function(x,...){
  if(sum(class(x)%in%c("gam"))!=1){
    stop("This model is not a GAM, please check input")
  }

  data_t <- tidy_gam(x)
  data_t$G <- NA
  data_g <- glance_gam(x)

  std_border=officer::fp_border(color = "black", style = "solid",...)
  ft <- flextable(data_t)
  ft <- delete_part(ft,part="header")
  ft <- colformat_num(ft, j = 3:6, digits = 3)

  param.head <- c("Component","Term", "Estimate", "Std Error", "t-value", "p-value")
  for(i in 1:length(param.head)){
    ft <- compose(ft,i=which(grepl(9999,data_t[,1])),j=i,value=as_paragraph(param.head[i]))
  }
  smooth.head<-c("Component","Term", "edf", "Ref. df", "F-value", "p-value")
  for(i in 1:length(smooth.head)){
    ft <- compose(ft,i=which(grepl(9998,data_t[,1])),j=i,value=as_paragraph(smooth.head[i]))
  }
  ft <- compose(ft,j=ncol(data_t),value=as_paragraph(pvalue_format(F)))
  ft<-hline(ft,i=which(grepl(9999,data_t[,1])),border=std_border)
  ft<-hline(ft,i=which(grepl(9998,data_t[,1]))-1,border=std_border)
  ft<-hline(ft,i=which(grepl(9998,data_t[,1])),border=std_border)
  ft<-bold(ft,i=which(data_t[,1]%in%c(9999,9998)))
  ft<-hline_top(ft,border=std_border)
  ft<-hline_bottom(ft,border=std_border)
  ft<-merge_v(ft,j=1)
  ft<-valign(ft,j=1,valign="top")
  ft<-fix_border_issues(ft)
  ft <- add_footer_lines(ft, values = c(
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05 < '.' < 0.1 < '' < 1",
    # "p-values for smooth terms are approximate.",
    "",
    sprintf("Adjusted R-squared: %s, Deviance explained %s", format(data_g$adj.r.squared,digits = 3,format="f",nsmall=3), format(data_g$deviance,digits = 3,format="f",nsmall=3)),
    sprintf("%s : %s, Scale est: %s, N: %d",data_g$method,format(data_g$sp.crit,format="f",digits=3,nsmall=3),format(data_g$scale.est,digits=3,nsmall=3),data_g$nobs)
  ))
  ft <- autofit(ft, part = c("header", "body"))
  ft

}


#' Summarize a(n) gam object
#' @description summarizes information about the components of a model
#' @keywords internal


tidy_gam<-function(model){
  ptab <- data.frame(summary(model)$p.table)
  ptab$term<-rownames(ptab)
  rownames(ptab)=NULL
  ptab$Component="A. parametric coefficients"
  ptab<-ptab[,c(6,5,1:4)]
  colnames(ptab) <- c("Component","Term", "Estimate", "Std.Error", "t.value", "p.value")
  ptab

  stab= data.frame(summary(model)$s.table)
  stab$term<-rownames(stab)
  rownames(stab)=NULL
  stab$Component="B. smooth terms"
  stab<-stab[,c(6,5,1:4)]
  colnames(stab) <- c("Component","Term", "edf", "Ref. df", "F.value", "p.value")
  stab

  ptab.cnames = c("Component","Term", "Estimate", "Std Error", "t-value", "p-value")
  stab.cnames = c("Component","Term", "edf", "Ref. df", "F-value", "p-value")

  colnames(ptab) = c("A", "B", "C", "D","E","F")
  if (ncol(stab) != 0) {
    colnames(stab) = colnames(ptab)
  }
  tab = rbind(ptab, stab)
  # colnames(tab) = ptab.cnames

  tab2 = rbind(rep(9999,length(ptab.cnames)), tab[1:nrow(ptab), ])
  if (nrow(stab) > 0) {
    tab2 = rbind(tab2, rep(9998,length(ptab.cnames)), tab[(nrow(ptab) + 1):nrow(tab), ])
  }

  tab2
}

#' Summarize a(n) gam object
#' @description provides model summaries in one line
#' @keywords internal


glance_gam<-function(model){
  data.frame(
    df=sum(model$edf),
    df.residual=stats::df.residual(model),
    logLik=as.numeric(stats::logLik(model)),
    AIC = stats::AIC(model),
    BIC = stats::BIC(model),
    adj.r.squared=summary(model)$r.sq,
    deviance=summary(model)$dev.expl,
    nobs = stats::nobs(model),
    method=as.character(summary(model)$method),
    sp.crit=as.numeric(summary(model)$sp.criterion),
    scale.est=summary(model)$scale
  )
}

