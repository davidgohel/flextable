# Build a paragraph from chunks

`as_paragraph()` assembles one or more chunks into a single paragraph
that defines the content of a flextable cell. Each cell in a flextable
contains exactly one paragraph; a paragraph is an ordered sequence of
chunks.

Chunks are the smallest content units and can be created with
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)
(formatted text),
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md)
/
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md)
(bold / italic shortcuts),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md)
(inline bar),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md)
(image),
[`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md)
(ggplot),
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md)
(equation) or
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)
(link). Plain character strings passed to `as_paragraph()` are
automatically converted to chunks via
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md).

The resulting paragraph is passed to the `value` argument of
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
or
[`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
to set cell content.

## Usage

``` r
as_paragraph(..., list_values = NULL)
```

## Arguments

- ...:

  chunk elements that are defining the paragraph content. If a character
  is used, it is transformed to a chunk object with function
  [`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md).

- list_values:

  a list of chunk elements that are defining the paragraph content. If
  specified argument `...` is unused.

## See also

[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)

Other functions to compose cell content:
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md),
[`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md),
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md),
[`void()`](https://davidgohel.github.io/flextable/dev/reference/void.md)

## Examples

``` r
library(flextable)
ft <- flextable(airquality[sample.int(150, size = 10), ])
ft <- compose(ft,
  j = "Wind",
  value = as_paragraph(
    as_chunk(Wind, props = fp_text_default(color = "orange")),
    " ",
    minibar(value = Wind, max = max(airquality$Wind), barcol = "orange", bg = "black", height = .15)
  ),
  part = "body"
)
ft <- autofit(ft)
ft


.cl-22a9fefa{}.cl-22a1a228{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-22a1a23c{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 165, 0, 1.00);background-color:transparent;}.cl-22a62e60{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-22a64d14{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-22a64d1e{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-22a64d28{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-22a64d32{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-22a64d33{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-22a64d3c{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Ozone
```

Solar.R

Wind

Temp

Month

Day

39

83

6.9
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuUlEQVR4nO3UQRHAIADAMJjN6ZtOZoEf9C5R0Ffn+sYaXGO+pwvgXs/pAIBdhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQMYPA58DWVhMNSQAAAAASUVORK5CYII=)

81

8

1

64

11.5
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuUlEQVR4nO3UQRHAIADAMJjN6ZtOZoEf9C5R0Ffn+sYacKH5ni7gNs/pAIBdhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQMYPo0ADWWQ6DegAAAAASUVORK5CYII=)

79

8

15

259

10.9
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIGPITV3E/TVuZ6xBnxs3qcL+IPrdADALsMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDjBbXwA1mQ0zMbAAAAAElFTkSuQmCC)

93

6

11

66

4.6
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAu0lEQVR4nO3UwQ2AMBDAsCtrMh9zlg0QvyqSPUFeWfuZPczMzLpPFwBfrtMBAH8ZFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGS8zDwNZL07+5gAAAABJRU5ErkJggg==)

87

8

6

150

6.3
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIGPITV3E/TVuZ6xBp+Y9+kC+JfrdADALsMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDjBRZPA1nPLclcAAAAAElFTkSuQmCC)

77

6

21

59

1.7
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAvElEQVR4nO3UwQmAQBAEwT3TND7jPFPwcSANVQEM8+q1n9lz2LpPLwLMXH8fAPhKsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyHgBdS8DWfubh+UAAAAASUVORK5CYII=)

76

6

22

266

14.9
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIGHCam5m6CvzvWMNYBPzPt0wb9dpwMAdhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZL2KQA1mVwCRjAAAAAElFTkSuQmCC)

58

5

26

35

7.4
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuUlEQVR4nO3UQRHAIADAMJjN6ZtOZoEf9C5R0Ffn+sYaXGu+pwvgHs/pAIBdhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQMYP/dADWQTlQ50AAAAASUVORK5CYII=)

85

8

5

168

238

3.4
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuUlEQVR4nO3UQQ3AIADAQJhN9KGTWdhrpMmdgr46zx5nBM11uwD423M7AOArwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIOMFUT8DWQuTeKgAAAAASUVORK5CYII=)

81

8

25

44

236

14.9
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIGHCam5m6CvzvWMNYBPzPt0wb9dpwMAdhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZL2KQA1mVwCRjAAAAAElFTkSuQmCC)

81

9

11
