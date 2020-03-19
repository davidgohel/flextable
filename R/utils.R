
rbind.match.columns <- function(list_df) {
  col <- unique(unlist(sapply(list_df, names)))

  list_df <- lapply(list_df, function(x, col) {
    x[, setdiff(col, names(x))] <- NA
    x
  }, col = col)
  list_df <- do.call(rbind, list_df)
  row.names(list_df) <- NULL
  list_df
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

#' @importFrom xml2 xml_attr<-
process_url <- function(rel, url, str, pattern, double_esc = TRUE){

  if(double_esc)
    escape <- function(x) htmlEscape(htmlEscape(x))
  else escape <- function(x) htmlEscape(x)# it seems that word does not behave as powerpoint


  doc <- as_xml_document(str)
  for(url_ in url){
    new_rid <- sprintf("rId%.0f", rel$get_next_id())
    rel$add(
      id = new_rid, type = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
      target = escape(url_), target_mode = "External" )

    linknodes <- xml_find_all(doc, paste0("//", pattern, "[@r:id=", shQuote(url_), "]"))
    xml_attr(linknodes, "r:id") <- new_rid
  }

  as.character(doc)
}

absolute_path <- function(x){

  if (length(x) != 1L)
    stop("'x' must be a single character string")
  epath <- path.expand(x)

  if( file.exists(epath)){
    epath <- normalizePath(epath, "/", mustWork = TRUE)
  } else {
    if( !dir.exists(dirname(epath)) ){
      stop("directory of ", x, " does not exist.", call. = FALSE)
    }
    cat("", file = epath)
    epath <- normalizePath(epath, "/", mustWork = TRUE)
    unlink(epath)
  }
  epath
}

#' @importFrom knitr opts_current
ref_label <- function() {
  label <- opts_current$get('label')
  if (is.null(label)) return('')
  paste0("(\\#tab:", label, ")")
}

has_label <- function(x) {
  grepl("^\\(\\\\#tab:[-[:alnum:]]+\\)", x)
}
