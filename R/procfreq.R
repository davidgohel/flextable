format_pct <- function(x){
  ifelse(is.na(x), "", sprintf("%.02f%%", x*100) )
}

#' @title procFreq for flextable
#'
#' @description This function compute statistics and make a flextable.
#'
#' @param x \code{data.frame} object
#' value specifying label to use.
#' @param row \code{characer} column of x for row
#' @param col \code{characer} column of x for col
#' @param main \code{characer} title
#'
#' @examples
#'
#' data("mtcars")
#' procFreq(mtcars, "vs", "gear")
#' procFreq(mtcars, "gear", "vs")
#' procFreq(mtcars, "gear", "vs", "My title")
#'
#' @export
procFreq <- function(x, row, col, main = ""){

  DD <- as.data.frame.matrix(table(x[[row]], x[[col]]))

  DDl <- DD/rowSums(DD)
  DDr <- t(t(DD)/colSums(DD))
  DDt <- DD/sum(DD)
  nr <- nrow(DD)
  ll <- sapply(seq_len(nr), function(X){
    dat <- rbind(DD[X,], DDl[X,], DDr[X,], DDt[X,])
    names(dat) <- colnames(DD)
    dd <- data.table::data.table(V1 =  rownames(DD[X,]),label = c("Frequency", "Row Pct", "Col Pct", "Percent"),
                                 dat)
    names(dd)[1] <- row
    dd
  }, simplify = FALSE)
  ll <- Reduce(rbind, ll)
  ll <- as.data.frame(ll, check.names = FALSE)

  ll$Total <- rowSums(ll[,3:ncol(ll)])
  ll[ which(ll$label == "Row Pct" | ll$label == "Col Pct" ),]$Total <- NA
  endR <- data.frame(GP = "Total", label = c("Frequency","Percent"))
  names(endR)[1] <-   names(ll)[1]
  for(i in 3:(ncol(ll) - 1)){
    endR[[names(ll)[i]]] <-  c(sum(ll[[i]][which(ll$label=="Frequency")]), sum(ll[[i]][which(ll$label=="Percent")]))
  }
  endR$Total = c(sum(ll[["Total"]][which(ll$label=="Frequency")]), NA)
  ll <- rbind(ll, endR)
  nl <- nrow(ll)
  llflex <- flextable(ll)
  llflex <- merge_v(llflex, j = row )
  llflex <- autofit(llflex)

  col_id_counts <- seq(3, ncol(ll), by = 1L )
  names_ll <- names(ll)
  which_freq <- ll$label %in% "Frequency"
  for(j in col_id_counts){
    llflex <- flextable::compose(
      llflex, i = which_freq, j = j,
      value = as_paragraph(
        as_chunk(ll[[j]][which_freq],
                 formater = function(x){
                   sprintf("%.0f", x)
                 })))

  }

  which_percent <- !which_freq
  for(j in col_id_counts){
    llflex <- flextable::compose(
      llflex, i = which_percent, j = j,
      value = as_paragraph(
        as_chunk(ll[[j]][which_percent],
                 formater = format_pct)))

  }

  fq <- which(ll$label == "Frequency")
  llflex <- flextable::bold(llflex, fq, 2:ncol(ll))
  llflex <- flextable::bold(llflex, 1:nrow(ll), 1)

  llflex <- flextable::border(llflex, fq, 1:ncol(ll), border.top = officer::fp_border(color = "black"))

  llflex <- add_header_row(llflex, values = c("", col), colwidths = c(2,ncol(ll)-2))
  llflex <- align(llflex, align = "center", part = "header")
  llflex <- flextable::bold(llflex, part = "header")
  llflex <- align(llflex, align = "center", part = "body")
  llflex <- valign(llflex, j = 1, valign = "top", part = "body")
  llflex <- fix_border_issues(llflex)

  if(main != ""){

    llflex <- flextable::add_header_lines(llflex,  values = main)
    llflex <- flextable::bold(llflex, part = "header")
    llflex <- align(llflex, i = 1, align = "left", part = "header")

  }
  llflex <- flextable::hline(llflex, part = "header", border = officer::fp_border(color = "black", width = 1))
  llflex <- flextable::hline_bottom(llflex, part = "header", border = officer::fp_border(color = "black", width = 2))

  llflex

}

