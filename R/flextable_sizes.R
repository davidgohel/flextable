#' @export
#' @title Set flextable columns width
#' @description control columns width
#' @param x flextable object
#' @param j columns selection
#' @param width width in inches
#' @details
#' Heights are not used when flextable is been rendered into HTML.
#' @examples
#'
#' ft <- flextable(iris)
#' ft <- width(ft, width = 1)
#'
#' write_docx("autofit.docx", ft)
#' @seealso \code{\link{flextable}}
width <- function(x, j = NULL, width){

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[["body"]], j )

  stopifnot(length(j)==length(width) || length(width) == 1)

  if( length(width) == 1 ) width <- rep(width, length(j))

  x$header$colwidths[j] <- width
  x$body$colwidths[j] <- width

  x
}

#' @export
#' @title Set flextable rows height
#' @description control rows height
#' @param x flextable object
#' @param i rows selection
#' @param height height in inches
#' @param part partname of the table
#' @examples
#'
#' ft <- flextable(iris)
#' ft <- height(ft, height = .3)
#'
#' write_docx("height.docx", ft)
height <- function(x, i = NULL, height, part = "body"){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( inherits(i, "formula") && any( c("header", "all") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'all'.")
  }

  if( part == "all" ){
    nrow_h <- nrow(x$header$dataset)
    nrow_b <- nrow(x$body$dataset)

    if( is.null(i) && length(height) != (nrow_h+nrow_b)  && length(height) != 1 ){
      stop("length of i should be ", (nrow_h+nrow_b), " or 1." )
    } else if( (!is.null(i) && length(i) == (nrow_h+nrow_b)) || is.null(i) ){
      if( length( height ) != 1 ){
        i_h <- seq_len(nrow_h)
        i_b <- seq_len(nrow_b)+nrow_h
      } else {
        i_h <- 1
        i_b <- 1
      }

      x <- height(x = x, i = i[i_h], height = height[i_h], part = "header")
      x <- height(x = x, i = i[i_b], height = height[i_b], part = "body")
    } else {
      x <- height(x = x, i = i, height = height, part = "header")
      x <- height(x = x, i = i, height = height, part = "body")
    }

    return(x)
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )
  if( !(length(i) == length(height) || length(height) == 1)){
    stop("height should be of length 1 or ", length(i))
  }

  x[[part]]$rowheights[i] <- height

  x
}

#' @title Get flextable dimensions
#' @description returns widths and heights for each table columns and rows.
#' @param x flextable object
#' @export
dim.flextable <- function(x){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      max_widths[[j]] <- x[[j]]$colwidths
      max_heights[[j]] <- x[[j]]$rowheights
    }
  }

  mat_widths <- do.call("rbind", max_widths)
  out_widths <- apply( mat_widths, 2, max )
  names(out_widths) <- x$col_keys

  out_heights <- as.double(unlist(max_heights))
  list(widths = out_widths, heights = out_heights )
}

#' @export
#' @title Calculate pretty dimensions
#' @param x flextable object
#' @description return minimum estimated widths and heights for
#' each table columns and rows.
#' @examples
#'
#' # get estimated widths
#' ft <- flextable(mtcars)
#' dim_pretty(ft)
dim_pretty <- function( x ){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      dimensions_ <- get_dimensions(x[[j]])
      x[[j]]$colwidths <- dimensions_$widths
      x[[j]]$rowheights <- dimensions_$heights
    }
  }
  dim(x)
}



#' @export
#' @title Adjusts cell widths and heights
#' @description compute and apply optimized widths and heights.
#' @param x flextable object
#' @param add_w extra width to add in inches
#' @param add_h extra height to add in inches
#' @examples
#'
#' ft <- flextable(mtcars)
#' ft <- autofit(ft)
#'
#' write_docx("autofit.docx", ft)
autofit <- function(x, add_w = 0.1, add_h = 0.1 ){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      dimensions_ <- get_dimensions(x[[j]])
      x[[j]]$colwidths <- dimensions_$widths + add_w
      x[[j]]$rowheights <- dimensions_$heights + add_h
    }
  }
  x
}


