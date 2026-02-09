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
#> <div class="tabwid"><style>.cl-cc134436{}.cl-cc0cc2aa{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-cc0cc2be{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-cc0f8fda{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-cc0fb1a4{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-cc0fb1ae{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-cc0fb1b8{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-cc134436'><thead><tr style="overflow-wrap:break-word;"><th class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2aa">a</span></p></th><th class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2aa">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-cc0fb1ae"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">1</span></p></td><td class="cl-cc0fb1ae"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">2</span></p></td><td class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">3</span></p></td><td class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-cc0fb1b8"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">4</span></p></td><td class="cl-cc0fb1a4"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc0fb1b8"><p class="cl-cc0f8fda"><span class="cl-cc0cc2be">10</span></p></td></tr></tbody></table></div>
ft <- fix_border_issues(ft)
print(ft)
#> <style></style>
#> <div class="tabwid"><style>.cl-cc1ea66e{}.cl-cc165d2e{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-cc165d42{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-cc19160e{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-cc1936de{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-cc1936e8{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-cc1936f2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 5pt solid rgba(255, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-cc1ea66e'><thead><tr style="overflow-wrap:break-word;"><th class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d2e">a</span></p></th><th class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d2e">b</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-cc1936e8"><p class="cl-cc19160e"><span class="cl-cc165d42">1</span></p></td><td class="cl-cc1936e8"><p class="cl-cc19160e"><span class="cl-cc165d42">6</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d42">2</span></p></td><td class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d42">7</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d42">3</span></p></td><td class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d42">8</span></p></td></tr><tr style="overflow-wrap:break-word;"><td  rowspan="2"class="cl-cc1936f2"><p class="cl-cc19160e"><span class="cl-cc165d42">4</span></p></td><td class="cl-cc1936de"><p class="cl-cc19160e"><span class="cl-cc165d42">9</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-cc1936f2"><p class="cl-cc19160e"><span class="cl-cc165d42">10</span></p></td></tr></tbody></table></div>
```
