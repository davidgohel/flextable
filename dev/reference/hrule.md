# Set how row heights are determined

`hrule()` controls whether row heights are automatic, minimum or fixed.
This only affects Word and PowerPoint outputs; it has no effect on HTML
or PDF.

- `"auto"` (default): the row height adjusts to fit the content; any
  value set by
  [`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md)
  is ignored.

- `"atleast"`: the row is at least as tall as the value set by
  [`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md),
  but can grow if the content is taller.

- `"exact"`: the row is exactly the height set by
  [`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md);
  content that overflows is clipped.

For PDF see the `ft.arraystretch` chunk option.

## Usage

``` r
hrule(x, i = NULL, rule = "auto", part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- rule:

  specify the meaning of the height. Possible values are "atleast"
  (height should be at least the value specified), "exact" (height
  should be exactly the value specified), or the default value "auto"
  (height is determined based on the height of the contents, so the
  value is ignored).

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/dev/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md),
[`fit_columns()`](https://davidgohel.github.io/flextable/dev/reference/fit_columns.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/dev/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md),
[`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md),
[`width()`](https://davidgohel.github.io/flextable/dev/reference/width.md)

## Examples

``` r

ft_1 <- flextable(head(iris))
ft_1 <- width(ft_1, width = 1.5)
ft_1 <- height(ft_1, height = 0.75, part = "header")
ft_1 <- hrule(ft_1, rule = "exact", part = "header")
ft_1


.cl-c3c3399e{}.cl-c3bcd450{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-c3bf8cc2{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c3bf8ccc{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c3bfad42{width:1.5in;height:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3bfad56{width:1.5in;height:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3bfad57{width:1.5in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3bfad60{width:1.5in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3bfad61{width:1.5in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3bfad6a{width:1.5in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
