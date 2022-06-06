#' @export
#' @title Set flextable style
#' @description Modify flextable text, paragraphs and cells formatting properties.
#' It allows to specify a set of formatting properties for a selection instead
#' of using multiple functions (.i.e `bold`, `italic`, `bg`) that
#' should all be applied to the same selection of rows and columns.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param pr_t object(s) of class `fp_text`
#' @param pr_p object(s) of class `fp_par`
#' @param pr_c object(s) of class `fp_cell`
#' @param part partname of the table (one of 'all', 'body', 'header' or 'footer')
#' @importFrom stats terms
#' @examples
#' library(officer)
#' def_cell <- fp_cell(border = fp_border(color = "wheat"))
#'
#' def_par <- fp_par(text.align = "center")
#'
#' ft <- flextable(head(mtcars))
#'
#' ft <- style(ft, pr_c = def_cell, pr_p = def_par, part = "all")
#' ft <- style(ft, ~ drat > 3.5, ~ vs + am + gear + carb,
#'   pr_t = fp_text(color = "red", italic = TRUE)
#' )
#'
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_style_1.png}{options: width="500"}}
style <- function(x, i = NULL, j = NULL,
                  pr_t = NULL, pr_p = NULL, pr_c = NULL, part = "body") {
  if (!inherits(x, "flextable")) stop("style supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    args <- list()
    for (p in c("header", "body", "footer")) {
      args$x <- x
      args$i <- i
      args$j <- j
      args$pr_t <- pr_t
      args$pr_p <- pr_p
      args$pr_c <- pr_c
      args$part <- p
      x <- do.call(style, args)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (!is.null(pr_t)) {
    x[[part]]$styles$text[i, j] <- pr_t
  }

  if (!is.null(pr_p)) {
    x[[part]]$styles$pars[i, j] <- pr_p
  }

  if (!is.null(pr_c)) {
    x[[part]]$styles$cells[i, j] <- pr_c
  }

  x
}


# text format ----

#' @export
#' @title Set bold font
#' @description change font weight of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bold boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- bold(ft, bold = TRUE, part = "header")
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_bold_1.png}{options: width="400"}}
bold <- function(x, i = NULL, j = NULL, bold = TRUE, part = "body") {
  if (!inherits(x, "flextable")) stop("bold supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- bold(x = x, i = i, j = j, bold = bold, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(bold) == length(j)) {
    bold <- rep(bold, each = length(i))
  }

  x[[part]]$styles$text[i, j, "bold"] <- bold

  x
}

#' @export
#' @title Set font size
#' @description change font size of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param size integer value (points)
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- fontsize(ft, size = 14, part = "header")
#' ft <- fontsize(ft, size = 14, j = 2)
#' ft <- fontsize(ft, size = 7, j = 3)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_fontsize_1.png}{options: width="400"}}
fontsize <- function(x, i = NULL, j = NULL, size = 11, part = "body") {
  if (!inherits(x, "flextable")) stop("fontsize supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- fontsize(x = x, i = i, j = j, size = size, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x[[part]]$styles$text[i, j, "font.size"] <- size

  x
}

#' @export
#' @title Set italic font
#' @description change font decoration of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param italic boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- italic(ft, italic = TRUE, part = "header")
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_italic_1.png}{options: width="400"}}
italic <- function(x, i = NULL, j = NULL, italic = TRUE, part = "body") {
  if (!inherits(x, "flextable")) stop("italic supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- italic(x = x, i = i, j = j, italic = italic, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(italic) == length(j)) {
    italic <- rep(italic, each = length(i))
  }

  x[[part]]$styles$text[i, j, "italic"] <- italic

  x
}

#' @export
#' @title Text highlight color
#' @description Change text highlight color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `color` is a function, it is possible to color cells based on values
#' located in other columns, using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' has to be used to define what are the columns to be used for the color
#' definition and the argument `j` has to be used to define where to apply
#' the colors and only accept values from `colkeys`.

#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param color color to use as text highlighting color.
#' If a function, function need to return a character vector of colors.
#' @param source if color is a function, source is specifying the dataset column to be used
#' as argument to `color`. This is only useful if j is colored with values contained in
#' other columns.
#' @family sugar functions for table style
#' @examples
#' my_color_fun <- function(x) {
#'   out <- rep("yellow", length(x))
#'   out[x < quantile(x, .75)] <- "pink"
#'   out[x < quantile(x, .50)] <- "wheat"
#'   out[x < quantile(x, .25)] <- "gray90"
#'   out
#' }
#' ft <- flextable(head(mtcars, n = 10))
#' ft <- highlight(ft, j = "disp", i = ~ disp > 200, color = "yellow")
#' ft <- highlight(ft, j = ~ drat + wt + qsec, color = my_color_fun)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_highlight_1.png}{options: width="500"}}
highlight <- function(x, i = NULL, j = NULL, color = "yellow", part = "body", source = j) {
  if (!inherits(x, "flextable")) stop("italic supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- highlight(x = x, i = i, j = j, color = color, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)

  if (is.function(color)) {
    source <- as_col_keys(x[[part]], source)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    color <- data_colors(source_dataset, color)
  }

  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(color) == length(j)) {
    color <- rep(color, each = length(i))
  }

  x[[part]]$styles$text[i, j, "shading.color"] <- color

  x
}

#' @export
#' @title Set font color
#' @description Change text color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `color` is a function, it is possible to color cells based on values
#' located in other columns, using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' has to be used to define what are the columns to be used for the color
#' definition and the argument `j` has to be used to define where to apply
#' the colors and only accept values from `colkeys`.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param color color to use as font color. If a function, function need to return
#' a character vector of colors.
#' @param source if color is a function, source is specifying the dataset column to be used
#' as argument to `color`. This is only useful if j is colored with values contained in
#' other columns.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- color(ft, color = "orange", part = "header")
#' ft <- color(ft,
#'   color = "red",
#'   i = ~ qsec < 18 & vs < 1
#' )
#' ft
#'
#' if (require("scales")) {
#'   scale <- scales::col_numeric(domain = c(-1, 1), palette = "RdBu")
#'   x <- as.data.frame(cor(iris[-5]))
#'   x <- cbind(
#'     data.frame(
#'       colname = colnames(x),
#'       stringsAsFactors = FALSE
#'     ),
#'     x
#'   )
#'
#'   ft_2 <- flextable(x)
#'   ft_2 <- color(ft_2, j = x$colname, color = scale)
#'   ft_2 <- set_formatter_type(ft_2)
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_color_1.png}{options: width="600"}}
#'
#' \if{html}{\figure{fig_color_2.png}{options: width="400"}}
color <- function(x, i = NULL, j = NULL, color, part = "body", source = j) {
  if (!inherits(x, "flextable")) stop("color supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- color(x = x, i = i, j = j, color = color, part = p, source = source)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)

  if (is.function(color)) {
    source <- as_col_keys(x[[part]], source)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    color <- data_colors(source_dataset, color)
  }

  i <- get_rows_id(x[[part]], i)
  j <- x$col_keys[get_columns_id(x[[part]], j)]

  if(length(color) == length(j)) {
    color <- rep(color, each = length(i))
  }

  x[[part]]$styles$text[i, j, "color"] <- color

  x
}

#' @export
#' @title Set font
#' @description change font of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param fontname single character value. With Word and PowerPoint output, the value specifies the font to
#' be used to format characters in the Unicode range (U+0000-U+007F).
#' @param cs.family Optional font to be used to format
#' characters in a complex script Unicode range. For example, Arabic
#' text might be displayed using the "Arial Unicode MS" font.
#' Used only with Word and PowerPoint outputs. Its default value is the value
#' of `fontname`.
#' @param eastasia.family optional font to be used to
#' format characters in an East Asian Unicode range. For example,
#' Japanese text might be displayed using the "MS Mincho" font.
#' Used only with Word and PowerPoint outputs. Its default value is the value
#' of `fontname`.
#' @param hansi.family optional. Specifies the font to be used to format
#' characters in a Unicode range which does not fall into one of the
#' other categories.
#' Used only with Word and PowerPoint outputs. Its default value is the value
#' of `fontname`.
#' @family sugar functions for table style
#' @examples
#' require("gdtools")
#' fontname <- "Brush Script MT"
#'
#' if (font_family_exists(fontname)) {
#'   ft_1 <- flextable(head(iris))
#'   ft_2 <- font(ft_1, fontname = fontname, part = "header")
#'   ft_2 <- font(ft_2, fontname = fontname, j = 5)
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_font_1.png}{options: width="500"}}
#'
#' \if{html}{\figure{fig_font_2.png}{options: width="500"}}
font <- function(x, i = NULL, j = NULL, fontname, part = "body", cs.family = fontname, hansi.family = fontname, eastasia.family = fontname) {
  if (!inherits(x, "flextable")) stop("font supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- font(x = x, i = i, j = j, fontname = fontname, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(fontname) == length(j)) {
    fontname <- rep(fontname, each = length(i))
  }
  if(length(cs.family) == length(j)) {
    cs.family <- rep(cs.family, each = length(i))
  }
  if(length(hansi.family) == length(j)) {
    hansi.family <- rep(hansi.family, each = length(i))
  }
  if(length(eastasia.family) == length(j)) {
    eastasia.family <- rep(eastasia.family, each = length(i))
  }

  x[[part]]$styles$text[i, j, "font.family"] <- fontname
  x[[part]]$styles$text[i, j, "cs.family"] <- cs.family
  x[[part]]$styles$text[i, j, "hansi.family"] <- hansi.family
  x[[part]]$styles$text[i, j, "eastasia.family"] <- eastasia.family
  x
}

# paragraphs format ----

#' @export
#' @title Set paragraph paddings
#' @description change paddings of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param padding padding (shortcut for top, bottom, left and right), unit is pts (points).
#' @param padding.top padding top, unit is pts (points).
#' @param padding.bottom padding bottom, unit is pts (points).
#' @param padding.left padding left, unit is pts (points).
#' @param padding.right padding right, unit is pts (points).
#' @family sugar functions for table style
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- theme_vader(ft_1)
#' ft_1 <- padding(ft_1, padding.top = 4, part = "all")
#' ft_1 <- padding(ft_1, j = 1, padding.right = 40)
#' ft_1 <- padding(ft_1, i = 3, padding.top = 40)
#' ft_1 <- padding(ft_1, padding.top = 10, part = "header")
#' ft_1 <- padding(ft_1, padding.bottom = 10, part = "header")
#' ft_1 <- autofit(ft_1)
#' ft_1
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_padding_1.png}{options: width="400"}}
padding <- function(x, i = NULL, j = NULL, padding = NULL,
                    padding.top = NULL, padding.bottom = NULL,
                    padding.left = NULL, padding.right = NULL,
                    part = "body") {
  if (!inherits(x, "flextable")) stop("padding supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (!is.null(padding)) {
    if (is.null(padding.top)) padding.top <- padding
    if (is.null(padding.bottom)) padding.bottom <- padding
    if (is.null(padding.left)) padding.left <- padding
    if (is.null(padding.right)) padding.right <- padding
  }
  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- padding(
        x = x, i = i, j = j,
        padding.top = padding.top, padding.bottom = padding.bottom,
        padding.left = padding.left, padding.right = padding.right,
        part = p
      )
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)


  if (!is.null(padding.top)) {
    x[[part]]$styles$pars[i, j, "padding.top"] <- padding.top
  }
  if (!is.null(padding.bottom)) {
    x[[part]]$styles$pars[i, j, "padding.bottom"] <- padding.bottom
  }
  if (!is.null(padding.left)) {
    x[[part]]$styles$pars[i, j, "padding.left"] <- padding.left
  }
  if (!is.null(padding.right)) {
    x[[part]]$styles$pars[i, j, "padding.right"] <- padding.right
  }

  x
}


#' @export
#' @title Set text alignment
#' @description change text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param align text alignment - a single character value, expected value
#' is one of 'left', 'right', 'center', 'justify'.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars)[, 3:6])
#' ft <- align(ft, align = "right", part = "all")
#' ft <- theme_tron_legacy(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_align_1.png}{options: width="400"}}
align <- function(x, i = NULL, j = NULL, align = "left",
                  part = "body") {
  if (!inherits(x, "flextable")) stop("align supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- align(x = x, i = i, j = j, align = align, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(align) == length(j)) {
    align <- rep(align, each = length(i))
  }
  x[[part]]$styles$pars[i, j, "text.align"] <- align

  x
}

keep_wn <- function(x, i = NULL, j = NULL, keep_with_next = TRUE,
                    part = "body") {
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- keep_wn(x = x, i = i, j = j, keep_with_next = keep_with_next, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x[[part]]$styles$pars[i, j, "keep_with_next"] <- keep_with_next

  x
}

#' @export
#' @title Set text alignment
#' @description change text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param space space between lines of text, 1 is single line spacing, 2 is double line spacing.
#' @param unit unit for space, one of "in", "cm", "mm".
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars)[, 3:6])
#' ft <- line_spacing(ft, space = 1.6, part = "all")
#' ft <- set_table_properties(ft, layout = "autofit")
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_line_spacing_1.png}{options: width="400"}}
line_spacing <- function(x, i = NULL, j = NULL, space = 1, part = "body", unit = "in") {
  space <- convin(unit = unit, x = space)

  if (!inherits(x, "flextable")) stop("align supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- line_spacing(x = x, i = i, j = j, space = space, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x[[part]]$styles$pars[i, j, "line_spacing"] <- space

  x
}

#' @export
#' @rdname align
#' @param header should the header be aligned with the body
#' @param footer should the footer be aligned with the body
#' @examples
#' ftab <- flextable(mtcars)
#' ftab <- align_text_col(ftab, align = "left")
#' ftab <- align_nottext_col(ftab, align = "right")
#' ftab
align_text_col <- function(x, align = "left", header = TRUE, footer = TRUE) {
  which_j <- which(sapply(x$body$dataset[x$col_keys], function(x) is.character(x) | is.factor(x)))
  x <- align(x, j = which_j, align = align, part = "body")
  if (header) {
    x <- align(x, j = which_j, align = align, part = "header")
  }
  if (footer) {
    x <- align(x, j = which_j, align = align, part = "footer")
  }
  x
}

#' @export
#' @rdname align
align_nottext_col <- function(x, align = "right", header = TRUE, footer = TRUE) {
  which_j <- which(!sapply(x$body$dataset[x$col_keys], function(x) is.character(x) | is.factor(x)))
  x <- align(x, j = which_j, align = align, part = "body")
  if (header) {
    x <- align(x, j = which_j, align = align, part = "header")
  }
  if (footer) {
    x <- align(x, j = which_j, align = align, part = "footer")
  }
  x
}

# cells format ----

#' @export
#' @title Set background color
#' @description Change background color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `bg` is a function, it is possible to color cells based on values
#' located in other columns, using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' has to be used to define what are the columns to be used for the color
#' definition and the argument `j` has to be used to define where to apply
#' the colors and only accept values from `colkeys`.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bg color to use as background color. If a function, function need to return
#' a character vector of colors.
#' @param source if bg is a function, source is specifying the dataset column to be used
#' as argument to `bg`. This is only useful if j is colored with values contained in
#' other columns.
#' @family sugar functions for table style
#' @note
#' Word does not allow you to apply transparency to table cells or paragraph shading.
#' @examples
#' ft_1 <- flextable(head(mtcars))
#' ft_1 <- bg(ft_1, bg = "wheat", part = "header")
#' ft_1 <- bg(ft_1, i = ~ qsec < 18, bg = "#EFEFEF", part = "body")
#' ft_1 <- bg(ft_1, j = "drat", bg = "#606060", part = "all")
#' ft_1 <- color(ft_1, j = "drat", color = "white", part = "all")
#' ft_1
#'
#' if (require("scales")) {
#'   ft_2 <- flextable(head(iris))
#'   colourer <- col_numeric(
#'     palette = c("wheat", "red"),
#'     domain = c(0, 7)
#'   )
#'   ft_2 <- bg(ft_2,
#'     j = c(
#'       "Sepal.Length", "Sepal.Width",
#'       "Petal.Length", "Petal.Width"
#'     ),
#'     bg = colourer, part = "body"
#'   )
#'   ft_2
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_bg_1.png}{options: width="400"}}
#'
#' \if{html}{\figure{fig_bg_2.png}{options: width="300"}}
bg <- function(x, i = NULL, j = NULL, bg, part = "body", source = j) {
  if (!inherits(x, "flextable")) stop("bg supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- bg(x = x, i = i, j = j, bg = bg, part = p, source = source)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)

  if (is.function(bg)) {
    source <- as_col_keys(x[[part]], source)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    bg <- data_colors(source_dataset, bg)
  }

  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if(length(bg) == length(j)) {
    bg <- rep(bg, each = length(i))
  }

  x[[part]]$styles$cells[i, j, "background.color"] <- bg

  x
}

#' @param x a complex_tabpart object
#' @noRd
as_col_keys <- function(x, j = NULL) {
  if (is.null(j)) {
    j <- x$col_keys
  } else if (inherits(j, "formula")) {
    j <- get_j_from_formula(j, x$dataset)
  } else if (is.logical(j)) {
    if (length(j) != length(x$col_keys)) {
      stop("j (as logical) is expected to have the same length than 'col_keys'.")
    }
    j <- x$col_keys[j]
  } else if (is.character(j)) {
    j <- intersect(colnames(x$dataset), j)
  } else if (is.numeric(j)) {
    j <- x$col_keys[intersect(seq_len(ncol(x$dataset)), j)]
  }

  j
}

data_colors <- function(dataset, fun) {
  out <- tryCatch(
    {
      lbg <- lapply(dataset, fun)
      matrix(unlist(lbg), ncol = length(lbg))
    },
    error = function(cond) {
      msg <- paste0(
        "an error occured while using color function: ",
        cond$message
      )
      stop(msg, call. = FALSE)
    },
    warning = function(cond) {
      msg <- paste0(
        "a warning occured while using color function: ",
        cond$message
      )
      stop(msg, call. = FALSE)
    }
  )
  return(out)
}


#' @export
#' @title Set vertical alignment
#' @description change vertical alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param valign vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @family sugar functions for table style
#' @examples
#' ft_1 <- flextable(iris[c(1:3, 51:53, 101:103), ])
#' ft_1 <- theme_box(ft_1)
#' ft_1 <- merge_v(ft_1, j = 5)
#' ft_1
#'
#' ft_2 <- valign(ft_1, j = 5, valign = "top", part = "all")
#' ft_2
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_valign_1.png}{options: width="400"}}
#'
#' \if{html}{\figure{fig_valign_2.png}{options: width="400"}}
valign <- function(x, i = NULL, j = NULL, valign = "center", part = "body") {
  if (!inherits(x, "flextable")) stop("valign supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- valign(x = x, i = i, j = j, valign = valign, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  x[[part]]$styles$cells[i, j, "vertical.align"] <- valign

  x
}


#' @export
#' @title rotate cell text
#' @description It can be useful to be able to change the direction,
#' when the table headers are huge for example, header labels can
#' be rendered as "tbrl" (top to bottom and right to left) corresponding
#' to a 90 degrees rotation or "btlr" corresponding to a 270
#' degrees rotation.

#' The function change cell text direction. By default, it is
#' "lrtb" which mean from left to right and top to bottom.
#'
#' 'Word' and 'PowerPoint' don't handle auto height with rotated headers.
#' So you need to set header heights (with function [height()])
#' and set rule "exact" for rows heights (with function [hrule()])
#' otherwise Word and PowerPoint outputs will have small height
#' not corresponding to the necessary height to display the text.
#'
#' Note that PDF does not yet support vertical alignments when
#' text is rotated.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param rotation one of "lrtb", "tbrl", "btlr".
#' @param align vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @details
#' When function `autofit` is used, the rotation will be
#' ignored. In that case, use [dim_pretty] and [width] instead
#' of [autofit].
#' @family sugar functions for table style
#' @examples
#' library(flextable)
#'
#' ft_1 <- flextable(head(iris))
#'
#' ft_1 <- rotate(ft_1, j = 1:4, align = "bottom", rotation = "tbrl", part = "header")
#' ft_1 <- rotate(ft_1, j = 5, align = "bottom", rotation = "btlr", part = "header")
#'
#' # if output is docx or pptx, think about (1) set header heights
#' # and (2) set rule "exact" for rows heights because Word
#' # and PowerPoint don't handle auto height with rotated headers
#' ft_1 <- height(ft_1, height = 1.2, part = "header")
#' ft_1 <- hrule(ft_1, i = 1, rule = "exact", part = "header")
#'
#' ft_1
#'
#' dat <- data.frame(
#'   a = c("left-top", "left-middle", "left-bottom"),
#'   b = c("center-top", "center-middle", "center-bottom"),
#'   c = c("right-top", "right-middle", "right-bottom")
#' )
#'
#' ft_2 <- flextable(dat)
#' ft_2 <- theme_box(ft_2)
#' ft_2 <- height_all(x = ft_2, height = 1.3, part = "body")
#' ft_2 <- hrule(ft_2, rule = "exact")
#' ft_2 <- rotate(ft_2, rotation = "tbrl")
#' ft_2 <- width(ft_2, width = 1.3)
#'
#' ft_2 <- align(ft_2, j = 1, align = "left")
#' ft_2 <- align(ft_2, j = 2, align = "center")
#' ft_2 <- align(ft_2, j = 3, align = "right")
#'
#' ft_2 <- valign(ft_2, i = 1, valign = "top")
#' ft_2 <- valign(ft_2, i = 2, valign = "center")
#' ft_2 <- valign(ft_2, i = 3, valign = "bottom")
#'
#' ft_2
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_rotate_1.png}{options: width="400"}}
rotate <- function(x, i = NULL, j = NULL, rotation, align = NULL, part = "body") {
  if (!inherits(x, "flextable")) stop("rotate supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- rotate(x = x, i = i, j = j, rotation = rotation, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  x[[part]]$styles$cells[i, j, "text.direction"] <- rotation
  if(!is.null(align)) {
    x[[part]]$styles$cells[i, j, "vertical.align"] <- align
  }

  x
}



# misc. ----


#' @title make blank columns as transparent
#' @description blank columns are set as transparent. This is a shortcut function
#' that will delete top and bottom borders, change background color to
#' transparent, display empty content and set blank columns' width.
#' @param x a flextable object
#' @param width width of blank columns (.1 inch by default).
#' @param unit unit for width, one of "in", "cm", "mm".
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @family sugar functions for table style
#' @examples
#' typology <- data.frame(
#'   col_keys = c(
#'     "Sepal.Length", "Sepal.Width", "Petal.Length",
#'     "Petal.Width", "Species"
#'   ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", " "),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE
#' )
#' typology
#'
#' ftab <- flextable(head(iris), col_keys = c(
#'   "Species",
#'   "break1", "Sepal.Length", "Sepal.Width",
#'   "break2", "Petal.Length", "Petal.Width"
#' ))
#' ftab <- set_header_df(ftab, mapping = typology, key = "col_keys")
#' ftab <- merge_h(ftab, part = "header")
#' ftab <- theme_vanilla(ftab)
#' ftab <- empty_blanks(ftab)
#' ftab <- width(ftab, j = c(2, 5), width = .1)
#' ftab
#' @export
#' @importFrom officer shortcuts
empty_blanks <- function(x, width = .05, unit = "in", part = "all") {
  if (!inherits(x, "flextable")) stop("empty_blanks supports only flextable objects.")
  if (length(x$blanks) < 1) {
    return(x)
  }

  x <- border(x,
    j = x$blanks,
    border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = part
  )
  x <- bg(x, j = x$blanks, bg = "transparent", part = part)
  x <- void(x, j = x$blanks, part = part)
  x <- width(x, j = x$blanks, width = width, unit = unit)
  x
}
