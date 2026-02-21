# Mini plot chunk

This function is used to insert mini plots into flextable with
functions:

- [`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
  and
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md),

- [`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),

- [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).

Available plots are 'box', 'line', 'points', 'density'.

## Usage

``` r
plot_chunk(
  value,
  width = 1,
  height = 0.2,
  type = "box",
  free_scale = FALSE,
  unit = "in",
  ...
)
```

## Arguments

- value:

  a numeric vector, stored in a list column.

- width, height:

  size of the resulting png file in inches

- type:

  type of the plot: 'box', 'line', 'points' or 'density'.

- free_scale:

  Should scales be free (TRUE or FALSE, the default value).

- unit:

  unit for width and height, one of "in", "cm", "mm".

- ...:

  arguments sent to plot functions (see
  [`par()`](https://rdrr.io/r/graphics/par.html))

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format.

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.

## See also

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
[`linerange()`](https://davidgohel.github.io/flextable/dev/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md)

## Examples

``` r
library(data.table)
library(flextable)

z <- as.data.table(iris)
z <- z[, list(
  Sepal.Length = mean(Sepal.Length, na.rm = TRUE),
  z = list(.SD$Sepal.Length)
), by = "Species"]

ft <- flextable(z,
  col_keys = c("Species", "Sepal.Length", "box", "density")
)
ft <- mk_par(ft, j = "box", value = as_paragraph(
  plot_chunk(
    value = z, type = "box",
    border = "red", col = "transparent"
  )
))
ft <- mk_par(ft, j = "density", value = as_paragraph(
  plot_chunk(value = z, type = "dens", col = "red")
))
ft <- set_table_properties(ft, layout = "autofit", width = .6)
ft <- set_header_labels(ft, box = "boxplot", density = "density")
theme_vanilla(ft)


.cl-93574776{table-layout:auto;width:60%;}.cl-9350d26a{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-9350d274{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-9353b05c{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-9353b070{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-9353cf88{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cf92{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cf9c{background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cf9d{background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cf9e{background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cfa6{background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cfa7{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9353cfb0{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Species
```

Sepal.Length

boxplot

density

setosa

5.006

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAoCAYAAAC7HLUcAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAB7CAAAewgFu0HU+AAACAElEQVR4nO3bv4vUQBTA8W/k3OKsFARBwesVBQsLQQQbwcZCUFBr8Q8QCysLQbjSSqy1Ua5RsFUEGws7wUIRwcrK5k44jnsWu4UcO5NhN5sf6/cDIZA3GV5mN8nLbBYkSZIkSZIkSZIkSZKkIlXXCQScBC413O0OsFHBz4b7ldoV8CUgFrBsdH1sGr6VrhMADk3Wr4HfU+IXgaNTtn8GPk3Zvgac/6dfabgCfk2u+CcS8TeJO8R6ov31SfztYjPX/2BfKhBwNuBZwLE2ExqygOMBzwPOdJ2LmpE8QYA7wE3gaku5LINrwA3gdteJqBm5E2Rlz1r1HLMlU/JBjgIOJGK7FfxJ7RjjaeTVmTJbgIARsL+m2VYFkeljlfT0+GjW3DQwAR8Kp1MfZvp4VbD/bhsP6QEXAjYL8nmZOZ71wjF5VzjM6rlciVUqebXtmaHkqR7JlVjfgHPAfeBxok22xAKuUF9ifQcO17SZWwXvAw5SU2JVsJmJ3Qt4QLrEuss4/nXGNNUzJc8g27kvTc6kls/u2+ZlvYJtxss8fWylYjFn3+qfXIm1s2eteo7ZksndQZ4wnpXxnaZyL4DTwNOuE1EzkidIBR+BWy3mMngV/MAxWyp9+kHrUUx/WfFUov3lgCNTtq81l5LUMV93V5/5hylJkiRJkiRJkiRJkiRJmt9fOugd5O+9FAgAAAAASUVORK5CYII=)

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAoCAYAAAC7HLUcAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAB7CAAAewgFu0HU+AAAEdUlEQVR4nO2dX2jVZRjHP2drykwUKZNAybaIypQuulgEUZBKZF2kRFT256YVQXlR9AcqKlOMIrrQSMIKIipYBAZdVHN00cCCIAhKHUbEtKa2NNm05beL3zPO47Ext36/33vOzvOB3ez83vd8z/Y+PH/e531PhQZBcC6wDlgOHAJ6KrA3raogqAMEtwgOCuR+/hFsFLSk1hcEyRA84oxiQPCa4DP3u+2CSmqdQVA6ggecIWwVzHav3WNeRIINKXUGQekIVjsD2PRfXsJ5l5OCFSl0BkHpCDoFf9jif2eiEEpQEXxiz30jaC1baxCUiqBd8J0t+n4fVk3w/IWCYXu+uyydQZAES7ol+F2w+CzHPGpjhgTzi9YYBEkQ3GUL/ZRg5RTGtQl+tLGbi9QYBEkQLBMct0X+/DTG32pjR87W8wRBQyCYL/jJFvjn00m2LWH/yubYUYTOICgdQavgU1vYvwgW/o+5ulyItjxPnUGQBMErLjS6Oof5PnKeKHbYg8alpo3kjpzm7BCM2py35TFnEJSO4F5nHE/lPPeLNu+vgnl5zh0EhSO43/IECV7POxSyzcZ9kbAHDYVVmh53nuONovIEwXXOCO8r4j2CIDcEswVvOeN4tegkWvCca2a8qcj3CoJpI7jEmgnHS7CltKcLWgQfOCPpjspWUDfYAu0W/GWL9LBgdckaZjkjkeBLwTVlagiCMxBcLuhzC7NPsCSRlhbLfUadnn7BnYK2FJqCJkUwT7DFQhpZf9UG1cHZccHFgh1OmwQ/C9ZH6BUUiuAcC6d+c4tvp2Bpam21CBYJnq3RuktwUWptwQzDSrdrVW03l2CPYE1qbZMhmCN4UtUu4iOCVal1BTMAM4xVgm+dYQwpax+ZlVrfVFB2xHe3qtcJPZRaU9DACK4SfOEM45jgBTVwW4ft07ztPtPmyEuCKaHs3MZWt0N9Qtk9VRek1pYH5hWfcUbyniY5Ex8EAAhWKmv+G188H9ZjAp4HynrF/rbP+bXihGIwEVad2uIMY6/ghtS6ikZwo6pXDx0W3B0hV3AagvMFvc44tgnmpNZVFpa8+yLEbqvYNVQRIigAwZWC/S4JX5daUwqU3ZjytCsFj3uUdwW3Cxak1hiUjOBmwVFbDPsEV6TWlBrbXNwoOOAMRYIx22R8MIxlhmNVnCdclWqX4LzUuuoJZZdMXK+sXf+HGmMZUdbSf1lqnUHOCBYIPnb/7Dcj1p4cZf1djwm+d3+7U1bla3rPOyMQrHEl3JMWLkTFZgqY971W1cu0xw3lfcGy1PqCaaLTv4xmj3K4eqfZEawQ9NSEXzuVfaVD3EDfSDiv8XIzlXDLQFlLTo/L6SQYVHYWf61gcXjq+qai7NaPlyowkFrMTEVwKfAwsJ4zK11Hgf3AQeAIcAwYBU4AfwLbKzBUntrAU+nt7d2UWkSz0DI21jp3YGBp++BgZ9vw8JLWkZGFTOJBjnd09B3q6uovSWJQQ7j3hChrhOwkO6i1iMy7zAXaySqII8C2ChxIJrLJ+Rekdq9QUT8tRAAAAABJRU5ErkJggg==)

versicolor

5.936

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAoCAYAAAC7HLUcAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAB7CAAAewgFu0HU+AAACWElEQVR4nO3bsWsUQRTH8e/EiyZGFCwsLLSMf4F2IoKksFERFERtLCRNGrHxPxD/CLXTTsFC0mgkVjY2lopCrEQQURNy57O4EY8jszvJ7jHvzt8HhoXLvndv3zFzu5tbEBERERERERERERERERERERHJEkoXMA4MjgDngU7pWgZ8Bh4F+F26EPnPGTwxMIfjdOneTDpPK6JnB+N2BfiYGTMPHN/i9W/A04b1LACHBuoSKcfgVVyxL2wjZjGx6r9roZ6XMdfFprmk2lTpArZicNbgvsG+0rVIPYMFgwcG+0vX0jaXEwS4DVwHThWuQ/LcAq4BZ0oX0javE6QztBXfJvbz8n5AMwZzib/1AqynAq0/+Wdr8m8E6FbkmAZ2A7tqKy1jT+zPzwCW2sn6fahaDOt6GYC9FfFe+zOZDD5l3OLsGtxIxHcM3mbk+GJwNJHjhMH3of1vbuMYRnmR/mEo57Il/qdlcCejDz2DxUT8lMGbzNvOS02PzRuvp1jSruS3i4whg9W4Il02mEuMmZocUxWxf0flKabBdNzvtdPbvFdifZW/iDCYrelDXS9DTfxKrOdS02Pzxvs1yHqAHzsJjD/B2FHsQI5NYNOg1yTPCG3k9CfAryZvEq9vku/juD+NeT3F6g5txbeJ/by8foPcBd4DLwrXIXnuAWvAculC2uZyggR4Rn/IGAjwnP6YOC4niGNLBucy951PvH7Y4GHDOo41jJdMmiB5vsbtyRZyHQCutpAH/tUlI6IHpjKYzwem1oDHemBKRERERERERERERERERERERMSFPxnFato/9OghAAAAAElFTkSuQmCC)

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAoCAYAAAC7HLUcAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAB7CAAAewgFu0HU+AAAF20lEQVR4nO2dfWjVVRjHP3evTjc1l00nlZZGWYFWpkQE5qIXCsMEjQrCKCsoiIrCoCAKK6t/NKiIiLKo1F40rX9aBZlWKmUviDHDl3JuazHv5tzrtz/Oue3s51Tmfveee+/OB36wXbZ7v/f3e57z9jzPOQkCg0JQBFwOXApMAkqAw8Be4CfglwR0+1MYCHhAMF7wnKBBoBNcLYJ1gjsEY3zrDgyNhG8B2Y7MPboPWA6Mti83A5uBPcBR4DRgKqZXcZ2iA9gAvA18kYCuDMkOBNKPYLTgU6d32C642Q6zBvr7QsEswdOC3yM9S71gheCCTH+PQCB2BBMFO61xHxU8KCgYxP8nBDMFLwsORZzlO8FdgvJ0fodAIC0IJgn+sMZ8UDBriO9XLJhve6Nux1GSglcFM+PSHgikFUGlMzz6U3BOzO8/QfCY44Bur7JYUBzn5wUCsSEYIdhsDXa/YHIaPyshmCt4X9DlOMo+wUNh+BXIKqzBvmeN9F/B9Ax+9gTBU5G5SpNgmaAiUzoCgeMieNwaZpdgricNIwR3R4ZfTYKHBSN8aAoEEFwr6LUGuTQL9BQJbhfsjgy97hQU+tYXGEYIpgiarRG+7luPi3WUJdY5Uo6yU3CdQpA3kG7skGa7NbwfBKW+NQ2E1fmonRulHOVLwWW+tQXyGMEb1tgaBWf51nMyBOMELwk6HEf5UCE6H4gbOxmWoEdQ41vPYBBMFrzjzJt67QrcRb61BfIAwRynFV7mW8+pIrhY8HEk4PiZoCbMUQKnhEwayUFrTB/lgyEJZgjWOD2KBLvs8nCVb32BHEFQLthhDejXfAvCCaYJVsnkeKUcpVuwUXBbvn3fQIzIJAxuskbTIJjiW1O6EFQIlgq+jwy/2mWKuRYJRvnWGcgSZOo0UmkkRwSzfWvKFILzZepTdkecpU3wrg2ShuDjcMUG21arL43kBt+afKC++pTlgrqIs+yXyQWb6FtnIIPYOccGxzlu8a0pG7DOMluwUvCP4yidgrdCXGUYIJgq+NkZe9/kW1M2IigV3Kq+NH83rjLNt75AzAgKBPc4Kzn1gjm+deUCtldx4ypdtpep9K0tEAOCKwVbnAf8jczeVYFBYOMqG5372Cy4N0zmcxA7CZ8v+Mp5oK0yVXnhgQ4BwdXOMFWCHxXq57MfO8mcIXhB8FdkSPCaoNq3xnzBNkAPyGyIlwo8rhCM9K0tEEEw3a7p74osUzYKnhec6VtjviKzDdIHzj2vE8zzrWvYI6gSPBLp6lN7Va0TLFCW1nHkI4Ibbdwk9RzeFIzzrWtYYYdQNdYB3H2kOgXrZcpRR5/8nQLpQCaVZZX6kiMPyeR65XziZ1YjKLNLtL9FeostMrlFoaXKIgRXRJ5VreBC37ryDpnN2p5U/53Tk7aVCkVAWYygRGZ7onZnEr9ScLpvbTmP4Fx7M9scx9hrl2jD0QE5hMzmF26QscU2emEoPBhkIt01gk/Uv8Bnh0zKw4A7pwdyA8E89dXcpDbhe0YhEfLECM62XXF0T9rP7U0NE7w8wTaCi9T/CIgumQ0mrg+NIP/XYMwSPKFjC3cOC15RyBrNa6yjLBB8G3n+jXZ5eGG2z1WG3GrLnJkxHlOhdx5mUn0J5hy/iv5/yteY05bWJKBtqJ8dyB0EM4AlwGKMvbjsArYBO+3Pe4B9CUhmVOQAHOMgMuKXYibJhZjusAQTjCvDlGpWAGMx3n8Gx9+yvwXjFJuA9Qmoj1d+INeww6urMOUH13DiZeFWoBFz5F2L/b0Nc+xdp7267dULbEvA2jj1Jmpra591X6jcunV2eV3doFMIeouLkz1lZc09o0Y1dY4Z03C0qurv9urqBgoKFJ/cQL5RlEyOHHngQHVJc3NVUWvr+KIjRyoLOjrGJnp6TiU7QvsXLnyxt7Q0trMgB+pBqoD7MT1FD+bgyS7MgZTtGA9OYjy6CWgA6hPGmwOBWJAZpUzAjGjGYZaLyzF2WWqvYnsV2mt7AlbHqeM/mGx3y3lRqkgAAAAASUVORK5CYII=)

virginica

6.588

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAoCAYAAAC7HLUcAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAB7CAAAewgFu0HU+AAADpklEQVR4nO3bzYsURxjH8W9FjW6yKnoQBF+iXsRDEBdBVHwjgShECAoaLyJCjvHgUXwD8eYf4EVURBJRBMUcXQgkviZ4UDCHCJpFFEXBuOvbmieHKmEdp3pqZ6a7xt3fB4Zmtuupenp6u7qruxpERERERERERERERERERERERJK43AkMZTAF+BqYB3wOPASuAtcc/Jczt1wMFgDf0Fn76raDC7mTGDUMZhscNxg0sDqfuwbbDcbkzrVqBjcjv0nuz5zcv00VsvdK5nvHn4DJ4U83gT+A58BMYDUwMaz7BfjewbOq88zF4D4wHd9jP0kM68GfeWr1Ab0tprQR6AJ6HPzZYl1SxGCFwZvQI10yWFynzASDnQYvQrleg3E58s3B4H7Y7oXDiDkU6fXPtyGfvlDXolbr+hh8kqthg0nAKWAscAZY6eBabTkHLx0cAlbgzyqrgF0VporBOoOjBt1VtivlMphhcKJex5ydwZ7QE/1l8FlizOYQ028wrewch7TbG9pdX1WbQ9rWGaQkBjvCthyJlclyBjE/9tkavu53MJAY+jNwA39AfVdGbhFja5YyMjTcr7l2+ExgLvAGOJca5PzRfhrfm64BDpeTXtR487ef63nr4GUs0Hxn1NWg/lcOBpvOrlqfFq1sx/aab6PReHPAgRXU0UX8RFC4DdkYLAuntjtNxG4Isb+VkVukzbsJtz0HDX6IxI8xuJFQx2ODL2piO+0Sqz/U9dZgW6TMOEu7Pf3IfGdZr46lBs8T6oh2sAYHEuIL/5eyDdJHoWgv95Fq1/aU+bu0XHeuS6x/wnKGQbfzd6dSzQ/LvjbnVOQeMAvYQrzHil5iOd/b9jAyLrGe4seAyx1crlfA+Vv3X9LC9jr43WAqCZdYsRUOdhscJH4i+BG//u9YHTkPkDv4cch64GRKUBjcbwxfL5aTWqFXDvqbCQxTZZqK7VCvi1a2Y3udb6OwnYQ6XsTWWULdWS6xwqDqWPi6N/U2L7AJfy0+AJwtI7eIwZqljAydu18NJhk8CIOk0wbjG5RfbPBvKL+vojTftb3WMj0o7MBB+kh6DtK5Dwqh6akmF01TTRrF6ABpk6wPvhz8avAtfrLiEuCqwS3gOn7gPgs/teTdZMULwBbnn5+MNgdseJMV61locLzFPKa2GC/DZX66+zHTdPcPJD5PyPHRdPeqmX9h6iv8C1Pd+BemrgDX9cJUR+0rvTAlIiIiIiIiIiIiIiIiIiIiIvK+/wGQaYSHVRNBegAAAABJRU5ErkJggg==)

![](data:image/png;base64,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)
