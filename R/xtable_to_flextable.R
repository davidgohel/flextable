#' @importFrom officer fp_text fp_par fp_border
#' @title get a flextable from a xtable object
#'
#' @description Get a \code{flextable} object from
#' a \code{xtable} object.
#'
#' @param x \code{xtable} object
#' @param text.properties default text formatting properties
#' @param format.args List of arguments for the formatC function.
#' See argument \code{format.args} of \code{print.xtable}. Not yet
#' implemented.
#' @param rowname_col colname used for row names column
#' @param hline.after see \code{?print.xtable}.
#' @param NA.string see \code{?print.xtable}.
#' @param include.rownames see \code{?print.xtable}.
#' @param rotate.colnames see \code{?print.xtable}.
#' @examples
#' library(officer)
#' if( require("xtable") ){
#'
#'   data(tli)
#'   tli.table <- xtable(tli[1:10, ])
#'   align(tli.table) <- rep("r", 6)
#'   align(tli.table) <- "|r|r|clr|r|"
#'   ft <- xtable_to_flextable(
#'     tli.table,
#'     rotate.colnames = TRUE,
#'     include.rownames = FALSE)
#'   ft <- height(ft, i = 1, part = "header", height = 1)
#'   ft
#'
#'   \donttest{
#'   Grade3 <- c("A","B","B","A","B","C","C","D","A","B",
#'     "C","C","C","D","B","B","D","C","C","D")
#'   Grade6 <- c("A","A","A","B","B","B","B","B","C","C",
#'     "A","C","C","C","D","D","D","D","D","D")
#'   Cohort <- table(Grade3, Grade6)
#'   ft <- xtable_to_flextable(xtable(Cohort))
#'   ft <- set_header_labels(ft, rowname = "Grade 3")
#'   ft <- autofit(ft)
#'   ft <- add_header(ft, A = "Grade 6")
#'   ft <- merge_at(ft, i = 1, j = seq_len( ncol(Cohort) ) + 1,
#'     part = "header" )
#'   ft <- bold(ft, j = 1, bold = TRUE, part = "body")
#'   ft <- height_all(ft, part = "header", height = .4)
#'   ft
#'
#'   temp.ts <- ts(cumsum(1 + round(rnorm(100), 0)),
#'     start = c(1954, 7), frequency = 12)
#'   xtable_to_flextable(x = xtable(temp.ts, digits = 0),
#'     NA.string = "-")
#'   }
#' }
#' @export
xtable_to_flextable <- function(
  x, text.properties = officer::fp_text(),
  format.args = getOption("xtable.format.args", NULL),
  rowname_col = "rowname",
  hline.after = getOption("xtable.hline.after", c(-1,0,nrow(x))),
  NA.string = getOption("xtable.NA.string", ""),
  include.rownames = TRUE,
  rotate.colnames = getOption("xtable.rotate.colnames", FALSE)
){

  padding.left <- 4
  padding.right <- 4

  stopifnot(inherits(x, "xtable"))

  if( ! is.null(hline.after) ){
    if (any(hline.after < -1) | any(hline.after > nrow(x))) {
      stop("'hline.after' must be inside [-1, nrow(x)]")
    }
  }

  if( !include.rownames ){
    data <- as.data.frame(x, stringsAsFactors = FALSE)
    col_labels <- names(x)
    col_id <- make.names(col_labels)
  } else {
    rn_x <- row.names(x)
    data <- cbind(
      structure(list(rn_x), .Names = rowname_col, row.names = seq_along(rn_x), class = "data.frame"),
      as.data.frame(x, stringsAsFactors = FALSE) )
    col_labels <- c("", names(x) )
    col_id <- make.names(col_labels)
    col_id[1] <- rowname_col
  }
  names(data) <- col_id

  nrow_ <- nrow(data)
  ncol_ <- ncol(data)

  ina <- matrix(FALSE, nrow = nrow(data), ncol = ncol(data) )

  for(j in seq_along(col_id)){
    if( is.factor( data[[j]] ) ){
      data[[j]] <- as.character(data[[j]])
    }
    if(is.list(data[[j]])) {
      data[[j]] <- sapply(data[[j]], unlist)
    }
    ina[,j] <- is.na(data[[j]])
  }

  if (is.null(format.args)){
    format.args <- list()
  }
  if (is.null(format.args$decimal.mark)){
    format.args$decimal.mark <- options()$OutDec
  }

  digits_val <- attr( x, "digits", exact = TRUE )
  display_val <- attr(x, "display", exact = TRUE )
  align <- attr(x, "align")

  if(!include.rownames) {
    digits_val <- digits_val[-1]
    display_val <- display_val[-1]
    which_grep <- grep("^[a-zA-Z]", align)[1]
    align <- align[-seq_len(which_grep)]
  }

  if( !is.matrix( digits_val ) ){
    digits_val <- rep(digits_val, each = nrow_ )
  }
  display_val <- ifelse(
    digits_val < 0, "E",
    rep( display_val, each = nrow_ )
  )

  col_names_ <- rep( col_id, each = nrow_ )
  rows_index <- rep(seq_len(nrow_), ncol_)

  ft <- flextable(data)

  ft <- set_header_df(ft, mapping = data.frame(col_keys=col_id, label = col_labels, stringsAsFactors = FALSE) )
  for(iter in seq_along(rows_index)){
    val <- sprintf("value ~ formatC_with_na(%s, digits = %.0f, format = '%s', na_string = '%s')", col_names_[iter], digits_val[iter], display_val[iter], NA.string )
    val <- as.formula(val)
    val[[3]] <- append(as.list(val[[3]]), format.args )
    mode(val[[3]]) <- "call"
    ft <- display(ft, col_key = col_names_[iter], i = rows_index[iter], pattern = "{{value}}",
                             formatters = list(val) )
  }
  ft <- border(x = ft, border = fp_border(width = 0), part = "all")
  ft <- style( x = ft, pr_t = text.properties, part = "all")
  ft <- bg(x = ft, bg = "transparent", part = "all")
  ft <- bold(x = ft, bold = TRUE, part = "header")
  if( include.rownames ){
    ft <- bold(x = ft, j = 1, bold = TRUE, part = "body")
  }

  parProp <- fp_par(padding.left = padding.left, padding.right = padding.right)

  if( any( align == "|") ){
    new_align = character(0)
    border_right_pos = integer(0)
    do_left_table = FALSE
    do_right_table = FALSE
    for( i in seq_along(align)){
      if( i == 1 && align[i] == "|" ){
        do_left_table = TRUE
      } else if( align[i] == "|" && i < length(align) ){
        border_right_pos = append( border_right_pos, length(new_align) )
      } else if( align[i] == "|" && i == length(align) ){
        do_right_table = TRUE
      } else {
        new_align = append( new_align, align[i] )
      }
    }
    align = new_align

    if( do_left_table ) {
      ft <- border(ft, j = 1, border.left = fp_border(), part = "all")
    }
    if( length( border_right_pos) > 0 ){
      ft <- border(ft, j = border_right_pos, border.right = fp_border(), part = "all")
    }
    if( do_right_table ) {
      ft <- border(ft, j = length(align), border.right = fp_border(), part = "all")
    }
  }

  if( rotate.colnames ){
    ft <- rotate(x = ft, rotation = "btlr", part = "header")
    header_dims <- dim_pretty(ft, part = "header")
    body_dims <- dim_pretty(ft, part = "body")
    footer_dims <- dim_pretty(ft, part = "footer")

    widths_header <- rep(header_dims$heights, each = length(ft$col_keys) )
    widths_header <- matrix(widths_header, ncol = length(ft$col_keys) )
    widths_header <- as.numeric( apply(widths_header, 2, max, na.rm = TRUE) )
    heights_header <- rep( max(header_dims$widths), nrow_part(ft, "header" ) )
    header_dims$widths <- widths_header
    header_dims$heights <- heights_header

    widths_ <- do.call(rbind, list(header_dims$widths, body_dims$widths, footer_dims$widths) )
    widths_ <- as.numeric( apply( widths_, 2, max, na.rm = TRUE ) )
    heights_ <- do.call(c, list(header_dims$heights, body_dims$heights, footer_dims$heights) )
    ft <- width(ft, width = widths_)
    ft <- height(ft, height = header_dims$heights, part = "header")
    ft <- height(ft, height = body_dims$heights, part = "body")
    ft <- height(ft, height = footer_dims$heights, part = "footer")
    ft <- align(ft, align = "left", part = "header")
  } else {
    ft <- autofit(ft)
  }

  widths <- get_xtable_widths(align)
  align[!is.na(widths)] <- "j"
  if( !all(is.na(widths))){
    j <- which(!is.na(widths))
    width <- widths[j]
    ft <- width( ft, j = j, width = width)
  }

  ft <- align( ft, j = align %in% "r", part = "all", align = "right")
  ft <- align( ft, j = align %in% "l", part = "all", align = "left")
  ft <- align( ft, j = align %in% "c", part = "all", align = "center")
  ft <- align( ft, j = align %in% "j", part = "all", align = "justify")


  if (!is.null(hline.after)){
    if( -1 %in% hline.after ){
      hline.after = setdiff( hline.after, -1 )
      ft <- border(ft, i = 1, border.top = fp_border(), part = "header")
    }
    if( 0 %in% hline.after ){
      hline.after = setdiff( hline.after, 0 )
      ft <- border(ft, border.bottom = fp_border(), part = "header")
    }
    if( length( hline.after ) > 0 ){
      ft <- border(ft, i = hline.after, border.bottom = fp_border(), part = "body")
    }

  }



  ft
}


formatC_with_na <- function(x, digits, format, na_string, ...){
  ifelse( is.na(x), na_string, formatC(x, digits = digits, format = format, ...) )
}


get_xtable_widths <- function(align, default_width = .3){
  rex <- "^(p\\{)([0-9\\.]+)(cm|in|px)(\\}$)"
  width <- rep(default_width, length(align))
  w_matches <- grepl(rex, align)
  width[w_matches]
  newwidths <- gsub(rex, "\\2", align)
  newwidths[!w_matches] <- ""
  newwidths <- as.numeric(newwidths)

  units <- gsub(rex, "\\3", align)
  units[!w_matches] <- "in"
  if( any(!units %in% c("in", "cm", "px")) ){
    stop("unknown unit, supported units for column width are in, cm and px")
  }
  newwidths[units %in% "cm"] <- newwidths[units %in% "cm"] / 2.54
  newwidths[units %in% "px"] <- newwidths[units %in% "cm"] / 72
  newwidths
}

