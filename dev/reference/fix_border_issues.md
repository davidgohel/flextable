# Fix border issues when cell are merged

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
#> <div class="tabwid"><style>.cl-90da8542{}.cl-90d3261c{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-90d32626{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-90d5d3c6{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-90d5f630{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-90d5f644{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-90d5f645{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-90da8542'><thead><tr style="overflow-wrap:break-word;"><th class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d3261c">a</span></p></th><th class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d3261c">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-90d5f644"><p class="cl-90d5d3c6"><span class="cl-90d32626">1</span></p></td><td class="cl-90d5f644"><p class="cl-90d5d3c6"><span class="cl-90d32626">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d32626">2</span></p></td><td class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d32626">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d32626">3</span></p></td><td class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d32626">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-90d5f645"><p class="cl-90d5d3c6"><span class="cl-90d32626">4</span></p></td><td class="cl-90d5f630"><p class="cl-90d5d3c6"><span class="cl-90d32626">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90d5f645"><p class="cl-90d5d3c6"><span class="cl-90d32626">10</span></p></td></tr></tbody></table></div>
ft <- fix_border_issues(ft)
print(ft)
#> <style></style>
#> <div class="tabwid"><style>.cl-90e4705c{}.cl-90de22e2{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-90de22ec{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-90e0ecac{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-90e1101a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-90e11024{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-90e1102e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-90e4705c'><thead><tr style="overflow-wrap:break-word;"><th class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22e2">a</span></p></th><th class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22e2">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-90e11024"><p class="cl-90e0ecac"><span class="cl-90de22ec">1</span></p></td><td class="cl-90e11024"><p class="cl-90e0ecac"><span class="cl-90de22ec">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22ec">2</span></p></td><td class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22ec">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22ec">3</span></p></td><td class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22ec">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-90e1102e"><p class="cl-90e0ecac"><span class="cl-90de22ec">4</span></p></td><td class="cl-90e1101a"><p class="cl-90e0ecac"><span class="cl-90de22ec">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-90e1102e"><p class="cl-90e0ecac"><span class="cl-90de22ec">10</span></p></td></tr></tbody></table></div>
```
