# Define displayed values and mixed content

Modify flextable displayed values with eventually mixed content
paragraphs.

Function is handling complex formatting as image insertion with
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
superscript with
[`as_sup()`](https://davidgohel.github.io/flextable/dev/reference/as_sup.md),
formated text with
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)
and several other *chunk* functions.

Function `mk_par` is another name for `compose` as there is an unwanted
**conflict with package 'purrr'**.

If you only need to add some content at the end or the beginning of
paragraphs and keep existing content as it is, functions
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
and
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)
should be prefered.

## Usage

``` r
compose(x, i = NULL, j = NULL, value, part = "body", use_dot = FALSE)

mk_par(x, i = NULL, j = NULL, value, part = "body", use_dot = FALSE)
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
  \<[`flextable column selection`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- value:

  a call to function
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- use_dot:

  by default `use_dot=FALSE`; if `use_dot=TRUE`, `value` is evaluated
  within a data.frame augmented of a column named `.` containing the
  `j`th column.

## See also

[`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md),
[`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md)

Other functions for mixed content paragraphs:
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md),
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)

## Examples

``` r
ft_1 <- flextable(head(cars, n = 5), col_keys = c("speed", "dist", "comment"))
ft_1 <- mk_par(
  x = ft_1, j = "comment",
  i = ~ dist > 9,
  value = as_paragraph(
    colorize(as_i("speed: "), color = "gray"),
    as_sup(sprintf("%.0f", speed))
  )
)
ft_1 <- set_table_properties(ft_1, layout = "autofit")
ft_1


.cl-2d6e15dc{table-layout:auto;}.cl-2d673f1e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2d673f32{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:italic;text-decoration:none;color:rgba(190, 190, 190, 1.00);background-color:transparent;}.cl-2d673f3c{font-family:'DejaVu Sans';font-size:6.6pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;vertical-align:super;}.cl-2d6a3606{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2d6a361a{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2d6a57e4{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2d6a57ee{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2d6a57f8{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2d6a57f9{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2d6a5802{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2d6a5803{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```

dist

4

2

4

10

speed: 4

7

4

7

22

speed: 7

8

16

speed: 8

\# using \`use_dot = TRUE\` ----
[set.seed](https://rdrr.io/r/base/Random.html)(8) dat \<-
iris\[[sample.int](https://rdrr.io/r/base/sample.html)(n = 150, size =
10), \] dat \<-
dat\[[order](https://rdrr.io/r/base/order.html)(dat\$Species), \] ft_2
\<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)(dat)
ft_2 \<- mk_par(ft_2, j = ~ . - Species, value =
[as_paragraph](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)(
[minibar](https://davidgohel.github.io/flextable/dev/reference/minibar.md)(.,
barcol = "white", height = .1 ) ), use_dot = TRUE ) ft_2 \<-
[theme_vader](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md)(ft_2)
ft_2 \<-
[autofit](https://davidgohel.github.io/flextable/dev/reference/autofit.md)(ft_2)
ft_2

| Sepal.Length                                                                                                                                                                                                                                                                                                                                        | Sepal.Width                                                                                                                                                                                                                                                                                                                                         | Petal.Length                                                                                                                                                                                                                                                                                                                                        | Petal.Width                                                                                                                                                                                                                                                                                                                                         | Species    |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cVeCCdguwJ8srs7l7wQzMzpxv41n06AOAtwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CAjAcPjgQ8ENA/yQAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UsQnAQBADQZ/77/lcg4N/WJjJBYp2dncfgMtmZv5u3hNHAE4QLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvI+AAJDgQ8nuhgTQAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiklEQVR4nO3UsQnAQBDAsLvsv/NngkC6xyBN4Mp7zjnDzMzs7t5uAL49twMA/jIsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8h4ARbOBDxZI1kvAAAAAElFTkSuQmCC) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiUlEQVR4nO3UsQ2AQBAEMY7+ez5aIHmhQXYDu9HM7u512MzM6Q3g/+6vDwC8JVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkPEAGW4EPHHePIIAAAAASUVORK5CYII=) | setosa     |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiklEQVR4nO3UsQnAQBDAsLvsv/NngkC6xyBN4Mp7zjkDzMzM7u7tBr49twMA/jIsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8h4AQ6+BDyu89alAAAAAElFTkSuQmCC) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAgElEQVR4nO3UQQ0AIBDAMMC/58MCP7KkVbDX9szMAgg4vwMAXhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWRc5+MEOK3hm+kAAAAASUVORK5CYII=)             | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cVkHicIuwJ8srs7l4/MDNzugH45j4dAPCWYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAxgMXXgQ8WmjLmwAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiUlEQVR4nO3UsQ2AQBAEMY7+ez5aIHmhQXYDu9HM7u512MzM6Q3g/+6vDwC8JVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkPEAGW4EPHHePIIAAAAASUVORK5CYII=) | setosa     |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y80KmBAPICTZrd3Qf4zczM7Yaq93YAwFeGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZBw0uBDw80uUEAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cVEJ9ThD1BXpnd3Qv4lZmZ0w1f3KcDAN4yLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIeAALHgQ8MlZaeQAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cV+KBTkD1BXpnd3Qt+YGbmdAPfuk8HALxlWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQ8QAPzgQ8ZPqKyAAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y80KUIBJAXaNLs7j7ws5mZ2w30vbcDAL4yLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIOBFeBDwsOp1wAAAAAElFTkSuQmCC)     | versicolor |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cV+KBTkD1BXpnd3Qv4lZmZ0w1fuE8HALxlWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQ8QALngQ8SQed6QAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAhklEQVR4nO3UsQ3AMAzAsLr//+zc0A4BBJAPaNPs7j4AH83M3G6+t4MAfxkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQcCg4EPAguZy0AAAAASUVORK5CYII=)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | versicolor |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+0C0RQF6gSbO7+wDXmpk53XCL93QAwF+GBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZHwxuBDxZ5u1oAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cV+KBTkD1BXpnd3Qv4lZmZ0w1fuE8HALxlWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQ8QALngQ8SQed6QAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | versicolor |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiklEQVR4nO3UsQnAQBDAsLvsv/NngkC6xyBN4Mp7zjkDzMzM7u7tBr49twMA/jIsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8h4AQ6+BDyu89alAAAAAElFTkSuQmCC) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cVeCCdguwJ8srs7l7AJ2ZmTjf82X06AOAtwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CAjAcNvgQ8URTrkwAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+/BrMzO3G+DEezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBxLuBDyJF5H5AAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UwQ2AQAzAMMr+O5cV4HWKsCfIK7O7e8FHMzOnG/if+3QAwFuGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZDxIeBDyvLG1gAAAAAElFTkSuQmCC)     | versicolor |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+0C0RQF6gSbO7+wDXmpk53XCL93QAwF+GBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZHwxuBDxZ5u1oAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UsQnAQBADQZ/77/lcg4N/WJjJBYp2dncfgMtmZv5u3hNHAE4QLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvI+AAJDgQ8nuhgTQAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cVEJ9ThD1BXpnd3Qv4ZGbmdMOf3KcDAN4yLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIeAAN/gQ808vU5QAAAABJRU5ErkJggg==) | versicolor |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAgElEQVR4nO3UQQ0AIBDAMMC/58MCP7KkVbDX9szMAgg4vwMAXhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWRc5+MEOK3hm+kAAAAASUVORK5CYII=)             | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y80KmBAPICTZrd3Qf4zczM7Yaq93YAwFeGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZBw0uBDw80uUEAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAgElEQVR4nO3UQQ0AIBDAMMC/58MCP7KkVbDX9szMAgg4vwMAXhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWRc5+MEOK3hm+kAAAAASUVORK5CYII=)             | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAgElEQVR4nO3UQQ0AIBDAMMC/58MCP7KkVbDX9szMAgg4vwMAXhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWRc5+MEOK3hm+kAAAAASUVORK5CYII=)             | virginica  |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UsQnAQBADQZ/77/lcg4N/WJjJBYp2dncfgMtmZv5u3hNHAE4QLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvI+AAJDgQ8nuhgTQAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAhklEQVR4nO3UMQ3AAAzAsHX8OXcU9lWRbAS5Mru7D5AxM3PdcOW9DgD4y7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIOMDDC4EPD+3kacAAAAASUVORK5CYII=)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UsQ2AQAzAQML+O4eWgoLuZeluAlee3d0L4GVm5nTDl/t0AMBfhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGQ8KngQ8LBFjGwAAAABJRU5ErkJggg==) | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAiElEQVR4nO3UwQ2AQAzAMMr+O5cV+KBTkD1BXpnd3Qv4lZmZ0w1fuE8HALxlWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQ8QALngQ8SQed6QAAAABJRU5ErkJggg==) | virginica  |
| ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y80KmBAPICTZrd3QdIm5m53fCH93YAwFeGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZBwveBDyMkRJ6AAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAhklEQVR4nO3UMQ3AAAzAsHX8OXcU9lWRbAS5Mru7D5AxM3PdcOW9DgD4y7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIOMDDC4EPD+3kacAAAAASUVORK5CYII=)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y80KmBAPICTZrd3Qf4zczM7Yaq93YAwFeGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZBw0uBDw80uUEAAAAAElFTkSuQmCC)     | ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAeCAYAAACWuCNnAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAh0lEQVR4nO3UsQ3AMAzAsLr//+y+kC0QSl6gSbO7+8BPzczcbuDcezsA4JRhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGBw7+BDxba1tQAAAAAElFTkSuQmCC)     | virginica  |
