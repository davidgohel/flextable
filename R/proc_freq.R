format_pct <- function(x){
  ifelse(is.na(x), "", paste0(css_no_unit(x*100, digits = 2), "%") )
}

#' @title frequency table as flextable
#'
#' @description This function compute a two way contingency table
#' and make a flextable with the result.
#'
#' @param x `data.frame` object
#' @param row `characer` column names for row
#' @param col `characer` column names for column
#' @param main `characer` title
#' @param include.row_percent `boolean` whether to include the row percents; defaults to `TRUE`
#' @param include.column_percent `boolean` whether to include the column percents; defaults to `TRUE`
#' @param include.table_percent `boolean` whether to include the table percents; defaults to `TRUE`
#' @param include.column_total `boolean` whether to include the row of column totals; defaults to `TRUE`
#' @param include.row_total `boolean` whether to include the column of row totals; defaults to `TRUE`
#' @param include.header_row `boolean` whether to include the header row; defaults to `TRUE`
#' @param weight `character` column name for weight
#'
#'
#' @importFrom stats as.formula na.omit
#'
#' @examples
#'
#' proc_freq(mtcars, "vs", "gear")
#' proc_freq(mtcars, "gear", "vs")
#' proc_freq(mtcars, "gear", "vs", weight = "wt")
#' proc_freq(mtcars, "gear", "vs", "My title")
#' @export
#' @author Titouan Robert
proc_freq <- function(x, row, col, main = "", include.row_percent = TRUE, include.column_percent = TRUE,
                      include.table_percent = TRUE, include.column_total = TRUE, include.row_total = TRUE, include.header_row = TRUE,
                      weight = NULL){

  ##Compute table
  # tabl <- as.data.frame.matrix(table(x[[row]], x[[col]]))

  x <- data.table::data.table(x)
  if(is.null(weight)){
    tabl <- x[,list(value =  .N), by = c(row, col)]
  }else{
    tabl <- x[,list(value = unlist(lapply(.SD, function(X)sum(X, na.rm = TRUE)))), by = c(row, col), .SDcols = weight]
  }

  tabl  <- na.omit(tabl)
  ff <- as.formula(paste0("`", row, "`~`", col, "`"))
  tabl <- data.table::dcast(tabl, ff, value.var = "value", fill = 0)
  table_out <- as.data.frame(tabl[,.SD, .SDcols = 2:ncol(tabl)])
  rownames(table_out) <- unlist(tabl[, .SD, .SDcols = 1])
  colnames(table_out) <- names(tabl)[2:ncol(tabl)]
  tabl <- table_out

  ##Compute sum
  tablL <- tabl/rowSums(tabl)
  tablR <- t(t(tabl)/colSums(tabl))
  tablT <- tabl/sum(tabl)
  nr <- nrow(tabl)

  ##Make table
  tab_end <- sapply(seq_len(nr), function(X){
    labels <- c("Frequency")
    dat <- tabl[X,, drop = FALSE]
    if (include.row_percent) {
      dat <- rbind(dat, tablL[X,, drop = FALSE])
      labels <- c(labels, "Row Pct", recursive = TRUE)
    }
    if (include.column_percent) {
      dat <- rbind(dat, tablR[X,, drop = FALSE])
      labels <- c(labels, "Col Pct", recursive = TRUE)
    }
    if (include.table_percent) {
      dat <- rbind(dat, tablT[X,, drop = FALSE])
      labels <- c(labels, "Percent", recursive = TRUE)
    }
    names(dat) <- colnames(tabl)

    dd <- data.table::data.table(V1 =  rownames(tabl[X,, drop = FALSE]),label = labels,dat)
    names(dd)[1] <- row
    dd
  }, simplify = FALSE)
  tab_end <- Reduce(rbind, tab_end)
  tab_end <- as.data.frame(tab_end, check.names = FALSE)

  ##Add total
  if (include.row_total) {
    tab_end$Total <- rowSums(tab_end[,3:ncol(tab_end), drop = FALSE])
    index <- which(tab_end$label == "Row Pct" | tab_end$label == "Col Pct" )
    if(length(index)>0)
      tab_end[ index,]$Total <- NA
  }
  if (include.column_total) {
    labels <- c("Frequency")
    if (include.table_percent) {
      labels <- c(labels, "Percent", recursive = TRUE)
    }
    endR <- data.frame(GP = "Total", label = labels)
    names(endR)[1] <-   names(tab_end)[1]
    columnIndexStart <- 3
    columnIndexEnd <- if (include.row_total) ncol(tab_end) - 1 else ncol(tab_end)
    for(i in columnIndexStart:columnIndexEnd){
      total_row <- c(sum(tab_end[[i]][which(tab_end$label=="Frequency")]))
      if (include.table_percent) {
        total_row <- c(total_row, sum(tab_end[[i]][which(tab_end$label=="Percent")]), recursive = TRUE)
      }
      endR[[names(tab_end)[i]]] <- total_row
    }
    if (include.row_total) {
      total_cell <- c(sum(tab_end[["Total"]][which(tab_end$label=="Frequency")]))
      if (include.table_percent) {
        total_cell <- c(total_cell, NA, recursive = TRUE)
      }
      endR$Total = total_cell
    }
    tab_end <- rbind(tab_end, endR)
  }
  nl <- nrow(tab_end)

  ##Make flex
  llflex <- flextable(tab_end)
  llflex <- merge_v(llflex, j = row )
  llflex <- autofit(llflex)

  col_id_counts <- seq(3, ncol(tab_end), by = 1L )
  names_ll <- names(tab_end)
  which_freq <- tab_end$label %in% "Frequency"
  ##Remove digit for Frequency
  llflex <- mk_par(
    llflex, i = ~ label %in% "Frequency", j = col_id_counts,
    value = as_paragraph(as_chunk(.,formatter = function(x) sprintf("%.0f", x))),
    use_dot = TRUE, part = "body")

  ##Add %
  llflex <- mk_par(
    llflex, i = ~ !label %in% "Frequency", j = col_id_counts,
    value = as_paragraph(as_chunk(.,formatter = format_pct)),
    use_dot = TRUE, part = "body")

  ##Style
  fq <- which(tab_end$label == "Frequency")
  llflex <- bold(llflex, j = 1)
  llflex <- border(llflex, i = ~label %in% "Frequency",
                   border.top = fp_border_default())

  if (include.header_row) {
    llflex <- add_header_row(llflex, values = c("", col), colwidths = c(2,ncol(tab_end)-2))
  }
  llflex <- align(llflex, align = "center", part = "header")
  llflex <- bold(llflex, part = "header")
  llflex <- align(llflex, align = "center", part = "body")
  llflex <- valign(llflex, j = 1, valign = "top", part = "body")
  llflex <- fix_border_issues(llflex)

  if(main != ""){

    llflex <- add_header_lines(llflex,  values = main)
    llflex <- bold(llflex, part = "header")
    llflex <- align(llflex, i = 1, align = "left", part = "header")

  }
  llflex <- hline(llflex, part = "header", border = officer::fp_border(color = "black", width = 1))
  llflex <- hline_bottom(llflex, part = "header", border = officer::fp_border(color = "black", width = 2))

  llflex

}

