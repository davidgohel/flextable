# Save flextable objects in a Typst file

Writes one or more flextables to a standalone Typst (`.typ`) document.
Images are embedded as base64 (decoded inline at compile time), so the
file is self-contained and compiles offline with `typst compile`.
Equations require the `mitex` Typst package, which is fetched from the
Typst package registry on first compilation.

## Usage

``` r
save_as_typst(
  ...,
  values = NULL,
  path,
  page = "#set page(width: auto, height: auto, margin: 12pt)"
)
```

## Arguments

- ...:

  flextable objects, possibly named.

- values:

  a list of flextable objects. If provided, `...` is ignored.

- path:

  Typst file to be created.

- page:

  a Typst `#set page(...)` rule used as document setup. The default
  produces a tightly cropped page fitting the table(s).

## Value

the path to the generated file, invisibly.

## Examples

``` r
ft <- flextable(head(iris))
tf <- tempfile(fileext = ".typ")
save_as_typst(ft, path = tf)
```
