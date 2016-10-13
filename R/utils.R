#' @title formatting functions
#' @description formatting functions to use with lsmeans objects
#' @param x the vector to format
#' @section extends:
#' Pour creer une nouvelle fonction de formatage, il faut une fonction
#' qui ne prend qu'un argument (un vecteur) et qui renvoie une chaine de
#' caracteres de meme taille que le vecteur d'entree.
#' @export
#' @examples
#' format_pvalue( runif(10))
#'
#' format_percent <- function(x)
#'   ifelse( is.na(x), "", paste0(formatC(x*100, format = "f", digits = 1 ), "%" ) )
#' format_percent( runif(10))
#' @rdname formatting_functions
#' @aliases formatting_functions
format_pvalue <- function(x){

  str <- ifelse( is.na(x) , "",
                 ifelse( x < .001 , "*** ",
                         ifelse( x < .05 , "** ",
                                 ifelse( x < .1 , "* ", "")
                         )
                 )
  )
  val <- ifelse( is.na(x), "", formatC(x, format = "f", digits = 3 ) )
  paste0(str, val)
}

#' @export
#' @param digits number of digits after the decimal point
#' @examples
#' format_double( runif(10))
#' @rdname formatting_functions
format_double <- function(x, digits = 3){
  ifelse( is.na(x), "", formatC(x, format = "f", digits = digits ) )
}


#' @export
#' @examples
#' format_integer( rnorm(10, 3))
#' @rdname formatting_functions
format_integer <- function(x){
  ifelse( is.na(x), "", formatC(x, format = "f", digits = 0 ) )
}

#' @export
#' @examples
#' format_integer( rnorm(10, 3))
#' @rdname formatting_functions
format_default <- function(x){
  if( is.double(x) ) format_double(x)
  else if( is.integer(x) ) format_integer(x)
  else if( is.factor(x) || is.character(x) ) as.character(x)
  else as.character(x)
}







get_rids <- function( last_id, imgs){
  data.frame(rId = paste0("rId", seq_along(imgs) + last_id),
             src = imgs, nvpr_id = seq_along(imgs), doc_pr_id = seq_along(imgs),
             stringsAsFactors = FALSE )
}

rids_substitute_xml <- function( out, rids ){
  for(id in seq_along(rids$src) ){
    out <- gsub(x = out,
                pattern = paste0("r:embed=\"", rids$src[id]),
                replacement = paste0("r:embed=\"", rids$rId[id]) )
    out <- gsub(x = out, pattern = "DRAWINGOBJECTID", replacement = rids$doc_pr_id[id] )
    out <- gsub(x = out, pattern = "PICTUREID", replacement = rids$nvpr_id[id] )
  }
  out
}

expected_rels <- function( rids ){
  data.frame(
    id = rids$rId,
    type = rep("http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
               length(rids$rId)),
    target = file.path("media", basename(rids$src) ),
    stringsAsFactors = FALSE )
}



