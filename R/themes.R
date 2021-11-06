#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply vanilla theme
#' @description Apply theme vanilla to a flextable:
#' The external horizontal lines of the different parts of
#' the table (body, header, footer) are black 2 points thick,
#' the external horizontal lines of the different parts
#' are black 0.5 point thick. Header text is bold,
#' text columns are left aligned, other columns are
#' right aligned.
#' @section behavior:
#' Theme functions are not like 'ggplot2' themes. They are applied to the existing
#' table **immediately**. If you add a row in the footer, the new row is not formatted
#' with the theme. The theme function applies the theme only to existing elements
#' when the function is called.
#'
#' That is why theme functions should be applied after all elements of the table
#' have been added (mainly additionnal header or footer rows).
#'
#' If you want to automatically apply a theme function to each flextable,
#' you can use the `theme_fun` argument of [set_flextable_defaults()]; be
#' aware that this theme function is applied as the last instruction when
#' calling `flextable()` - so if you add headers or footers to the array,
#' they will not be formatted with the theme.
#'
#' You can also use the `post_process_html` argument
#' of [set_flextable_defaults()] (or `post_process_pdf()`,
#' `post_process_docx()`, `post_process_pptx()`) to specify a theme
#' to be applied systematically before the `flextable()` is printed;
#' in this case, don't forget to take care that the theme doesn't
#' override any formatting done before the print statement.
#' @param x a flextable object
#' @family functions related to themes
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_vanilla(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_vanilla_1.png}{options: width=60\%}}
theme_vanilla <- function(x) {
  if (!inherits(x, "flextable")) {
    stop("theme_vanilla supports only flextable objects.")
  }

  std_b <- fp_border(width = 2, color = flextable_global$defaults$border.color)
  thin_b <- fp_border(width = 0.5, color = flextable_global$defaults$border.color)

  x <- border_remove(x)

  x <- hline(x, border = thin_b, part = "all")
  x <- hline_top(x, border = std_b, part = "header")
  x <- hline_bottom(x, border = std_b, part = "header")
  x <- hline_bottom(x, border = std_b, part = "body")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  fix_border_issues(x)
}

#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply box theme
#' @description Apply theme box to a flextable
#' @param x a flextable object
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_box(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_box_1.png}{options: width=60\%}}
theme_box <- function(x) {
  if (!inherits(x, "flextable")) {
    stop("theme_box supports only flextable objects.")
  }

  x <- border_remove(x)

  fp_bdr <- fp_border(
    width = 1,
    color = flextable_global$defaults$border.color
  )

  x <- border_outer(x, part = "all", border = fp_bdr)
  x <- border_inner_h(x, border = fp_bdr, part = "all")
  x <- border_inner_v(x, border = fp_bdr, part = "all")

  x <- bold(x = x, bold = TRUE, part = "header")
  x <- italic(x = x, italic = TRUE, part = "footer")
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  fix_border_issues(x)
}

#' @importFrom officer fp_border fp_par
#' @export
#' @title Apply alafoli theme
#' @description Apply alafoli theme
#' @param x a flextable object
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_alafoli(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_alafoli_1.png}{options: width=60\%}}
theme_alafoli <- function(x) {
  if (!inherits(x, "flextable")) {
    stop("theme_alafoli supports only flextable objects.")
  }

  fp_bdr <- fp_border(
    width = 1,
    color = flextable_global$defaults$border.color
  )

  x <- border_remove(x)
  x <- bg(x, bg = "transparent", part = "all")
  x <- color(x, color = "#666666", part = "all")
  x <- bold(x = x, bold = FALSE, part = "all")
  x <- italic(x = x, italic = FALSE, part = "all")
  x <- padding(x = x, padding = 3, part = "all")

  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  x <- hline_bottom(x, part = "header", border = fp_bdr)
  x <- hline_top(x, part = "body", border = fp_bdr)
  fix_border_issues(x)
}

#' @export
#' @title Apply Sith Lord Darth Vader theme
#' @description Apply Sith Lord Darth Vader theme to a flextable
#' @param x a flextable object
#' @param ... unused
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_vader(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_vader_1.png}{options: width=60\%}}
theme_vader <- function(x, ...) {
  if (!inherits(x, "flextable")) {
    stop("theme_vader supports only flextable objects.")
  }

  x <- border_remove(x)
  x <- bg(x, bg = "#242424", part = "all")
  x <- color(x, color = "#dfdfdf", part = "all")
  x <- bold(x = x, bold = FALSE, part = "all")
  x <- bold(x = x, bold = TRUE, part = "header")
  x <- italic(x = x, italic = FALSE, part = "all")

  big_border <- fp_border(color = "#ff0000", width = 3)

  h_nrow <- nrow_part(x, "header")
  b_nrow <- nrow_part(x, "body")

  if (h_nrow > 0) {
    x <- hline_bottom(x, border = big_border, part = "header")
  }
  if (b_nrow > 0) {
    x <- hline_top(x, border = big_border, part = "body")
  }

  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  fix_border_issues(x)
}

#' @export
#' @title Apply zebra theme
#' @description Apply theme zebra to a flextable
#' @param x a flextable object
#' @param odd_header,odd_body,even_header,even_body odd/even colors for table header and body
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_zebra(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_zebra_1.png}{options: width=60\%}}
theme_zebra <- function(x, odd_header = "#CFCFCF", odd_body = "#EFEFEF",
                        even_header = "transparent", even_body = "transparent") {
  if (!inherits(x, "flextable")) {
    stop("theme_zebra supports only flextable objects.")
  }

  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border_remove(x)
  x <- align(x = x, align = "center", part = "header")

  if (h_nrow > 0) {
    even <- seq_len(h_nrow) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_header, part = "header")
    x <- bg(x = x, i = even, bg = even_header, part = "header")
    x <- bold(x = x, bold = TRUE, part = "header")
  }
  if (f_nrow > 0) {
    even <- seq_len(f_nrow) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_header, part = "footer")
    x <- bg(x = x, i = even, bg = even_header, part = "footer")
    x <- bold(x = x, bold = TRUE, part = "footer")
  }
  if (b_nrow > 0) {
    even <- seq_len(b_nrow) %% 2 == 0
    odd <- !even

    x <- bg(x = x, i = odd, bg = odd_body, part = "body")
    x <- bg(x = x, i = even, bg = even_body, part = "body")
  }
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)

  fix_border_issues(x)
}

#' @export
#' @title Apply tron legacy theme
#' @description Apply theme tron legacy to a flextable
#' @param x a flextable object
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_tron_legacy(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_tron_legacy_1.png}{options: width=60\%}}
theme_tron_legacy <- function(x) {
  if (!inherits(x, "flextable")) {
    stop("theme_tron_legacy supports only flextable objects.")
  }

  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border(
    x = x, border = fp_border(width = 1, color = "#6FC3DF"),
    part = "all"
  )
  x <- align(x = x, align = "right", part = "all")
  x <- bg(x = x, bg = "#0C141F", part = "all")

  if (h_nrow > 0) {
    x <- bold(x = x, bold = TRUE, part = "header")
    x <- color(x = x, color = "#DF740C", part = "header")
  }
  if (f_nrow > 0) {
    x <- color(x = x, color = "#DF740C", part = "footer")
  }
  if (b_nrow > 0) {
    x <- color(x = x, color = "#FFE64D", part = "body")
  }
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)

  fix_border_issues(x)
}

#' @export
#' @title Apply tron theme
#' @description Apply theme tron to a flextable
#' @param x a flextable object
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_tron(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_tron_1.png}{options: width=60\%}}
theme_tron <- function(x) {
  if (!inherits(x, "flextable")) {
    stop("theme_tron supports only flextable objects.")
  }

  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border(
    x = x, border = fp_border(width = 1, color = "#a4cee5"),
    part = "all"
  )
  x <- align(x = x, align = "right", part = "all")
  x <- bg(x = x, bg = "#000000", part = "all")

  if (h_nrow > 0) {
    x <- bold(x = x, bold = TRUE, part = "header")
    x <- color(x = x, color = "#ec9346", part = "header")
  }
  if (f_nrow > 0) {
    x <- color(x = x, color = "#ec9346", part = "footer")
  }
  if (b_nrow > 0) {
    x <- color(x = x, color = "#a4cee5", part = "body")
  }
  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)

  fix_border_issues(x)
}

#' @export
#' @title Apply booktabs theme
#' @description Apply theme booktabs to a flextable
#' @param x a flextable object
#' @param bold_header header will be bold if TRUE.
#' @param ... unused
#' @family functions related to themes
#' @inheritSection theme_vanilla behavior
#' @examples
#' ft <- flextable(head(airquality))
#' ft <- theme_booktabs(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_theme_booktabs_1.png}{options: width=60\%}}
theme_booktabs <- function(x, bold_header = FALSE, ...) {
  if (!inherits(x, "flextable")) {
    stop("theme_booktabs supports only flextable objects.")
  }

  big_border <- fp_border(width = 2, color = flextable_global$defaults$border.color)
  std_border <- update(big_border, width = 1)

  h_nrow <- nrow_part(x, "header")
  f_nrow <- nrow_part(x, "footer")
  b_nrow <- nrow_part(x, "body")

  x <- border_remove(x)

  if (h_nrow > 0) {
    x <- hline_top(x, border = big_border, part = "header")
    x <- hline(x, border = std_border, part = "header")
    x <- hline_bottom(x, border = big_border, part = "header")
    x <- bold(x, bold = bold_header, part = "header")
  }
  if (f_nrow > 0) {
    x <- hline_bottom(x, border = big_border, part = "footer")
  }
  if (b_nrow > 0) {
    x <- hline_bottom(x, border = big_border, part = "body")
  }

  x <- align_text_col(x, align = "left", header = TRUE)
  x <- align_nottext_col(x, align = "right", header = TRUE)
  fix_border_issues(x)
}
