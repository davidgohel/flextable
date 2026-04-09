# Fix border issues when cells are merged

When cells are merged, the rendered borders will be those of the first
cell. If a column is made of three merged cells, the bottom border that
will be seen will be the bottom border of the first cell in the column.
From a user point of view, this is wrong, the bottom should be the one
defined for cell 3. This function modify the border values to avoid that
effect.

Note since version `0.9.7` that the function is called automatically
before rendering, user should not have to call this function anymore.

## Usage

``` r
fix_border_issues(x, part = "all")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Examples

``` r
library(officer)
dat <- data.frame(a = 1:5, b = 6:10)
ft <- flextable(dat)
ft <- theme_box(ft)
ft <- merge_at(ft, i = 4:5, j = 1, part = "body")
ft <- hline(ft,
  i = 5, part = "body",
  border = fp_border(color = "red", width = 5)
)
print(ft)
#> <style></style>
#> <div class="tabwid"><style>.cl-161cf516{}.cl-16163a46{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-16163a64{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-161928a0{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-16194b78{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-16194b82{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-16194b83{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-161cf516'><thead><tr style="overflow-wrap:break-word;"><th class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a46">a</span></p></th><th class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a46">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-16194b82"><p class="cl-161928a0"><span class="cl-16163a64">1</span></p></td><td class="cl-16194b82"><p class="cl-161928a0"><span class="cl-16163a64">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a64">2</span></p></td><td class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a64">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a64">3</span></p></td><td class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a64">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-16194b83"><p class="cl-161928a0"><span class="cl-16163a64">4</span></p></td><td class="cl-16194b78"><p class="cl-161928a0"><span class="cl-16163a64">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-16194b83"><p class="cl-161928a0"><span class="cl-16163a64">10</span></p></td></tr></tbody></table></div>
ft <- fix_border_issues(ft)
print(ft)
#> <style></style>
#> <div class="tabwid"><style>.cl-16299c9e{}.cl-16201d0e{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-16201d22{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1624b634{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1624ed34{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1624ed3e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1624ed48{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-16299c9e'><thead><tr style="overflow-wrap:break-word;"><th class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d0e">a</span></p></th><th class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d0e">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-1624ed3e"><p class="cl-1624b634"><span class="cl-16201d22">1</span></p></td><td class="cl-1624ed3e"><p class="cl-1624b634"><span class="cl-16201d22">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d22">2</span></p></td><td class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d22">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d22">3</span></p></td><td class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d22">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-1624ed48"><p class="cl-1624b634"><span class="cl-16201d22">4</span></p></td><td class="cl-1624ed34"><p class="cl-1624b634"><span class="cl-16201d22">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-1624ed48"><p class="cl-1624b634"><span class="cl-16201d22">10</span></p></td></tr></tbody></table></div>
```
