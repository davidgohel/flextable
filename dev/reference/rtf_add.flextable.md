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

## See also

Other functions for officer integration:
[`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md),
[`body_replace_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/body_replace_flextable_at_bkm.md),
[`ph_with.flextable()`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md)

## Examples

``` r
library(flextable)
library(officer)

ft <- flextable(head(iris))
ft <- autofit(ft)

z <- rtf_doc()
z <- rtf_add(z, ft)

print(z, target = tempfile(fileext = ".rtf"))
#> [1] "/tmp/Rtmp83fftt/file25274aac30f7.rtf"
```
