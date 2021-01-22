#' @export
#' @title fix border issues when cell are merged
#' @description When cells are merged, the rendered borders will be those
#' of the first cell. If a column is made of three merged cells, the bottom
#' border that will be seen will be the bottom border of the first cell in the
#' column. From a user point of view, this is wrong, the bottom should be the one
#' defined for cell 3. This function modify the border values to avoid that effect.
#' @param x flextable object
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @examples
#' library(officer)
#' dat <- data.frame(a = 1:5, b = 6:10)
#' ft <- flextable(dat)
#'   ft <- theme_box(ft)
#'   ft <- merge_at(ft, i = 4:5, j = 1, part = "body")
#'   ft <- hline(ft, i = 5, part = "body",
#'         border = fp_border(color = "red", width = 5) )
#' print(ft)
#' ft <- fix_border_issues(ft)
#' print(ft)
fix_border_issues <- function(x, part = "all"){
  if( !inherits(x, "flextable") ) stop("fix_border_issues supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- fix_border_issues(x = x, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  x[[part]] <- correct_h_border(x[[part]])
  x[[part]] <- correct_v_border(x[[part]])
  x
}

correct_h_border <- function(x){

  span_cols <- as.list(as.data.frame(x$spans$columns))

  bool_to_be_corrected <- lapply( span_cols, function(x) x > 1 )
  l_apply_bottom_border <- lapply( span_cols, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1 )
  })

  for(j in seq_len(ncol(x$spans$columns)) ){
    apply_bottom_border <- l_apply_bottom_border[[j]]

    if( apply_bottom_border$dont ) next

    for( i in seq_along(apply_bottom_border$from) ){
      i_from <- apply_bottom_border$from[i]
      i_to <- apply_bottom_border$to[i]

      x$styles$cells$border.color.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.color.bottom[i_from, x$col_keys[j]]
      x$styles$cells$border.width.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.width.bottom[i_from, x$col_keys[j]]
      x$styles$cells$border.style.bottom[i_to, x$col_keys[j]] <- x$styles$cells$border.style.bottom[i_from, x$col_keys[j]]
    }

  }

  x
}
correct_v_border <- function(x){

  span_rows <- as.list(as.data.frame(t(x$spans$rows)))

  l_apply_right_border <- lapply( span_rows, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1 )
  })

  for(i in seq_along(l_apply_right_border) ){

    apply_right_border <- l_apply_right_border[[i]]

    if( apply_right_border$dont ) next

    for( j in seq_along(apply_right_border$from) ){

      colkeyto <- x$col_keys[apply_right_border$to[j]]
      colkeyfrom <- x$col_keys[apply_right_border$from[j]]
      x$styles$cells$border.color.right[i, colkeyto] <- x$styles$cells$border.color.right[i, colkeyfrom]
      x$styles$cells$border.width.right[i, colkeyto] <- x$styles$cells$border.width.right[i, colkeyfrom]
      x$styles$cells$border.style.right[i, colkeyto] <- x$styles$cells$border.style.right[i, colkeyfrom]

    }

  }

  x
}
