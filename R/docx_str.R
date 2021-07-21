# utils -----
coalesce_options <- function(a=NULL, b=NULL) {
  if(is.null(a)) return(b)
  if(is.null(b)) return(a)
  if( length(b) == 1 ){
    b <- rep(b, length(a))
  }
  out <- a
  out[!is.finite(a)] <- b[!is.finite(a)]
  out
}
mcoalesce_options <- function(...) {
  Reduce(coalesce_options, list(...))
}

# docx_str -----
docx_str <- function(x, align = "center", split = FALSE, doc = NULL, ...){

  imgs <- character(0)
  hlinks <- character(0)

  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(x)
  widths <- dims$widths

  out <- paste0(
      "<w:tbl xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" ",
      "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
      "xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" ",
      "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" ",
      "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
      "xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\" ",
      ">")
  if(x$properties$layout %in% "autofit"){
    pt <- prop_table(
      layout = table_layout(type = "autofit"),
      align = align,
      width = table_width(width = x$properties$width, unit = "pct"),
      colwidths = table_colwidths(double(0L)))
  } else {
    pt <- prop_table(
      layout = table_layout(type = "fixed"),
      align = align,
      width = table_width(unit = "in",
                          width = sum(widths, na.rm = TRUE)
      ),
      colwidths = table_colwidths(widths))
  }
  properties_str <- to_wml(pt, add_ns= FALSE, base_document = doc)


  out <- paste0(out, properties_str )

  if( nrow_part(x, "header") > 0 ){
    xml_content <- format(x$header, header = TRUE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
    out = paste0(out, xml_content )
  }
  if( nrow_part(x, "body") > 0 ){
    xml_content <- format(x$body, header = FALSE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )

    out = paste0(out, xml_content )
  }
  if( nrow_part(x, "footer") > 0 ){
    xml_content <- format(x$footer, header = FALSE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
    out = paste0(out, xml_content )
  }

  imgs <- unique(imgs)
  hlinks <- unique(hlinks)

  out <- paste0(out,  "</w:tbl>" )

  if( length(imgs) > 0 ) {
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      doc <- docx_reference_img( doc, imgs )
      out <- wml_link_images( doc, out )
    }
  }
  if( length(hlinks) > 0 ){
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      for( hl in hlinks ){
        rel <- doc$doc_obj$relationship()
        out <- process_url(rel, url = hl, str = out, pattern = "w:hyperlink", double_esc = FALSE)
      }
    }
  }

  out

}

#' @importFrom officer run_bookmark ftext
caption_docx_bookdown <- function(x){
  tab_props <- opts_current_table()
  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, opts_current$get('label'))
  tab_props$cap <- mcoalesce_options(x$caption$value, tab_props$cap)
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  has_caption_label <- !is.null(tab_props$cap)
  has_caption_style <- !is.null(tab_props$cap.style)
  style_start <- ""
  style_end <- ""

  if(has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }

  caption <- ""
  if(has_caption_label) {
    zz <- if(!is.null(tab_props$id)){
      run_bookmark(paste0(tab_props$tab.lp, tab_props$id), ftext(tab_props$cap))
    } else {
      ftext(tab_props$cap)
    }

    zz <- paste("`", to_wml(zz), "`{=openxml}", sep = "")

    caption <- paste(
      "",
      style_start,
      paste0("<caption>(\\#", tab_props$tab.lp, tab_props$id, ")", zz, "</caption>"),
      style_end,
      "", sep = "\n")
  }
  caption
}

caption_docx_standard <- function(x){
  tab_props <- opts_current_table()

  caption_label <- mcoalesce_options(x$caption$value, tab_props$cap)
  caption_style <- mcoalesce_options(x$caption$style, tab_props$cap.style)
  caption_id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id)
  caption_lp <- mcoalesce_options(if( !is.null(tab_props$tab.lp) )
                                    gsub(":$", "", tab_props$tab.lp)
                                  else NULL,
                                  x$caption$autonum$seq_id)
  caption_pre_label <- mcoalesce_options(tab_props$cap.pre, x$caption$autonum$pre_label)
  caption_post_label <- mcoalesce_options(tab_props$cap.sep, x$caption$autonum$post_label)

  autonum <- run_autonum(
    seq_id = caption_lp,
    pre_label = caption_pre_label,
    post_label = caption_post_label,
    bkm = caption_id, bkm_all = FALSE
  )
  bc <- block_caption(label = caption_label, style = caption_style, autonum = autonum)
  caption <- to_wml(bc, knitting = TRUE)

  caption
}

caption_docx_str <- function(x, bookdown = FALSE){
  if(bookdown) caption_docx_bookdown(x)
  else caption_docx_standard(x)
}
