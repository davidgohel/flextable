# Arrange pieces of text into lines

Give the line of each piece of a text, from their widths, for a maximum
width. This is the part shared by
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
and the packages that draw rich text with 'grid'.

A piece that makes the line too wide goes to the next line, except if it
is the first of its line. Spaces are dropped when they do not fit and at
the start of a line that follows an automatic line break; they are kept
after a line break of the text, as they were written. A line break ends
its line, and gives a line of its own if that line is empty.

## Usage

``` r
layout_lines(width, newline, space, max_width, first_line = 0, hanging = 0)
```

## Arguments

- width:

  widths of the pieces.

- newline, space:

  logical vectors, `TRUE` for the line breaks and the spaces.

- max_width:

  maximum width of a line, `Inf` for no automatic line break.

- first_line, hanging:

  width removed from the first line, and from the other lines.

## Value

An integer vector, the line of each piece, `0` for the dropped pieces.

## Examples

``` r
layout_lines(
  width = c(2, 1, 2, 1, 3),
  newline = rep(FALSE, 5),
  space = c(FALSE, TRUE, FALSE, TRUE, FALSE),
  max_width = 5
)
#> [1] 1 1 1 0 2
```
