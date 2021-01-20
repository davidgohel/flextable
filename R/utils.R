
#' @importFrom data.table rbindlist setDF
rbind.match.columns <- function(list_df) {
  df <- rbindlist(list_df, use.names = TRUE, fill = TRUE)
  setDF(df)
  row.names(df) <- NULL
  df
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


#' @importFrom stats median median sd mad
#' @importFrom stats quantile
Q1 <- function(z) as.double(quantile(z, probs = .25, na.rm = TRUE, names = FALSE))
Q3 <- function(z) as.double(quantile(z, probs = .75, na.rm = TRUE, names = FALSE))
MEDIAN <- function(z) as.double(median(z, na.rm = TRUE))
MEAN <- function(z) as.double(mean(z, na.rm = TRUE))
SD <- function(z) as.double(sd(z, na.rm = TRUE))
MAD <- function(z) as.double(mad(z, na.rm = TRUE))
MIN <- function(z) as.double(min(z, na.rm = TRUE))
MAX <- function(z) as.double(max(z, na.rm = TRUE))
N <- function(z) length(z)
NAS <- function(z) sum(is.na(z))


#' @importFrom uuid UUIDgenerate
as_bookmark <- function(id, str) {
  new_id <- UUIDgenerate()
  bm_start_str <- sprintf("<w:bookmarkStart w:id=\"%s\" w:name=\"%s\"/>", new_id, id)
  bm_start_end <- sprintf("<w:bookmarkEnd w:id=\"%s\"/>", new_id)
  paste0(bm_start_str, str, bm_start_end)
}

format_double <- function(x, digits = 2){
  formatC(x, format = "f", digits = digits, decimal.mark = ".", drop0trailing = TRUE )
}


