#' @importFrom magrittr %>%
#' @importFrom tibble tibble
#' @importFrom purrr pmap_df map_df map_lgl map_dbl map_chr
#' @importFrom tidyr spread_ complete_
#' @importFrom dplyr mutate inner_join right_join
#' @importFrom gdtools str_extents
#' @importFrom dplyr do ungroup select bind_rows group_by summarise

extract_cell_space <- function(x){
  cell_fp <- x$styles$cells$get_fp()
  tibble( pr_id = names(cell_fp),
          margin.left = map_dbl( cell_fp, "margin.left" ) * (4/3),
          margin.right = map_dbl( cell_fp, "margin.right" ) * (4/3),
          margin.top = map_dbl( cell_fp, "margin.top" ) * (4/3),
          margin.bottom = map_dbl( cell_fp, "margin.bottom" ) * (4/3)
          )
}
extract_par_space <- function(x){
  text_fp <- x$styles$pars$get_fp()
  map_df(text_fp, function(x) as.data.frame( as.list(dim(x))), .id = "pr_id" )
}

#' @importFrom rlang syms
get_adjusted_sizes <- function( x ){


  txt_data <- x$styles$formats$get_map(x$styles$text, x$dataset)
  text_fp <- x$styles$text$get_fp()
  text_fp <- append( text_fp, x$styles$formats$get_all_fp() )

  fp_props <- tibble(
    pr_id = names(text_fp),
    size = map_int(text_fp, "font.size"),
    bold = map_lgl(text_fp, "bold"),
    italic = map_lgl(text_fp, "italic"),
    fontname = map_chr(text_fp, "font.family") )

  image_selection <- c("col_key", "id", "pos", "width", "height", "pr_id")
  var_ok <- image_selection %in% names(txt_data)
  names(image_selection) <- c("col_key", "id", "pos", "width", "height", "pr_id")
  img_sizes <- txt_data[txt_data$type_out %in% "image", image_selection[var_ok]]
  colnames(img_sizes) <- names(image_selection)[var_ok]

  col_selection <- c("col_key", "id", "pos", "str", "pr_id")
  text_only_data <- txt_data[txt_data$type_out %in% "text", col_selection]
  sizes <- text_only_data %>%
    inner_join(fp_props, by = "pr_id") %>%
    distinct() %>%
    group_by(!!!syms(c("str", "pr_id"))) %>% do({
      str_ext <- str_extents(.$str, fontname = unique(.$fontname),
                             fontsize = unique(.$size),
                             bold = unique(.$bold), italic = unique(.$italic))
      tibble( width = str_ext[,1]/72, height = str_ext[,2]/72 )
    }) %>% ungroup() %>% distinct() %>%
    right_join(text_only_data,
                      by = c("str", "pr_id")) %>%
    bind_rows(img_sizes) %>%
    group_by(!!!syms(c("id", "col_key"))) %>%
    summarise(width = sum(width), height = max(height)) %>%
    ungroup()

  sizes$col_key <- factor(sizes$col_key, levels = x$col_keys)
  sizes <- sizes[order(sizes$col_key, sizes$id ), ]
  widths <- sizes %>% select(!!!syms(c("col_key", "width", "id"))) %>%
    spread_("col_key", "width") %>% drop_column("id") %>% as.matrix()
  heights <- sizes %>% select(!!!syms(c("col_key", "height", "id"))) %>%
    spread_("col_key", "height") %>% drop_column("id") %>% as.matrix()

  par_dim <- extract_par_space(x)
  par_dim <- x$styles$pars$get_map() %>%
    inner_join(par_dim, by = "pr_id")
  par_dim$col_key <- factor(par_dim$col_key, levels = x$col_keys)

  parwidths <- par_dim %>%
    select(!!!syms(c("col_key", "width", "id"))) %>%
    spread_("col_key", "width") %>%
    drop_column("id") %>% as.matrix()
  parheights <- par_dim %>%
    select(!!!syms(c("col_key", "height", "id"))) %>%
    spread_("col_key", "height") %>%
    drop_column("id") %>% as.matrix()

  widths <- widths + parwidths
  heights <- heights + parheights


  widths[x$spans$rows<1] <- 0
  widths[x$spans$columns<1] <- 0
  heights[x$spans$rows<1] <- 0
  heights[x$spans$columns<1] <- 0

  cell_dim <- extract_cell_space(x)
  cell_dim <- x$styles$cells$get_map() %>%
    inner_join(cell_dim, by = "pr_id")
  cell_dim$width <- cell_dim$margin.left + cell_dim$margin.right
  cell_dim$height <- cell_dim$margin.top + cell_dim$margin.bottom
  cell_dim$margin.left<-NULL;cell_dim$margin.right<-NULL;
  cell_dim$margin.top<-NULL;cell_dim$margin.bottom<-NULL;

  cell_dim$col_key <- factor(cell_dim$col_key, levels = x$col_keys)
  parwidths <- cell_dim %>%
    select(!!!syms(c("col_key", "width", "id"))) %>%
    spread_("col_key", "width") %>%
    drop_column("id") %>% as.matrix()
  parheights <- cell_dim %>%
    select(!!!syms(c("col_key", "height", "id"))) %>%
    spread_("col_key", "height") %>%
    drop_column("id") %>% as.matrix()

  widths <- widths + parwidths
  heights <- heights + parheights

  list(widths = apply(widths, 2, max),
       heights = apply(heights, 1, max)
  )
}



