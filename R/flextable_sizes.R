#' @export
#' @title Set flextable columns width
#' @description control columns width
#' @param x flextable object
#' @param j columns selection
#' @param width width in inches
#' @details
#' Heights are not used when flextable is been rendered into HTML.
#' @examples
#'
#' ft <- flextable(iris)
#' ft <- width(ft, width = 1)
#'
#' @seealso \code{\link{flextable}}
width <- function(x, j = NULL, width){

  j <- get_columns_id(x[["body"]], j )

  stopifnot(length(j)==length(width) || length(width) == 1)

  if( length(width) == 1 ) width <- rep(width, length(j))

  x$header$colwidths[j] <- width
  x$body$colwidths[j] <- width

  x
}

#' @export
#' @title Set flextable rows height
#' @description control rows height
#' @param x flextable object
#' @param i rows selection
#' @param height height in inches
#' @param part partname of the table
#' @examples
#'
#' ft <- flextable(iris)
#' ft <- height(ft, height = .3)
#'
height <- function(x, i = NULL, height, part = "body"){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( inherits(i, "formula") && any( c("header", "all") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'all'.")
  }

  if( part == "all" ){
    nrow_h <- nrow(x$header$dataset)
    nrow_b <- nrow(x$body$dataset)

    if( is.null(i) && length(height) != (nrow_h+nrow_b)  && length(height) != 1 ){
      stop("length of i should be ", (nrow_h+nrow_b), " or 1." )
    } else if( (!is.null(i) && length(i) == (nrow_h+nrow_b)) || is.null(i) ){
      if( length( height ) != 1 ){
        i_h <- seq_len(nrow_h)
        i_b <- seq_len(nrow_b)+nrow_h
      } else {
        i_h <- 1
        i_b <- 1
      }

      x <- height(x = x, i = i[i_h], height = height[i_h], part = "header")
      x <- height(x = x, i = i[i_b], height = height[i_b], part = "body")
    } else {
      x <- height(x = x, i = i, height = height, part = "header")
      x <- height(x = x, i = i, height = height, part = "body")
    }

    return(x)
  }

  i <- get_rows_id(x[[part]], i )
  if( !(length(i) == length(height) || length(height) == 1)){
    stop("height should be of length 1 or ", length(i))
  }

  x[[part]]$rowheights[i] <- height

  x
}

#' @title Get flextable dimensions
#' @description returns widths and heights for each table columns and rows.
#' @param x flextable object
#' @export
dim.flextable <- function(x){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      max_widths[[j]] <- x[[j]]$colwidths
      max_heights[[j]] <- x[[j]]$rowheights
    }
  }

  mat_widths <- do.call("rbind", max_widths)
  out_widths <- apply( mat_widths, 2, max )
  names(out_widths) <- x$col_keys

  out_heights <- as.double(unlist(max_heights))
  list(widths = out_widths, heights = out_heights )
}

#' @export
#' @title Calculate pretty dimensions
#' @param x flextable object
#' @description return minimum estimated widths and heights for
#' each table columns and rows.
#' @examples
#'
#' ft <- flextable(mtcars)
#' \donttest{dim_pretty(ft)}
dim_pretty <- function( x ){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      dimensions_ <- optimal_sizes(x[[j]])
      x[[j]]$colwidths <- dimensions_$widths
      x[[j]]$rowheights <- dimensions_$heights
    }
  }
  dim(x)
}



#' @export
#' @title Adjusts cell widths and heights
#' @description compute and apply optimized widths and heights.
#' @param x flextable object
#' @param add_w extra width to add in inches
#' @param add_h extra height to add in inches
#' @examples
#'
#' ft <- flextable(mtcars)
#' \donttest{ft <- autofit(ft)}
#' ft
autofit <- function(x, add_w = 0.1, add_h = 0.1 ){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      dimensions_ <- optimal_sizes(x[[j]])

      x[[j]]$colwidths <- dimensions_$widths + add_w
      x[[j]]$rowheights <- dimensions_$heights + add_h
    }
  }
  x
}





#' @importFrom gdtools m_str_extents
optimal_sizes <- function( x ){
  UseMethod("optimal_sizes")
}


#' @importFrom rlang syms
optimal_sizes.complex_tabpart <- function( x ){


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

  sizes_ <- inner_join(text_only_data, fp_props, by = "pr_id")
  sizes_ <- m_str_extents(sizes_$str, fontname = sizes_$fontname,
                                   fontsize = sizes_$size, bold = sizes_$bold,
                                   italic = sizes_$italic) / 72
  dimnames(sizes_) <- list(NULL, c("width", "height"))

  sizes <- cbind( text_only_data, sizes_ ) %>%
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

optimal_sizes.simple_tabpart <- function( x ){

  txt_data <- get_text_data(x)
  text_fp <- x$styles$text$get_fp()

  fp_props <- tibble(
    pr_id = names(text_fp),
    size = map_int(text_fp, "font.size"),
    bold = map_lgl(text_fp, "bold"),
    italic = map_lgl(text_fp, "italic"),
    fontname = map_chr(text_fp, "font.family") )

  sizes_ <- inner_join(txt_data, fp_props, by = "pr_id")
  sizes_ <- m_str_extents(sizes_$str, fontname = sizes_$fontname,
                         fontsize = sizes_$size, bold = sizes_$bold,
                         italic = sizes_$italic) / 72
  dimnames(sizes_) <- list(NULL, c("width", "height"))
  sizes <- cbind( txt_data, sizes_ )
  # system.time({
  #   sizes <- txt_data %>%
  #     inner_join(fp_props, by = "pr_id") %>%
  #     group_by(!!!syms(c("pr_id"))) %>% do({
  #       str_ext <- str_extents(.$str, fontname = unique(.$fontname),
  #                              fontsize = unique(.$size),
  #                              bold = unique(.$bold), italic = unique(.$italic))
  #       tibble( id = .$id, col_key = .$col_key, str = .$str, width = str_ext[,1]/72, height = str_ext[,2]/72 )
  #     }) %>% ungroup()
  # })


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




