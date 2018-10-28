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
  x$footer$colwidths[j] <- width
  x$body$colwidths[j] <- width

  x
}

#' @export
#' @title Set flextable rows height
#' @description control rows height.
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

  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  if( inherits(i, "formula") && any( c("header", "footer") %in% part ) ){
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if( nrow_part(x, part ) < 1 ) return(x)

  i <- get_rows_id(x[[part]], i )
  if( !(length(i) == length(height) || length(height) == 1)){
    stop("height should be of length 1 or ", length(i))
  }

  x[[part]]$rowheights[i] <- height

  x
}

#' @export
#' @rdname height
height_all <- function(x, height, part = "all"){

  part <- match.arg(part, c("body", "header", "footer", "all"), several.ok = FALSE )
  if( length(height) != 1 || !is.numeric(height) || height < 0.0 ){
    stop("height should be a single positive numeric value", call. = FALSE)
  }

  if( "all" %in% part ){
    for(i in c("body", "header", "footer") ){

      x <- height_all(x, height = height, part = i)
    }
  }

  if( nrow_part(x, part) > 0 ){
    i <- seq_len(nrow(x[[part]]$dataset))
    x[[part]]$rowheights[i] <- height
  }

  x
}

#' @title Get flextable dimensions
#' @description returns widths and heights for each table columns and rows.
#' Values are inches.
#' @param x flextable object
#' @export
dim.flextable <- function(x){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body", "footer")){
    if( nrow_part(x, j ) > 0 ){
      max_widths[[j]] <- x[[j]]$colwidths
      max_heights[[j]] <- x[[j]]$rowheights
    }
  }

  mat_widths <- do.call("rbind", max_widths)
  if( is.null( mat_widths ) ){
    out_widths <- numeric(0)
  } else {
    out_widths <- apply( mat_widths, 2, max )
    names(out_widths) <- x$col_keys
  }

  out_heights <- as.double(unlist(max_heights))
  list(widths = out_widths, heights = out_heights )
}

#' @export
#' @title Calculate pretty dimensions
#' @param x flextable object
#' @param part partname of the table (one of 'all', 'body', 'header' or 'footer')
#'
#' @description return minimum estimated widths and heights for
#' each table columns and rows in inches.
#' @examples
#'
#' ft <- flextable(mtcars)
#' \donttest{dim_pretty(ft)}
dim_pretty <- function( x, part = "all" ){

  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )
  if( "all" %in% part ){
    part <- c("header", "body", "footer")
  }
  dimensions <- list()
  for(j in part){
    if( nrow_part(x, j ) > 0 ){
      dimensions[[j]] <- optimal_sizes(x[[j]])
    } else {
      dimensions[[j]] <- list(widths = rep(0, length(x$col_keys) ),
           heights = numeric(0) )
    }
  }
  widths <- lapply( dimensions, function(x) x$widths )
  widths <- as.numeric(apply( do.call(rbind, widths), 2, max, na.rm = TRUE ))

  heights <- lapply( dimensions, function(x) x$heights )
  heights <- as.numeric(do.call(c, heights))


  list(widths = widths, heights = heights)
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

  stopifnot(inherits(x, "complextable") || inherits(x, "regulartable") )

  for(j in c("header", "body", "footer")){
    if( nrow_part(x, j ) > 0 ){
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

optimal_sizes.complex_tabpart <- function( x ){

  txt_data <- x$styles$formats$get_map(x$styles$text, x$dataset)
  text_fp <- x$styles$text$get_fp()
  text_fp <- append( text_fp, x$styles$formats$get_all_fp() )

  img_sizes <- images_metric(txt_data)
  txt_data_metric <- text_metric(txt_data, text_fp)

  # rbind txt sizes and img sizes
  sizes <- rbind(txt_data_metric, img_sizes)
  sizes <- agg_sizes(sizes = sizes)

  sizes$col_key <- factor(sizes$col_key, levels = x$col_keys)
  sizes <- sizes[order(sizes$col_key, sizes$id ), ]

  widths <- as_wide_matrix_(data = sizes[, c("col_key", "width", "idrow")], idvar = "idrow")
  dimnames(widths)[[2]] <- gsub("^width\\.", "", dimnames(widths)[[2]])
  heights <- as_wide_matrix_(data = sizes[, c("col_key", "height", "idrow")], idvar = "idrow")
  dimnames(heights)[[2]] <- gsub("^height\\.", "", dimnames(heights)[[2]])

  par_dim <- dim_paragraphs(x)
  widths <- widths + par_dim$widths
  heights <- heights + par_dim$heights

  widths[x$spans$rows<1] <- 0
  widths[x$spans$columns<1] <- 0
  heights[x$spans$rows<1] <- 0
  heights[x$spans$columns<1] <- 0

  cell_dim <- dim_cells(x)
  widths <- widths + cell_dim$widths
  heights <- heights + cell_dim$heights

  list(widths = apply(widths, 2, max, na.rm = TRUE),
       heights = apply(heights, 1, max, na.rm = TRUE) )
}

optimal_sizes.simple_tabpart <- function( x ){

  txt_data <- get_text_data(x)
  txt_data$type_out <- rep("text", nrow(txt_data))
  txt_data$pos <- rep(1, nrow(txt_data))
  text_fp <- x$styles$text$get_fp()

  sizes <- text_metric(data = txt_data, all_fp = text_fp)
  sizes$col_key <- factor(sizes$col_key, levels = x$col_keys)
  sizes <- sizes[order(sizes$col_key, sizes$id ), ]
  widths <- as_wide_matrix_(as.data.frame(sizes[, c("col_key", "width", "idrow")]), idvar = "idrow")
  heights <- as_wide_matrix_(as.data.frame(sizes[, c("col_key", "height", "idrow")]), idvar = "idrow")

  par_dim <- dim_paragraphs(x)
  widths <- widths + par_dim$widths
  heights <- heights + par_dim$heights

  widths[x$spans$rows<1] <- 0
  widths[x$spans$columns<1] <- 0
  heights[x$spans$rows<1] <- 0
  heights[x$spans$columns<1] <- 0

  cell_dim <- dim_cells(x)
  widths <- widths + cell_dim$widths
  heights <- heights + cell_dim$heights
  list(widths = apply(widths, 2, max, na.rm = TRUE),
       heights = apply(heights, 1, max, na.rm = TRUE)
  )
}



# utils ----
as_wide_matrix_ <- function(data, idvar, timevar = "col_key"){
  x <- reshape(data = data, idvar = idvar, timevar = timevar, direction = "wide")
  x[[idvar]] <- NULL
  as.matrix(x)
}


dim_paragraphs <- function(x){

  par_fp <- x$styles$pars$get_fp()
  par_dim <- lapply(par_fp, dim)
  par_dim <- data.frame( pr_id = names(par_fp),
              width = sapply(par_dim, function(x) x["width"]),
              height = sapply(par_dim, function(x) x["height"]),
              stringsAsFactors = FALSE, row.names = NULL)
  par_dim <- merge(x$styles$pars$get_map(),
                   par_dim, by = "pr_id",
                   all.x = FALSE, all.y = FALSE, sort = FALSE)

  par_dim$col_key <- factor(par_dim$col_key, levels = x$col_keys)

  list( widths = as_wide_matrix_( par_dim[,c("col_key", "width", "idrow")], idvar = "idrow" ),
        heights = as_wide_matrix_( par_dim[,c("col_key", "height", "idrow")], idvar = "idrow" )
  )
}

dim_cells <- function(x){

  cell_fp <- x$styles$cells$get_fp()
  cell_dim <- data.frame( pr_id = names(cell_fp),
                          width = (sapply( cell_fp, function(x) x$"margin.left" ) + sapply( cell_fp, function(x) x$"margin.right" ) )* (4/3),
                          height = (sapply( cell_fp, function(x) x$"margin.top" ) + sapply( cell_fp, function(x) x$"margin.bottom" )) * (4/3),
                          stringsAsFactors = FALSE )
  cell_dim <- merge(x$styles$cells$get_map(), cell_dim, by = "pr_id",
                    all.x = FALSE, all.y = FALSE, sort = FALSE)

  cell_dim$col_key <- factor(cell_dim$col_key, levels = x$col_keys)
  cell_dim <- as.data.frame(cell_dim)

  cellwidths <- as_wide_matrix_( cell_dim[,c("col_key", "width", "idrow")], idvar = "idrow" )
  cellheights <- as_wide_matrix_( cell_dim[,c("col_key", "height", "idrow")], idvar = "idrow")

  list( widths = cellwidths, heights = cellheights )
}


text_metric <- function(data, all_fp ){

  fp_props <- data.frame(
    pr_id = names(all_fp),
    size = sapply(all_fp, function(x) x$"font.size"),
    bold = sapply(all_fp, function(x) x$"bold"),
    italic = sapply(all_fp, function(x) x$"italic"),
    fontname = sapply(all_fp, function(x) x$"font.family"), stringsAsFactors = FALSE )


  selection_ <- c("col_key", "idrow", "pos", "width", "height")
  data$width <- NULL
  data$height <- NULL
  data <- as.data.frame( data[data$type_out %in% c("text", "htext"), ] )
  sizes_ <- merge(data, as.data.frame( fp_props ), by = "pr_id",
                  all.x = TRUE, all.y = FALSE, sort = FALSE)
  str_extents_ <- m_str_extents(sizes_$str, fontname = sizes_$fontname,
                          fontsize = sizes_$size, bold = sizes_$bold,
                          italic = sizes_$italic) / 72

  dimnames(str_extents_) <- list(NULL, c("width", "height"))
  sizes_ <- cbind( sizes_, str_extents_ )
  sizes_ <- sizes_[, selection_]
  sizes_
}

images_metric <- function(data){

  selection_ <- c("col_key", "idrow", "pos", "width", "height")

  img_sizes <- as.data.frame(data[data$type_out %in% "image", ])
  if( nrow(img_sizes) < 1 ) {
    img_sizes$width <- numeric(nrow(img_sizes))
    img_sizes$height <- numeric(nrow(img_sizes))
  }
  img_sizes <- img_sizes[, selection_]
  img_sizes
}

agg_sizes <- function(sizes){

  group_ref_ <- group_ref(sizes, c("idrow", "col_key"))

  width_ <- tapply(sizes$width, group_index(sizes, c("idrow", "col_key")), sum)
  height_ <- tapply(sizes$height, group_index(sizes, c("idrow", "col_key")), max)

  sizes_ <- data.frame(index_ = names(width_), width = width_, height = height_, stringsAsFactors = FALSE )
  sizes_ <- merge( group_ref_, sizes_, by = "index_", all.x = TRUE, all.y = TRUE, sort = FALSE)
  sizes_$index_ <- NULL
  sizes_
}

