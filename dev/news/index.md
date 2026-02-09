# Changelog

## flextable 0.9.11

### new features

- new function
  [`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)
  enables integration with ‘patchwork’ layouts. Flextable objects can be
  combined with ‘ggplot2’ plots using `+`, `|`, and `/` operators. Table
  headers and footers are aligned with plot panel areas. The `panel`
  argument controls alignment (`"body"`, `"full"`, `"rows"`, `"cols"`)
  and the `space` argument controls sizing (`"free"`, `"fixed"`,
  `"free_x"`, `"free_y"`). `flex_body` stretches body rows to match a
  neighbouring plot’s panel height; `flex_cols` stretches data columns
  to match the panel width. `just` controls horizontal alignment
  (`"left"`, `"right"`, `"center"`) when the table is narrower than the
  panel. S3 methods `ggplot_add.flextable` and `as_patch.flextable` are
  registered so that `plot + flextable` works transparently.
- new function
  [`theme_borderless()`](https://davidgohel.github.io/flextable/dev/reference/theme_borderless.md)
  applies a minimal theme with no borders, bold header, and standard
  column alignment.
- support strikethrough formatting with
  [`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md).
- new function
  [`as_strike()`](https://davidgohel.github.io/flextable/dev/reference/as_strike.md)
  to apply strikethrough formatting to text chunks.
- new function
  [`compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/compact_summary.md)
  to create a compact summary of a data.frame that can be transformed as
  a flextable with
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md).
- [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md):
  when using `overall_label` with multiple `by` columns, an overall
  level is now added for each grouping column (not only the last one).
  This produces margins at every nesting level, including a grand total.
- [`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
  gains a `symbol_sep` argument to insert a separator between multiple
  footnote symbols in the same cell
  ([\#699](https://github.com/davidgohel/flextable/issues/699)).

### Known limitations

- PDF/LaTeX: a table row whose content is taller than a page cannot be
  split across pages
  ([\#548](https://github.com/davidgohel/flextable/issues/548)). This is
  a fundamental constraint of LaTeX’s `longtable` environment, which
  only supports page breaks between rows, not within a single row. HTML
  and Word outputs are not affected.

### Internals

- Strings metrics are now computed with
  [`gdtools::strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.html)
  instead of
  [`m_str_extents()`](https://davidgohel.github.io/gdtools/reference/m_str_extents.html)
  and
  [`str_metrics()`](https://davidgohel.github.io/gdtools/reference/str_metrics.html),
  goal is to let ‘gdtools’ use only ‘systemfonts’ and be simplified.

### Issues

- images in google docs should now be sized as expected
- specifying a `word_style` for a paragraph style works now. The
  `word_style` values will be ignored if flextable is process by
  ‘rmarkdown’ or ‘quarto’.
- [`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md):
  the N= counts in column headers are now displayed when there are
  multiple grouping columns (previously limited to a single grouping
  column).
- [`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
  no longer errors when the row selector `i` matches zero rows
  ([\#712](https://github.com/davidgohel/flextable/issues/712)).
- footnote symbols no longer clash with rotated cells in HTML output
  ([\#713](https://github.com/davidgohel/flextable/issues/713)).
- PDF/Quarto: the `fontspec` LaTeX package is no longer included when
  the PDF engine is `pdflatex`, fixing compilation errors in Quarto
  documents using `pdf-engine: pdflatex`
  ([\#701](https://github.com/davidgohel/flextable/issues/701),
  [\#707](https://github.com/davidgohel/flextable/issues/707)). Engine
  detection now also reads `QUARTO_EXECUTE_INFO` (Quarto \>= 1.8) and
  nested YAML (`format > pdf > pdf-engine`).
- inner borders of vertically merged cells no longer show in PDF output
  when background color is set
  ([\#673](https://github.com/davidgohel/flextable/issues/673)).
- PDF/Quarto: footer repetition and longtable part ordering now work
  correctly with the default container (`none`) in Quarto output.
- [`merge_v()`](https://davidgohel.github.io/flextable/dev/reference/merge_v.md):
  vertically merged cell labels now appear at the top of the merged
  range in PDF/LaTeX output instead of the bottom
  ([\#654](https://github.com/davidgohel/flextable/issues/654)).
- vertical alignment (`valign`) in merged cells now works correctly in
  PDF/LaTeX output when rows have different heights
  ([\#639](https://github.com/davidgohel/flextable/issues/639)). Content
  is placed in the first (top), middle (center), or last (bottom) row of
  the merged range; `\multirow` is no longer used as it miscalculates
  offsets with unequal row heights.
- using `by` of
  [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  referring to two columns, one of which has only one unique value no
  longer causes and error when passed on to
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md).

## flextable 0.9.10

CRAN release: 2025-08-24

### new features

- It is now possible to not repeat headers’rows along Word pages by
  using
  `set_table_properties(opts_word = list(repeat_headers = FALSE))`.

### Issues

- fix `format_fun.default` so that it works with logical columns.

### Change

- `print.flextable(preview = "log")` use
  [`str()`](https://rdrr.io/r/utils/str.html) to show first values of
  data instead of [`print()`](https://rdrr.io/r/base/print.html) so that
  when there are ggplot2 v4 objects in the table, the print is not
  failing.

## flextable 0.9.9

CRAN release: 2025-05-31

### new features

- `proc_freq` gains new argument `count_format_fun` to let control the
  function that format the count values.

### Issues

- fix compatibility issue with rmarkdown::word_document and quarto
  introduced with version `0.9.8`.

### Changes

- Defunct previously deprecated functions
  [`as_raster()`](https://davidgohel.github.io/flextable/dev/reference/as_raster.md),
  [`lollipop()`](https://davidgohel.github.io/flextable/dev/reference/lollipop.md)
  and
  [`set_formatter_type()`](https://davidgohel.github.io/flextable/dev/reference/set_formatter_type.md).
- Definitively forbid usage of empty symbol `''` with footnotes. Users
  should use
  [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
  instead.

## flextable 0.9.8

CRAN release: 2025-05-21

### Issues

- [`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md)
  is now using j argument as expected
  ([\#635](https://github.com/davidgohel/flextable/issues/635))
- doc inconsistency for
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  with layout that defaults to “fixed”.
- add_header_row produced an error after using `delete_column()`
  ([\#676](https://github.com/davidgohel/flextable/issues/676))
- [`fmt_signif_after_zeros()`](https://davidgohel.github.io/flextable/dev/reference/fmt_signif_after_zeros.md)
  fixed issue with 0 rounding
- `proc_freq` supports now non syntactically names

## flextable 0.9.7

CRAN release: 2024-10-27

### new features

- Added support for labelled datasets.

### Changes

- The `fix_border_issues` function is now useless for users, as it is
  now called automatically before printing.

### Issues

- fix caption issue that came with no version of bookdown (issue
  [\#645](https://github.com/davidgohel/flextable/issues/645)),
  ‘bookdown’ management of caption has been simplified.
- fix vertical overlapping lines with grid output (issue
  [\#644](https://github.com/davidgohel/flextable/issues/644))
- fix broken internal links in PDF file, probably due to a change in
  knitr or rmarkdown (issue
  [\#632](https://github.com/davidgohel/flextable/issues/632))
- fix right outer border issue in grid format (issue
  [\#650](https://github.com/davidgohel/flextable/issues/650))
- fix
  [`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md)
  issue with images in pdf (issue
  [\#651](https://github.com/davidgohel/flextable/issues/651))
- fix
  [`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md)
  issue with local chunk `eval` option (issue
  [\#631](https://github.com/davidgohel/flextable/issues/631))
- `proc_freq` can now display only the table percentages without the
  count using `include.table_count = FALSE`.
- bring back support for ‘pagedown’ with `pagedown >= 0.20.2`
- flextable now applies defined text-format to empty cells for Word and
  Powerpoint outputs.

## flextable 0.9.6

CRAN release: 2024-05-05

### Changes

- [`headers_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/headers_flextable_at_bkm.md)
  and
  [`footers_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/footers_flextable_at_bkm.md)
  are defunct.
- [`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md)
  is now using `knit_child()` for safer usage from `for` loops or `if`
  statements.
- Add explanation about caption limitations in the manual of functions
  [`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md)
  and
  [`ph_with.flextable()`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md).
- Deprecate
  [`as_raster()`](https://davidgohel.github.io/flextable/dev/reference/as_raster.md)
  since
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
  is easier to use and render nicer.
- BREAKING CHANGE: in
  [`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
  the default argument value for `align` is now `"left"`, rather than
  `c("left", "center", "right", "justify")`. This returns the default
  value to how it was in older versions of {flextable}.
  - in
    [`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
    use of the old default `align` argument could cause an error if the
    number of columns being adjusted was not a multiple of 4.
  - The documentation specified that `align` had to be a single value,
    when it could actually accept multiple values. This is why a default
    value of `c("left", "center", "right", "justify")`, was problematic.
    This documentation has now been updated and new examples included in
    the documentation.
  - The default `align` argument will now apply left alignment to all
    columns in the body.
  - If the user specifies an alignment that is invalid, a error will be
    displayed.
  - The `path` argument now has a signature of
    `part = c("body", "header", "footer", "all")`, but because only a
    single value can be selected, it will pick `"body"` by default, as
    before.
- Deprecate
  [`lollipop()`](https://davidgohel.github.io/flextable/dev/reference/lollipop.md)
  since it produces (ugly) results that can be replaced by nice results
  with
  [`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md)
  or
  [`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md).

### Issues

- fix issue with
  [`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md)
  when the table contains no text.
- fix font instruction issue with PDF and quarto
- fix issue with Quarto detection and R \> 4.4
- fix
  [`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  issue with recycling and update documentation that was wrong about
  argument `align` that is vectorized over columns.

## flextable 0.9.5

CRAN release: 2024-03-06

### new features

- new functions
  [`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md)
  to set tabulation marks configuration for Word and RTF. It works with
  [`officer::fp_tabs()`](https://davidgohel.github.io/officer/reference/fp_tabs.html).
- new function `fmt_signif_after_zero()` to round significant figures
  after zeros.

### Issues

- [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  don’t stop anymore if table only contain discrete columns.
- [`as_flextable.data.frame()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.data.frame.md)
  supports ‘data.table’
- [`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
  handle undefined `ref_symbols` argument
- [`delete_rows()`](https://davidgohel.github.io/flextable/dev/reference/delete_rows.md)
  does not delete rows if the row selection is empty
- improve
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
  alignments when wrapping text
- fix horizontal border issue with
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
  when cells are vertically merged
- Word captions set with
  [`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)
  can have no bookmark and have autonumber used together.

### Changes

- default `tabcolsep` is now set to 2.
- Deprecate
  [`set_formatter_type()`](https://davidgohel.github.io/flextable/dev/reference/set_formatter_type.md).
- renovate
  [`fmt_2stats()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md)
  so that it uses global flextable settings, i.e. digits, etc.
- refactoring of data structure for content
- footer along pages in PDF are now deactivated by default. It can be
  activated with command
  `set_table_properties(opts_pdf = list(footer_repeat = TRUE))`.
- more argument checkings in
  [`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)

## flextable 0.9.4

CRAN release: 2023-10-22

### Issues

- [`ph_with.flextable()`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md)
  formats widths and heights correctly.
- move image shown in add_footer to footnote where it should be.
- update the documentation and automatically change alignment ‘justify’
  to ‘left’ for latex output.
- borders’width for grid output are fixed

### new features

- new functions
  [`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md)
  and
  [`delete_rows()`](https://davidgohel.github.io/flextable/dev/reference/delete_rows.md)
  to let users delete rows or columns.
- [`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md)
  now supports svg export with ‘svglite’.

## flextable 0.9.3

CRAN release: 2023-09-07

### new features

- The
  [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  function has been enhanced to offer three new options:
  - an empty `by` argument meaning ‘no grouping,’
  - the ability for users to select numeric statistics to display
    (“mean_sd,” “median_iqr,” “range”),
  - and the option to specify whether or not to show all NA counts.

### Changes

- [`as_flextable.data.frame()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.data.frame.md)
  always shows the number of rows even if less than 10 (because I need
  it!).

### Issues

- Make sure ‘gfm’ format is rendered as an image.
- As adviced by Ben Bolker, functions
  [`as_flextable.lm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.lm.md),
  [`as_flextable.gam()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.gam.md),
  [`as_flextable.glm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.glm.md),
  [`as_flextable.merMod()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  and
  [`as_flextable.htest()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.htest.md)
  now respect the global value of `getOption("show.signif.stars")`.
- new argument `add.random` in
  [`as_flextable.merMod()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  to let add or not random effects in the final table.
- drop superfluous semicolons when include.row_percent = FALSE
- Super and subscripts are now correctly rendered in PDF (thanks to
  Philippe Grosjean).
- argument `max_iter` of function `fit_to_width` is not ignored anymore.

### Internals

- rename technical column `part` to `.part` so that column named `part`
  can be used.

## flextable 0.9.2

CRAN release: 2023-06-18

### Issues

- rmarkdown expect list of dependencies to be unnamed. This property is
  used in HTML or LaTeX deps resolution to know when to be recursive
- [`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
  returns correct numbers when not ‘inches’
- [`as_flextable.table()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.table.md)
  now propagates `...` as expected
- pdf: when table was on two pages, there were duplicated caption
  entries, this is fixed thanks to Christophe Dervieux and Nick Bart.
  Repeating the caption along pages can be desactivated with command
  `set_table_properties(opts_pdf = list(caption_repeat = FALSE))`.
- [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  now works on tabular objects and `R < 4.1`.
- `to_html(type = "img")` now use the correct width and height

### Changes

- bookdown has now bookmarks associated with captions and flextable
  benefits from this feature.
- In ‘Quarto’ captions are ignored, which make Quarto captions valid
  with HTML and PDF outputs; the responsibility for managing captions
  lies with the Quarto framework itself. It does not work with Quarto
  for Word and should be possible with Quarto `1.4`.
- [`as_flextable.tabular()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md)
  now generate tabulated content only if the sub group contains more
  than a single row. When possible, row titles are tabulated.

### Deprecated functions

- The functions `footers_flextable_at_bkm` and
  `headers_flextable_at_bkm` are deprecated. Instead, we recommend using
  the
  [`prop_section()`](https://davidgohel.github.io/officer/reference/prop_section.html)
  and
  [`block_list()`](https://davidgohel.github.io/officer/reference/block_list.html)
  functions from the `officer` package as alternative solutions. These
  functions provide more reliable and flexible options for managing
  footers and headers.

## flextable 0.9.1

CRAN release: 2023-04-02

### breaking change

- parameter `keepnext` and `ft.keepnext` are defunct, they are replaced
  by function
  [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)
  that enable nice pagination of tables across pages or
  [`keep_with_next()`](https://davidgohel.github.io/flextable/dev/reference/keep_with_next.md)
  to get total control over rows pagination.

### new features

- add RTF support for captions.
- [`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
  gains parameter `pct_digits` (number of digits for percentages) that
  will be used in relevant functions (only
  [`proc_freq()`](https://davidgohel.github.io/flextable/dev/reference/proc_freq.md)
  for now).
- new method
  [`as_flextable.table()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.table.md).
- new functions
  [`fmt_dbl()`](https://davidgohel.github.io/flextable/dev/reference/fmt_dbl.md),
  [`fmt_int()`](https://davidgohel.github.io/flextable/dev/reference/fmt_int.md)
  and
  [`fmt_pct()`](https://davidgohel.github.io/flextable/dev/reference/fmt_pct.md).
- Support for Word and RTF pagination with function
  [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)

### internals

- refactor proc_freq and support 1d frequency table

### issues

- colname `type` is now possible when using
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).
- value for html dependancies parameter is a list of html-dep as
  expected. This solves issue for blogdown and pkgdown introduced in the
  previous version.
- fix
  [`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md)
  ugly default title.
- fix alignment issues when rows are horizontally merged in PDF

## flextable 0.9.0

CRAN release: 2023-03-13

### new features

- add RTF support for captions.
- enable new labels with
  [`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md)
  from a simple un-named vector.
- function
  [`set_formatter()`](https://davidgohel.github.io/flextable/dev/reference/set_formatter.md)
  now accepts single function to be applied to all columns.
- HTML output now can capture google fonts if installed with
  [`gdtools::register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html).
- refactor
  [`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md):
  use rmarkdown and add google fonts if possible (See
  [`gdtools::register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html)).

### issues

- fix `as_flextable.tabular(spread_first_col=TRUE)`

## flextable 0.8.6

CRAN release: 2023-02-23

In short:

- RTF support,
- revealjs support,
- preserve all aspects within Quarto html format
- use grid graphics for saving as png (no need for “webshot” or
  “webshot2” packages)
- support for
  [`tables::tabular()`](https://dmurdoch.github.io/tables/reference/tabular.html):
  “Computes a table of summary statistics, cross-classified by various
  variables”

### new features

- add RTF support with
  [`officer::rtf_add()`](https://davidgohel.github.io/officer/reference/rtf_add.html).
- new convert
  [`tables::tabular()`](https://dmurdoch.github.io/tables/reference/tabular.html)
  to flextable with new function
  [`as_flextable.tabular()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md).
- add
  [`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)
  to make easy embedding of flextable results in HTML (with ‘ggiraph’
  for example).
- add global setting `border.width` (see `?set_flextable_defaults()`)
  and set its default value to .75, this setting is used in theme
  functions. The old default value was hard coded to 1 and can be
  defined during the whole R session with
  `set_flextable_defaults(border.width = 1)`.

### internals

- drop ‘base64enc’ dependency and use ‘officer’ functions as
  replacement.
- Use
  [`officer_url_encode()`](https://davidgohel.github.io/officer/reference/officer_url_encode.html)
  to encode URL in office files.
- refactor
  [`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
  and related functions.
- drop webshot dependency to produce images, now using package ‘ragg’.
- refactor captions: knitr context now updates the caption instead of
  managing caption value and defined knitr options.
- use shadow in all HTML output generated via knitr (i.e. ‘Quarto’ and
  ‘R Markdown’).

### issues

- support revealjs (and probably all RMD formats that generate HTML)
- fix cell’s vertical alignments in latex
- fix detection of non transparent background table in latex so that the
  correct lines instructions (hhlines or clines) are being used.
- fix
  [`headers_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/headers_flextable_at_bkm.md)
  and
  [`footers_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/footers_flextable_at_bkm.md)

## flextable 0.8.5

CRAN release: 2023-01-29

### changes

- use pkgdown features instead of images shots in the manual examples.
  The website now shows flextable results.

### issues

- fix issue with flextable_to_rmd and pdf introduced in `0.8.4`.
- fix caption issue with Word and
  [`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md).

## flextable 0.8.4

CRAN release: 2023-01-21

### new features

- new argument `expand_single` in
  [`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md).
  If `FALSE`, groups with only one row will not be expanded with a title
  row.
- argument `labels` of
  [`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md)
  now support functions in addition to named vectors.
- [`as.character()`](https://rdrr.io/r/base/character.html) now returns
  the HTML string of the table
- new method `as_flextable` for data.frame using
  [`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md)
  function implementation.

### Issues

- fix mis-calculated columns widths in latex
- fix horizontal lines in latex tables
- adapt latex table container to quarto changes
- Word caption: autonumber works without bookmark

## flextable 0.8.3

CRAN release: 2022-11-06

### new features

- new argument `expand_single` in
  [`as_grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_grouped_data.md).
  If FALSE, groups with only one row will not be expanded with a title
  row.
- new functions
  [`fmt_avg_dev()`](https://davidgohel.github.io/flextable/dev/reference/fmt_avg_dev.md),
  [`fmt_header_n()`](https://davidgohel.github.io/flextable/dev/reference/fmt_header_n.md),
  [`fmt_n_percent()`](https://davidgohel.github.io/flextable/dev/reference/fmt_n_percent.md)
  and renaming of
  [`fmt_2stats()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md)
  to
  [`fmt_summarizor()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md)
  to help working with
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
  has also new internal values that allow N=xxx notes and automatic
  labels.
- function
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  is now the recommanded way to set arguments related to format options
  and alignment in a document. It is supposed to replace “knitr” chunk
  options `ft.align`, `ft.split`, `ft.keepnext`, `ft.tabcolsep`,
  `ft.arraystretch`, `ft.latex.float`, `ft.shadow`, `fonts_ignore`
  although they are all still supported. This allows less interaction
  with the ‘R Markdown’ or ‘Quarto’ eco-system and let to define it
  globally with
  [`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md).
- HTML scrolling can be activated by calling
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  and providing a *scroll* value for argument `opts_html`:
  `opts_html = list(scroll = list(height = "500px",freeze_first_column = TRUE))`.
- new function
  [`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md)
  to let users add grid graphics
- functions
  [`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md),
  [`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
  [`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md),
  [`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md)
  and
  [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
  now supports formatted paragraph made with
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).
- captions: support for simple text in addition to
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
- [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  can now be transformed directly as a flextable with method
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md).

### Issues

- fix issue with keepnext and
  [`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md)
- fix issue of misordered chunks with
  [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)
- argument ‘unit’ is dropped in
  [`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md)
  as it is expected to be a ratio

### Changes

- `ft.keepnext` now default to FALSE as lot of users had issues with
  this option.
- function `xtable_to_flextable()` is removed (use
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md))

## flextable 0.8.2

CRAN release: 2022-09-26

### Issues

- prevent docx captions test when pandoc version is “2.9.2.1” (on CRAN
  Flavor r-devel-linux-x86_64-fedora-gcc).

## flextable 0.8.1

CRAN release: 2022-09-19

### Issues

- fix warning with subscript and superscript
  [\#456](https://github.com/davidgohel/flextable/issues/456)
- prevent usage of gregexec if R \< 4.1
- fix for rdocx captions

## flextable 0.8.0

CRAN release: 2022-09-11

### new features

- flextable now supports “Grid graphics” output format. See
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md).
- [`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md)
  is a new function to help change text by labels.
- add support for paragraph settings (made with
  [`fp_par()`](https://davidgohel.github.io/officer/reference/fp_par.html))
  in captions with
  [`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md).
- captions are now made with
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
- caption alignments and keep_with_next is now computed instead of being
  provided by user
- alternative text for Word tables with word_title and word_description
  by calling
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  or setting values to knitr chunk options `tab.alt.title` and
  `tab.alt.description`.
- Word and HTML captions paragraphs settings can be defined by using
  [`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md).
  The alignment of the paragraph can be different from the alignment of
  the table with the argument `align_with_table=FALSE`.
- new theme ‘APA’, `theme_apa` ([@rempsyc](https://github.com/rempsyc)
  [\#426](https://github.com/davidgohel/flextable/issues/426))
- method
  [`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md)
  gains an argument `spread_first_col` to enable spreading of the first
  column of the table as a line separator.
- fix doc links to functions from other packages for future releases

### Issues

- fix caption issue resulting from a clash with variable name ‘n’
  ([\#443](https://github.com/davidgohel/flextable/issues/443))
- Quarto support
- fix as_grouped_data() with date columns
  ([\#438](https://github.com/davidgohel/flextable/issues/438))
- fix footnotes spread over separate lines when ‘inline’
  ([\#442](https://github.com/davidgohel/flextable/issues/442))
- fix missing caption with rmarkdown pdf output
- fix first horizontal borders repeated issue with Word output
- add empty paragraphs between tables in
  [`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md)
  to avoid Word confusion
- fix `fortify_width()` calculation

## flextable 0.7.3

CRAN release: 2022-08-09

### new features

- function
  [`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md)
  gained an argument `label_rows` used for labels to display in the
  first column names, i.e. the *row* column names.
- new function
  [`shift_table()`](https://davidgohel.github.io/flextable/dev/reference/shift_table.md)
  to produce Shift Tables used used in clinical trial analysis ready to
  be used by
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).
- [`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md)
  don’t need anymore parameters `width` and `height` if package ‘magick’
  is available.

### Changes

- `plot.flextable` now default to *grid Graphics*. It produce a plot
  object that can be used with packages ‘ggplot2’, ‘patchwork’ and
  ‘cowplot’. The raster version made with ‘webshot’ and ‘magick’
  pachages is still available, use `plot(..., method = "webshot")`.

### Issues

- fix top borders correction (for docx and pptx)
- check that used colors do not contain NA
- fix HTML scrolling that is always visible to Windows users
- fix “cs.family”, “hansi.family” and “eastasia.family” for Word
- fix anti-selectors for bg/color/highlight, a regression from version
  0.7.2
- when HTML and layout “autofit”, output width is not set when width has
  been defined to 0 to avoid unnecessary word breaks
  ([\#429](https://github.com/davidgohel/flextable/issues/429)).

### Changes

- pptx output is constructed with top and bottom margins whose value is
  top and bottom padding of the paragraph and there is no more borders
  copies while rendering.
- add visual tests with doconv
- footnote can not be used with “” symbols, use
  [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
  instead.

## flextable 0.7.2

CRAN release: 2022-06-12

### Issues

- fix selector issue with numeric values
  ([\#409](https://github.com/davidgohel/flextable/issues/409))

## flextable 0.7.1

CRAN release: 2022-06-01

### new features

- function
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  has now methods for lm, glm, models from package ‘lme’ and ‘lme4’,
  htest (t.test, chisq.test, …), gam, kmeans and pam.
- new function
  [`use_model_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_model_printer.md)
  to set model automatic printing as a flextable in an R Markdown
  document.
- new function
  [`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md)
  to add a row in the body part with eventually merged/spanned
  columns.  
- new function
  [`tabulator_colnames()`](https://davidgohel.github.io/flextable/dev/reference/tabulator_colnames.md)
  to get column names of a `tabulator` object.
- new function
  [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)
  to prepend chunks of content in flextable cells as with
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
  but without replacing the whole content.
- addition of chunk function
  [`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md)
  to let add ‘Word’ computed values into a flextable, as
  `as_word_field(x = "Page")` for a page number.
- new function
  [`separate_header()`](https://davidgohel.github.io/flextable/dev/reference/separate_header.md)
  to Separate collapsed colnames into multiple rows.
- Functions
  [`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
  and
  [`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
  now support newlines.
- [`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
  and
  [`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
  now have an argument `hspans` to help specify how horizontally spanned
  cells should affect the results.
- PDF output now supports various floating placement options with knitr
  option `ft.latex.float`, supported values are ‘none’ (the default
  value), ‘float’, ‘wrap-r’, ‘wrap-l’, ‘wrap-i’ and ‘wrap-o’.
- HTML output have now a scrool bar if width does not fit in the
  container. This can be switch off by using the knitr option
  `ft.htmlscroll = FALSE`.
- [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
  can display any columns before and after the columns of displayed
  aggregations.

### Issues

- fix append_chunks usage by adding `i`, `j` and `part` at the end of
  the function arguments, after the `...`.
- add forgotten `supp_data` in the result table of
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
- merged horizontal borders are now visible in PowerPoint
  ([\#378](https://github.com/davidgohel/flextable/issues/378))
- PowerPoint ‘soft returns’ are now real ‘soft returns’.
  ([\#379](https://github.com/davidgohel/flextable/issues/379))
- mapping between argument `j` and `source` when color is a function (in
  [`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
  [`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md)
  and
  [`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md))
  is now based on colnames to avoid mistake while mapping.
  [\#395](https://github.com/davidgohel/flextable/issues/395)
- Fix issue with footnotes forcing rectangular extent for selection;
  thanks to Sean Browning
- fix horizontal and vertical alignements when rotating paragraphs for
  pptx, docx and html outputs
- links in pptx and docx are not transformed anymore.
- fix handling of special characters in latex
- vertically merged cells now wrap text into the paragraph

### Changes

- refactor the code for pptx and docx output

## flextable 0.7.0

CRAN release: 2022-03-06

### new features

- new function
  [`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
  to append chunks of content in flextable cells as with
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
  but without replacing the whole content.
- new function
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
  and its method
  [`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md)
  that help the creation of tables used in life science industry. It
  also comes with function
  [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  and sugar function
  [`fmt_2stats()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md).
- [`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md)
  gained arguments `width` so that users can also set blank columns’
  width.
- pass `...` to [`format()`](https://rdrr.io/r/base/format.html)
  function when using
  [`colformat_num()`](https://davidgohel.github.io/flextable/dev/reference/colformat_num.md).
  It makes possible to use arguments for
  [`format()`](https://rdrr.io/r/base/format.html), for example
  `colformat_num(drop0trailing = TRUE)`.
- add knitr chunk option `ft.keepnext` and parameter `keepnext` to
  function
  [`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md)
  that enable the Word option ‘keep rows together’, so that page break
  within a table is avoided when possible.
- new function
  [`add_latex_dep()`](https://davidgohel.github.io/flextable/dev/reference/add_latex_dep.md)
  to manually add flextable latex dependencies to the knitr session.

### Issues

- fix Rd files which when converted to HTML had `<img>` entries with
  invalid width attributes e.g. `width=40\%`.

### Changes

- In a bookdown context and without package officedown, it is not
  possible to keep the cross-references as they are provided by bookdown
  and to provide a real Word cross-reference on table captions (the
  reference number only is displayed). That’s why when using bookdown
  without package officedown : 1. Word auto-numbering is desactivated
  and 2. caption prefix formatting feature.

## flextable 0.6.10

CRAN release: 2021-11-15

### new features

- add function `df_printer` that can be used via the `df_print` option
  of R Markdown documents or by calling
  [`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md).
- add support to knitr table options `tab.cap.fp_text` to let format
  caption prefix in function
  [`opts_current_table()`](https://davidgohel.github.io/officer/reference/opts_current_table.html).
- Applies existing formatting properties to new header/footer lines

### Issues

- fix convertion when unit = “mm”
- fix regression with captions when bookdown generate a ‘Word’ document
  [\#354](https://github.com/davidgohel/flextable/issues/354)
- fix highlight for PowerPoint

### Enhancement

- Theme functions behavior is now more detailed in the manual.

## flextable 0.6.9

CRAN release: 2021-10-07

### new features

- add “nan” option in formatting functions  
  `colformat_*` and `set_flextable_defaults`.
- new function
  [`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md)
  to ease the highlighting of specific cells with borders.
- add “pdf” option for previewing a flextable in PDF with
  `print(x, preview ="pdf")`.

### Issues

- fix width with border overlaps in pdf
- chunks are now ordered as expected in pdf
- markdown can be used in table captions in R Markdown documents

## flextable 0.6.8

CRAN release: 2021-09-06

### Issues

- fix issue with border spaces and widths in HTML output.
  [\#343](https://github.com/davidgohel/flextable/issues/343)
- fix tests obfuscations with “pandoc-citeproc” that was not necessary.

## flextable 0.6.7

CRAN release: 2021-07-22

### new features

- tab.lp is now a knitr supported chunk option and can be use to change
  the label prefix for the table sequence id when a caption is used. See
  <https://github.com/davidgohel/officedown/issues/71>.
- support for `tab.topcaption` that let modify the table caption
  position from “top” (TRUE) to “bottom” (FALSE).
- add helper function
  [`before()`](https://davidgohel.github.io/flextable/dev/reference/before.md)
  to ease addition of
  [`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md)
  before some values to match with.

### Issues

- fix issue with white spaces instead of empty borders in HTML output
- fix issue with missing top or right border in LaTeX output (thanks to
  huaixv for the fix)
- Table cells containing square braces were causing errors (thanks to
  Nick Bart for the fix)
- fix proc_freq error when include.row_percent, include.table_percent
  and include.column_percent are all set to FALSE.

## flextable 0.6.6

CRAN release: 2021-05-17

### new features

- add argument `ft.shadow = TRUE` to htmltools_value so that shadow dom
  can not be used.
- add arguments “cs.family”, “hansi.family” and “eastasia.family” to
  `fontname`.
- add “line_spacing” to defaults formatting properties (see
  `set_flextable_defaults(line_spacing=1)`)

### Issues

- fix issue with spaces in latex - see
  [\#314](https://github.com/davidgohel/flextable/issues/314)
- fix issue with powerpoint hyperlinks - see
  [\#310](https://github.com/davidgohel/flextable/issues/310)
- fix issue with conditional color with scale - see
  [\#309](https://github.com/davidgohel/flextable/issues/309)

## flextable 0.6.5

CRAN release: 2021-04-11

### new features

- add function `as_equation` for ‘MathJax’ equations.
- add argument `text_after` to function `flextable_to_rmd` to let append
  any text to the produced flextable.

## flextable 0.6.4

CRAN release: 2021-03-10

### new features

- export of `chunk_dataframe` for those who want to create functions
  that work with `as_paragraph`.
- in R Markdown for Word, bookmarks are now added to captions when
  output format is from bookdown
- shadow hosts HTML elements get the class `flextable-shadow-host`.
- `set_flextable_defaults` now accept argument `padding` that set values
  for padding top, bottom, left and right.
- new functions `colorize`, `as_highlight`
- functions `nrow_part` and `ncol_keys` are now exported

### Issues

- fix for minibar when all values are equal to zero (thanks to Martin
  Durian)
- fix URLs formatted incorrectly in Word and PowerPoint (thanks to David
  Czihak)

## flextable 0.6.3

CRAN release: 2021-02-01

### new features

- `compose` has a new argument `use_dot` to let use `.` and loop over
  columns
- new function
  [`init_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
- inst/mediasrc/man-figures.R can also be used for visual testing with
  `git diff`

### Issues

- fix line spacing with pdf output
- Now `colformat_num` calls the `format` function on the numeric values
  (integer and float) which are therefore displayed as in console R.
  This function is used during the creation of a flextable so that by
  default the content of the cells is the same as that displayed in
  console R.

## flextable 0.6.2

CRAN release: 2021-01-25

### changes

- new documentation! See at
  <https://ardata-fr.github.io/flextable-book/>

### new features

- `merge_v` has a new argument `combine` to let use j columns be used as
  a single value (all values are pasted).
- new function `add_body` for adding rows into a flextable body
- new function `colformat_image` for images in flextable
- new method `as_flextable` for `gam` models
- function `set_flextable_defaults` gained 4 new arguments
  `post_process_pdf`, `post_process_html`, `post_process_docx` and
  `post_process_pptx` to enable flextable post-treatments conditionned
  by the output format.
- new helper functions `fp_text_default` and `fp_border_default`.

### Issues

- fix encoding issue with Windows platforms
- bring back caption into the table
- fix overlapping issue with hline_top
  [\#244](https://github.com/davidgohel/flextable/issues/244)
- fix `\n` and `\t` usage for pdf

## flextable 0.6.1

CRAN release: 2020-12-08

### new features

- HTML flextable are now isolated from the document CSS (except caption
  which is copied before).

### Issues

- correction of latex tables which resulted in a centering of the
  following text.
- minor correction for density graphs inserted in tables
- fix suffix/prefix usage in colformat\_\* functions

### changes

- drop defunct functions.

## flextable 0.6.0

CRAN release: 2020-12-01

### new features

- flextable now supports PDF/latex output format.
- new function
  [`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md)
  for text highlighting color
- new function
  [`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
  to set some default formatting properties, i.e. default border color,
  font color, padding, decimal.mark …
- `save_as_docx` gained a new argument `pr_section` to define page
  layout with section properties, `save_as_html` can now output more
  than a single table.
- `colformat_` functions now use default values and filter columns that
  are irrelevant (i.e. if colformat_num, only numeric values are
  formatted). Also, new `colformat_` functions have been implemented
  (`colformat_date`, `colformat_datetime` and `colformat_double`).
- new functions `plot_chunk` and `gg_chunk` to add miniplots or ggplots
  into a flextable

### changes

- defunct of `ph_with_flextable()`
- use pandoc’s raw attribute when possible within “R Markdown”
  documents.

### Issues

- fix bug in HTML output with invalid css when locale makes decimal
  separator not `.`
- `fix_border_issues` is the last instruction of all theme functions so
  that borders are corrected if some cells have been merged.
- caption was always printed in bookdown and now it’s conditionned by
  testing if `tab_props$cap` has a value.
- fix missing tfoot tag in HTML output

## flextable 0.5.11

CRAN release: 2020-09-09

### Changes

- HTML code is now minimized as CSS styles are now used instead of
  inline CSS.

### new features

- save_as_html now accepts argument `encoding`
- line spacing (for Word and PowerPoint) or line height (for HTML) can
  now be defined with function
  [`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md)
  (or with function
  [`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md)).

### Issues

- selection when i or j was integer(0) was resulting to all rows, it’s
  now fixed. To select all rows or columns, use `i = NULL` or
  `j = NULL`, to select none, `i = integer(0)` or `j = integer(0)`.
- tab were not displayed when output was HTML

## flextable 0.5.10

CRAN release: 2020-05-15

### new features

- flextable captions in Word can be auto-numbered and bookmarked
- function `footnote` is now able to add inline footnotes
- support for bookdown references
- new as_flextable methods for lm and glm objects and xtable (replacing
  `xtable_to_flextable()`)
- new sugar function
  [`continuous_summary()`](https://davidgohel.github.io/flextable/dev/reference/continuous_summary.md):
  summarize continuous columns in a flextable
- function `autofit` can now use only some parts of the tables. This
  allows for example to no longer have gigantic columns by not taking
  into account the “footer” part that is often composed of long texts.
- bookdown and xaringan HTML outputs should now be rendered as
  expected - table css has been overwritten.
- new function `set_table_properties` lets adapt flextable size as
  “100%”, “50%” of the available width for Word and HTML.

### Changes

- manual pages have been improved and illustrations are added
- [`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md)
  and
  [`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md)
  now accept functions
  (i.e. [`scales::col_numeric()`](https://scales.r-lib.org/reference/col_numeric.html))

## flextable 0.5.9

CRAN release: 2020-03-06

### Changes

- defunct of
  [`display()`](https://rdrr.io/pkg/xtable/man/table.attributes.html)
- rename arg ‘formater’ to ‘formatter’ of `as_chunk`
  ([\#152](https://github.com/davidgohel/flextable/issues/152))

### Internal

- drop `officer::fp_sign` importation that was not used anymore so that
  officer can drop digest dependency.

## flextable 0.5.8

CRAN release: 2020-02-17

### Changes

- deprecation of
  [`display()`](https://rdrr.io/pkg/xtable/man/table.attributes.html).
- defunct of `ph_with_flextable_at()`
- function `knit_to_wml()` has new arguments `align`, `split` and
  `tab.cap.style`
- function
  [`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md)
  has a new argument `ft.align`

### new features

- new function `flextable_html_dependency` to get flextable
  htmltools::htmlDependancy. This is necessary to output flextables in
  html R Markdown documents from loop or other nested operations.

### Issues

- fix issue [\#188](https://github.com/davidgohel/flextable/issues/188),
  add_rows error that came with version 0.5.7

## flextable 0.5.7

CRAN release: 2020-02-03

### new features

- new suger functions `save_as_docx`, `save_as_pptx` that lets users
  export flextable objects to PowerPoint or Word documents.

### Changes

- merge_v can use hidden columns.
- new function `hrule` to control how row heights should be understood
  (at least, auto, exact)
- Allow unused values in set_header_labels - PR
  [\#172](https://github.com/davidgohel/flextable/issues/172) from
  DanChaltiel
- deprecation of ph_with_flextable_at, ph_with_flextable will be
  deprected in the next release

### Issues

- fix issue [\#180](https://github.com/davidgohel/flextable/issues/180),
  background color of runs transparency issue with googlesheet
- fix issue [\#157](https://github.com/davidgohel/flextable/issues/157),
  issue with rotate and HTML output

## flextable 0.5.6

CRAN release: 2019-11-12

### Issues

- force officer \>= 0.3.6
- fix rounding issue for css borders

## flextable 0.5.6

CRAN release: 2019-11-12

### new features

- new function `lollipop` that lets users add mini lollipop chart to
  flextable (kindly provided by github.com/pteridin)
- function `proc_freq` got a new argument `weight` to enable weighting
  of results.
- function
  [`as_flextable.grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.grouped_data.md)
  has now an argument `hide_grouplabel` to let not print the group
  names.

### Issues

- let footnotes symbols be affected by style functions (related to
  [\#137](https://github.com/davidgohel/flextable/issues/137))
- enable usage of ‘webshot2’ instead of ‘webshot’. It enable better
  screenshots. It can be specified with argument `webshot` in function
  `save_as_image` or with chunk option `webshot="webshot2"`.

## flextable 0.5.5

CRAN release: 2019-06-25

### new features

- new function `knit_to_wml` to let display flextables from non top
  level calls inside R Markdown document.
- ph_with method for flextable object. This enable `ph_location*` usage
  and make placement into slides easier.
- new function `fit_to_width` to fit a flextable to a maximum width
- `set_caption` can now be used with R Markdown for Word document and
  caption style can be defined with chunk option `tab.cap.style`.

### Issues

- fix issue with `save_as_image` with R for Windows

## flextable 0.5.3

### new features

- new functions to render flextable in plot (see `plot`), as an image
  (see `save_as_image`) and raster for ggplot2 (see `as_raster`).
- new function `footnote` to ease footnotes management
- colformat functions are suporting i argument now for rows selection.

## flextable 0.5.2

CRAN release: 2019-04-02

### new features

- new function `valign` to align vertically paragraphs in cell
- new function `proc_freq` that mimic SAS proc freq provided by Titouan
  Robert.
- new function `linerange` to produce mini lineranges.

### Issues

- fix issue with `set_footer_df`

## flextable 0.5.1

CRAN release: 2019-02-07

### Issues

- fix issue with font colors in powerpoint
- fix issues with colors for Windows RStudio viewer

### new features

- new themes functions
  [`theme_alafoli()`](https://davidgohel.github.io/flextable/dev/reference/theme_alafoli.md)
  and
  [`theme_vader()`](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md)
- new functions
  [`align_text_col()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  and
  [`align_nottext_col()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  to align columns by data type
- new functions
  [`merge_h_range()`](https://davidgohel.github.io/flextable/dev/reference/merge_h_range.md)
  to merge a set of columns row by row
- new functions
  [`fix_border_issues()`](https://davidgohel.github.io/flextable/dev/reference/fix_border_issues.md)
  fix issues with borders when cells are merged
- new functions
  [`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md),
  [`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
  [`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md)
  and
  [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
  to add easily data in header or footer.
- new generic function
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  to let develop new flextable functions
- new function
  [`as_grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_grouped_data.md)
  and its method
  [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  to create row titles to separate data in a flextable.

## flextable 0.5.0

CRAN release: 2019-01-31

### Improvement

- new arguments `values` for functions `set_header_labels` and
  `set_formatter`
- styles functions now support injection of more than a single value
- this version a big refactoring and got rid of R6

### new features

- new function `compose` that will replace `display`
- new function `set_caption` only available for html output

## flextable 0.4.7

### new features

- `knit_print()` can be used with rmarkdown when rendering to
  PowerPoint.

### Issues

- fix issue with `regulartable` and logical columns

## flextable 0.4.6

CRAN release: 2018-10-31

### new features

- a new helper function `body_replace_flextable_at_bkm` to replace a
  bookmarked paragraph by a flextable.
- new functions `colformat_*` to make content formatting easier. It also
  deals with NA.

### Improvement

- Documentation `format.flextable` method so that users can create their
  components.
- new knitr chunk options `ft.align` to align tables in
  [`rmarkdown::word_document`](https://pkgs.rstudio.com/rmarkdown/reference/word_document.html)
  and `ft.split` to activate Word option ‘Allow row to break across
  pages’.

### Issues

- fix issue (unordered and duplicated chunk of text) in function
  [`display()`](https://rdrr.io/pkg/xtable/man/table.attributes.html)

## flextable 0.4.5

CRAN release: 2018-08-27

### Improvement

- flextable will not be split across rows at a page break in Word
  documents.

### Issues

- fix border rendering with
  [`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md)
- empty data.frame are no more generating an error

## flextable 0.4.4

CRAN release: 2018-04-19

### new features

- Soft return `\n` is now supported. Function `autofit` and `dim_pretty`
  do not support soft returns and may return wrong results (will be
  considered as ““).
- format function for flextable objects.

### Issues

- fix border rendering with
  [`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md)

## flextable 0.4.3

CRAN release: 2018-03-14

### new features

- new functions:
  [`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)
  to be used with `display`,
  [`font()`](https://davidgohel.github.io/flextable/dev/reference/font.md)
- new functions `hline*()` and `vline*()` and many new helper functions
  to be used instead of borders.

### Improvement

- manuals have been refactored

### Issues

- fix display issue when a cell was containing NA

## flextable 0.4.2

CRAN release: 2018-01-10

### new features

- new function `xtable_to_flextable()` that is returning a flextable
  from an xtable object.
- function
  [`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md)
  is exported for shiny applications.

## flextable 0.4.1

### new features

- flextables have now a footer part

## flextable 0.4.0

CRAN release: 2017-12-08

### new features

- new function `knit_print()` to render flextable in rmarkdown.

### Changes

- function tabwid() is deprecated in favor of a knit_print
  implementation.
- list of dependencies has been reduced.

## flextable 0.3

### new features

- new function `regulartable`, faster and simpler than `flextable`

### Issues

- characters \<, \> and & are now html encoded
- fix columns widths when output format is HTML

## flextable 0.2

### new features

- new function `ph_with_flextable_at` to add a flextable at any position
  in a slide.
- new function `merge_at` is providing a general way of merging cells.
- new theme function:
  [`theme_box()`](https://davidgohel.github.io/flextable/dev/reference/theme_box.md)

### Changes

- function display() now works with a mustache template

### Issues

- fix fontsize when part == “all”
