def_fonts <- if( Sys.info()["sysname"] == "Windows" ){
  "Arial"
} else if( Sys.info()["sysname"] == "Darwin" ){
  "Helvetica"
} else {
  "DejaVu Sans"
}

flextable_global <- new.env(parent = emptyenv())
default_flextable_settings <- list(
  font.family = def_fonts,
  cs.family = def_fonts, eastasia.family = def_fonts, hansi.family = def_fonts,
  font.size = 11, font.color = "black",
  text.align = "left", padding.bottom = 5, padding.top = 5,
  padding.left = 5, padding.right = 5,
  line_spacing = 1,
  border.color = "#666666",
  border.width = .75,

  background.color = "transparent",
  table.layout = "fixed",
  decimal.mark = ".",
  big.mark = ",",
  digits = 1,
  na_str  = "",
  nan_str  = "",
  fmt_date = "%Y-%m-%d", fmt_datetime = "%Y-%m-%d %H:%M:%S",

  extra_css = "",
  scroll = NULL,
  split = TRUE, keep_with_next = FALSE,
  tabcolsep = 0, arraystretch = 1.5, float = "none",

  fonts_ignore = FALSE,

  theme_fun = "theme_booktabs",
  post_process_pdf = function(x) x,
  post_process_docx = function(x) x,
  post_process_html = function(x) x,
  post_process_pptx = function(x) x
)

flextable_global$defaults <- default_flextable_settings


#' @export
#' @title Modify flextable defaults formatting properties
#'
#' @description The current formatting properties (see [get_flextable_defaults()])
#' are automatically applied to every flextable you produce.
#' Use `set_flextable_defaults()` to override them. Use `init_flextable_defaults()`
#' to re-init all values with the package defaults.
#' @param font.family single character value. When format is Word, it specifies the font to
#' be used to format characters in the Unicode range (U+0000-U+007F).
#' @param cs.family optional and only for Word. Font to be used to format
#' characters in a complex script Unicode range. For example, Arabic
#' text might be displayed using the "Arial Unicode MS" font.
#' @param eastasia.family optional and only for Word. Font to be used to
#' format characters in an East Asian Unicode range. For example,
#' Japanese text might be displayed using the "MS Mincho" font.
#' @param hansi.family optional and only for Word. Font to be used to format
#' characters in a Unicode range which does not fall into one of the
#' other categories.
#' @param font.size font size (in point) - 0 or positive integer value.
#' @param font.color font color - a single character value specifying
#' a valid color (e.g. "#000000" or "black").
#' @param text.align text alignment - a single character value, expected value
#' is one of 'left', 'right', 'center', 'justify'.
#' @param padding.bottom,padding.top,padding.left,padding.right paragraph paddings - 0 or
#' positive integer value.
#' @param padding padding (shortcut for top, bottom, left and right padding)
#' @param line_spacing space between lines of text, 1 is single line spacing, 2 is double line spacing.
#' @param border.color border color - single character value
#' (e.g. "#000000" or "black").
#' @param border.width border width in points.
#' @param background.color cell background color - a single character value specifying a
#' valid color (e.g. "#000000" or "black").
#' @param table.layout 'autofit' or 'fixed' algorithm. Default to 'autofit'.
#' @param digits [formatC] argument used by [colformat_double()].
#' @param decimal.mark,big.mark,na_str,nan_str [formatC] arguments used by [colformat_num()],
#' [colformat_double()], and [colformat_int()].
#' @param fmt_date,fmt_datetime formats for date and datetime columns as
#' documented in [strptime()]. Default to '%Y-%m-%d' and '%Y-%m-%d %H:%M:%S'.
#' @param fonts_ignore if TRUE, pdf-engine pdflatex can be used instead of
#' xelatex or lualatex. If pdflatex is used, fonts will be ignored because they are
#' not supported by pdflatex, whereas with the xelatex and lualatex engines they are.
#' @param extra_css css instructions to be integrated with the table.
#' @param scroll NULL or a list if you want to add a scroll-box.
#' See **scroll** element of argument `opts_html` in function [set_table_properties()].
#' @param split Word option 'Allow row to break across pages' can be
#' activated when TRUE.
#' @param keep_with_next Word option 'keep rows together' is
#' activated when TRUE. It avoids page break within tables. This
#' is handy for small tables, i.e. less than a page height.
#' @param tabcolsep space between the text and the left/right border of its containing
#' cell.
#' @param arraystretch height of each row relative to its default
#' height, the default value is 1.5.
#' @param float type of floating placement in the PDF document, one of:
#' * 'none' (the default value), table is placed after the preceding
#' paragraph.
#' * 'float', table can float to a place in the text where it fits best
#' * 'wrap-r', wrap text around the table positioned to the right side of the text
#' * 'wrap-l', wrap text around the table positioned to the left side of the text
#' * 'wrap-i', wrap text around the table positioned inside edge-near the binding
#' * 'wrap-o', wrap text around the table positioned outside edge-far from the binding
#' @param theme_fun a single character value (the name of the theme function
#' to be applied) or a theme function (input is a flextable, output is a flextable).
#' @param post_process_pdf,post_process_docx,post_process_html,post_process_pptx Post-processing functions
#' that will allow you to customize the display by output type (pdf, html, docx, pptx).
#' They are executed just before printing the table.
#' @param ... unused or deprecated arguments
#' @return a list containing previous default values.
#' @examples
#' ft_1 <- qflextable(head(airquality))
#' ft_1
#'
#' old <- set_flextable_defaults(
#'   font.color = "#AA8855",
#'   border.color = "#8855AA")
#' ft_2 <- qflextable(head(airquality))
#' ft_2
#'
#' do.call(set_flextable_defaults, old)
#' @family functions related to themes
#' @importFrom utils modifyList
set_flextable_defaults <- function(
  font.family = NULL,
  font.size = NULL, font.color = NULL,
  text.align = NULL,
  padding = NULL,
  padding.bottom = NULL, padding.top = NULL,
  padding.left = NULL, padding.right = NULL,
  border.color = NULL,
  border.width = NULL,
  background.color = NULL,
  line_spacing = NULL,
  table.layout = NULL,
  cs.family = NULL, eastasia.family = NULL, hansi.family = NULL,
  decimal.mark = NULL, big.mark = NULL, digits = NULL,
  na_str = NULL, nan_str = NULL,
  fmt_date = NULL, fmt_datetime = NULL,
  extra_css = NULL,
  scroll = NULL,
  split = NULL, keep_with_next = NULL,
  tabcolsep = NULL, arraystretch = NULL, float = NULL,
  fonts_ignore = NULL,
  theme_fun = NULL,
  post_process_pdf = NULL,
  post_process_docx = NULL,
  post_process_html = NULL,
  post_process_pptx = NULL,
  ...
  ){

  x <- list()

  if( !is.null(padding) ){
    if( is.null( padding.top) ) padding.top <- padding
    if( is.null( padding.bottom) ) padding.bottom <- padding
    if( is.null( padding.left) ) padding.left <- padding
    if( is.null( padding.right) ) padding.right <- padding
  }

  if( !is.null(font.family) ){
    x$font.family <- font.family
  }
  if( !is.null(cs.family) ){
    x$cs.family <- cs.family
  }
  if( !is.null(eastasia.family) ){
    x$eastasia.family <- eastasia.family
  }
  if( !is.null(hansi.family) ){
    x$hansi.family <- hansi.family
  }

  if( !is.null(font.size) && is.numeric(font.size) && !(font.size<0) ){
    x$font.size <- font.size
  }

  if( !is.null(font.color) ){
    x$font.color <- font.color
  }

  if( !is.null(text.align) && text.align %in% c("left", "right", "center", "justify") ){
    x$text.align <- text.align
  }

  if( !is.null(padding.bottom) && is.numeric(padding.bottom) && !(padding.bottom<0) ){
    x$padding.bottom <- padding.bottom
  }
  if( !is.null(padding.top) && is.numeric(padding.top) && !(padding.top<0) ){
    x$padding.top <- padding.top
  }
  if( !is.null(padding.left) && is.numeric(padding.left) && !(padding.left<0) ){
    x$padding.left <- padding.left
  }
  if( !is.null(padding.right) && is.numeric(padding.right) && !(padding.right<0) ){
    x$padding.right <- padding.right
  }
  if( !is.null(line_spacing) && is.numeric(line_spacing) && !(line_spacing<0) ){
    x$line_spacing <- line_spacing
  }

  if( !is.null(border.color) ){
    x$border.color <- border.color
  }
  if( !is.null(border.width) ){
    x$border.width <- border.width
  }
  if( !is.null(background.color) ){
    x$background.color <- background.color
  }
  if( !is.null(table.layout) ){
    x$table.layout <- table.layout
  }
  if( !is.null(big.mark) ){
    x$big.mark <- big.mark
  }
  if( !is.null(decimal.mark) ){
    x$decimal.mark <- decimal.mark
  }
  if( !is.null(digits) ){
    x$digits <- digits
  }
  if( !is.null(na_str) ){
    x$na_str <- na_str
  }
  if( !is.null(nan_str) ){
    x$nan_str <- nan_str
  }
  if( !is.null(fonts_ignore) ){
    x$fonts_ignore <- fonts_ignore
  }
  if( !is.null(split) ){
    x$split <- split
  }
  if( !is.null(keep_with_next) ){
    x$keep_with_next <- keep_with_next
  }
  if( !is.null(tabcolsep) ){
    x$tabcolsep <- tabcolsep
  }
  if( !is.null(arraystretch) ){
    x$arraystretch <- arraystretch
  }
  if( !is.null(float) ){
    x$float <- float
  }

  if( !is.null(scroll) ){
    x$scroll <- scroll
  }
  if( !is.null(extra_css) ){
    x$extra_css <- extra_css
  }
  if( !is.null(fmt_date) ){
    x$fmt_date <- fmt_date
  }
  if( !is.null(fmt_datetime) ){
    x$fmt_datetime <- fmt_datetime
  }

  if( !is.null(theme_fun) && is.character(theme_fun) && length(theme_fun) == 1 ){
    x$theme_fun <- theme_fun
  }
  if( !is.null(theme_fun) && is.function(theme_fun) ){
    x$theme_fun <- theme_fun
  }

  if( !is.null(post_process_pdf) && is.function(post_process_pdf) ){
    x$post_process_pdf <- post_process_pdf
  }
  if( !is.null(post_process_docx) && is.function(post_process_docx) ){
    x$post_process_docx <- post_process_docx
  }
  if( !is.null(post_process_html) && is.function(post_process_html) ){
    x$post_process_html <- post_process_html
  }
  if( !is.null(post_process_pptx) && is.function(post_process_pptx) ){
    x$post_process_pptx <- post_process_pptx
  }

  flextable_defaults <- flextable_global$defaults

  flextable_new_defaults <- modifyList(flextable_defaults, x)
  flextable_global$defaults <- flextable_new_defaults
  invisible(flextable_defaults)
}

#' @export
#' @rdname set_flextable_defaults
init_flextable_defaults <- function(){
  x <- default_flextable_settings
  flextable_global$defaults <- x
  class(x) <- "flextable_defaults"
  invisible(x)
}


#' @export
#' @title Get flextable defaults formatting properties
#'
#' @description The current formatting properties
#' are automatically applied to every flextable you produce.
#' These default values are returned by this function.
#' @return a list containing default values.
#' @examples
#' get_flextable_defaults()
#' @family functions related to themes
get_flextable_defaults <- function(){
  x <- flextable_global$defaults
  class(x) <- "flextable_defaults"
  x
}

#' @export
print.flextable_defaults <- function(x, ...){

  cat("## style properties\n")
  styles <- c("font.family", "hansi.family", "eastasia.family", "cs.family",
              "font.size", "font.color", "text.align", "padding.bottom",
    "padding.top", "padding.left", "padding.right", "line_spacing",
    "border.color", "border.width",
    "background.color")
  df <- data.frame(property = styles, value = unlist(x[styles]), stringsAsFactors = FALSE)
  row.names(df) <- NULL
  print(df)
  cat("\n")

  cat("## cell content settings\n")
  contents <- c("decimal.mark", "big.mark",
              "digits", "na_str", "nan_str", "fmt_date", "fmt_datetime")
  df <- data.frame(property = contents, value = unlist(x[contents]), stringsAsFactors = FALSE)
  row.names(df) <- NULL
  print(df)
  cat("\n")

  cat("## table.layout is:", x$table.layout, "\n")
  if(is.character(x$theme_fun)) cat("## default theme is:", x$theme_fun, "\n")

  cat("## HTML specific:\n")
  cat("extra_css:", x$extra_css, "\n")
  cat("scrool:", if (is.null(x$scrool)) "no" else "yes", "\n")
  cat("post_process_html:\n")
  print(x$post_process_html)
  cat("\n")

  cat("## latex specific:\n")
  cat("post_process_pdf:\n")
  print(x$post_process_pdf)
  cat("\n")

  cat("## Word specific:\n")
  cat("post_process_docx:\n")
  print(x$post_process_docx)
  cat("\n")

  cat("## PowerPoint specific:\n")
  cat("post_process_pptx:\n")
  print(x$post_process_pptx)
  cat("\n")

  invisible(NULL)
}




#' @export
#' @inheritParams officer::fp_text
#' @title Text formatting properties
#'
#' @description Create a [fp_text()] object that uses
#' defaut values defined in the flextable it applies to.
#'
#' `fp_text_default()` is a handy function that will allow
#' you to specify certain formatting values to be applied
#' to a piece of text, the formatting values that are not
#' specified will simply be the existing formatting values.
#'
#' For example, if you set the text in the cell to red
#' previously, using the code `fp_text_default(bold = TRUE)`,
#' the formatting will be 'bold' but it will also be 'red'.
#'
#' On the other hand, the `fp_text()` function forces you
#' to specify all the parameters, so we strongly recommend
#' working with `fp_text_default()` which was created
#' to replace the use of the former.
#'
#' See also [set_flextable_defaults()] to modify flextable
#' defaults formatting properties.
#' @examples
#' library(flextable)
#'
#' set_flextable_defaults(
#'   font.size = 11, font.color = "#303030",
#'   padding = 3, table.layout = "autofit")
#' z <- flextable(head(cars))
#'
#' z <- compose(
#'   x = z,
#'   i = ~ speed < 6,
#'   j = "speed",
#'   value = as_paragraph(
#'     as_chunk("slow... ", props = fp_text_default(color = "red")),
#'     as_chunk(speed, props = fp_text_default(italic = TRUE))
#'   )
#' )
#' z
#'
#' init_flextable_defaults()
#'
#' @family functions for defining formatting properties
#' @seealso [as_chunk()], [compose()], [append_chunks()], [prepend_chunks()]
fp_text_default <- function(color = flextable_global$defaults$font.color,
                            font.size = flextable_global$defaults$font.size,
                            bold = FALSE,
                            italic = FALSE,
                            underlined = FALSE,
                            font.family = flextable_global$defaults$font.family,
                            cs.family = NULL, eastasia.family = NULL, hansi.family = NULL,
                            vertical.align = "baseline",
                            shading.color = "transparent"){
  fp_text(
    color = color,
    font.size = font.size,
    bold = bold,
    italic = italic,
    underlined = underlined,
    font.family = font.family,
    cs.family = cs.family, eastasia.family = eastasia.family, hansi.family = hansi.family,
    vertical.align = vertical.align,
    shading.color = shading.color
  )

}
#' @export
#' @inheritParams officer::fp_border
#' @title Border formatting properties
#'
#' @description Create a [fp_border()] object that uses
#' defaut values defined in flextable defaults formatting properties, i.e.
#' default border color (see [set_flextable_defaults()]).
#' @examples
#' library(flextable)
#'
#' set_flextable_defaults(
#'   border.color = "orange")
#'
#' z <- flextable(head(cars))
#' z <- theme_vanilla(z)
#' z <- vline(
#'   z, j = 1, part = "all",
#'   border = officer::fp_border())
#' z <- vline(
#'   z, j = 2, part = "all",
#'   border = fp_border_default())
#' z
#'
#' init_flextable_defaults()
#'
#' @family functions for defining formatting properties
#' @seealso [hline()], [vline()]
fp_border_default <- function(
    color = flextable_global$defaults$border.color,
    style = "solid",
    width = flextable_global$defaults$border.width){
  fp_border(
    color = color,
    style = style,
    width = width)

}
