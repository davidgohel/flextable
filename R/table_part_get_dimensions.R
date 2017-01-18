#' @importFrom lazyeval lazy_eval
get_p <- function(id, form, data){
  args_ <- as.list(data[id,,drop = FALSE])
  args_$. <- data
  lazy_eval(form, args_)
}

#' @importFrom magrittr %>%
#' @importFrom tibble tibble
get_all_p <- function( x ){

  byfid <- x$styles$formats %>%
    as_tibble() %>%
    setNames(x$col_keys) %>%
    add_column(id = seq_len(nrow(.)) ) %>%
    gather(col_key, fid, -id) %>%
    split(f = .$fid) %>%
    map(.f = function(x) select(x, -fid) )

  map2_df(byfid,
          x$style_ref_table$formats[names(byfid)],
          function(subset_, form_, data){
            pars <- map(subset_$id, get_p, form_, data)
            tibble( id = subset_$id, col_key = subset_$col_key, p = pars)
            },
          data = x$dataset)
}

#' @importFrom purrr map map_lgl
get_img_chunks <- function(x){
  chunks <- x$chunks
  chunks[map_lgl(chunks, function(x) inherits(x, c("minibar", "external_img")))]
}

#' @importFrom purrr map_df
#' @importFrom dplyr do
extract_images <- function( par_list ){
  out <- par_list %>%
    group_by(id, col_key) %>% # change to rowwise
    do({
      img <- get_img_chunks(.$p[[1]])
      map_df(img, function(x){
        data.frame(src = as.character(x),
                   width = attr(x,"dims")$width * 72,
                   height = attr(x,"dims")$height * 72,
                   stringsAsFactors = FALSE)
      })
    } ) %>% ungroup()
  if( nrow(out) < 1 )
    out <- add_column(out, src = character(0), width = double(0), height = double(0))
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
#' @importFrom dplyr ungroup select bind_rows group_by summarise
#' @importFrom purrr map_dbl map_chr map map2_df
#' @importFrom stats setNames
get_dimensions <- function( x ){

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
    mutate(col_key = factor(col_key, levels = x$col_keys) ) %>%
    arrange(col_key, id)

  par_ref_dim <- map2_df(x$style_ref_table$pars, names(x$style_ref_table$pars),
                         function(x, z, type) {
                           par_style <- format(x, type = type)
                           data.frame( value = par_style, ref = z, stringsAsFactors = FALSE )
                         }, type = type)
  par_dim <- x$styles$pars
  dimnames(par_dim) <- list(NULL, x$col_keys)
  par_dim <- par_dim %>% as_tibble() %>%
    mutate(id = seq_len(nrow(par_dim))) %>%
    gather(col_key, ref, -id) %>%
    inner_join(par_ref_dim, by = "ref") %>%
    mutate(col_key = factor(col_key, levels = x$col_keys) ) %>%
    arrange(col_key, id) %>% select(-ref) %>%
    rename(pptag = value)

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

