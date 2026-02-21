# Merge flextable cells horizontally

Merge flextable cells horizontally when consecutive cells have identical
values. Text of formatted values are used to compare values.

## Usage

``` r
merge_h(x, i = NULL, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' is not allowed by the function.

## See also

Other flextable merging function:
[`merge_at()`](https://davidgohel.github.io/flextable/dev/reference/merge_at.md),
[`merge_h_range()`](https://davidgohel.github.io/flextable/dev/reference/merge_h_range.md),
[`merge_none()`](https://davidgohel.github.io/flextable/dev/reference/merge_none.md),
[`merge_v()`](https://davidgohel.github.io/flextable/dev/reference/merge_v.md)

## Examples

``` r
library(flextable)

schedule <- data.frame(
  time = c("9h", "10h", "11h", "14h", "15h", "16h"),
  monday = c("Math", "Math", "French", "History", "Science", "French"),
  tuesday = c("English", "Math", "Art", "Math", "Math", "French"),
  wednesday = c("Science", "Math", "Science", "English", "English", "French"),
  stringsAsFactors = FALSE
)

ft <- flextable(schedule)
ft <- theme_box(ft)
ft <- merge_h(ft)
ft


.cl-8f021b1a{}.cl-8efba7a8{font-family:'Liberation Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-8efba7b2{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-8efe60ec{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8efe8194{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8efe819e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


time
```

monday

tuesday

wednesday

9h

Math

English

Science

10h

Math

11h

French

Art

Science

14h

History

Math

English

15h

Science

Math

English

16h

French
