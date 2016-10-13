lazy_format_simple <- function( col_key ){
  format_simple_l <- as.lazy( interp("fpar(x)", x = as.name(col_key) ), globalenv() )
  format_simple_l
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



