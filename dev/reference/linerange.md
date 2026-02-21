# Mini linerange chunk

This function is used to insert lineranges into flextable with
functions:

- [`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
  and
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md),

- [`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),

- [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).

## Usage

``` r
linerange(
  value,
  min = NULL,
  max = NULL,
  rangecol = "#CCCCCC",
  stickcol = "#FF0000",
  bg = "transparent",
  width = 1,
  height = 0.2,
  raster_width = 30,
  unit = "in"
)
```

## Arguments

- value:

  values containing the bar size

- min:

  min bar size. Default min of value

- max:

  max bar size. Default max of value

- rangecol:

  bar color

- stickcol:

  jauge color

- bg:

  background color

- width, height:

  size of the resulting png file in inches

- raster_width:

  number of pixels used as width when interpolating value.

- unit:

  unit for width and height, one of "in", "cm", "mm".

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format.

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.

## See also

[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/dev/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/dev/reference/as_qmd.md),
[`as_strike()`](https://davidgohel.github.io/flextable/dev/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/dev/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/dev/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/dev/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/dev/reference/plot_chunk.md)

## Examples

``` r
myft <- flextable(head(iris, n = 10))

myft <- compose(myft,
  j = 1,
  value = as_paragraph(
    linerange(value = Sepal.Length)
  ),
  part = "body"
)

autofit(myft)


.cl-7226cdc0{}.cl-721deea8{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-7222de86{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-7222de90{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-7222ff24{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff2e{width:1.109in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff2f{width:1.143in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff38{width:1.066in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff39{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff42{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff43{width:1.109in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff44{width:1.143in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff4c{width:1.066in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff4d{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff56{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff57{width:1.109in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff60{width:1.143in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff6a{width:1.066in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7222ff74{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```

Sepal.Width

Petal.Length

Petal.Width

Species

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHklEQVR4nO3duwkDMRBAQZ1xSeq/guvp3MKCP/gdM/EGSvYhUKDjPM9rDey9j8kc3Mm11mg/jrXsxxumHXp8+yAAnyJYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQMZzOjj9ShpuZe/RmP34DTcsIEOwgAzBAjIEC8gQLCBj/Eq49z6+eRD4R9dao9c/+/Ge6SurGxaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAxgtC5heoCnM7iwAAAABJRU5ErkJggg==)

3.5

1.4

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHElEQVR4nO3dsQkDMRAAQcm4JPVfwff0buEM/mDNTHyBgmMRKNC+ruteA+ecPZnjv91rjfZlr2VfGJt26PX0QQB+RbCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CAjPd0cPqVNH/unNGYfeEJblhAhmABGYIFZAgWkCFYQMb4lfCcs588CA33WqPXP/vCN6avym5YQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARkfIv4XqG4B4S0AAAAASUVORK5CYII=)

3.0

1.4

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHUlEQVR4nO3dsQnDMBBAUTlkJO0/gXdyJjAcJC4+ea++QlzxEajQcZ7ntQb23sdk7t9ca432d6xlf3Bj2qHX0wcB+BXBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjLe08HpV9J/Z+/RmP3B99ywgAzBAjIEC8gQLCBDsICM8Svh3vt48iBV11qj1z/7g3vTV3Q3LCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICMDwMWF6hhKDWDAAAAAElFTkSuQmCC)

3.2

1.3

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABI0lEQVR4nO3dwYnEMBAAQfm4kJR/BM7JG8HCwN2yblz1nofm0wj00HGe57UG9t7HZO5brrVGexxr3XoPeKJph34+fRCA/yJYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQMbvdHD6lfTX7D0au/0ewFtuWECGYAEZggVkCBaQIVhAxviVcO99fPIgf3WtNXr9u/se8ETT13s3LCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICMF/MTF6iIN0WGAAAAAElFTkSuQmCC)

3.1

1.5

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHElEQVR4nO3dsQ0DIRAAQd5ySfRfwff07sC6wARrzcQXEJxWSARc930/a2DvfU3m4IRnrdGeXmvZ06Bph16nDwLwK4IFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZLyng9OvpOGIvUdj9vS/uWEBGYIFZAgWkCFYQIZgARnjV8K993XyIPDNs9bo9c+eNk1fd92wgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjI+MvIXqIwggcsAAAAASUVORK5CYII=)

3.6

1.4

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABDklEQVR4nO3dwYkDMRAAQa25kCb/CDandQpjOD8aV73noVczIIGu+76fszAz12YO4FPPOasOvb59EID/IlhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAxt92cPulPcDHZlZjNiwgQ7CADMECMgQLyBAsIGN9Szgz1zcPAvyu55zVKwQbFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWEDGGxehDOB0zqk/AAAAAElFTkSuQmCC)

3.9

1.7

0.4

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABI0lEQVR4nO3dwYnEMBAAQfm4kJR/BM7JG8HCwN2yblz1nofm0wj00HGe57UG9t7HZO5brrVGexxr3XoPeKJph34+fRCA/yJYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQMbvdHD6lfTX7D0au/0ewFtuWECGYAEZggVkCBaQIVhAxviVcO99fPIgf3WtNXr9u/se8ETT13s3LCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICMF/MTF6iIN0WGAAAAAElFTkSuQmCC)

3.4

1.4

0.3

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHElEQVR4nO3dsQ0DIRAAQd5ySfRfwff07sC6wARrzcQXEJxWSARc930/a2DvfU3m4IRnrdGeXmvZ06Bph16nDwLwK4IFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZLyng9OvpOGIvUdj9vS/uWEBGYIFZAgWkCFYQIZgARnjV8K993XyIPDNs9bo9c+eNk1fd92wgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjI+MvIXqIwggcsAAAAASUVORK5CYII=)

3.4

1.5

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABCUlEQVR4nO3dsQ3DMAwAQSn7j8bM5GxgKEBcPHJXs2D1IKBC+1rrWgf2WvtkDuBbM3PUodfTiwD8imABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGfv0q/r3zNO7ANxyYQEZggVkCBaQIVhAhmABGcevhHut/fQywH+amaMOubCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMj4pww+fz22WFQAAAABJRU5ErkJggg==)

2.9

1.4

0.2

setosa

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAA8CAYAAADc3IdaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABHElEQVR4nO3dsQkDMRAAQcm4JPVfwff0buEM/mDNTHyBgmMRKNC+ruteA+ecPZnjv91rjfZlr2VfGJt26PX0QQB+RbCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CAjPd0cPqVNH/unNGYfeEJblhAhmABGYIFZAgWkCFYQMb4lfCcs588CA33WqPXP/vCN6avym5YQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARkfIv4XqG4B4S0AAAAASUVORK5CYII=)

3.1

1.5

0.1

setosa
