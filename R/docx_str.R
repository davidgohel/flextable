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


caption_docx_bookdown <- function(x){
  tab_props <- opts_current_table()

  if(!is.null(x$caption$autonum$bookmark)){
    tab_props$id <- x$caption$autonum$bookmark
  } else if(is.null(tab_props$id)){
    tab_props$id <- opts_current$get('label')
  }

  if(!is.null(x$caption$value)){
    tab_props$cap <- x$caption$value
  }
  if(!is.null(x$caption$style)){
    tab_props$cap.style <- x$caption$style
  }

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
      structure(
        list(
          id = paste0(tab_props$tab.lp, tab_props$id),
          run = list(
            structure(list(
              value = tab_props$cap, pr = NULL),
              class = c("ftext", "cot", "run")))),
        class = c("run_bookmark", "run")
        )
      #TODO: when officer update on cran, run_bookmark(paste0(tab_props$tab.lp, tab_props$id), ftext(tab_props$cap))
    } else {
      structure(list(
        value = tab_props$cap, pr = NULL),
        class = c("ftext", "cot", "run"))
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
  caption <- ""
  if(!is.null(x$caption$value)){
    bc <- block_caption(label = x$caption$value, style = x$caption$style,
                        autonum = x$caption$autonum)
    caption <- to_wml(bc, knitting = TRUE)
  } else if(!is.null(tab_props$cap) && !is.null(tab_props$id)) {
    bc <- block_caption(label = tab_props$cap, style = tab_props$cap.style,
                        autonum = run_autonum(
                          seq_id = gsub(":$", "", tab_props$tab.lp),
                          pre_label = tab_props$cap.pre,
                          post_label = tab_props$cap.sep,
                          bkm = tab_props$id, bkm_all = FALSE
                        ))
    caption <- to_wml(bc, knitting = TRUE)
  } else if(!is.null(tab_props$cap) && is.null(tab_props$id)) {
    bc <- block_caption(label = tab_props$cap, style = tab_props$cap.style)
    caption <- to_wml(bc, knitting = TRUE)
  }

  caption
}

caption_docx_str <- function(x, bookdown = FALSE){
  if(bookdown) caption_docx_bookdown(x)
  else caption_docx_standard(x)
}
