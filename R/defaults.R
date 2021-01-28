def_fonts <- if( Sys.info()["sysname"] == "Windows" ){
  "Arial"
} else if( Sys.info()["sysname"] == "Darwin" ){
  "Helvetica"
} else {
  "DejaVu Sans"
}

flextable_global <- new.env(parent = emptyenv())
default_flextable_settings <- list(
  font.family = def_fonts, font.size = 11, font.color = "black",
  text.align = "left", padding.bottom = 5, padding.top = 5,
  padding.left = 5, padding.right = 5,
  border.color = "#666666",
  background.color = "transparent",
  table.layout = "fixed",
  decimal.mark = ".",
  big.mark = ",",
  digits = 1,
  na_str  = "",
  fmt_date = "%Y-%m-%d", fmt_datetime = "%Y-%m-%d %H:%M:%S",
  fonts_ignore = FALSE,
  extra_css = "caption {color: #777;margin-top: 10px;margin-bottom: 10px;text-align: center;}",
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
#' @param font.family single character value specifying font name.
#' @param font.size font size (in point) - 0 or positive integer value.
#' @param font.color font color - a single character value specifying
#' a valid color (e.g. "#000000" or "black").
#' @param text.align text alignment - a single character value, expected value
#' is one of 'left', 'right', 'center', 'justify'.
#' @param padding.bottom,padding.top,padding.left,padding.right paragraph paddings - 0 or
#' positive integer value.
#' @param border.color border color - single character value
#' (e.g. "#000000" or "black").
#' @param background.color cell background color - a single character value specifying a
#' valid color (e.g. "#000000" or "black").
#' @param table.layout 'autofit' or 'fixed' algorithm. Default to 'autofit'.
#' @param decimal.mark,big.mark,digits,na_str [formatC] arguments used by [colformat_num()]
#' and [colformat_int()].
#' @param fmt_date,fmt_datetime formats for date and datetime columns as
#' documented in [strptime()]. Default to '%Y-%m-%d' and '%Y-%m-%d %H:%M:%S'.
#' @param fonts_ignore if TRUE, pdf-engine pdflatex can be used instead of
#' xelatex or lualatex. If pdflatex is used, fonts will be ignored because they are
#' not supported by pdflatex, whereas with the xelatex and lualatex engines they are.
#' @param extra_css css instructions to be integrated with the table. By default, it
#' contains only the style for captions.
#' @param theme_fun a single character value (the name of the theme function
#' to be applied) or a theme function (input is a flextable, output is a flextable).
#' @param post_process_pdf,post_process_docx,post_process_html,post_process_pptx Post-processing functions
#' that will allow you to customize the display by output type (pdf, html, docx, pptx).
#' They are executed just before printing the table.
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
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_flextable_defaults_1.png}{options: width=50\%}}
#'
#' \if{html}{\figure{fig_set_flextable_defaults_2.png}{options: width=50\%}}
set_flextable_defaults <- function(
  font.family = NULL, font.size = NULL, font.color = NULL,
  text.align = NULL, padding.bottom = NULL, padding.top = NULL,
  padding.left = NULL, padding.right = NULL,
  border.color = NULL, background.color = NULL,
  table.layout = NULL,
  decimal.mark = NULL, big.mark = NULL, digits = NULL, na_str = NULL,
  fmt_date = NULL, fmt_datetime = NULL, extra_css = NULL,
  fonts_ignore = NULL, theme_fun = NULL,
  post_process_pdf = NULL,
  post_process_docx = NULL,
  post_process_html = NULL,
  post_process_pptx = NULL
  ){

  x <- list()

  if( !is.null(font.family) ){
    x$font.family <- font.family
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

  if( !is.null(border.color) ){
    x$border.color <- border.color
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
  if( !is.null(fonts_ignore) ){
    x$fonts_ignore <- fonts_ignore
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

  message("## style properties\n")
  styles <- c("font.family", "font.size", "font.color", "text.align", "padding.bottom",
    "padding.top", "padding.left", "padding.right", "border.color",
    "background.color")
  df <- data.frame(property = styles, value = unlist(x[styles]), stringsAsFactors = FALSE)
  row.names(df) <- NULL
  print(df)
  message("")

  message("## cell content settings\n")
  contents <- c("decimal.mark", "big.mark",
              "digits", "na_str", "fmt_date", "fmt_datetime")
  df <- data.frame(property = contents, value = unlist(x[contents]), stringsAsFactors = FALSE)
  row.names(df) <- NULL
  print(df)
  message("")

  message("## table.layout is:", x$table.layout, "\n")
  message("## default theme is:", x$theme_fun, "\n")

  message("## HTML specific:")
  message("extra_css:", x$extra_css)
  message("post_process_html:")
  print(x$post_process_html)
  message("")

  message("## latex specific:")
  message("post_process_pdf:")
  print(x$post_process_pdf)
  message("")

  message("## Word specific:")
  message("post_process_docx:")
  print(x$post_process_docx)
  message("")

  message("## PowerPoint specific:")
  message("post_process_pptx:")
  print(x$post_process_pptx)
  message("")

  invisible(NULL)
}




#' @export
#' @inheritParams officer::fp_text
#' @title Text formatting properties
#'
#' @description Create a [fp_text()] object that uses
#' defaut values defined in flextable defaults formatting properties, i.e.
#' default font color, font size and font family (see [set_flextable_defaults()]).
#' (see [set_flextable_defaults()]).
#' @examples
#' fp_text_default(bold = TRUE)
#' @family functions for defining formatting properties
#' @seealso [as_chunk()]
fp_text_default <- function(color = flextable_global$defaults$font.color,
                            font.size = flextable_global$defaults$font.size,
                            bold = FALSE,
                            italic = FALSE,
                            underlined = FALSE,
                            font.family = flextable_global$defaults$font.family,
                            vertical.align = "baseline",
                            shading.color = "transparent"){
  fp_text(
    color = color,
    font.size = font.size,
    bold = bold,
    italic = italic,
    underlined = underlined,
    font.family = font.family,
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
#' fp_border_default(width = 2)
#' @family functions for defining formatting properties
#' @seealso [hline()], [vline()]
fp_border_default <- function(color = flextable_global$defaults$border.color,
                              style = "solid", width = 1){
  fp_border(
    color = color,
    style = style,
    width = width)

}

