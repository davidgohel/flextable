#' @importFrom lazyeval lazy_eval
get_p <- function(id, form, data){
  args_ <- as.list(data[id,,drop = FALSE])
  args_$. <- data
  lazy_eval(form, args_)
}

get_ref_par <- function(x){
  par_all <- unique(as.vector(x$styles$pars))
  map2_df( x$style_ref_table$pars[par_all],
           par_all,
           function(x, name){
             tibble( ref = name, fp_p = list(x))
           } )
}

get_ref_text <- function(x){
  text_all <- unique( as.vector( x$styles$text ) )
  map2_df( x$style_ref_table$text[text_all],
           text_all,
           function(x, name){
             tibble( ref = name, fp_t = list(x))
           } )
}


#' @importFrom dplyr rowwise
#' @importFrom magrittr %>%
#' @importFrom tibble tibble
get_all_p <- function( x ){

  fid <- as.vector( x$styles$formats )
  map_data <- tibble(id = seq_len(nrow(x$styles$formats) ) %>% rep(ncol(x$styles$formats) ) ,
                     col_key = rep(x$col_keys, each = nrow(x$styles$formats) )
                      )
  byfid <- split(map_data, f = fid)

  ref_par <- get_ref_par(x)
  ref_text <- get_ref_text(x)

  def_pp <- map_data
  def_pp$ref <- as.vector( x$styles$pars )
  def_pp <- def_pp %>%
    inner_join(ref_par, by = c("ref" = "ref") )
  def_pp$ref <- NULL

  def_tp <- map_data
  def_tp$ref <- as.vector( x$styles$text )
  def_tp <- def_tp %>%
    inner_join(ref_text, by = c("ref" = "ref") )
  def_tp$ref <- NULL

  map2_df(byfid, x$style_ref_table$formats[names(byfid)],
      function(subset_, form_, data){
        pars <- map(subset_$id, get_p, form_, data)
        tibble( id = subset_$id, col_key = subset_$col_key, p = pars)
        }, data = x$dataset) %>%
    inner_join(def_pp, by = c("id", "col_key") ) %>%
    inner_join(def_tp, by = c("id", "col_key") ) %>%
    rowwise() %>%
    mutate( p = list( update(p, fp_p = fp_p, fp_t = fp_t)) ) %>%
    ungroup() %>%
    select( -fp_p, -fp_t )
}

#' @importFrom purrr pmap_df map_df map_lgl
extract_images <- function( par_list ){
  out <- pmap_df( list(x = par_list$p, id = par_list$id, col_key = par_list$col_key) ,
           function(x, id, col_key) {
             ok <- map_lgl( x$chunks, inherits, c("minibar", "external_img"))
             src <- map_chr( x$chunks[ok], as.character )
             dims <- map_df( x$chunks[ok], function(x){
               dims <- attr(x,"dims")
               list(width = dims$width * 72, height = dims$height * 72, id = id, col_key = col_key )
             } )
             dims$src <- src
             dims
           } )

  if( nrow(out) < 1 )
    out <- tibble(id = integer(0), col_key = character(0), src = character(0), width = double(0), height = double(0))
  out
}

dim_as_df <- function(x, z) {
  x <- as.data.frame(as.list(dim(x) ) )
  x$ref <- z
  x
}
set_tibble_names <- function(x, z) {
  names(x) <- z
  x
}

#' @importFrom purrr map_dbl
#' @importFrom stats setNames
extract_cell_space <- function(x, name){
  margin <- map_dbl( x$style_ref_table$cells, name ) * (4/3)
  setNames(margin[as.vector(x$styles$cells)], NULL)
}

extract_par_space <- function(x){

  par_ref_dim <- map2_df(x$style_ref_table$pars,
                         names(x$style_ref_table$pars),
                         dim_as_df)

  nrow_ <- nrow(x$styles$pars)

  as_tibble(x$styles$pars) %>%
    set_tibble_names(x$col_keys) %>%
    add_column(id = seq_len(nrow_), .before = 1) %>%
    gather(col_key, ref, -id) %>%
    inner_join(par_ref_dim, by = "ref") %>%
    mutate( col_key = factor(col_key, levels = x$col_keys) ) %>%
    arrange(col_key, id)
}

#' @importFrom gdtools str_extents
#' @importFrom dplyr do ungroup select bind_rows group_by summarise
#' @importFrom purrr map_dbl map_chr map map2_df
#' @importFrom stats setNames
get_adjusted_sizes <- function( x ){

  par_data <- get_all_p(x)
  chunks <- par_data %>%
    group_by(id, col_key) %>%
    do(as.data.frame(.$p)) %>%
    ungroup()

  sizes <- chunks %>%
    group_by(size, bold, italic, font.family) %>%
    do({
      fontname <- unique( .$font.family )
      fontsize <- unique( .$size )
      bold <- unique( .$bold )
      italic <- unique( .$italic )
      str_ext_ <- str_extents(.$value, fontname = fontname, fontsize = fontsize,
                              bold = bold, italic = italic )
      data.frame(id = .$id, value = .$value, col_key = .$col_key, width = str_ext_[,1], height = str_ext_[,2], stringsAsFactors = FALSE)
    }) %>% ungroup()

  img_data <- extract_images(par_data)
  img_sizes <- img_data %>%
    select(col_key, id, width, height)

  dims <- chunks %>%
    inner_join(sizes,
               by = c("id", "value", "size", "bold",
                      "italic", "font.family", "col_key")) %>%
    select(col_key, id,width, height) %>%
    bind_rows(img_sizes) %>%
    group_by(col_key, id) %>%
    summarise(
      width = sum(width) / 72,
      height = max(height) / 72)

  dims$col_key <- factor(dims$col_key, levels = x$col_keys)
  dims <- arrange(dims, col_key, id)
  widths <- dims %>% select(col_key, width, id) %>% spread(col_key, width) %>% select(-id) %>% as.matrix()
  heights <- dims %>% select(col_key, height, id) %>% spread(col_key, height) %>% select(-id) %>% as.matrix()

  par_dim <- extract_par_space(x)
  parwidths <- par_dim %>%
    select(col_key, width, id) %>%
    spread(col_key, width) %>%
    select(-id) %>% as.matrix()
  parheights <- par_dim %>%
    select(col_key, height, id) %>%
    spread(col_key, height) %>%
    select(-id) %>% as.matrix()

  widths <- widths + parwidths
  heights <- heights + parheights


  widths[x$spans$rows<1] <- 0
  widths[x$spans$columns<1] <- 0
  heights[x$spans$rows<1] <- 0
  heights[x$spans$columns<1] <- 0

  ref_ <- x$style_ref_table$cells
  id_ <- x$styles$cells
  is_rotate <- map_chr(ref_,"text.direction") %in% c("tbrl", "btlr")
  vrowid <- which( id_ %in% names(ref_)[is_rotate] )
  heights_ <- heights[vrowid]
  widths_ <- widths[vrowid]
  heights[vrowid] <- widths_
  widths[vrowid] <- heights_

  margin.left <- extract_cell_space(x, "margin.left")
  margin.right <- extract_cell_space(x, "margin.right")
  margin.top <- extract_cell_space(x, "margin.top")
  margin.bottom <- extract_cell_space(x, "margin.bottom")

  widths <- widths + margin.left + margin.right
  widths <- matrix( widths, ncol = length(x$col_keys) )
  heights <- heights + margin.top + margin.bottom
  heights <- matrix( heights, ncol = length(x$col_keys) )



  list(widths = apply(widths, 2, max),
       heights = apply(heights, 1, max)
  )
}



#' @importFrom tibble as_tibble add_column
#' @importFrom tidyr gather spread
#' @importFrom dplyr rename arrange mutate inner_join
#' @importFrom purrr map2_df
cot_to_matrix <- function(x, type = "pml"){

  par_data <- get_all_p(x)
  img_data <- extract_images(par_data)

  par_data$value <- map_chr(par_data$p, function(x){
    fortify_fpar(x) %>% map_chr(format, type = type) %>% paste(collapse = "")
  })
  par_data$p <- NULL
  par_data <- par_data %>%
    mutate(col_key = factor(col_key, levels = x$col_keys) )

  par_ref_dim <- map2_df(x$style_ref_table$pars, names(x$style_ref_table$pars),
                         function(x, z, type) {
                           par_style <- format(x, type = type)
                           data.frame( pptag = par_style, ref = z, stringsAsFactors = FALSE )
                         }, type = type)

  map_data <- tibble(id = seq_len(nrow(x$styles$pars) ) %>% rep(ncol(x$styles$pars) ) ,
                     col_key = rep(x$col_keys, each = nrow(x$styles$pars) )
  )
  par_dim <- map_data
  par_dim$ref <- as.vector( x$styles$pars )
  par_dim <- par_dim %>%
    inner_join(par_ref_dim, by = c("ref" = "ref") )
  par_dim$col_key <- factor(par_dim$col_key, levels = x$col_keys)
  par_dim$ref <- NULL

  chunks <- par_data %>% inner_join(par_dim, by = c("col_key", "id")) %>%
    mutate(value = {
      if( type == "pml" )
        paste0("<a:p>", pptag, value, "</a:p>")
      else if( type == "html" )
        paste0("<p style=\"", pptag, "\">", value, "</p>")
      else if( type == "wml" )
        paste0("<w:p>", pptag, value, "</w:p>")
    }) %>% select(-pptag) %>%
    spread(col_key, value) %>%
    select(-id) %>% as.matrix()

  attr(chunks, "imgs") <- unique(img_data$src)
  chunks
}

