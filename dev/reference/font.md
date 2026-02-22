# Set font

Change the font of selected rows and columns of a flextable.

Fonts impact the readability and aesthetics of the table. Font families
refer to a set of typefaces that share common design features, such as
'Arial' and 'Open Sans'.

'Google Fonts' is a popular library of free web fonts that can be easily
integrated into flextable with the
[`gdtools::register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html)
function. When the output is HTML, the font will be automatically added
to the HTML document.

## Usage

``` r
font(
  x,
  i = NULL,
  j = NULL,
  fontname,
  part = "body",
  cs.family = fontname,
  hansi.family = fontname,
  eastasia.family = fontname
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- fontname:

  single character value, the font family name. With Word and PowerPoint
  output, this value specifies the font to be used for formatting
  characters in the Unicode range (U+0000-U+007F).

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- cs.family:

  Optional font to be used for formatting characters in a complex script
  Unicode range. For example, Arabic text might be displayed using the
  "Arial Unicode MS" font. Used only with Word and PowerPoint outputs.
  The default value is the value of `fontname`.

- hansi.family:

  Optional font to be used for formatting characters in a Unicode range
  that does not fall into one of the other categories. Used only with
  Word and PowerPoint outputs. The default value is the value of
  `fontname`.

- eastasia.family:

  Optional font to be used for formatting characters in an East Asian
  Unicode range. For example, Japanese text might be displayed using the
  "MS Mincho" font. Used only with Word and PowerPoint outputs. The
  default value is the value of `fontname`.

## See also

Other formatting shortcuts:
[`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md),
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/dev/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

## Examples

``` r
library(gdtools)
fontname <- "Brush Script MT"

if (font_family_exists(fontname)) {
  ft_1 <- flextable(head(iris))
  ft_2 <- font(ft_1, fontname = fontname, part = "header")
  ft_2 <- font(ft_2, fontname = fontname, j = 5)
  ft_2
}
```
