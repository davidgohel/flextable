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

Other functions for mixed content paragraphs:
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)

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


.cl-f71582f0{}.cl-f70d04b8{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-f70d04c2{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 165, 0, 1.00);background-color:transparent;}.cl-f7118be6{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-f711b0f8{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b102{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b10c{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b10d{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b116{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b117{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b120{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b121{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b12a{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b134{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b135{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b136{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b13e{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b13f{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b140{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b148{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b149{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f711b152{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Ozone
```

Solar.R

Wind

Temp

Month

Day

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

47

10.3
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIHEB2m8m6CvzvWMNeCjeZ8u4A+u0wEAuwwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsIAMwwIyDAvIMCwgw7CADMMCMgwLyDAsIMOwgAzDAjIMC8gwLCDDsICMF8FwA1kx1U7UAAAAAElFTkSuQmCC)

73

6

27

4

25

9.7
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UsQ2AMADAsJY3uY87y9AdsVWR7AsyZa5nrAEf5n26ALbrdADAX4YFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGC85gA1mTIUkuAAAAAElFTkSuQmCC)

61

5

23

80

294

8.6
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UwQ2AIADAQHBN53NOXIGHCam5m6CvzvWMNfi1eZ8ugG9cpwMAdhkWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZL+VgA1nciYs0AAAAAElFTkSuQmCC)

86

7

24

287

9.7
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuklEQVR4nO3UsQ2AMADAsJY3uY87y9AdsVWR7AsyZa5nrAEf5n26ALbrdADAX4YFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWEDGC85gA1mTIUkuAAAAAElFTkSuQmCC)

74

6

2

46

237

6.9
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAAtCAYAAAAUVlZkAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAAAuUlEQVR4nO3UQRHAIADAMJjN6ZtOZoEf9C5R0Ffn+sYaXGO+pwvgXs/pAIBdhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQIZhARmGBWQYFpBhWECGYQEZhgVkGBaQYVhAhmEBGYYFZBgWkGFYQMYPA58DWVhMNSQAAAAASUVORK5CYII=)

78

9

16
