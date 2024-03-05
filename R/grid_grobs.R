# flextable grob ----------------------------------------------------------

#' @export
#' @title Convert a flextable to a grid grob object
#' @description It uses Grid Graphics (package `grid`) to Convert a flextable
#' into a grob object with scaling and text wrapping capabilities.
#'
#' This method can be used to insert a flextable inside a `ggplot2` plot,
#' it can also be used with package 'patchwork' or 'cowplot' to combine
#' ggplots and flextables into the same graphic.
#'
#' User can vary the size of the elements according to the size of the graphic window. The text
#' behavior is controllable, user can decide to make the paragraphs (texts and images)
#' distribute themselves correctly in the available space of the cell. It is possible
#' to define resizing options, for example by using only the width, or by distributing
#' the content so that it occupies the whole graphic space. It is also possible to
#' freeze or not the size of the columns.
#'
#' It is not recommended to use this function for
#' large tables because the calculations can be long.
#'
#' Limitations: equations (see [as_equation()]) and hyperlinks (see [hyperlink_ftext()])
#' will not be displayed.
#'
#' @section size:
#'
#' The size of the flextable can be known by using the method
#' \link[=dim.flextableGrob]{dim} on the grob.
#'
#' @param x A flextable object
#'
#' @param fit Determines the fitting/scaling of the grob on its parent viewport.
#' One of `auto`, `width`, `fixed`, `TRUE`, `FALSE`:
#' \itemize{
#'   \item `auto` or `TRUE` (default): The grob is resized to fit in the parent viewport.
#'   The table row heights and column widths are resized proportionally.
#'   \item `width`: The grob is resized horizontally to fit the width
#'   of the parent viewport. The column widths are resized proportionally.
#'   The row heights are unaffected and the table height may be smaller or larger
#'   than the height of the parent viewport.
#'   \item `fixed` or `FALSE`: The grob will have fixed dimensions,
#'   as determined by the column widths and the row heights.
#' }
#'
#' @param scaling Determines the scaling of the table contents.
#' One of `min`, `full`, `fixed`, `TRUE`, `FALSE`:
#' \itemize{
#'   \item `min` or `TRUE` (default):
#'   When the parent viewport is smaller than the necessary,
#'   the various content sizes (text font size, line width and image dimensions)
#'   will decrease accordingly so that the content can still fit.
#'   When the parent viewport is larger than the necessary,
#'   the content sizes will remain the same, they will not increase.
#'   \item `full`: Same as `min`, except that the content sizes are scaled fully,
#'   they will increase or decrease, according to the size of the drawing surface.
#'   \item `fixed` or `FALSE`: The content sizes will not be scaled.
#' }
#'
#' @param wrapping Determines the soft wrapping (line breaking) method
#' for the table cell contents. One of `TRUE`, `FALSE`:
#' \itemize{
#'   \item `TRUE`: Text content may wrap into separate lines at normal word break points
#'   (such as a space or tab character between two words) or at newline characters
#'   anywhere in the text content. If a word does not fit in the available cell width,
#'   then the text content may wrap at any character.
#'   Non-text content (such as images) is also wrapped into new lines,
#'   according to the available cell width.
#'   \item `FALSE`: Text content may wrap only with a newline character.
#'   Non-text content is not wrapped.
#' }
#'
#' Superscript and subscript chunks do not wrap.
#' Newline and tab characters are removed from these chunk types.
#'
#' @param autowidths If `TRUE` (default) the column widths are adjusted
#' in order to fit the contents of the cells (taking into account the `wrapping` setting).
#'
#' @param just Justification of viewport layout,
#' same as `just` argument in [grid::grid.layout()].
#' When set to `NULL` (default), it is determined according to the `fit` argument.
#'
#' @param ... Reserved for extra arguments
#'
#' @return a grob (gTree) object made with package `grid`
#' @examples
#' library(ragg)
#' library(gdtools)
#' register_liberationsans()
#'
#' set_flextable_defaults(font.family = "Liberation Sans")
#'
#' ft <- flextable(head(mtcars))
#'
#' gr <- gen_grob(ft)
#'
#' png_f_1 <- tempfile(fileext = ".png")
#' ragg::agg_png(
#'   filename = png_f_1, width = 4, height = 2,
#'   units = "in", res = 150)
#' plot(gr)
#' dev.off()
#'
#' png_f_2 <- tempfile(fileext = ".png")
#' # get the size
#' dims <- dim(gr)
#' dims
#' ragg::agg_png(
#'   filename = png_f_2, width = dims$width + .1,
#'   height = dims$height + .1, units = "in", res = 150
#' )
#' plot(gr)
#' dev.off()
#' @family flextable print function
#' @importFrom grid gTree
gen_grob <- function(x,
                     ...,
                     fit = c("auto", "width", "fixed"),
                     scaling = c("min", "full", "fixed"),
                     wrapping = TRUE,
                     autowidths = TRUE,
                     just = NULL) {
  dots <- list(...)
  debug <- isTRUE(dots$debug)
  if (identical(fit, TRUE)) fit <- "auto"
  if (identical(fit, FALSE)) fit <- "fixed"
  if (identical(scaling, TRUE)) scaling <- "min"
  if (identical(scaling, FALSE)) scaling <- "fixed"
  fit <- match.arg(fit)
  scaling <- match.arg(scaling)
  wrapping <- isTRUE(wrapping)
  autowidths <- isTRUE(autowidths)
  if (fit %in% "fixed") {
    scaling <- "fixed"
  }

  # generate grid data
  dat <- get_grid_data(x, autowidths, wrapping)
  dat <- grid_data_add_cell_info(dat, x)
  dat <- grid_data_add_par_info(dat, x)
  dat <- grid_data_add_chunk_info(dat, x, autowidths, wrapping)
  setorderv(dat, cols = c("row_index", "col_index"))

  # create grob
  gr <- make_flextable_grob(dat, fit, scaling, wrapping, debug = debug)

  # calculate real row heights/column widths
  dims <- dim(x)
  widths <- calc_grob_widths(gr, dat, dims)
  heights <- calc_grob_heights(gr, dat, dims)

  # set parameter list
  gr$ftpar <- list(
    fit = fit,
    scaling = scaling,
    wrapping = wrapping,
    just = just,
    dims = dims,
    widths = widths,
    heights = heights,
    debug = debug
  )

  # set data
  gr$ftdat <- dat[, c("row_index", "col_index", "rowspan", "colspan")]

  # done
  invisible(gr)
}

#' @importFrom grid viewport grid.layout gList vpStack
make_flextable_grob <- function(dat, fit, scaling, wrapping, debug = FALSE) {
  gTree(
    cl = "flextableGrob",
    children = do.call(gList, mapply(
      function(row_index, col_index, cell_vp, cell_width, cell_height, cell_params,
               background, borders, contents_vp, chunk_data, chunk_part_data) {
        # single cell grob
        gTree(
          children = gList(
            # background
            make_background_grob(background),
            # borders
            make_borders_grob(borders),
            # debug contents rect
            if (debug) {
              rectGrob(
                gp = gpar(col = "red", fill = "yellow", alpha = 0.15),
                vp = viewport(
                  width = unit(1, "npc") - unit(cell_params$paddingx, "in"),
                  height = unit(1, "npc") - unit(cell_params$paddingy, "in")
                )
              )
            },
            # contents
            make_contents_grob(
              row_index = row_index,
              col_index = col_index,
              chunk_data = chunk_data,
              chunk_part_data = chunk_part_data,
              vp = contents_vp,
              params = cell_params,
              width = cell_width,
              height = cell_height,
              fit = fit,
              scaling = scaling,
              wrapping = wrapping,
              debug = debug
            ),
            # debug text
            if (debug) {
              textGrob(
                label = paste(row_index, col_index, sep = "_"),
                x = cell_params$just[[1]], y = cell_params$just[[2]],
                gp = gpar(col = "red", fontsize = 8),
                just = cell_params$justr, rot = cell_params$angle
              )
            }
          ),
          vp = do.call(viewport, cell_vp),
          name = paste("cell", row_index, col_index, sep = "_")
        )
      },
      row_index = dat$row_index,
      col_index = dat$col_index,
      cell_vp = dat$cell_vp,
      cell_width = dat$cell_width,
      cell_height = dat$cell_height,
      cell_params = dat$cell_params,
      background = dat$background,
      borders = dat$borders,
      contents_vp = dat$contents_vp,
      chunk_data = dat$chunk_data,
      chunk_part_data = dat$chunk_part_data,
      SIMPLIFY = FALSE
    ))
  )
}

#' Calculate column widths for a flextableGrob
#' @param x The flextable grob
#' @param dat The grid_data
#' @param dims The flextable dimensions
#' @return A numeric vector with the widths
#' @noRd
calc_grob_widths <- function(x, dat, dims) {
  # get the minimum width of each column
  col_dat <- dat[, list(width = min(.SD$cell_width, na.rm = TRUE)), by = "col_index"]
  # dims contain all columns, but some of them might have been merged
  # completely into others and they should get a 0 size.
  col_dat <- merge(
    data.table(col_index = seq_along(dims$widths)),
    col_dat,
    by = "col_index", all.x = TRUE
  )
  col_dat[is.na(col_dat$width), "width" := 0]
  col_dat$width
}

#' Calculate the row heights for a flextableGrob
#' @param x The flextable grob
#' @param dat The grid_data
#' @param dims The flextable dimensions
#' @return A numeric vector with the heights
#' @noRd
#' @importFrom grid is.grob
calc_grob_heights <- function(x, dat, dims) {
  # get height info from the grob contents
  content_heights <- mapply(
    function(row_index, col_index, colspan) {
      cell_name <- paste("cell", row_index, col_index, sep = "_")
      gr <- x$children[[cell_name]]$children[["contents"]]
      if (is.grob(gr)) {
        list(
          row_index = gr$ftpar$row_index,
          col_index = gr$ftpar$col_index,
          colspan = colspan,
          height = gr$ftpar$height
        )
      }
    },
    dat$row_index,
    dat$col_index,
    dat$colspan,
    SIMPLIFY = FALSE
  )
  height_dat <- rbindlist(content_heights)
  # keep only the rows with minimum colspan
  height_dat <- merge(
    height_dat,
    dat[, list(colspan = min(.SD$colspan)), by = c("row_index")],
    by = c("row_index", "colspan")
  )
  # get the maximum height of each row
  height_dat <- height_dat[, list(height = max(.SD$height, na.rm = TRUE)), by = "row_index"]
  # dims contain all rows, but some of them might have been merged
  # completely into others and they should get a 0 size.
  row_dat <- merge(
    data.table(row_index = seq_along(dims$heights)),
    height_dat,
    by = "row_index", all.x = TRUE
  )
  row_dat[is.na(row_dat$height), "height" := 0]
  row_dat$height
}

#' @importFrom grid makeContext unit convertWidth convertHeight
#' @export
makeContext.flextableGrob <- function(x) {
  params <- x$ftpar
  dat <- x$ftdat
  cex <- 1
  lex <- 1

  # dimensions of the table
  widths <- params$widths
  table_width <- sum(widths)
  heights <- params$heights
  table_height <- sum(heights)

  if (params$fit %in% c("auto", "width")) {
    # dimensions of drawing area
    norm_width <- convertWidth(unit(1, "npc"), unitTo = "in", valueOnly = TRUE)
    norm_height <- convertHeight(unit(1, "npc"), unitTo = "in", valueOnly = TRUE)
    # calculate table scale factor
    norm_surface <- norm_width * norm_height
    table_surface <- table_width * table_height
    surface_factor <- sqrt(norm_surface / table_surface)
    width_factor <- norm_width / table_width
    height_factor <- norm_height / table_height

    # set cex/lex as the smallest of the three
    scale_factor <- min(surface_factor, width_factor, height_factor)
    if (params$scaling %in% "full" || (params$scaling %in% "min" && scale_factor < 1)) {
      lex <- cex <- scale_factor
    }

    # rearrange the contents with new parameters
    cell_names <- paste("cell", dat$row_index, dat$col_index, sep = "_")
    for (cell_name in cell_names) {
      gr <- x$children[[cell_name]]$children[["contents"]]
      if (is.grob(gr)) {
        x$children[[cell_name]]$children[["contents"]] <- arrange_contents_grob(gr,
          width_factor = width_factor, height_factor = height_factor, cex = cex
        )
      }
    }

    # recalculate the heights
    heights <- calc_grob_heights(x, dat, params$dims)
    table_height <- sum(heights)
  }

  # create viewport
  layout_just <- params$just
  if (params$fit %in% "auto") {
    # convert to relative widths/heights
    layout_widths <- unit(widths / table_width, "npc")
    layout_heights <- unit(heights / table_height, "npc")
    if (is.null(layout_just)) layout_just <- c(0.5, 0.5)
  } else if (params$fit %in% "width") {
    layout_widths <- unit(widths / table_width, "npc")
    layout_heights <- unit(heights, "in")
    if (is.null(layout_just)) layout_just <- c(0.5, 1)
  } else {
    layout_widths <- unit(widths, "in")
    layout_heights <- unit(heights, "in")
    if (is.null(layout_just)) layout_just <- c(0, 1)
  }
  layout_vp <- viewport(
    gp = gpar(
      cex = cex,
      lex = lex
    ),
    layout = grid.layout(
      nrow = length(heights),
      ncol = length(widths),
      widths = layout_widths,
      heights = layout_heights,
      just = layout_just
    )
  )
  if (is.null(x$vp)) {
    x$vp <- layout_vp
  } else {
    x$vp <- vpStack(x$vp, layout_vp)
  }

  # done
  x
}

#' plot a flextable grob
#'
#' @param x a flextableGrob object
#' @param ... additional arguments passed to other functions
#' @importFrom grid grid.newpage grid.draw pushViewport popViewport
#' @export
plot.flextableGrob <- function(x, ...) {
  grid.newpage()
  # leave a 5pt margin around the plot
  pushViewport(viewport(
    width = unit(1, "npc") - unit(10, "pt"),
    height = unit(1, "npc") - unit(10, "pt")
  ))
  grid.draw(x)
  popViewport()
  invisible(x)
}

#' @title Get optimal width and height of a flextable grob
#' @description returns the optimal width and height for the grob,
#' according to the grob generation parameters.
#' @param x a flextableGrob object
#' @return a named list with two elements, `width` and `height`.
#' Values are expressed in inches.
#' @examples
#' ftab <- flextable(head(iris))
#' gr <- gen_grob(ftab)
#' dim(gr)
#' @export
dim.flextableGrob <- function(x) {
  list(width = sum(x$ftpar$widths, na.rm = TRUE), height = sum(x$ftpar$heights, na.rm = TRUE))
}

# contents grob -----------------------------------------------------------

#' @importFrom data.table is.data.table .GRP
make_contents_grob <- function(row_index, col_index,
                               chunk_data, chunk_part_data,
                               vp, params, ...) {
  if (!is.data.table(chunk_data) || !nrow(chunk_data) ||
    !is.data.table(chunk_part_data) || !nrow(chunk_part_data)) {
    return(NULL)
  }

  dots <- list(...)
  params <- c(list(
    row_index = row_index,
    col_index = col_index
  ), params, dots)

  # create contents grob
  gr <- gTree(
    vp = do.call(viewport, vp),
    name = "contents"
  )

  # create chunk grobs
  gr$ftgrobs <- chunk_data[,
    list(grobs = list(make_chunk_grob(.GRP, .SD, params))),
    by = "chunk_index"
  ]$grobs

  # set data
  gr$ftdat <- chunk_part_data

  # set parameters
  gr$ftpar <- params

  # arrange grob to get the real height
  # if the fit is fixed, make the changes permanent
  gr <- arrange_contents_grob(gr, do_update_grob = params$fit %in% "fixed")

  # done
  gr
}

#' @importFrom grid setChildren
arrange_contents_grob <- function(x,
                                  width_factor = 1,
                                  height_factor = 1,
                                  cex = 1,
                                  do_update_grob = TRUE) {
  params <- x$ftpar
  dat <- x$ftdat

  if (nrow(dat) > 1) {
    # calculate real max width for the contents
    if (params$angle == 0) {
      max_width <- (params$width - params$paddingx) * width_factor
    } else {
      max_width <- (max(params$height, params$min_height, params$max_height, na.rm = TRUE) -
        params$paddingy) * height_factor
    }

    child_count <- .chunk_index <- width <- NULL
    if (params$wrapping) {
      filtered <- c(
        unlist(dat[child_count > 0 & width * cex <= max_width, "children_index"]),
        unlist(dat[child_count > 0 & width * cex > max_width, ".chunk_index"])
      )
      dat <- dat[!.chunk_index %in% filtered, , drop = FALSE]
    }
    n <- nrow(dat)
    if (n > 1) {
      # loop the chunk parts and arrange them in rows/columns
      # according to their width
      row_index <- integer(n)
      col_index <- integer(n)
      cur_width <- 0
      cur_row <- 1L
      cur_col <- 1L
      cur_chunk <- 0L
      for (i in seq_len(n)) {
        item <- dat[i, ]
        cur_width <- cur_width + (item$width * cex)
        if (item$is_newline) {
          # if it's the first item in first row, add it, else ignore it
          if (cur_row == 1 && cur_col == 1) {
            row_index[[i]] <- cur_row
            col_index[[i]] <- cur_col
          }
          cur_row <- cur_row + 1L
          cur_col <- 1L
          cur_width <- 0
          cur_chunk <- 0L
        } else if (params$wrapping && cur_width > max_width) {
          if (cur_col == 1) {
            # if it's the first item in row, add it and go to next row
            row_index[[i]] <- cur_row
            col_index[[i]] <- cur_col
            cur_row <- cur_row + 1L
            cur_col <- 1L
            cur_width <- 0
            cur_chunk <- 0L
          } else {
            # else go to next row and then add it
            cur_row <- cur_row + 1L
            cur_col <- 1L
            if (item$is_whitespace) {
              # ignore whitespace in line break
              cur_width <- 0
              cur_chunk <- 0L
            } else {
              row_index[[i]] <- cur_row
              col_index[[i]] <- cur_col
              cur_col <- cur_col + 1L
              cur_width <- (item$width * cex)
              cur_chunk <- item$chunk_index
            }
          }
        } else {
          if (cur_row > 1L && cur_col == 1L && item$is_whitespace) {
            # ignore whitespace
            cur_width <- 0
            cur_chunk <- 0L
          } else {
            # set the row
            row_index[[i]] <- cur_row
            # if the item is from a different chunk than the previous
            if (item$chunk_index != cur_chunk) {
              # set the column
              col_index[[i]] <- cur_col
              # and go to next column
              cur_col <- cur_col + 1L
            } else {
              # set it to the previous column
              col_index[[i]] <- cur_col - 1
            }
            cur_chunk <- item$chunk_index
          }
        }
      }
      dat$row_index <- row_index
      dat$col_index <- col_index
      dat <- dat[row_index > 0, ]
    }
  }

  make_row_grob <- function(row_index, grobs, layout) {
    # when there are more than one grobs in a row
    # we need to align them to their baseline
    # because they might have different font sizes
    # use flextableRowPartGrob class for that
    if (length(grobs) > 1) {
      grob_names <- sapply(grobs, `[[`, "name")
      grobs <- lapply(grobs, function(gr) {
        class(gr) <- c("flextableRowPartGrob", class(gr))
        gr$ftsiblings <- grob_names
        names(gr$ftsiblings) <- grob_names
        gr
      })
    }

    if (params$debug) {
      grobs <- c(grobs, list(
        rectGrob(
          gp = gpar(lwd = 0.5, col = "red", fill = NA)
        )
      ))
    }

    gTree(
      children = do.call(gList, grobs),
      vp = viewport(
        layout.pos.row = row_index,
        layout.pos.col = 1,
        layout = layout
      ),
      name = paste("chunk_row", row_index, sep = "_")
    )
  }

  make_col_grob <- function(col_index, chunk_index,
                            txt_data, from_.chunk_index, to_.chunk_index,
                            width, height) {
    gr <- x$ftgrobs[[chunk_index]]
    params <- gr$ftpar
    if (inherits(gr, "text") && params$txt_data != txt_data) {
      gr$label <- calc_grid_label(
        x = txt_data,
        valign = params$valign,
        is_underlined = params$is_underlined,
        is_bold = params$is_bold,
        is_italic = params$is_italic
      )
      gr$name <- paste(gr$name, "seq", from_.chunk_index, "to", to_.chunk_index, sep = "_")
    }
    gr$vp <- viewport(
      layout.pos.row = 1,
      layout.pos.col = col_index
    )
    if (inherits(gr, "flextableRasterChunk")) {
      gr$vp <- vpStack(
        gr$vp,
        viewport(
          width = unit(width * cex, "in"),
          height = unit(height * cex, "in")
        )
      )
    }
    gr
  }

  if (nrow(dat) > 1) {
    # group data by row, column and chunk
    col_dat <- dat[, list(
      from = min(.SD$.chunk_index),
      to = max(.SD$.chunk_index),
      txt_data = paste0(.SD$txt_data, collapse = ""),
      width = sum(.SD$width),
      height = max(.SD$ascent) + max(.SD$descent)
    ), by = c("row_index", "col_index", "chunk_index")]

    if (do_update_grob) {
      # create grobs for columns
      col_dat[, "grob" := mapply(
        make_col_grob,
        .SD$col_index,
        .SD$chunk_index,
        .SD$txt_data,
        .SD$from,
        .SD$to,
        .SD$width,
        .SD$height,
        SIMPLIFY = FALSE
      )]
    }

    # group data by row
    row_dat <- col_dat[, list(
      grobs = list(.SD$grob),
      layout = list(grid.layout(
        nrow = 1,
        ncol = nrow(.SD),
        widths = unit(.SD$width * cex, "in"),
        # heights = unit(max(.SD$height * cex), "in"),
        just = params$justr
      )),
      width = sum(.SD$width * cex),
      height = max(.SD$height * cex)
    ), by = "row_index"]

    if (do_update_grob) {
      # create grobs for rows
      row_dat[, "grob" := mapply(
        make_row_grob,
        .SD$row_index,
        .SD$grobs,
        .SD$layout,
        SIMPLIFY = FALSE
      )]
      children <- do.call(gList, row_dat$grob)
    }
    widths <- row_dat$width
    heights <- row_dat$height
  } else {
    if (do_update_grob) {
      children <- gList(make_col_grob(
        1L, dat$chunk_index,
        dat$txt_data, dat$.chunk_index, dat$.chunk_index,
        dat$width, dat$height
      ))
    }
    widths <- dat$width * cex
    heights <- dat$height * cex
  }

  if (do_update_grob) {
    # set viewport layout
    x$vp$layout <- grid.layout(
      nrow = length(children),
      ncol = 1,
      heights = unit(heights, "in"),
      widths = unit(max(widths), "in"),
      just = params$justr
    )
  }

  # calculate real height of the contents
  if (params$angle == 0) {
    height <- sum(heights) + params$paddingy
  } else {
    height <- max(widths) + params$paddingy
  }
  height <- min(
    max(height, params$min_height, na.rm = TRUE), params$max_height,
    na.rm = TRUE
  )

  # set the height info
  x$ftpar$height <- height

  if (do_update_grob) {
    # set the children and return the updated grob
    setChildren(x, children)
  } else {
    # just return the grob
    x
  }
}

# misc grobs --------------------------------------------------------------

#' @importFrom grid textGrob rasterGrob
make_chunk_grob <- function(chunk_index, dat, params) {
  if (dat$is_text) {
    gr <- textGrob(
      label = calc_grid_label(
        x = paste(dat$txt_data[[1]], collapse = ""),
        valign = dat$valign,
        is_underlined = dat$is_underlined,
        is_bold = dat$is_bold,
        is_italic = dat$is_italic
      ),
      gp = dat$gp[[1]]
    )
    # store info for label
    gr$ftpar <- list(
      txt_data = dat$txt_data[[1]],
      valign = dat$valign,
      is_underlined = dat$is_underlined,
      is_bold = dat$is_bold,
      is_italic = dat$is_italic
    )
  } else if (dat$is_raster) {
    if (inherits(dat$img_data[[1]], "flextableRasterChunk")) {
      gr <- rasterGrob(
        image = dat$img_data[[1]],
        width = unit(1, "npc"),
        height = unit(1, "npc"),
        gp = dat$gp[[1]]
      )
      class(gr) <- c("flextableRasterChunk", class(gr))
    } else {
      gr <- rasterGrob(
        image = dat$img_data[[1]],
        gp = dat$gp[[1]]
      )
    }
  } else {
    gr <- rasterGrob(
      image = blank_raster_image,
      width = unit(1, "npc"),
      height = unit(1, "npc"),
      gp = dat$gp[[1]]
    )
  }
  if (!dat$shading_color %in% "transparent" || params$debug) {
    class(gr) <- c("flextableHighlightedGrob", class(gr))
    gr$highlight_gp <- gpar(
      lwd = 0.5,
      fill = dat$shading_color,
      col = ifelse(params$debug, "black", dat$shading_color)
    )
  }
  gr$name <- paste("chunk", chunk_index, sep = "_")
  gr
}

#' @importFrom grid rectGrob
make_background_grob <- function(args) {
  if (length(args) > 0) {
    args$name <- "background"
    do.call(rectGrob, args)
  }
}

#' @importFrom grid segmentsGrob
make_segment_grob <- function(args) {
  if (length(args) > 0) {
    do.call(segmentsGrob, args)
  }
}

make_borders_grob <- function(args) {
  if (length(args) > 0) {
    segments <- lapply(args, make_segment_grob)
    if (length(segments) > 0) {
      gTree(
        children = do.call(gList, segments),
        name = "borders"
      )
    }
  }
}

#' @importFrom grid drawDetails grid.rect grobWidth grobHeight grobDescent
#' @export
drawDetails.flextableHighlightedGrob <- function(x, recording) {
  if (!is.null(x$highlight_gp)) {
    # draw a rect around the grob, taking into account the descent
    # as grobHeight does not include it
    descent <- grobDescent(x)
    if (inherits(x, "text") && is.expression(x$label)) {
      yadd <- descent
      yoffset <- unit(0, "npc")
    } else {
      yadd <- descent * 2
      yoffset <- descent / 2
    }
    grid.rect(
      x = x$x,
      y = x$y - yoffset,
      just = x$just,
      width = grobWidth(x),
      height = grobHeight(x) + yadd,
      gp = x$highlight_gp
    )
  }
  NextMethod()
}

#' @export
drawDetails.flextableRowPartGrob <- function(x, recording) {
  # When different chunks are parts of a row, they must be aligned in their baseline.
  # At this point they are aligned in their middle (as vjust is 0.5).
  # So we must offset them according to the tallest grob.
  # We use grobHeight from grid because it is most accurate and it excludes ascent and descent.
  # x$ftsiblings contains the names of all the grobs in the row
  if (length(x$ftsiblings) > 1) {
    # calculate half height of the grobs
    halfheights <- sapply(x$ftsiblings, function(z) {
      convertHeight(grobHeight(z) / 2, unitTo = "in", valueOnly = TRUE)
    })
    # offset y, so that it is aligned with the tallest grob
    x$y <- x$y - unit(max(halfheights) - halfheights[[x$name]], "in")
    # offset further for subscripts
    if (inherits(x, "text") && x$ftpar$valign %in% "subscript") {
      x$y <- x$y - grobDescent(x)
    }
  }
  NextMethod()
}
