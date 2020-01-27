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

