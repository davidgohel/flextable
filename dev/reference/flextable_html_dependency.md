# htmlDependency for flextable objects

When using loops in an R Markdown for HTML document, the htmlDependency
object for flextable must also be added at least once.

## Usage

``` r
flextable_html_dependency()
```

## Examples

``` r
if (require("htmltools")) {
  div(flextable_html_dependency())
}
#> Loading required package: htmltools
#> <div></div>
```
