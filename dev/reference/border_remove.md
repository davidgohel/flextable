# Remove borders

The function is deleting all borders of the flextable object.

## Usage

``` r
border_remove(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## See also

Other borders management:
[`border_inner()`](https://davidgohel.github.io/flextable/dev/reference/border_inner.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_h.md),
[`border_inner_v()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_v.md),
[`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md),
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/dev/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md),
[`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)

## Examples

``` r
dat <- iris[c(1:5, 51:55, 101:105), ]
ft_1 <- flextable(dat)
ft_1 <- theme_box(ft_1)
ft_1


.cl-1cf9a9ce{}.cl-1cf2602e{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1cf26042{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1cf5656c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1cf56576{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1cf587b8{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1cf587c2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1cf587c3{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1cf587cc{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```

Sepal.Width

Petal.Length

Petal.Width

Species

5.1

3.5

1.4

0.2

setosa

4.9

3.0

1.4

0.2

setosa

4.7

3.2

1.3

0.2

setosa

4.6

3.1

1.5

0.2

setosa

5.0

3.6

1.4

0.2

setosa

7.0

3.2

4.7

1.4

versicolor

6.4

3.2

4.5

1.5

versicolor

6.9

3.1

4.9

1.5

versicolor

5.5

2.3

4.0

1.3

versicolor

6.5

2.8

4.6

1.5

versicolor

6.3

3.3

6.0

2.5

virginica

5.8

2.7

5.1

1.9

virginica

7.1

3.0

5.9

2.1

virginica

6.3

2.9

5.6

1.8

virginica

6.5

3.0

5.8

2.2

virginica

\# remove all borders ft_2 \<- border_remove(x = ft_1) ft_2

| Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species    |
|--------------|-------------|--------------|-------------|------------|
| 5.1          | 3.5         | 1.4          | 0.2         | setosa     |
| 4.9          | 3.0         | 1.4          | 0.2         | setosa     |
| 4.7          | 3.2         | 1.3          | 0.2         | setosa     |
| 4.6          | 3.1         | 1.5          | 0.2         | setosa     |
| 5.0          | 3.6         | 1.4          | 0.2         | setosa     |
| 7.0          | 3.2         | 4.7          | 1.4         | versicolor |
| 6.4          | 3.2         | 4.5          | 1.5         | versicolor |
| 6.9          | 3.1         | 4.9          | 1.5         | versicolor |
| 5.5          | 2.3         | 4.0          | 1.3         | versicolor |
| 6.5          | 2.8         | 4.6          | 1.5         | versicolor |
| 6.3          | 3.3         | 6.0          | 2.5         | virginica  |
| 5.8          | 2.7         | 5.1          | 1.9         | virginica  |
| 7.1          | 3.0         | 5.9          | 2.1         | virginica  |
| 6.3          | 2.9         | 5.6          | 1.8         | virginica  |
| 6.5          | 3.0         | 5.8          | 2.2         | virginica  |
