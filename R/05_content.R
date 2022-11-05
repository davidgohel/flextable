#' @export
#' @title create a chunk representation suitable for flextable
#' @description This function is to be used by external packages
#' that want to provide an object that can be inserted as a chunk
#' object in paragraphs of a flextable object.
#' @param ... values to set.
#' @section  text pattern with default values:
#'
#' ```
#' chunk_dataframe(txt = c("any text", "other text"))
#' ```
#' @section  text pattern with bold set to TRUE:
#'
#' ```
#' chunk_dataframe(
#'   txt = c("any text", "other text"),
#'   bold = c(TRUE, TRUE))
#' ```
#' @section  text pattern with control over all formatting properties:
#'
#' ```
#' chunk_dataframe(
#'   txt = c("any text", "other text"),
#'   font.size = c(12, 10),
#'   italic = c(FALSE, TRUE),
#'   bold = c(FALSE, TRUE),
#'   underlined = c(FALSE, TRUE),
#'   color = c("black", "red"),
#'   shading.color = c("transparent", "yellow"),
#'   font.family = c("Arial", "Arial"),
#'   hansi.family = c("Arial", "Arial"),
#'   eastasia.family = c("Arial", "Arial"),
#'   cs.family = c("Arial", "Arial"),
#'   vertical.align = c("top", "bottom") )
#' ```
#' @section  text with url pattern:
#' ```
#' chunk_dataframe(
#'   txt = c("any text", "other text"),
#'   url = rep("https://www.google.fr", 2),
#'   font.size = c(12, 10),
#'   italic = c(FALSE, TRUE),
#'   bold = c(FALSE, TRUE),
#'   underlined = c(FALSE, TRUE),
#'   color = c("black", "red"),
#'   shading.color = c("transparent", "yellow"),
#'   font.family = c("Arial", "Arial"),
#'   hansi.family = c("Arial", "Arial"),
#'   eastasia.family = c("Arial", "Arial"),
#'   cs.family = c("Arial", "Arial"),
#'   vertical.align = c("top", "bottom") )
#' ```
#' @section  images pattern:
#' ```
#' chunk_dataframe(width = width, height = height, img_data = files )
#' ```
#' @keywords internal
#' @return a data.frame with an additional class "chunk" that makes it
#' suitable for beeing used in [as_paragraph()]
chunk_dataframe <- function(...){
  x <- list(...)

  img_data <- x$img_data
  x$img_data <- NULL
  x <- as.data.frame(x, stringsAsFactors = FALSE)
  def_chr <- rep(NA_character_, nrow(x))
  def_dbl <- rep(NA_real_, nrow(x))
  def_lgl <- as.logical(rep(NA_integer_, nrow(x)))
  def_lst <- rep(list(NULL), nrow(x))
  data0 <- data.frame(
    txt = def_chr,
    font.size = def_dbl,
    italic = def_lgl,
    bold = def_lgl,
    underlined = def_lgl,
    color = def_chr,
    shading.color = def_chr,
    font.family = def_chr,
    hansi.family = def_chr,
    eastasia.family = def_chr,
    cs.family = def_chr,
    vertical.align = def_chr,
    width = def_dbl,
    height = def_dbl,
    url = def_chr,
    eq_data = def_chr,
    word_field_data = def_chr,
    stringsAsFactors = FALSE)
  data0$img_data <- def_lst

  data0[names(x)] <- x
  if( !is.null(img_data))
    data0$img_data <- img_data
  class(data0) <- c("chunk", "data.frame")
  data0
}

default_fptext_prop <- structure(list(
  font.size = NA_real_,
  bold = as.logical(NA_integer_),
  italic = as.logical(NA_integer_),
  underlined = as.logical(NA_integer_),
  color = NA_character_,
  shading.color = NA_character_,
  font.family = NA_character_,
  hansi.family = NA_character_,
  eastasia.family = NA_character_,
  cs.family = NA_character_,
  vertical.align = NA_character_),
  class = "fp_text")


#' @export
#' @title chunk of text wrapper
#' @description The function lets add formated text in flextable
#' cells.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' It should be used inside a call to [as_paragraph()].
#' @param x text or any element that can be formatted as text
#' with function provided in argument `formatter`.
#' @param props an [fp_text_default()] or [officer::fp_text()] object to be used to format the text.
#' If not specified, it will be the default value corresponding to the cell.
#' @param formatter a function that will format x as a character vector.
#' @param ... additional arguments for `formatter` function.
#' @family chunk elements for paragraph
#' @examples
#' library(officer)
#'
#' ft <- flextable( head(iris))
#'
#' ft <- compose( ft, j = "Sepal.Length",
#'  value = as_paragraph(
#'    "Sepal.Length value is ",
#'    as_chunk(Sepal.Length, props = fp_text(color = "red"))
#'  ),
#'  part = "body")
#' ft <- color(ft, color = "gray40", part = "all")
#' ft <- autofit(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_chunk_1.png}{options: width="400"}}
as_chunk <- function(x, props = NULL, formatter = format_fun, ...) {

  if(is.function(x)){
    stop("argument `x` in function `as_chunk` cannot be a function", call. = FALSE)
  }

  text <- formatter(x, ...)

  if( is.null(props) ){
    props <- default_fptext_prop
  }

  if( inherits(props, "fp_text") ){
    props <- rep(list(props), length(text))
  }

  if( length(props) > 0 && is.list(props) ){
    if( !all(sapply(props, inherits, "fp_text")) ){
      stop("`props` should be a list of `fp_text` object(s).")
    }
    if( length(props) != length(text) ){
      stop(sprintf("`props` should be a list of same length than `x`: %.0f.", length(text)))
    }
  }
  data <- chunk_dataframe(txt = text,
                  font.size = sapply(props, function(x) x$font.size),
                  italic = sapply(props, function(x) x$italic),
                  bold = sapply(props, function(x) x$bold),
                  underlined = sapply(props, function(x) x$underlined),
                  color = sapply(props, function(x) x$color),
                  shading.color = sapply(props, function(x) x$shading.color),
                  font.family = sapply(props, function(x) x$font.family),
                  hansi.family = sapply(props, function(x) x$hansi.family),
                  eastasia.family = sapply(props, function(x) x$eastasia.family),
                  cs.family = sapply(props, function(x) x$cs.family),
                  vertical.align = sapply(props, function(x) x$vertical.align) )

  data
}


#' @export
#' @title subscript chunk
#' @description The function is producing a chunk with
#' subscript vertical alignment.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#' @param x value, if a chunk, the chunk will be updated
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris), col_keys = c("dummy") )
#'
#' ft <- compose(ft, i = 1, j = "dummy", part = "header",
#'     value = as_paragraph(
#'       as_sub("Sepal.Length"),
#'       " anything "
#'     ) )
#'
#' ft <- autofit(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_sub_1.png}{options: width="300"}}
as_sub <- function(x){
  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }
  x$vertical.align = "subscript"
  x
}
#' @export
#' @title superscript chunk
#' @description The function is producing a chunk with
#' superscript vertical alignment.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @inheritParams as_sub
#' @note
#' This is a sugar function that ease the composition of complex
#' labels made of different formattings. It should be used inside a
#' call to [as_paragraph()].
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris), col_keys = c("dummy") )
#'
#' ft <- compose(ft, i = 1, j = "dummy", part = "header",
#'     value = as_paragraph(
#'       " anything ",
#'       as_sup("Sepal.Width")
#'     ) )
#'
#' ft <- autofit(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_sup_1.png}{options: width="300"}}
as_sup <- function(x){
  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }
  x$vertical.align = "superscript"
  x
}


#' @export
#' @title bold chunk
#' @description The function is producing a chunk with
#' bold font.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @inheritParams as_sub
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris),
#'   col_keys = c("Sepal.Length", "dummy") )
#'
#' ft <- compose(ft, j = "dummy",
#'     value = as_paragraph(
#'       as_b(Sepal.Length)
#'     ) )
#'
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_b_1.png}{options: width="300"}}
as_b <- function(x){
  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }
  x$bold = TRUE
  x
}

#' @export
#' @title italic chunk
#' @description The function is producing a chunk with
#' italic font.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @inheritParams as_sub
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris),
#'   col_keys = c("Sepal.Length", "dummy") )
#'
#' ft <- compose(ft, j = "dummy",
#'   value = as_paragraph(as_i(Sepal.Length)) )
#'
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_i_1.png}{options: width="300"}}
as_i <- function(x){
  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }
  x$italic = TRUE
  x
}

#' @export
#' @title colorize chunk
#' @description The function is producing a chunk with
#' a font in color.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @param color color to use as text highlighting color as character vector.
#' @inheritParams as_sub
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris),
#'   col_keys = c("Sepal.Length", "dummy") )
#'
#' ft <- compose(ft, j = "dummy",
#'   value = as_paragraph(colorize(Sepal.Length, color = "red")) )
#'
#' ft
colorize <- function(x, color){

  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }

  x$color <- color
  x
}

#' @export
#' @title highlight chunk
#' @description The function is producing a chunk with
#' an highlight chunk.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @param color color to use as text highlighting color as character vector.
#' @inheritParams as_sub
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris),
#'   col_keys = c("Sepal.Length", "dummy") )
#'
#' ft <- compose(ft, j = "dummy",
#'   value = as_paragraph(as_highlight(Sepal.Length, color = "yellow")) )
#'
#' ft
as_highlight <- function(x, color){

  if( !inherits(x, "chunk") ){
    x <- as_chunk(x, formatter = format_fun)
  }
  x$shading.color <- color
  x
}

#' @export
#' @title chunk with values in brackets
#' @description The function is producing a chunk by
#' pasting values and add the result in brackets.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' @param ... text and column names
#' @param sep separator
#' @param p prefix, default to '('
#' @param s suffix, default to ')'
#' @family chunk elements for paragraph
#' @examples
#' ft <- flextable( head(iris),
#'   col_keys = c("Species", "Sepal", "Petal") )
#' ft <- set_header_labels(ft, Sepal="Sepal", Petal="Petal")
#' ft <- compose(ft, j = "Sepal",
#'   value = as_paragraph( as_bracket(Sepal.Length, Sepal.Width) ) )
#' ft <- compose(ft, j = "Petal",
#'   value = as_paragraph( as_bracket(Petal.Length, Petal.Width) ) )
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_bracket_1.png}{options: width="300"}}
as_bracket <- function(..., sep = ", ", p = "(", s = ")"){
  x <- list(...)
  x <- lapply(x, formatC)
  x$sep <- sep
  x <- do.call(paste, x)
  x <- paste0(p, x, s)
  as_chunk(x)
}

#' @export
#' @title Chunk of text with hyperlink
#' @description The function lets add hyperlinks within flextable
#' objects.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' URL are not encoded, they are preserved 'as is'.
#'
#' @note
#' This chunk option requires package officedown in a R Markdown
#' context with Word output format.
#' @inheritParams as_chunk
#' @param url url to be used
#' @seealso [compose()]
#' @examples
#' dat <- data.frame(
#'   col = "Google it",
#'   href = "https://www.google.fr/search?source=hp&q=flextable+R+package",
#'   stringsAsFactors = FALSE)
#'
#' ftab <- flextable(dat)
#' ftab <- compose( x = ftab, j = "col",
#'   value = as_paragraph(
#'     "This is a link: ",
#'     hyperlink_text(x = col, url = href ) ) )
#' ftab
#' @family chunk elements for paragraph
hyperlink_text <- function(x, props = NULL, formatter = format_fun, url, ...){
  zz <- data.frame(x = x, url = url, stringsAsFactors = FALSE)
  x <- as_chunk( x = zz$x, props = props, formatter = formatter, ...)
  x$url <- zz$url
  x
}

#' @export
#' @title equation chunk
#' @description This function is used to insert equations into
#' flextable.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' To use this function, package 'equatags' is required;
#' also `equatags::mathjax_install()` must be executed only once
#' to install necessary dependencies.
#'
#' @param x values containing the 'MathJax' equations
#' @param props an [fp_text_default()] or [officer::fp_text()] object to be used to format the text.
#' If not specified, it will be the default value corresponding to the cell.
#' @param width,height size of the resulting equation
#' @param unit unit for width and height, one of "in", "cm", "mm".
#' @family chunk elements for paragraph
#' @examples
#' library(flextable)
#' if(require("equatags") && mathjax_available()){
#'
#' eqs <- c(
#'   "(ax^2 + bx + c = 0)",
#'   "a \\ne 0",
#'   "x = {-b \\pm \\sqrt{b^2-4ac} \\over 2a}")
#' df <- data.frame(formula = eqs)
#' df
#'
#'
#' ft <- flextable(df)
#' ft <- compose(
#'   x = ft, j = "formula",
#'   value = as_paragraph(as_equation(formula, width = 2, height = .5)))
#' ft <- align(ft, align = "center", part = "all")
#' ft <- width(ft, width = 2)
#' ft
#'
#' }
as_equation <- function(x, width = 1, height = .2, unit = "in", props = NULL){

  width <- convin(unit = unit, x = width)
  height <- convin(unit = unit, x = height)

  if( length(x) > 1 ){
    if( length(width) == 1 ) width <- rep(width, length(x))
    if( length(height) == 1 ) height <- rep(height, length(x))
  }
  if( is.null(props) ){
    props <- default_fptext_prop
  }

  if( inherits(props, "fp_text") ){
    props <- rep(list(props), length(x))
  }

  if( length(props) > 0 && is.list(props) ){
    if( !all(sapply(props, inherits, "fp_text")) ){
      stop("`props` should be a list of `fp_text` object(s).")
    }
    if( length(props) != length(x) ){
      stop(sprintf(
        "`props` should be a list of same length than `x`: %.0f.",
        length(x)))
    }
  }

  x <- chunk_dataframe(width = as.double(width),
                       height = as.double(height),
                       eq_data = x,
                       font.size = sapply(props, function(x) x$font.size),
                       italic = sapply(props, function(x) x$italic),
                       bold = sapply(props, function(x) x$bold),
                       underlined = sapply(props, function(x) x$underlined),
                       color = sapply(props, function(x) x$color),
                       shading.color = sapply(props, function(x) x$shading.color),
                       font.family = sapply(props, function(x) x$font.family),
                       hansi.family = sapply(props, function(x) x$hansi.family),
                       eastasia.family = sapply(props, function(x) x$eastasia.family),
                       cs.family = sapply(props, function(x) x$cs.family),
                       vertical.align = sapply(props, function(x) x$vertical.align) )
  class(x) <- c("chunk", "data.frame")
  x
}


#' @export
#' @title 'Word' computed field
#' @description This function is used to insert
#' 'Word' computed field into flextable.
#'
#' It is used to add it to the content of a cell of the
#' flextable with the functions [compose()], [append_chunks()]
#' or [prepend_chunks()].
#'
#' This has only effect on 'Word' output. If you want to
#' condition its execution only for Word output, you can
#' use it in the post processing step (see
#' `set_flextable_defaults(post_process_docx = ...)`)
#'
#' **Do not forget to update the computed field in Word**.
#' Fields are defined but are not computed, this computing is an
#' operation that has to be made by 'Microsoft Word'
#' (select all text and hit `F9` when on mac os).
#' @param x computed field strings
#' @param props text properties (see [fp_text_default()] or [officer::fp_text()])
#' object to be used to format the text. If not specified, it will use
#' the default text properties of the cell(s).
#' @param width,height size computed field
#' @param unit unit for width and height, one of "in", "cm", "mm".
#' @family chunk elements for paragraph
#' @examples
#' library(flextable)
#'
#' # define some default values ----
#' set_flextable_defaults(font.size = 22, border.color = "gray")
#'
#' # an example with append_chunks ----
#' pp_docx = function(x) {
#'   x <- add_header_lines(x, "Page ")
#'   x <- append_chunks(
#'     x = x, i = 1, part = "header", j = 1,
#'     as_word_field(x = "Page")
#'   )
#'   align(x, part = "header", align = "left")
#' }
#' ft_1 <- flextable(cars)
#' ft_1 <- autofit(ft_1)
#' ft_1 <- pp_docx(ft_1)
#'
#' ## or:
#' # set_flextable_defaults(post_process_docx = pp_docx)
#' ## to prevent this line addition when output is not docx
#'
#' # print(ft_1, preview = "docx")
#'
#' # an example with compose ----
#'
#' library(officer)
#' ft_2 <- flextable(head(cars))
#' ft_2 <- add_footer_lines(ft_2, "temp text")
#' ft_2 <- compose(
#'   x = ft_2, part = "footer", i = 1, j = 1,
#'   as_paragraph("p. ",
#'                as_word_field(x = "Page", width = .05),
#'                " on ", as_word_field(x = "NumPages", width = .05))
#' )
#' ft_2 <- autofit(ft_2, part = c("header", "body"))
#'
#' doc <- read_docx()
#' doc <- body_add_flextable(doc, ft_2)
#' doc <- body_add_break(doc)
#' doc <- body_add_flextable(doc, ft_2)
#' outfile <- print(doc, target = tempfile(fileext = ".docx"))
#'
#' # reset default values ----
#' init_flextable_defaults()
as_word_field <- function(x, props = NULL, width = .1, height = .15, unit = "in"){

  width <- convin(unit = unit, x = width)
  height <- convin(unit = unit, x = height)

  if( is.null(props) ){
    props <- default_fptext_prop
  }

  if( inherits(props, "fp_text") ){
    props <- rep(list(props), length(x))
  }

  if( length(props) > 0 && is.list(props) ){
    if( !all(sapply(props, inherits, "fp_text")) ){
      stop("`props` should be a list of `fp_text` object(s).")
    }
    if( length(props) != length(x) ){
      stop(sprintf(
        "`props` should be a list of same length than `x`: %.0f.",
        length(x)))
    }
  }

  x <- chunk_dataframe(width = as.double(width),
                       height = as.double(height),
                       word_field_data = x,
                       font.size = sapply(props, function(x) x$font.size),
                       italic = sapply(props, function(x) x$italic),
                       bold = sapply(props, function(x) x$bold),
                       underlined = sapply(props, function(x) x$underlined),
                       color = sapply(props, function(x) x$color),
                       shading.color = sapply(props, function(x) x$shading.color),
                       font.family = sapply(props, function(x) x$font.family),
                       hansi.family = sapply(props, function(x) x$hansi.family),
                       eastasia.family = sapply(props, function(x) x$eastasia.family),
                       cs.family = sapply(props, function(x) x$cs.family),
                       vertical.align = sapply(props, function(x) x$vertical.align)
                       )
  class(x) <- c("chunk", "data.frame")
  x
}
to_wml_word_field <- function(x, pr_txt) {

  xml_elt_1 <- paste0(
    "<w:r>",
    pr_txt,
    "<w:fldChar w:fldCharType=\"begin\" w:dirty=\"true\"/>",
    "</w:r>"
  )
  xml_elt_2 <- paste0(
    "<w:r>",
    pr_txt,
    sprintf("<w:instrText xml:space=\"preserve\" w:dirty=\"true\">%s</w:instrText>", x),
    "</w:r>"
  )
  xml_elt_3 <- paste0(
    "<w:r>",
    pr_txt,
    "<w:fldChar w:fldCharType=\"end\" w:dirty=\"true\"/>",
    "</w:r>"
  )
  out <- paste0(xml_elt_1, xml_elt_2, xml_elt_3)

  out
}



#' @export
#' @title concatenate chunks in a flextable
#' @description The function is concatenating text and images within paragraphs of
#' a flextable object, this function is to be used with functions such as [compose()],
#' [add_header_lines()], [add_footer_lines()].
#'
#' This allows the concatenation of formatted pieces of text (chunks) that
#' represent the content of a paragraph.
#'
#' The cells of a flextable contain each a single paragraph. This paragraph
#' is made of chunks that can be text, images or plots, equations and links.
#'
#' @param ... chunk elements that are defining paragraph. If a character is used,
#' it is transformed to a chunk object with function [as_chunk()].
#' @param list_values a list of chunk elements that are defining paragraph. If
#' specified argument `...` is unused.
#' @family functions for mixed content paragraphs
#' @seealso [as_chunk()], [minibar()],
#' [as_image()], [hyperlink_text()]
#' @examples
#' library(flextable)
#' ft <- flextable(airquality[sample.int(150, size = 10), ])
#' ft <- compose(ft,
#'   j = "Wind",
#'   value = as_paragraph(
#'     as_chunk(Wind, props = fp_text_default(color = "orange")),
#'     " ",
#'     minibar(value = Wind, max = max(airquality$Wind), barcol = "orange", bg = "black", height = .15)
#'   ),
#'   part = "body"
#' )
#' ft <- autofit(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_as_paragraph_1.png}{options: width="400"}}
as_paragraph <- function(..., list_values = NULL) {
  if (is.null(list_values)) {
    list_values <- list(...)
  }

  is_atomic <- sapply(list_values, is.atomic)
  if (any(is_atomic)) {
    list_values[is_atomic] <- lapply(list_values[is_atomic], function(x) {
      as_chunk(x, formatter = format_fun)
    })
  }

  if (!all(sapply(list_values, inherits, "chunk"))) {
    stop("argument ... should only contain objects of class 'chunk'.")
  }

  nrows <- sapply(list_values, nrow)
  exp_nrow <- max(nrows)

  id_recycl <- which(nrows == 1)
  if (length(nrows) != 1 && length(id_recycl) > 0) {
    list_values[id_recycl] <- lapply(list_values[id_recycl], function(x, n) {
      z <- rbind.match.columns(rep(list(x), n))
      z
    }, exp_nrow)
  }

  nrows <- sapply(list_values, nrow)

  if (length(unique(nrows)) != 1 && 1 %in% nrows) {
    which_ <- which(nrows %in% 1)
    list_values[which_] <- lapply(list_values[which_], function(x, n) {
      rbind.match.columns(rep(list(x), n))
    }, n = max(nrows, na.rm = TRUE))
  }
  nrows <- sapply(list_values, nrow)

  if (length(unique(nrows)) != 1) {
    stop("paragraph elements should all have the same length")
  }

  data <- mapply(function(x, index) {
    x$seq_index <- rep(index, nrow(x))
    x
  }, list_values, seq_along(list_values), SIMPLIFY = FALSE, USE.NAMES = FALSE)
  data <- rbind.match.columns(data)

  data <- split(data, rep(seq_len(nrow(list_values[[1]])), length((list_values))))
  names(data) <- NULL
  class(data) <- c("paragraph")
  data
}


