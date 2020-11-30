#' @importFrom grDevices as.raster
#' @export
#' @title image chunk wrapper
#' @description The function lets add images within flextable
#' objects with function \code{\link{compose}}.
#' It should be used inside a call to \code{\link{as_paragraph}}.
#' @param src image filename
#' @param width,height size of the png file in inches
#' @param ... unused argument
#' @family chunk elements for paragraph
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @seealso \code{\link{compose}}, \code{\link{as_paragraph}}
#' @examples
#' img.file <- file.path( R.home("doc"), "html", "logo.jpg" )
#' library(officer)
#'
#' myft <- flextable( head(iris))
#'
#' myft <- compose( myft, i = 1:3, j = 1,
#'  value = as_paragraph(
#'    as_image(src = img.file, width = .20, height = .15),
#'    " blah blah ",
#'    as_chunk(Sepal.Length, props = fp_text(color = "red"))
#'  ),
#'  part = "body")
#'
#' ft <- autofit(myft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_image_1.png}{options: width=60\%}}
as_image <- function(src, width = .5, height = .2, ...) {

  if( length(src) > 1 ){
    if( length(width) == 1 ) width <- rep(width, length(src))
    if( length(height) == 1 ) height <- rep(height, length(src))
  }

  data <- chunk_dataframe(width = as.double(width),
                          height = as.double(height),
                          img_data = src
  )
  class(data) <- c("img_src", "chunk", "data.frame")
  data
}


#' @export
#' @title mini barplots chunk wrapper
#' @description This function is used to insert bars into
#' flextable with function \code{\link{compose}}.
#' It should be used inside a call to \code{\link{as_paragraph}}
#' @param value values containing the bar size
#' @param max max bar size
#' @param barcol bar color
#' @param bg background color
#' @param width,height size of the resulting png file in inches
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris, n = 10 ))
#'
#' ft <- compose(ft, j = 1,
#'   value = as_paragraph(
#'     minibar(value = Sepal.Length, max = max(Sepal.Length))
#'   ),
#'   part = "body")
#'
#' ft <- autofit(ft)
#' ft
#' @importFrom grDevices as.raster col2rgb rgb
#' @seealso \code{\link{compose}}, \code{\link{as_paragraph}}
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_minibar_1.png}{options: width=60\%}}
minibar <- function(value, max = NULL, barcol = "#CCCCCC", bg = "transparent", width = 1, height = .2) {


  if( all( is.na(value) ) ){
    max <- 1
  }
  value[is.na(value)] <- 0

  if( is.null(max))
    max <- max(value, na.rm = TRUE)

  stopifnot(value >= 0, max >= 0)
  barcol <- rgb(t(col2rgb(barcol))/255)
  bg <- ifelse( bg == "transparent", bg, rgb(t(col2rgb(bg))/255) )
  if( any(value > max) ){
    warning("value > max, truncate to max")
    value[value > max] <- max
  }
  width_ <- as.integer(width * 72)
  value <- as.integer( (value / max) * width_ )
  n_empty <- width_ - value

  rasters <- mapply(function(count_on, count_off, bg_on, bg_off ){
    as.raster( matrix(c(rep(bg_on, count_on), rep(bg_off, count_off)), nrow = 1) )
  }, value, n_empty, bg_on = barcol, bg_off = bg,
  SIMPLIFY = FALSE )
  z <- chunk_dataframe(width = as.double(rep(width, length(value)) ),
                       height = as.double(rep(height, length(value))),
                       img_data = rasters )

  class(z) <- c("img_chunk", "chunk", "data.frame")
  z
}

#' @export
#' @title mini linerange chunk wrapper
#' @description This function is used to insert lineranges into
#' flextable with function \code{\link{compose}}.
#' It should be used inside a call to \code{\link{as_paragraph}}
#' @param value values containing the bar size
#' @param min min bar size. Default min of value
#' @param max max bar size. Default max of value
#' @param rangecol bar color
#' @param stickcol jauge color
#' @param bg background color
#' @param width,height size of the resulting png file in inches
#' @param raster_width number of pixels used as width
#' when interpolating value.
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @family chunk elements for paragraph
#' @examples
#' myft <- flextable( head(iris, n = 10 ))
#'
#' myft <- compose( myft, j = 1,
#'   value = as_paragraph(
#'     linerange(value = Sepal.Length)
#'   ),
#'   part = "body")
#'
#' autofit(myft)
#' @importFrom grDevices as.raster col2rgb rgb
#' @importFrom stats approx
#' @seealso \code{\link{compose}}, \code{\link{as_paragraph}}
linerange <- function(value, min = NULL, max = NULL, rangecol = "#CCCCCC",
                      stickcol = "#FF0000", bg = "transparent", width = 1,
                      height = .2, raster_width = 30) {
  if( all( is.na(value) ) ){
    min <- 0
    max <- 1
  }

  if( raster_width < 2)
    stop("raster_width must be greater than 1")

  raster_nrow <- 9
  raster_center <- 5

  if( is.null(max))
    max <- max(value, na.rm = TRUE)
  if ( is.null(min))
    min <- min(value, na.rm = TRUE)

  value[!is.finite(value)] <- max + 1 # to be sure not displayed

  stopifnot(!is.null(value), !is.null(min), !is.null(min))

  # transform color code
  stickcol  <- rgb(t(col2rgb(stickcol))/255)
  rangecol  <- rgb(t(col2rgb(rangecol))/255)
  bg <- ifelse( bg == "transparent", bg, rgb(t(col2rgb(bg))/255) )


  # get value approx on range 1,raster_width
  stick_pos <- as.integer(approx(x = c(min,max), y = c(1, raster_width), xout = value)$y)
  base <- matrix(bg, nrow = raster_nrow, ncol = raster_width)
  base[, 1]   <- rangecol
  base[, raster_width] <- rangecol
  base[raster_center,] <- rangecol

  rasters <- lapply(stick_pos, function(val, def_mat, col) {
    newmat <- def_mat
    newmat[, val] <- col
    as.raster(newmat)
  }, base, stickcol)

  z <- chunk_dataframe(width = as.double(rep(width, length(value)) ),
                       height = as.double(rep(height, length(value))),
                       img_data = rasters )

  class(z) <- c("img_chunk", "chunk", "data.frame")
  z

}

#' @export
#' @title mini lollipop chart chunk wrapper
#' @description This function is used to insert lollipop charts into
#' flextable with function \code{\link{compose}}.
#' It should be used inside a call to \code{\link{as_paragraph}}
#' @param value values containing the bar size
#' @param min min bar size. Default min of value
#' @param max max bar size. Default max of value
#' @param rangecol bar color
#' @param bg background color
#' @param width,height size of the resulting png file in inches
#' @param raster_width number of pixels used as width
#' @param positivecol box color of positive values
#' @param negativecol box color of negative values
#' @param neutralcol box color of neutral values
#' @param neutralrange minimal and maximal range of neutral values (default: 0)
#' @param rectanglesize size of the rectangle (default: 2, max: 5)
#' when interpolating value.
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @family chunk elements for paragraph
#' @examples
#' iris$Sepal.Ratio <- (iris$Sepal.Length - mean(iris$Sepal.Length))/mean(iris$Sepal.Length)
#' ft <- flextable( tail(iris, n = 10 ))
#'
#' ft <- compose( ft, j = "Sepal.Ratio",   value = as_paragraph(
#'   lollipop(value = Sepal.Ratio, min=-.25, max=.25)
#' ),
#' part = "body")
#'
#' ft <- autofit(ft)
#' ft
#' @importFrom grDevices as.raster col2rgb rgb
#' @importFrom stats approx
#' @seealso \code{\link{compose}}, \code{\link{as_paragraph}}
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_lollipop_1.png}{options: width=60\%}}
lollipop <- function(value, min = NULL, max = NULL, rangecol = "#CCCCCC",
                     bg = "transparent", width = 1,
                     height = .2, raster_width = 30, positivecol = "#00CC00",
                     negativecol = "#CC0000", neutralcol = "#CCCCCC", neutralrange = c(0,0),
                     rectanglesize = 2) {
  if( all( is.na(value) ) ){
    min <- 0
    max <- 1
  }

  if( raster_width < 2)
    stop("raster_width must be greater than 1")

  raster_nrow <- 9
  raster_center <- 5

  if(rectanglesize>5)
    rectanglesize <- 5

  if( is.null(max))
    max <- max(c(0,value), na.rm = TRUE)
  if ( is.null(min))
    min <- min(c(0,value), na.rm = TRUE)

  value[!is.finite(value)] <- max + 1 # to be sure not displayed

  stopifnot(!is.null(value), !is.null(min), !is.null(min))

  # transform color code
  rangecol  <- rgb(t(col2rgb(rangecol))/255)
  positivecol  <- rgb(t(col2rgb(positivecol))/255)
  negativecol  <- rgb(t(col2rgb(negativecol))/255)
  neutralcol <- rgb(t(col2rgb(neutralcol))/255)
  bg <- ifelse( bg == "transparent", bg, rgb(t(col2rgb(bg))/255) )


  # get value approx on range 1,raster_width
  zero_pos <- as.integer(approx(x = c(min,max), y = c(1, raster_width), xout = 0)$y)

  base <- matrix(bg, nrow = raster_nrow, ncol = raster_width)
  base[, 1]   <- rangecol
  base[, raster_width] <- rangecol
  base[, zero_pos] <- rangecol

  rasters <- lapply(value, function(val, def_mat) {
    stick_pos <- as.integer(approx(x = c(min,max), y = c(1, raster_width), xout = val)$y)

    newmat <- def_mat

    # fix switch statement and neutral color range
    value_position <- sign(val)
    value_position <- ifelse(val <= neutralrange[1] & val >= neutralrange[2], 0, value_position)

    rectangle_color <- switch(value_position + 2, negativecol, neutralcol, positivecol)

    # create middle stick
    if(value_position == -1)
      newmat[row(newmat) == raster_center & col(newmat) < zero_pos & col(newmat) > stick_pos] <- rangecol
    else
      newmat[row(newmat) == raster_center & col(newmat) > zero_pos & col(newmat) < stick_pos] <- rangecol

    # create rectangle
    newmat[col(newmat)>=stick_pos - rectanglesize/2 & col(newmat)<=stick_pos + rectanglesize/2 &
             row(newmat)>=raster_center - rectanglesize & row(newmat)<=raster_center + rectanglesize] <- rectangle_color

    as.raster(newmat)
  }, base)

  z <- chunk_dataframe(width = as.double(rep(width, length(value)) ),
                       height = as.double(rep(height, length(value))),
                       img_data = rasters )

  class(z) <- c("img_chunk", "chunk", "data.frame")
  z

}


#' @export
#' @title mini plots chunk wrapper
#' @description This function is used to insert mini plots into
#' flextable with function \code{\link{compose}}.
#' It should be used inside a call to [as_paragraph()].
#'
#' Available plots are 'box', 'line', 'points', 'density'.
#' @param value a numeric vector, stored in a list column.
#' @param width,height size of the resulting png file in inches
#' @param type type of the plot: 'box', 'line', 'points' or 'density'.
#' @param free_scale Should scales be free (TRUE or FALSE, the default value).
#' @param ... arguments sent to plot functions (see [par()])
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @family chunk elements for paragraph
#' @examples
#' library(data.table)
#' library(flextable)
#'
#' z <- as.data.table(iris)
#' z <- z[ , list(
#'   Sepal.Length = mean(Sepal.Length, na.rm  = TRUE),
#'   z = list(.SD$Sepal.Length)
#'   ), by = "Species"]
#'
#' ft <- flextable(z,
#'   col_keys = c("Species", "Sepal.Length", "box", "density"))
#' ft <- mk_par(ft, j = "box", value = as_paragraph(
#'   plot_chunk(value = z, type = "box",
#'              border = "red", col = "transparent")))
#' ft <- mk_par(ft, j = "density", value = as_paragraph(
#'  plot_chunk(value = z, type = "dens", col = "red")))
#' ft <- set_table_properties(ft, layout = "autofit", width = .6)
#' ft <- set_header_labels(ft, box = "boxplot", density= "density")
#' theme_vanilla(ft)
#' @importFrom grDevices dev.off png
#' @importFrom graphics boxplot
#' @importFrom stats density
plot_chunk <- function(value, width = 1, height = .2,
                       type = "box", free_scale = FALSE, ...) {

  type <- match.arg(arg = type, choices = c('box', 'line', 'points', 'density'), several.ok = FALSE)

  width <- as.double(rep(width, length(value)))
  height <- as.double(rep(height, length(value)))

  params <- list(...)
  params <- append(params,
                   list(
                     xlab = "", ylab = "", main = "", axes = FALSE)
  )

  lims <- NULL
  if(!free_scale){
    lims <- range(unlist(value), na.rm = TRUE)
  }

  files <- mapply(function(x, width, height, type){
    file <- tempfile(fileext = ".png")
    png(filename = file, width = width, height = height,
        units = "in", bg = "transparent", res = 300)
    par(mar = rep(0,4))
    parcall <- params

    if("box" %in% type){
      parcall$x <- x
      parcall$horizontal <- TRUE
      parcall$ylim = lims
      do.call(boxplot, parcall)
    } else if("line" %in% type){
      parcall$x <- seq_along(x)
      parcall$y <- x
      parcall$type = "l"
      parcall$ylim = lims
      do.call(plot, parcall)
    } else if("point" %in% type){
      parcall$x <- seq_along(x)
      parcall$y <- x
      parcall$ylim = lims
      do.call(plot, parcall)
    } else if("dens" %in% type){
      parcall$x <- density(x)
      parcall$xlim = lims
      do.call(plot, parcall)
    }
    dev.off()
    file
  }, x = value,
  width = width, height = height,
  SIMPLIFY = FALSE,
  MoreArgs = list(type =  type))

  files <- as.character(unlist(files))

  z <- chunk_dataframe(width = width, height = height, img_data = files )
  class(z) <- c("img_chunk", "chunk", "data.frame")
  z
}


#' @export
#' @title gg plots chunk wrapper
#' @description This function is used to insert mini gg plots into
#' flextable with function \code{\link{compose}}.
#' It should be used inside a call to [as_paragraph()].
#'
#' @param value gg objects, stored in a list column.
#' @param width,height size of the resulting png file in inches
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#'
#' PowerPoint cannot mix images and text in a paragraph, images
#' are removed when outputing to PowerPoint format.
#' @family chunk elements for paragraph
#' @examples
#' library(data.table)
#' library(flextable)
#' if(require("ggplot2")){
#'   my_cor_plot <- function(x){
#'     cols <- colnames(x)[sapply(x, is.numeric)]
#'     x <- x[, .SD, .SDcols = cols]
#'     cormat <- as.data.table(cor(x))
#'     cormat$var1 <- colnames(cormat)
#'     cormat <- melt(cormat, id.vars = "var1", measure.vars = cormat$var1,
#'                    variable.name = "var2", value.name = "correlation")
#'     ggplot(data = cormat, aes(x=var1, y=var2, fill=correlation)) +
#'       geom_tile() + coord_equal() +
#'       scale_fill_gradient2(low = "blue",
#'                            mid = "white", high = "red", limits = c(-1, 1),
#'                            guide = FALSE) + theme_void()
#'   }
#'   z <- as.data.table(iris)
#'   z <- z[ , list(gg = list(my_cor_plot(.SD))), by = "Species"]
#'   ft <- flextable(z)
#'   ft <- mk_par(ft, j = "gg",
#'                value = as_paragraph(
#'                  gg_chunk(value = gg, width = 1, height = 1)
#'                ))
#'   print(ft)
#' }
gg_chunk <- function(value, width = 1, height = .2) {

  width <- as.double(rep(width, length(value)))
  height <- as.double(rep(height, length(value)))

  files <- mapply(function(x, width, height){
    file <- tempfile(fileext = ".png")
    png(filename = file, width = width, height = height,
        units = "in", bg = "transparent", res = 300)
      print(x)
    dev.off()
    file
  }, x = value,
  width = width, height = height,
  SIMPLIFY = FALSE)

  files <- as.character(unlist(files))

  z <- chunk_dataframe(width = width, height = height, img_data = files )
  class(z) <- c("img_chunk", "chunk", "data.frame")
  z
}
