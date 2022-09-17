# flextable 0.8.1

## Issues

- fix warning with subscript and superscript #456
- prevent usage of gregexec if R < 4.1
- fix for rdocx captions

# flextable 0.8.0

## new features

- flextable now supports "Grid graphics" output format. See `gen_grob()`.
- `labelizor()` is a new function to help change text by labels. 
- add support for paragraph settings (made with `fp_par()`) in captions with `set_caption()`.
- captions are now made with `as_paragraph()`
- caption alignments and keep_with_next is now computed instead of being provided by user
- alternative text for Word tables with word_title and word_description 
by calling `set_table_properties()` or setting values to knitr chunk options `tab.alt.title` and `tab.alt.description`.
- Word and HTML captions paragraphs settings can be defined by using `set_caption()`. 
The alignment of the paragraph can be different from the alignment of the table 
with the argument `align_with_table=FALSE`.
- new theme 'APA', `theme_apa` (@rempsyc #426)
- method `as_flextable.tabulator()` gains an argument `spread_first_col` to enable 
spreading of the first column of the table as a line separator.


## Issues

- fix caption issue resulting from a clash with variable name 'n' (#443)
- Quarto support
- fix as_grouped_data() with date columns (#438)
- fix footnotes spread over separate lines when 'inline' (#442)
- fix missing caption with rmarkdown pdf output
- fix first horizontal borders repeated issue with Word output
- add empty paragraphs between tables in `save_as_docx()` to avoid Word confusion
- fix `fortify_width()` calculation



# flextable 0.7.3

## new features

- function `as_flextable.tabulator()` gained an argument `label_rows` used for 
labels to display in the first column names, i.e. the *row* column names.
- new function `shift_table()` to produce Shift Tables used used in 
clinical trial analysis ready to be used by `tabulator()`.
- `as_image()` don't need anymore parameters `width` and 
`height` if package 'magick' is available.

## Changes

- `plot.flextable` now default to *grid Graphics*. It produce a plot object 
that can be used with packages 'ggplot2', 'patchwork' and 'cowplot'. The raster 
version made with 'webshot' and 'magick' pachages is still available, use `plot(..., method = "webshot")`. 


## Issues

- fix top borders correction (for docx and pptx)
- check that used colors do not contain NA
- fix HTML scrolling that is always visible to Windows users
- fix "cs.family", "hansi.family" and "eastasia.family" for Word
- fix anti-selectors for bg/color/highlight, a regression from version 0.7.2
- when HTML and layout "autofit", output width is not set when width has been 
defined to 0 to avoid unnecessary word breaks (#429).


## Changes

- pptx output is constructed with top and bottom margins whose value is 
  top and bottom padding of the paragraph and there is no more borders copies 
  while rendering. 
- add visual tests with doconv
- footnote can not be used with "" symbols, use `add_footer_lines()` instead.

# flextable 0.7.2

## Issues

- fix selector issue with numeric values (#409)


# flextable 0.7.1

## new features

* function `as_flextable()` has now methods for 
lm, glm, models from package 'lme' and 'lme4',
htest (t.test, chisq.test, ...), gam, kmeans and pam.
* new function `use_model_printer()` to set model automatic 
printing as a flextable in an R Markdown document.
* new function `add_body_row()` to add a row in the body part 
with eventually merged/spanned columns.  
* new function `tabulator_colnames()` to get column names 
of a `tabulator` object.
* new function `prepend_chunks()` to prepend chunks of content
in flextable cells as with `as_paragraph()` but without 
replacing the whole content.
* addition of chunk function `as_word_field()` to let add 'Word' computed
values into a flextable, as `as_word_field(x = "Page")` for a page number.
* new function `separate_header()` to Separate collapsed 
colnames into multiple rows.
* Functions `autofit()` and `dim_pretty()` now support newlines.
* `autofit()` and `dim_pretty()` now have an argument `hspans` 
to help specify how horizontally spanned cells should affect 
the results.
* PDF output now supports various floating placement options with 
knitr option `ft.latex.float`, supported values are 'none' 
(the default value), 'float', 'wrap-r', 'wrap-l', 
'wrap-i' and 'wrap-o'.
* HTML output have now a scrool bar if width does not fit in the 
container. This can be switch off by using the knitr 
option `ft.htmlscroll = FALSE`.
* `tabulator()` can display any columns before and 
after the columns of displayed aggregations.

## Issues

* fix append_chunks usage by adding `i`, `j` and `part` 
at the end of the function arguments, after the `...`.
* add forgotten `supp_data` in the result table of `tabulator()`
* merged horizontal borders are now visible in PowerPoint (#378)
* PowerPoint 'soft returns' are now real 'soft returns'. (#379)
* mapping between argument `j` and `source` when color is a function 
(in `bg()`, `highlight()` and `color()`) is now based on colnames 
to avoid mistake while mapping. #395
* Fix issue with footnotes forcing rectangular extent for selection; 
thanks to Sean Browning
* fix horizontal and vertical alignements when rotating paragraphs for 
pptx, docx and html outputs
* links in pptx and docx are not transformed anymore.
* fix handling of special characters in latex
* vertically merged cells now wrap text into the paragraph 


## Changes

* refactor the code for pptx and docx output

# flextable 0.7.0

## new features

* new function `append_chunks()` to append chunks of content
in flextable cells as with `as_paragraph()` but without 
replacing the whole content.
* new function `tabulator()` and its method 
`as_flextable.tabulator()` that help the creation 
of tables used in life science industry. It also 
comes with function `summarizor()` and sugar function 
`fmt_2stats()`.
* `empty_blanks()` gained arguments `width` so that users can also 
set blank columns' width.
* pass `...` to `format()` function when using `colformat_num()`. It 
makes possible to use arguments for `format()`, for example 
`colformat_num(drop0trailing = TRUE)`.
* add knitr chunk option `ft.keepnext` and parameter `keepnext` 
to function `body_add_flextable()` that enable the Word option 
'keep rows together', so that page break within a table is 
avoided when possible.
* new function `add_latex_dep()` to manually add flextable latex 
dependencies to the knitr session.

## Issues

* fix Rd files which when converted to HTML had `<img>` entries with
invalid width attributes e.g. `width=40\%`.

## Changes

* In a bookdown context and without package officedown, it is not possible to keep 
the cross-references as they are provided by bookdown and to provide a
real Word cross-reference on table captions (the reference number only is displayed).
That's why when using bookdown without package officedown : 1. Word auto-numbering is 
desactivated and 2. caption prefix formatting feature.

# flextable 0.6.10

## new features

* add function `df_printer` that can be used via the `df_print` option 
of R Markdown documents or by calling `use_df_printer()`.
* add support to knitr table options `tab.cap.fp_text` to let format caption prefix 
in function `opts_current_table()`.
* Applies existing formatting properties to new header/footer lines

## Issues

* fix convertion when unit = "mm"
* fix regression with captions when bookdown generate a 'Word' document #354
* fix highlight for PowerPoint

## Enhancement

* Theme functions behavior is now more detailed in the manual.

# flextable 0.6.9

## new features

* add "nan" option in formatting functions  
`colformat_*` and `set_flextable_defaults`.
* new function `surround()` to ease the highlighting 
of specific cells with borders.
* add "pdf" option for previewing a flextable in PDF 
with `print(x, preview ="pdf")`.

## Issues

* fix width with border overlaps in pdf
* chunks are now ordered as expected in pdf
* markdown can be used in table captions in R Markdown documents

# flextable 0.6.8

## Issues

* fix issue with border spaces and widths in HTML output. #343 
* fix tests obfuscations with "pandoc-citeproc" that was not necessary.

# flextable 0.6.7

## new features

* tab.lp is now a knitr supported chunk option and can be use to change the 
label prefix for the table sequence id when a caption is used. See 
https://github.com/davidgohel/officedown/issues/71.
* support for `tab.topcaption` that let modify the table caption 
position from "top" (TRUE) to "bottom" (FALSE). 
* add helper function `before()` to ease addition of `hline()` before some values 
to match with.

## Issues

* fix issue with white spaces instead of empty borders in HTML output
* fix issue with missing top or right border in LaTeX output (thanks to huaixv for the fix)
* Table cells containing square braces were causing errors (thanks to Nick Bart for the fix)
* fix proc_freq error when include.row_percent, include.table_percent and include.column_percent are 
all set to FALSE.

# flextable 0.6.6

## new features

* add argument `ft.shadow = TRUE` to htmltools_value so that 
shadow dom can not be used.
* add arguments "cs.family", "hansi.family" and "eastasia.family" to `fontname`.
* add "line_spacing" to defaults formatting properties (see `set_flextable_defaults(line_spacing=1)`)

## Issues

* fix issue with spaces in latex - see #314
* fix issue with powerpoint hyperlinks - see #310
* fix issue with conditional color with scale - see #309

# flextable 0.6.5

## new features

* add function `as_equation` for 'MathJax' equations.
* add argument `text_after` to function `flextable_to_rmd` to let append 
any text to the produced flextable.

# flextable 0.6.4

## new features

* export of `chunk_dataframe` for those who want to create functions that work with 
 `as_paragraph`.
* in R Markdown for Word, bookmarks are now added to captions when output format is from bookdown
* shadow hosts HTML elements get the class `flextable-shadow-host`.
* `set_flextable_defaults` now accept argument `padding` that set values for padding 
top, bottom, left and right.
* new functions `colorize`, `as_highlight`
* functions `nrow_part` and `ncol_keys` are now exported

## Issues

* fix for minibar when all values are equal to zero (thanks to Martin Durian)
* fix URLs formatted incorrectly in Word and PowerPoint (thanks to David Czihak)

# flextable 0.6.3

## new features

* `compose` has a new argument `use_dot` to let 
use `.` and loop over columns 
* new function `init_flextable_defaults()`
* inst/mediasrc/man-figures.R can also be used for visual testing 
with `git diff`

## Issues

* fix line spacing with pdf output
* Now `colformat_num` calls the `format` function on the numeric values 
(integer and float) which are therefore displayed as in console R. This function
is used during the creation of a flextable so that by default the content of the
cells is the same as that displayed in console R.

# flextable 0.6.2

## changes

* new documentation! See at https://ardata-fr.github.io/flextable-book/


## new features

* `merge_v` has a new argument `combine` to let use j columns 
be used as a single value (all values are pasted).
* new function `add_body` for adding rows into a flextable body
* new function `colformat_image` for images in flextable
* new method `as_flextable` for `gam` models
* function `set_flextable_defaults` gained 4 new arguments 
 `post_process_pdf`, `post_process_html`, `post_process_docx` 
 and `post_process_pptx` to enable flextable post-treatments 
 conditionned by the output format.
* new helper functions `fp_text_default` and `fp_border_default`.


## Issues

* fix encoding issue with Windows platforms
* bring back caption into the table
* fix overlapping issue with hline_top #244
* fix `\n` and `\t` usage for pdf

# flextable 0.6.1

## new features

* HTML flextable are now isolated from the document CSS (except caption which 
is copied before).

## Issues

* correction of latex tables which resulted in a centering of the following text.
* minor correction for density graphs inserted in tables
* fix suffix/prefix usage in colformat_* functions

## changes

* drop defunct functions.


# flextable 0.6.0

## new features

* flextable now supports PDF/latex output format.
* new function `highlight()` for text highlighting color
* new function `set_flextable_defaults()` to set some default 
formatting properties, i.e. default border color, font color, padding, decimal.mark ...
* `save_as_docx` gained a new argument `pr_section` to define page 
layout with section properties, `save_as_html` can now output more than 
a single table.
* `colformat_` functions now use default values and filter columns that 
are irrelevant (i.e. if colformat_num, only numeric values are formatted). 
Also, new `colformat_` functions have been implemented (`colformat_date`, `colformat_datetime`
and `colformat_double`).
* new functions `plot_chunk` and `gg_chunk` to add miniplots or ggplots into a flextable

## changes

* defunct of `ph_with_flextable()`
* use pandoc's raw attribute when possible within "R Markdown" documents.

## Issues

* fix bug in HTML output with invalid css when locale makes decimal separator not `.`
* `fix_border_issues` is the last instruction of all theme functions so that borders 
are corrected if some cells have been merged.
* caption was always printed in bookdown and now it's conditionned by 
testing if `tab_props$cap` has a value.
* fix missing tfoot tag in HTML output

# flextable 0.5.11

## Changes

* HTML code is now minimized as CSS styles are now used instead of inline CSS.

## new features

* save_as_html now accepts argument `encoding`
* line spacing (for Word and PowerPoint) or line height (for  HTML) can now be
defined with function `line_spacing()` (or with function `style()`).

## Issues

* selection when i or j was integer(0) was resulting to all rows, it's now fixed. To
select all rows or columns, use `i = NULL` or `j = NULL`, to select none, `i = integer(0)` or
`j = integer(0)`.
* tab were not displayed when output was HTML

# flextable 0.5.10

## new features

* flextable captions in Word can be auto-numbered and bookmarked
* function `footnote` is now able to add inline footnotes
* support for bookdown references
* new as_flextable methods for lm and glm objects and xtable (replacing `xtable_to_flextable()`)
* new sugar function `continuous_summary()`: summarize continuous columns in a flextable
* function `autofit` can now use only some parts of the tables. This allows
for example to no longer have gigantic columns by not taking into account the "footer" part that is often composed of long texts.
* bookdown and xaringan HTML outputs should now be rendered as expected - table css has been overwritten.
* new function `set_table_properties` lets adapt flextable size as "100%", "50%" of the available width
for Word and HTML.

## Changes

* manual pages have been improved and illustrations are added
* `bg()` and `color()` now accept functions (i.e. `scales::col_numeric()`)

# flextable 0.5.9

## Changes

* defunct of `display()`
* rename arg 'formater' to 'formatter' of `as_chunk` (#152)

## Internal

* drop `officer::fp_sign` importation that was not used anymore so that officer can
 drop digest dependency.


# flextable 0.5.8

## Changes

* deprecation of `display()`.
* defunct of `ph_with_flextable_at()`
* function `knit_to_wml()` has new arguments `align`, `split` and `tab.cap.style`
* function `htmltools_value()` has a new argument `ft.align`

## new features

* new function `flextable_html_dependency` to get flextable htmltools::htmlDependancy. This is
necessary to output flextables in html R Markdown documents from loop or other nested operations.


## Issues

* fix issue #188, add_rows error that came with version 0.5.7


# flextable 0.5.7

## new features

* new suger functions `save_as_docx`, `save_as_pptx` that lets users export flextable objects
  to PowerPoint or Word documents.

## Changes

* merge_v can use hidden columns.
* new function `hrule` to control how row heights should be
  understood (at least, auto, exact)
* Allow unused values in set_header_labels - PR #172 from DanChaltiel
* deprecation of ph_with_flextable_at, ph_with_flextable will be deprected in the next release

## Issues

* fix issue #180, background color of runs transparency issue with googlesheet
* fix issue #157, issue with rotate and HTML output


# flextable 0.5.6

## Issues

* force officer >= 0.3.6
* fix rounding issue for css borders


# flextable 0.5.6

## new features

* new function `lollipop` that lets users add mini lollipop chart to flextable
  (kindly provided by github.com/pteridin)
* function `proc_freq` got a new argument `weight` to enable weighting of results.
* function `as_flextable.grouped_data()` has now an argument `hide_grouplabel` to
let not print the group names.

## Issues

* let footnotes symbols be affected by style functions (related to #137)
* enable usage of 'webshot2' instead of 'webshot'. It enable better screenshots. It
  can be specified with argument `webshot` in function `save_as_image` or with
  chunk option `webshot="webshot2"`.

# flextable 0.5.5

## new features

* new function `knit_to_wml` to let display flextables from non top level
 calls inside R Markdown document.
* ph_with method for flextable object. This enable `ph_location*` usage
  and make placement into slides easier.
* new function `fit_to_width` to fit a flextable to a maximum width
* `set_caption` can now be used with R Markdown for Word document and caption
  style can be defined with chunk option `tab.cap.style`.

## Issues

* fix issue with `save_as_image` with R for Windows

# flextable 0.5.3

## new features

* new functions to render flextable in plot (see `plot`), as an image (see `save_as_image`)
  and raster for ggplot2 (see `as_raster`).
* new function `footnote` to ease footnotes management
* colformat functions are suporting i argument now for rows selection.

# flextable 0.5.2

## new features

* new function `valign` to align vertically paragraphs in cell
* new function `proc_freq` that mimic SAS proc freq provided by Titouan Robert.
* new function `linerange` to produce mini lineranges.

## Issues

* fix issue with `set_footer_df`

# flextable 0.5.1

## Issues

* fix issue with font colors in powerpoint
* fix issues with colors for Windows RStudio viewer


## new features

* new themes functions `theme_alafoli()` and `theme_vader()`
* new functions `align_text_col()` and `align_nottext_col()` to align
  columns by data type
* new functions `merge_h_range()` to merge a set of columns row by row
* new functions `fix_border_issues()` fix issues with borders when cells are merged
* new functions `add_header_row()`, `add_footer_row()`, `add_header_lines()`
 and `add_footer_lines()` to add easily data in header or footer.
* new generic function `as_flextable()` to let develop new flextable functions
* new function `as_grouped_data()` and its method `as_flextable()` to
  create row titles to separate data in a flextable.


# flextable 0.5.0

## Improvement

* new arguments `values` for functions `set_header_labels` and `set_formatter`
* styles functions now support injection of more than a single value
* this version a big refactoring and got rid of R6

## new features

* new function `compose` that will replace `display`
* new function `set_caption` only available for html output

# flextable 0.4.7

## new features

* `knit_print()` can be used with rmarkdown when rendering to PowerPoint.

## Issues

* fix issue with `regulartable` and logical columns

# flextable 0.4.6

## new features

* a new helper function `body_replace_flextable_at_bkm` to
  replace a bookmarked paragraph by a flextable.
* new functions `colformat_*` to make content formatting easier.
  It also deals with NA.

## Improvement

* Documentation `format.flextable` method so that users can create
  their components.
* new knitr chunk options `ft.align` to align tables in
  `rmarkdown::word_document` and `ft.split` to activate Word
  option 'Allow row to break across pages'.

## Issues

* fix issue (unordered and duplicated chunk of text) in function `display()`


# flextable 0.4.5

## Improvement

* flextable will not be split across rows at a page break in Word documents.

## Issues

* fix border rendering with `vline()`
* empty data.frame are no more generating an error

# flextable 0.4.4

## new features

* Soft return `\n` is now supported. Function `autofit` and `dim_pretty` do not
  support soft returns and may return wrong results (\n will be considered as "").
* format function for flextable objects.

## Issues

* fix border rendering with `border_outer()`


# flextable 0.4.3

## new features

* new functions: `hyperlink_text()` to be used with `display`, `font()`
* new functions `hline*()` and `vline*()` and many new helper functions
  to be used instead of borders.

## Improvement

* manuals have been refactored


## Issues

* fix display issue when a cell was containing NA


# flextable 0.4.2

## new features

* new function `xtable_to_flextable()` that is returning
  a flextable from an xtable object.
* function `htmltools_value()` is exported for shiny applications.

# flextable 0.4.1

## new features

* flextables have now a footer part


# flextable 0.4.0

## new features

* new function `knit_print()` to render flextable in rmarkdown.

## Changes

* function tabwid() is deprecated in favor of a knit_print implementation.
* list of dependencies has been reduced.

# flextable 0.3

## new features

* new function `regulartable`, faster and simpler than `flextable`

## Issues

* characters <, > and & are now html encoded
* fix columns widths when output format is HTML

# flextable 0.2

## new features

* new function `ph_with_flextable_at` to add a flextable at any position in a slide.
* new function `merge_at` is providing a general way of merging cells.
* new theme function: `theme_box()`

## Changes

* function display() now works with a mustache template

## Issues

* fix fontsize when part == "all"

