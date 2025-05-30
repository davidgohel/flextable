# flextable 0.9.9

## new features

- `proc_freq` gains new argument `count_format_fun` to let control the function 
that format the count values.

## Issues

- fix compatibility issue with rmarkdown::word_document and quarto introduced with
version `0.9.8`.

## Changes

- Defunct previously deprecated functions `as_raster()`, `lollipop()` 
  and `set_formatter_type()`.
- Definitively forbid usage of empty symbol `''` with footnotes. Users should 
  use `add_footer_lines()` instead.

# flextable 0.9.8

## Issues

- `tab_settings()` is now using j argument as expected (#635)
- doc inconsistency for `set_table_properties()` with layout that defaults to 
"fixed".
- add_header_row produced an error after using `delete_column()` (#676)
- `fmt_signif_after_zeros()` fixed issue with 0 rounding
- `proc_freq` supports now non syntactically names

# flextable 0.9.7

## new features

- Added support for labelled datasets.

## Changes

- The `fix_border_issues` function is now useless for users, as it is now 
called automatically before printing.

## Issues

- fix caption issue that came with no version of bookdown (issue #645),
'bookdown' management of caption has been simplified.
- fix vertical overlapping lines with grid output (issue #644)
- fix broken internal links in PDF file, probably due to a change in knitr or 
rmarkdown (issue #632)
- fix right outer border issue in grid format (issue #650)
- fix `flextable_to_rmd()` issue with images in pdf (issue #651)
- fix `flextable_to_rmd()` issue with local chunk `eval` option (issue #631)
- `proc_freq` can now display only the table percentages without the count 
using `include.table_count = FALSE`.
- bring back support for 'pagedown' with `pagedown >= 0.20.2`
- flextable now applies defined text-format to empty cells for Word and
Powerpoint outputs.

# flextable 0.9.6

## Changes

- `headers_flextable_at_bkm()` and `footers_flextable_at_bkm()` are defunct.
- `flextable_to_rmd()` is now using `knit_child()` for safer usage from `for`
  loops or `if` statements.
- Add explanation about caption limitations in the manual of functions
  `save_as_image()` and `ph_with.flextable()`.
- Deprecate `as_raster()` since `gen_grob()` is easier to use and render
  nicer.
- BREAKING CHANGE: in `align()`, the default argument value for `align` is now
  `"left"`, rather than `c("left", "center", "right", "justify")`. This
  returns the default value to how it was in older versions of {flextable}.
    - in `align()`, use of the old default `align` argument could cause an
      error if the number of columns being adjusted was not a multiple of 4.
    - The documentation specified that `align` had to be a single value, when
      it could actually accept multiple values. This is why a default value of
      `c("left", "center", "right", "justify")`, was problematic. This
      documentation has now been updated and new examples included in the
      documentation.
    - The default `align` argument will now apply left alignment to all
      columns in the body.
    - If the user specifies an alignment that is invalid, a error will be
      displayed.
    - The `path` argument now has a signature of `part = c("body", "header",
      "footer", "all")`, but because only a single value can be selected, it
      will pick `"body"` by default, as before.
- Deprecate `lollipop()` since it produces (ugly) results that can be replaced
by nice results with `gg_chunk()` or `grid_chunk()`.

## Issues

- fix issue with `as_image()` when the table contains no text.
- fix font instruction issue with PDF and quarto
- fix issue with Quarto detection and R > 4.4
- fix `align()` issue with recycling and update documentation
that was wrong about argument `align` that is vectorized over 
columns.

# flextable 0.9.5

## new features

- new functions `tab_settings()` to set tabulation marks configuration
for Word and RTF. It works with `officer::fp_tabs()`.
- new function `fmt_signif_after_zero()` to round significant figures after zeros.

## Issues

- `summarizor()` don't stop anymore if table only contain discrete columns.
- `as_flextable.data.frame()` supports 'data.table'
- `footnote()` handle undefined `ref_symbols` argument
- `delete_rows()` does not delete rows if the row selection is empty
- improve `gen_grob()` alignments when wrapping text
- fix horizontal border issue with `gen_grob()` when cells are vertically merged
- Word captions set with `set_caption()` can have no bookmark and have
autonumber used together.

## Changes

- default `tabcolsep` is now set to 2.
- Deprecate `set_formatter_type()`.
- renovate `fmt_2stats()` so that it uses global flextable settings, 
i.e. digits, etc.
- refactoring of data structure for content
- footer along pages in PDF are now deactivated by default. It can be 
activated with command `set_table_properties(opts_pdf = list(footer_repeat = TRUE))`.
- more argument checkings in `as_chunk()`

# flextable 0.9.4

## Issues

- `ph_with.flextable()` formats widths and heights correctly.
- move image shown in add_footer to footnote where it should be.
- update the documentation and automatically change alignment
'justify' to 'left' for latex output.
- borders'width for grid output are fixed

## new features

- new functions `delete_columns()` and `delete_rows()` 
to let users delete rows or columns.
- `save_as_image()` now supports svg export with 'svglite'.

# flextable 0.9.3

## new features

- The `summarizor()` function has been enhanced to offer three new options: 
  - an empty `by` argument meaning 'no grouping,' 
  - the ability for users to select numeric statistics to display ("mean_sd," "median_iqr," "range"), 
  - and the option to specify whether or not to show all NA counts.

## Changes

- `as_flextable.data.frame()` always shows the number of rows even if less than 10 
(because I need it!).

## Issues

- Make sure 'gfm' format is rendered as an image.
- As adviced by Ben Bolker, functions `as_flextable.lm()`, `as_flextable.gam()`,
`as_flextable.glm()`, `as_flextable.merMod()` and `as_flextable.htest()`
now respect the global value of `getOption("show.signif.stars")`.
- new argument `add.random` in `as_flextable.merMod()` to let add or not
random effects in the final table.
- drop superfluous semicolons when include.row_percent = FALSE
- Super and subscripts are now correctly
rendered in PDF (thanks to Philippe Grosjean).
- argument `max_iter` of function `fit_to_width` is not
ignored anymore.

## Internals

- rename technical column `part` to `.part` so that
column named `part` can be used.

# flextable 0.9.2

## Issues

- rmarkdown expect list of dependencies to be unnamed.
This property is used in HTML or LaTeX deps resolution to know 
when to be recursive 
- `dim_pretty()` returns correct numbers when not 'inches'
- `as_flextable.table()` now propagates `...` as expected
- pdf: when table was on two pages, there were duplicated caption entries,
this is fixed thanks to Christophe Dervieux and Nick Bart. Repeating 
the caption along pages can be desactivated with command 
`set_table_properties(opts_pdf = list(caption_repeat = FALSE))`.
- `as_flextable()` now works on tabular objects and `R < 4.1`.
- `to_html(type = "img")` now use the correct width and height

## Changes

- bookdown has now bookmarks associated with captions and flextable benefits
from this feature.
- In 'Quarto' captions are ignored, which make Quarto captions valid with HTML
and PDF outputs; the responsibility for managing captions lies with the
Quarto framework itself. It does not work with Quarto for Word and should be
possible with Quarto `1.4`.
- `as_flextable.tabular()` now generate tabulated content only if the sub group
contains more than a single row. When possible, row titles are tabulated.

## Deprecated functions

- The functions `footers_flextable_at_bkm` and `headers_flextable_at_bkm` are deprecated.
Instead, we recommend using the `prop_section()` and `block_list()` functions from the `officer` package as alternative solutions. These functions provide more reliable and flexible options for managing footers and headers. 

# flextable 0.9.1

## breaking change

- parameter `keepnext` and `ft.keepnext` are defunct, they are replaced
by function `paginate()` that enable nice pagination of tables across pages 
or `keep_with_next()` to get total control over rows pagination.

## new features

- add RTF support for captions.
- `set_flextable_defaults()` gains parameter `pct_digits` 
(number of digits for percentages) that will be used in relevant 
functions (only `proc_freq()` for now).
- new method `as_flextable.table()`.
- new functions `fmt_dbl()`, `fmt_int()` and `fmt_pct()`.
- Support for Word and RTF pagination with function `paginate()`

## internals

- refactor proc_freq and support 1d frequency table

## issues

- colname `type` is now possible when using `tabulator()`.
- value for html dependancies parameter is a list of html-dep as expected.
This solves issue for blogdown and pkgdown introduced in the previous version.
- fix `save_as_html()` ugly default title.
- fix alignment issues when rows are horizontally merged in PDF

# flextable 0.9.0

## new features

- add RTF support for captions.
- enable new labels with `set_header_labels()` from a simple
un-named vector.
- function `set_formatter()` now accepts single function to 
be applied to all columns.
- HTML output now can capture google fonts if installed with 
`gdtools::register_gfont()`.
- refactor `save_as_html()`: use rmarkdown and add google fonts
if possible (See `gdtools::register_gfont()`).

## issues

- fix `as_flextable.tabular(spread_first_col=TRUE)`

# flextable 0.8.6

In short: 

- RTF support, 
- revealjs support,
- preserve all aspects within Quarto html format
- use grid graphics for saving as png (no need for "webshot" or "webshot2" packages)
- support for `tables::tabular()`: "Computes a table of summary statistics, cross-classified by various variables"

## new features

- add RTF support with `officer::rtf_add()`.
- new convert `tables::tabular()` to flextable with new 
function `as_flextable.tabular()`.
- add `to_html.flextable()` to make easy embedding of 
flextable results in HTML (with 'ggiraph' for example).
- add global setting `border.width` (see `?set_flextable_defaults()`) 
and set its default value to .75, this setting is 
used in theme functions. The old default value was hard coded 
to 1 and can be defined during the whole R session with
`set_flextable_defaults(border.width = 1)`.

## internals

- drop 'base64enc' dependency and use 'officer' functions
as replacement. 
- Use `officer_url_encode()` to encode URL in office files.
- refactor `knit_print.flextable()` and related functions. 
- drop webshot dependency to produce images, now using package
'ragg'.
- refactor captions: knitr context now updates the caption 
instead of managing caption value and defined knitr 
options.
- use shadow in all HTML output generated via knitr 
(i.e. 'Quarto' and 'R Markdown').

## issues

- support revealjs (and probably all RMD formats that generate HTML)
- fix cell's vertical alignments in latex
- fix detection of non transparent background table in latex so that
the correct lines instructions (hhlines or clines) are being used.
- fix `headers_flextable_at_bkm()` and `footers_flextable_at_bkm()`

# flextable 0.8.5

## changes

- use pkgdown features instead of images shots 
in the manual examples. The website now shows
flextable results.

## issues

- fix issue with flextable_to_rmd and pdf introduced in `0.8.4`.
- fix caption issue with Word and `body_add_flextable()`.

# flextable 0.8.4

## new features

- new argument `expand_single` in `as_flextable.tabulator()`. If `FALSE`,
groups with only one row will not be expanded with a title row.
- argument `labels` of `labelizor()` now support functions in 
addition to named vectors.
- `as.character()` now returns the HTML string of the table
- new method `as_flextable` for data.frame using `df_printer()` function
implementation.

## Issues

- fix mis-calculated columns widths in latex
- fix horizontal lines in latex tables
- adapt latex table container to quarto changes
- Word caption: autonumber works without bookmark

# flextable 0.8.3

## new features

- new argument `expand_single` in `as_grouped_data()`. If FALSE, groups with only one
row will not be expanded with a title row.
- new functions `fmt_avg_dev()`, `fmt_header_n()`, `fmt_n_percent()` and renaming of `fmt_2stats()` 
to `fmt_summarizor()` to help working with `tabulator()`. `tabulator()` has also new
internal values that allow N=xxx notes and automatic labels.
- function `set_table_properties()` is now the recommanded way to set
arguments related to format options and alignment in a document. It is
supposed to replace "knitr" chunk options `ft.align`, `ft.split`,
`ft.keepnext`, `ft.tabcolsep`, `ft.arraystretch`, `ft.latex.float`,
`ft.shadow`, `fonts_ignore` although they are all still
supported.
This allows less interaction with the 'R Markdown' or 'Quarto'
eco-system and let to define it globally with `set_flextable_defaults()`.
- HTML scrolling can be activated by calling `set_table_properties()` and 
providing a *scroll* value for argument `opts_html`: 
`opts_html = list(scroll = list(height = "500px",freeze_first_column = TRUE))`.
- new function `grid_chunk()` to let users add grid graphics
- functions `add_header_row()`, `add_footer_row()`, `add_body_row()`,
`add_header_lines()` and `add_footer_lines()` 
now supports formatted paragraph made with `as_paragraph()`.
- captions: support for simple text in addition to `as_paragraph()`
- `summarizor()` can now be transformed directly as a flextable 
with method `as_flextable()`.

## Issues

- fix issue with keepnext and `body_add_flextable()`
- fix issue of misordered chunks with `prepend_chunks()`
- argument 'unit' is dropped in `line_spacing()` as it is expected to be a ratio

## Changes

- `ft.keepnext` now default to FALSE as lot of users had issues
with this option.
- function `xtable_to_flextable()` is removed (use `as_flextable()`)

# flextable 0.8.2

## Issues

- prevent docx captions test when pandoc version 
is "2.9.2.1" (on CRAN Flavor r-devel-linux-x86_64-fedora-gcc).

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
- fix doc links to functions from other packages for future releases

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

