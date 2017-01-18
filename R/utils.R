# tools for images treatment----

# compute ids associated with images to be inserted into a MS doc
get_rids <- function( last_id, imgs){
  data.frame(rId = paste0("rId", seq_along(imgs) + last_id),
             src = imgs, nvpr_id = seq_along(imgs), doc_pr_id = seq_along(imgs),
             stringsAsFactors = FALSE )
}

# replace all src in r:embed by their rId
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

# compute the additional relations to insert in the package
expected_rels <- function( rids ){
  data.frame(
    id = rids$rId,
    type = rep("http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
               length(rids$rId)),
    target = file.path("media", basename(rids$src) ),
    stringsAsFactors = FALSE )
}

globalVariables(c(".", "size", "col_key", "fid", "font.family", "id", "pptag", "ref", "value"))

