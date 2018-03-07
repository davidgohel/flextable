
globalVariables(c("str", ".", "str_is_run"))

image_entry <- function(src, width, height){
  x <- data.frame(image_src = src, width = width, height = height, stringsAsFactors = FALSE)
  class(x) <- c( "image_entry", class(x) )
  x
}

format.image_entry = function (x, type = "console", ...){
  stopifnot( length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html", "console") )

  if( type == "pml" ){
    out <- rep("", nrow(x))
  } else if( type == "console" ){
    out <- rep("{image_entry:{...}}", nrow(x))
  } else {
    out <- mapply( function(image_src, width, height){
      format( external_img(src = image_src, width = width, height = height), type = type )
    }, x$image_src, x$width, x$height, SIMPLIFY = FALSE)
    out <- setNames(unlist(out), NULL)
  }
  out
}



drop_column <- function(x, cols){
  x[, !(colnames(x) %in% cols), drop = FALSE]
}





as_grp_index <- function(x){
  sprintf( "gp_%09.0f", x )
}

group_index <- function(x, by, varname = "grp"){
  order_ <- do.call( order, x[ by ] )
  x$ids_ <- seq_along(order_)
  x <- x[order_, ,drop = FALSE]
  gprs <- cumsum(!duplicated(x[, by ]) )
  gprs <- gprs[order(x$ids_)]
  as_grp_index(gprs)
}

group_ref <- function(x, by, varname = "grp"){
  order_ <- do.call( order, x[ by ] )
  x$ids_ <- seq_along(order_)
  x <- x[order_, ,drop = FALSE]
  ref <- x[!duplicated(x[, by ]), by]
  ref$index_ <- as_grp_index( seq_len( nrow(ref) ) )
  row.names(ref) <- NULL
  ref
}

drop_useless_blank <- function( x ){
  grp <- group_index(x, by = c("col_key", "id") )
  x <- split( x, grp)
  x <- lapply( x, function(x){
    non_empty <- which( !x$str %in% c("", NA) | x$type_out %in% "image_entry" )
    if(length(non_empty)) x[non_empty,]
    else x[1,]
  })
  do.call(rbind, x)
}

get_i_from_formula <- function( f, data ){
  if( length(f) > 2 )
    stop("formula selection is not as expected ( ~ condition )", call. = FALSE)
  i <- eval(as.call(f[[2]]), envir = data)
  if( !is.logical(i) )
    stop("formula selection should return a logical vector", call. = FALSE)
  i
}
get_j_from_formula <- function( f, data ){
  if( length(f) > 2 )
    stop("formula selection is not as expected ( ~ variables )", call. = FALSE)
  j <- attr(terms(f), "term.labels")
  names_ <- names(data)
  if( any( invalid_names <- (!j %in% names_) ) ){
    invalid_names <- paste0("[", j[invalid_names], "]", collapse = ", ")
    stop("unknown variables:", invalid_names, call. = FALSE)
  }
  j
}

check_formula_i_and_part <- function(i, part){
  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part '", part, "'.", call. = FALSE)
  } else if( inherits(i, "formula") && "footer" %in% part ){
    stop("formula in argument i cannot adress part '", part, "'.", call. = FALSE)
  }
  TRUE
}

nrow_part <- function(x, part){
  if( is.null(x[[part]]) )
    0
  else if( is.null(x[[part]]$dataset) )
    0
  else nrow(x[[part]]$dataset)
}

process_url <- function(rel, url, str, pattern, double_esc = TRUE){
  new_rid <- sprintf("rId%.0f", rel$get_next_id())

  if(double_esc)
    escape <- function(x) htmlEscape(htmlEscape(x))
  else escape <- function(x) htmlEscape(x)# it seems that word does not behave as powerpoint

  rel$add(
    id = new_rid, type = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
    target = escape(url), target_mode = "External" )

  str_replace_all( string = str,
    fixed( sprintf("<%s r:id=\"%s\"", pattern, url ) ),
    sprintf("<%s r:id=\"%s\"", pattern, new_rid )
  )
}

create_display <- function(data, col_keys){
  set_formatter_type_formals <- formals(set_formatter_type)
  formatters <- mapply(function(x, varname){
    if( is.double(x) ) paste0(varname, " ~ sprintf(", shQuote(set_formatter_type_formals$fmt_double), ", `", varname ,"`)")
    else if( is.integer(x) ) paste0(varname, " ~ sprintf(", shQuote(set_formatter_type_formals$fmt_integer), ", `", varname ,"`)")
    else if( is.factor(x) ) paste0(varname, " ~ as.character(`", varname ,"`)")
    else if( is.character(x) ) paste0(varname, " ~ as.character(`", varname ,"`)")
    else if( inherits(x, "Date") ) paste0(varname, " ~ format(`", varname ,"`, ", shQuote(set_formatter_type_formals$fmt_date), ")")
    else if( inherits(x, "POSIXt") ) paste0(varname, " ~ format(`", varname ,"`, ", shQuote(set_formatter_type_formals$fmt_datetime), ")")
    else paste0(varname, " ~ ", set_formatter_type_formals$fun_any, "(`", varname ,"`)")
  }, data[col_keys], col_keys, SIMPLIFY = FALSE)
  formatters <- mapply(function(f, varname){
    display_parser$new(x = paste0("{{", varname, "}}"),
                       formatters = list( as.formula( f ) ),
                       fprops = list() )
  }, formatters, col_keys )
  display_structure$new(nrow(data), col_keys, formatters )
}


replace.na <- function(x, by = ""){
  x[is.na(x)] <- by
  x
}
dbl_fun <- function(x, fmt_double) {
  replace.na(sprintf(fmt_double, x), by = "")
}
int_fun <- function(x, fmt_integer) {
  replace.na(sprintf(fmt_integer, x), by = "")
}
str_fun <- function(x) {
  replace.na(as.character(x), by = "")
}
date_fun <- function(x, fmt_date){
  replace.na(format(x, fmt_date), by = "")
}
datetime_fun <- function(x, fmt_datetime){
  replace.na(format(x, fmt_datetime), by = "")
}
any_fun <- function(x){
  replace.na(format(x), by = "")
}

