# Add a 'flextable' into an RTF document

[`officer::rtf_add()`](https://davidgohel.github.io/officer/reference/rtf_add.html)
method for adding flextable objects into 'RTF' documents.

## Usage

``` r
# S3 method for class 'flextable'
rtf_add(x, value, ...)
```

## Arguments

- x:

  rtf object, created by
  [`officer::rtf_doc()`](https://davidgohel.github.io/officer/reference/rtf_doc.html).

- value:

  a flextable object

- ...:

  unused arguments

## Examples

``` r
library(flextable)
library(officer)

ft <- flextable(head(iris))
ft <- autofit(ft)

z <- rtf_doc()
z <- rtf_add(z, ft)

print(z, target = tempfile(fileext = ".rtf"))
#> [1] "/tmp/Rtmp4M6RrT/file259142ed3cae.rtf"
```
