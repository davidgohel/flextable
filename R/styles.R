#' @export
#' @title Set flextable default styles
#' @description Modify flextable text, paragraph, and cell default formatting
#' properties. This allows you to specify a set of formatting properties for a
#' selection instead of using multiple functions (e.g., `bold`, `italic`, `bg`)
#' that must all be applied to the same selection of rows and columns.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param pr_t object(s) of class `fp_text`, result of [officer::fp_text()]
#' or [officer::fp_text_lite()]
#' @param pr_p object(s) of class `fp_par`, result of [officer::fp_par()]
#' or [officer::fp_par_lite()]
#' @param pr_c object(s) of class `fp_cell`, result of [officer::fp_cell()]
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
style <- function(
    x,
    i = NULL,
    j = NULL,
    pr_t = NULL,
    pr_p = NULL,
    pr_c = NULL,
    part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "style()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
    x[[part]]$styles$text <- set_text_struct_values(
      x = x[[part]]$styles$text,
      i = i,
      j = j,
      value = pr_t
    )
  }

  if (!is.null(pr_p)) {
    if (
      !is.null(pr_p$tabs) && !isFALSE(pr_p$tabs) && !is.character(pr_p$tabs)
    ) {
      pr_p$tabs <- as.character(pr_p$tabs)
    } else {
      pr_p$tabs <- NULL
    }

    for (property in intersect(names(pr_p), names(x[[part]]$styles$pars))) {
      if (!is.null(pr_p[[property]]) && !is.na(pr_p[[property]])) {
        x[[part]]$styles$pars[[property]]$data[i, j] <- pr_p[[property]]
      }
    }
  }

  if (!is.null(pr_c)) {
    pr_c <- cast_borders(pr_c)
    for (property in intersect(names(pr_c), names(x[[part]]$styles$cells))) {
      x[[part]]$styles$cells[[property]]$data[i, j] <- pr_c[[property]]
    }
  }

  x
}


# text format ----

#' @export
#' @title Set bold font
#' @description Change the font weight of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bold boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(iris))
#' ft <- bold(ft, bold = TRUE, part = "header")
bold <- function(x, i = NULL, j = NULL, bold = TRUE, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "bold()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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

  if (length(bold) == length(j)) {
    bold <- rep(bold, each = length(i))
  }

  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "bold",
    value = bold
  )

  x
}

#' @export
#' @title Set font size
#' @description Change the font size of selected rows and columns of a flextable.
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
fontsize <- function(x, i = NULL, j = NULL, size = 11, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "fontsize()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "font.size",
    value = size
  )

  x
}

#' @export
#' @title Set italic font
#' @description Change the font decoration of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param italic boolean value
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- italic(ft, italic = TRUE, part = "header")
italic <- function(x, i = NULL, j = NULL, italic = TRUE, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "italic()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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

  if (length(italic) == length(j)) {
    italic <- rep(italic, each = length(i))
  }

  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "italic",
    value = italic
  )

  x
}

#' @export
#' @title Text highlight color
#' @description Change the text highlight color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `color` is a function, it is possible to color cells based on values
#' located in other columns; using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' must be used to define the columns to be used for the color
#' definition, and the argument `j` must be used to define where to apply
#' the colors and only accepts values from `colkeys`.

#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param color color to use as text highlighting color.
#' If a function, the function must return a character vector of colors.
#' @param source if color is a function, source specifies the dataset column to be used
#' as an argument to `color`. This is only useful when j is colored with values contained in
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
highlight <- function(
    x,
    i = NULL,
    j = NULL,
    color = "yellow",
    part = "body",
    source = j) {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "highlight()"
    ))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
    source <- as_col_keys(x[[part]], source, blanks = x$blanks)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    color <- data_colors(source_dataset, color)
  }

  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (length(color) == length(j)) {
    color <- rep(color, each = length(i))
  }

  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "shading.color",
    value = color
  )

  x
}

#' @export
#' @title Set font color
#' @description Change the text color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `color` is a function, it is possible to color cells based on values
#' located in other columns; using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' must be used to define the columns to be used for the color
#' definition, and the argument `j` must be used to define where to apply
#' the colors and only accepts values from `colkeys`.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param color color to use as font color. If a function, the function must return
#' a character vector of colors.
#' @param source if color is a function, source specifies the dataset column to be used
#' as an argument to `color`. This is only useful when j is colored with values contained in
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
#' }
color <- function(x, i = NULL, j = NULL, color, part = "body", source = j) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "color()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
    source <- as_col_keys(x[[part]], source, blanks = x$blanks)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    color <- data_colors(source_dataset, color)
  }

  i <- get_rows_id(x[[part]], i)
  j <- x$col_keys[get_columns_id(x[[part]], j)]

  if (length(color) == length(j)) {
    color <- rep(color, each = length(i))
  }

  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "color",
    value = color
  )

  x
}

#' @export
#' @title Set font
#' @description Change the font of selected rows and columns of a flextable.
#'
#' Fonts impact the readability and aesthetics of the table. Font families
#' refer to a set of typefaces that share common design features, such as 'Arial'
#' and 'Open Sans'.
#'
#' 'Google Fonts' is a popular library of free web fonts that can be
#' easily integrated into flextable with the [gdtools::register_gfont()] function.
#' When the output is HTML, the font will be automatically added to the HTML
#' document.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param fontname single character value, the font family name.
#' With Word and PowerPoint output, this value specifies the font to
#' be used for formatting characters in the Unicode range (U+0000-U+007F).
#' @param cs.family Optional font to be used for formatting
#' characters in a complex script Unicode range. For example, Arabic
#' text might be displayed using the "Arial Unicode MS" font.
#' Used only with Word and PowerPoint outputs. The default value is the value
#' of `fontname`.
#' @param eastasia.family Optional font to be used for
#' formatting characters in an East Asian Unicode range. For example,
#' Japanese text might be displayed using the "MS Mincho" font.
#' Used only with Word and PowerPoint outputs. The default value is the value
#' of `fontname`.
#' @param hansi.family Optional font to be used for formatting
#' characters in a Unicode range that does not fall into one of the
#' other categories.
#' Used only with Word and PowerPoint outputs. The default value is the value
#' of `fontname`.
#' @family sugar functions for table style
#' @examples
#' library(gdtools)
#' fontname <- "Brush Script MT"
#'
#' if (font_family_exists(fontname)) {
#'   ft_1 <- flextable(head(iris))
#'   ft_2 <- font(ft_1, fontname = fontname, part = "header")
#'   ft_2 <- font(ft_2, fontname = fontname, j = 5)
#'   ft_2
#' }
font <- function(
    x,
    i = NULL,
    j = NULL,
    fontname,
    part = "body",
    cs.family = fontname,
    hansi.family = fontname,
    eastasia.family = fontname) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "font()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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

  if (length(fontname) == length(j)) {
    fontname <- rep(fontname, each = length(i))
  }
  if (length(cs.family) == length(j)) {
    cs.family <- rep(cs.family, each = length(i))
  }
  if (length(hansi.family) == length(j)) {
    hansi.family <- rep(hansi.family, each = length(i))
  }
  if (length(eastasia.family) == length(j)) {
    eastasia.family <- rep(eastasia.family, each = length(i))
  }

  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "font.family",
    value = fontname
  )
  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "cs.family",
    value = cs.family
  )
  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "hansi.family",
    value = hansi.family
  )
  x[[part]]$styles$text <- set_text_struct_values(
    x = x[[part]]$styles$text,
    i = i,
    j = j,
    property = "eastasia.family",
    value = eastasia.family
  )
  x
}

# paragraphs format ----

#' @export
#' @title Set paragraph paddings
#' @description Change the padding of selected rows and columns of a flextable.
#' @note
#' Padding is not implemented in PDF due to technical infeasibility but
#' it can be replaced with `set_table_properties(opts_pdf = list(tabcolsep = 1))`.
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
padding <- function(
    x,
    i = NULL,
    j = NULL,
    padding = NULL,
    padding.top = NULL,
    padding.bottom = NULL,
    padding.left = NULL,
    padding.right = NULL,
    part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "padding()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (!is.null(padding)) {
    if (is.null(padding.top)) {
      padding.top <- padding
    }
    if (is.null(padding.bottom)) {
      padding.bottom <- padding
    }
    if (is.null(padding.left)) {
      padding.left <- padding
    }
    if (is.null(padding.right)) padding.right <- padding
  }
  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- padding(
        x = x,
        i = i,
        j = j,
        padding.top = padding.top,
        padding.bottom = padding.bottom,
        padding.left = padding.left,
        padding.right = padding.right,
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
    x[[part]]$styles$pars <- set_par_struct_values(
      x = x[[part]]$styles$pars,
      i = i,
      j = j,
      property = "padding.top",
      value = padding.top
    )
  }
  if (!is.null(padding.bottom)) {
    x[[part]]$styles$pars <- set_par_struct_values(
      x = x[[part]]$styles$pars,
      i = i,
      j = j,
      property = "padding.bottom",
      value = padding.bottom
    )
  }
  if (!is.null(padding.left)) {
    x[[part]]$styles$pars <- set_par_struct_values(
      x = x[[part]]$styles$pars,
      i = i,
      j = j,
      property = "padding.left",
      value = padding.left
    )
  }
  if (!is.null(padding.right)) {
    x[[part]]$styles$pars <- set_par_struct_values(
      x = x[[part]]$styles$pars,
      i = i,
      j = j,
      property = "padding.right",
      value = padding.right
    )
  }

  x
}


#' @export
#' @title Set text alignment
#' @description Change the text alignment of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'body', 'header', 'footer', 'all')
#' @param align text alignment - a single character value, or a vector of
#' character values equal in length to the number of columns selected by `j`.
#' Expected values must be from the set ('left', 'right', 'center', or 'justify').
#'
#' If the number of columns is a multiple of the length of the `align` parameter,
#' then the values in `align` will be recycled across the remaining columns.
#' @family sugar functions for table style
#' @examples
#' # Table of 6 columns
#' ft_car <- flextable(head(mtcars)[, 2:7])
#'
#' # All 6 columns right aligned
#' align(ft_car, align = "right", part = "all")
#'
#' # Manually specify alignment of each column
#' align(
#'   ft_car,
#'   align = c("left", "right", "left", "center", "center", "right"),
#'   part = "all"
#' )
#'
#' # Center-align column 2 and left-align column 5
#' align(ft_car, j = c(2, 5), align = c("center", "left"), part = "all")
#'
#' # Alternate left and center alignment across columns 1-4 for header only
#' align(ft_car, j = 1:4, align = c("left", "center"), part = "header")
align <- function(
    x,
    i = NULL,
    j = NULL,
    align = "left",
    part = c("body", "header", "footer", "all")) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "align()"))
  }
  part <- match.arg(
    part,
    c("body", "header", "footer", "all"),
    several.ok = FALSE
  )

  allowed_alignments <- c("left", "center", "right", "justify")
  if (!all(align %in% allowed_alignments)) {
    stop(
      "Invalid `align` argument(s) provided to `align()`: \"",
      paste(setdiff(align, allowed_alignments), collapse = "\", \""),
      "\".\n  `align` should be one of: \"",
      paste(allowed_alignments, collapse = "\", \""),
      "\"."
    )
  }

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

  if (length(j) %% length(align) == 0) {
    align <- rep(align, each = length(i))
  }

  x[[part]]$styles$pars <- set_par_struct_values(
    x = x[[part]]$styles$pars,
    i = i,
    j = j,
    property = "text.align",
    value = align
  )
  x
}

#' @export
#' @title Set Word 'Keep with next' instructions
#' @description The 'Keep with next' functionality in 'Word', applied
#' to the rows of a table, ensures that rows with that attribute
#' stay together and do not break across multiple pages.
#'
#' This function provides better control of page breaks than
#' the global `keep_with_next` parameter.
#' @param x a flextable object
#' @param i rows selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param value TRUE or FALSE. When applied to a group, all rows
#' except the last one should be flagged with the 'Keep with next' attribute.
#' @family sugar functions for table style
#' @seealso [paginate()]
#' @examples
#' library(flextable)
#' dat <- iris[c(1:25, 51:75, 101:125), ]
#' ft <- qflextable(dat)
#' ft <- keep_with_next(
#'   x = ft,
#'   i = c(1:24, 26:49, 51:74),
#'   value = TRUE
#' )
#'
#' save_as_docx(ft, path = tempfile(fileext = ".docx"))
keep_with_next <- function(x, i = NULL, value = TRUE, part = "body") {
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- keep_with_next(x = x, i = i, value = value, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  x[[part]]$styles$pars <- set_par_struct_values(
    x = x[[part]]$styles$pars,
    i = i,
    j = NULL,
    property = "keep_with_next",
    value = value
  )

  x
}

#' @export
#' @title Set tabulation marks configuration
#' @description Define tabulation marks configuration.
#' Specifying the positions and types of tabulation marks in table
#' paragraphs helps organize content, especially in clinical tables,
#' by aligning numbers properly.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param value an object generated by [officer::fp_tabs()].
#' @family sugar functions for table style
#' @examples
#' library(officer)
#' library(flextable)
#'
#' z <- data.frame(
#'   Statistic = c("Median (Q1 ; Q3)", "Min ; Max"),
#'   Value = c(
#'     "\t999.99\t(99.9 ; 99.9)",
#'     "\t9.99\t(9999.9 ; 99.9)"
#'   )
#' )
#'
#' ts <- fp_tabs(
#'   fp_tab(pos = 0.4, style = "decimal"),
#'   fp_tab(pos = 1.4, style = "decimal")
#' )
#'
#' zz <- flextable(z)
#' zz <- tab_settings(zz, j = 2, value = ts)
#' zz <- width(zz, width = c(1.5, 2))
#'
#'
#' save_as_docx(zz, path = tempfile(fileext = ".docx"))
tab_settings <- function(x, i = NULL, j = NULL, value = TRUE, part = "body") {
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- tab_settings(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x[[part]]$styles$pars <- set_par_struct_values(
    x = x[[part]]$styles$pars,
    i = i,
    j = j,
    property = "tabs",
    value = as.character(value)
  )

  x
}

#' @export
#' @title Set line spacing
#' @description Change the line spacing of selected rows and columns of a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param space space between lines of text; 1 is single line spacing, 2 is double line spacing.
#' @family sugar functions for table style
#' @examples
#' ft <- flextable(head(mtcars)[, 3:6])
#' ft <- line_spacing(ft, space = 1.6, part = "all")
#' ft <- set_table_properties(ft, layout = "autofit")
#' ft
line_spacing <- function(x, i = NULL, j = NULL, space = 1, part = "body") {
  if (!inherits(x, "flextable")) {
    stop("align supports only flextable objects.")
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
  x[[part]]$styles$pars <- set_par_struct_values(
    x = x[[part]]$styles$pars,
    i = i,
    j = j,
    property = "line_spacing",
    value = space
  )

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
  which_j <- which(sapply(x$body$dataset[x$col_keys], function(x) {
    is.character(x) | is.factor(x)
  }))
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
align_nottext_col <- function(
    x,
    align = "right",
    header = TRUE,
    footer = TRUE) {
  which_j <- which(
    !sapply(x$body$dataset[x$col_keys], function(x) {
      is.character(x) | is.factor(x)
    })
  )
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
#' @description Change the background color of selected rows and
#' columns of a flextable. A function can be used instead of
#' fixed colors.
#'
#' When `bg` is a function, it is possible to color cells based on values
#' located in other columns; using hidden columns (those not used by
#' argument `colkeys`) is a common use case. The argument `source`
#' must be used to define the columns to be used for the color
#' definition, and the argument `j` must be used to define where to apply
#' the colors and only accepts values from `colkeys`.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param bg color to use as background color. If a function, the function must return
#' a character vector of colors.
#' @param source if bg is a function, source specifies the dataset column to be used
#' as an argument to `bg`. This is only useful when j is colored with values contained in
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
bg <- function(x, i = NULL, j = NULL, bg, part = "body", source = j) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "bg()"))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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
    source <- as_col_keys(x[[part]], source, blanks = x$blanks)
    source_dataset <- x[[part]]$dataset[source]
    source_dataset <- source_dataset[get_rows_id(x[[part]], i), ]
    bg <- data_colors(source_dataset, bg)
  }

  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (length(bg) == length(j)) {
    bg <- rep(bg, each = length(i))
  }

  x[[part]]$styles$cells[["background.color"]]$data[i, j] <- bg

  x
}


data_colors <- function(dataset, fun) {
  out <- tryCatch(
    {
      lbg <- lapply(dataset, fun)
      matrix(unlist(lbg), ncol = length(lbg))
    },
    error = function(cond) {
      msg <- paste0(
        "an error occurred while using color function: ",
        cond$message
      )
      stop(msg, call. = FALSE)
    }
  )
  if (anyNA(out)) {
    stop("colors can not contain missing values")
  }
  return(out)
}


#' @export
#' @title Set vertical alignment
#' @description Change the vertical alignment of selected rows and columns of a flextable.
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
valign <- function(x, i = NULL, j = NULL, valign = "center", part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "valign()"))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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

  x[[part]]$styles$cells[["vertical.align"]]$data[i, j] <- valign

  x
}


#' @export
#' @title Rotate cell text
#' @description It can be useful to change the text direction
#' when table headers are large. For example, header labels can
#' be rendered as "tbrl" (top to bottom and right to left), corresponding
#' to a 90-degree rotation, or "btlr", corresponding to a 270-degree
#' rotation.

#' This function changes cell text direction. By default, it is
#' "lrtb", which means from left to right and top to bottom.
#'
#' 'Word' and 'PowerPoint' do not handle automatic height with rotated headers.
#' Therefore, you need to set header heights (with the [height()] function)
#' and set the rule to "exact" for row heights (with the [hrule()] function);
#' otherwise, Word and PowerPoint outputs will have insufficient height
#' to properly display the text.
#'
#' flextable does not rotate text by arbitrary angles. It only
#' rotates by right angles (90-degree increments). This choice ensures
#' consistent rendering across Word, PowerPoint (limited to angles 0, 270, and 90),
#' HTML, and PDF.
#'
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param rotation one of "lrtb", "tbrl", "btlr".
#' @param align vertical alignment of paragraph within cell,
#' one of "center" or "top" or "bottom".
#' @details
#' When the [autofit()] function is used, rotation will be
#' ignored. In that case, use [dim_pretty] and [width] instead
#' of `autofit()`.
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
rotate <- function(
    x,
    i = NULL,
    j = NULL,
    rotation,
    align = NULL,
    part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "rotate()"))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

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

  x[[part]]$styles$cells[["text.direction"]]$data[i, j] <- rotation
  if (!is.null(align)) {
    x[[part]]$styles$cells[["vertical.align"]]$data[i, j] <- align
  }

  x
}


# misc. ----

#' @title Make blank columns transparent
#' @description Blank columns are set as transparent. This is a shortcut function
#' that deletes top and bottom borders, changes the background color to
#' transparent, displays empty content, and sets blank column widths.
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
empty_blanks <- function(x, width = .05, unit = "in", part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "empty_blanks()"
    ))
  }
  if (length(x$blanks) < 1) {
    return(x)
  }

  x <- border(
    x,
    j = x$blanks,
    border.top = fp_border_default(width = 0),
    border.bottom = fp_border_default(width = 0),
    part = part
  )
  x <- bg(x, j = x$blanks, bg = "transparent", part = part)
  x <- void(x, j = x$blanks, part = part)
  x <- width(x, j = x$blanks, width = width, unit = unit)
  x
}
