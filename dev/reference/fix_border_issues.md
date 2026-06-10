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
#> <div class="tabwid"><style>.cl-97c13ac6{}.cl-97b89736{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-97b89740{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-97bd0d2a{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-97bd3a84{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-97bd3a8e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-97bd3a98{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-97c13ac6'><thead><tr style="overflow-wrap:break-word;"><th class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89736">a</span></p></th><th class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89736">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-97bd3a8e"><p class="cl-97bd0d2a"><span class="cl-97b89740">1</span></p></td><td class="cl-97bd3a8e"><p class="cl-97bd0d2a"><span class="cl-97b89740">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89740">2</span></p></td><td class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89740">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89740">3</span></p></td><td class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89740">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-97bd3a98"><p class="cl-97bd0d2a"><span class="cl-97b89740">4</span></p></td><td class="cl-97bd3a84"><p class="cl-97bd0d2a"><span class="cl-97b89740">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97bd3a98"><p class="cl-97bd0d2a"><span class="cl-97b89740">10</span></p></td></tr></tbody></table></div>
ft <- fix_border_issues(ft)
print(ft)
#> <style></style>
#> <div class="tabwid"><style>.cl-97cac4e2{}.cl-97c45ef4{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-97c45f08{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-97c72c7e{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-97c74d30{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-97c74d3a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-97c74d44{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-97cac4e2'><thead><tr style="overflow-wrap:break-word;"><th class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45ef4">a</span></p></th><th class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45ef4">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-97c74d3a"><p class="cl-97c72c7e"><span class="cl-97c45f08">1</span></p></td><td class="cl-97c74d3a"><p class="cl-97c72c7e"><span class="cl-97c45f08">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45f08">2</span></p></td><td class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45f08">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45f08">3</span></p></td><td class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45f08">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-97c74d44"><p class="cl-97c72c7e"><span class="cl-97c45f08">4</span></p></td><td class="cl-97c74d30"><p class="cl-97c72c7e"><span class="cl-97c45f08">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-97c74d44"><p class="cl-97c72c7e"><span class="cl-97c45f08">10</span></p></td></tr></tbody></table></div>
```
