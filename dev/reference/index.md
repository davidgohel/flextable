# Package index

## Create a flextable

Functions to create flextable objects from data frames or other R
objects. Start here - flextable() is the main constructor, qflextable()
is a quick shortcut, and as_flextable() converts other objects.

- [`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
  [`qflextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
  : Create a flextable from a data frame
- [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  : Method to transform objects into flextables
- [`flextable-package`](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  : flextable: Functions for Tabular Reporting

## Convert objects to flextable

Transform statistical models, cross-tabulations, and summary tables into
flextables. Use tabulator() for pivot-style tables, summarizor() for
descriptive statistics, and specific as_flextable methods for models.

- [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
  [`summary(`*`<tabulator>`*`)`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
  : Create pivot-style summary tables
- [`tabulator_colnames()`](https://davidgohel.github.io/flextable/dev/reference/tabulator_colnames.md)
  : Column keys of tabulator objects
- [`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md)
  : Prepare descriptive statistics for flextable
- [`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
  : Method to transform objects into flextables
- [`as_flextable(`*`<compact_summary>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.compact_summary.md)
  : Transform a 'compact_summary' object into a flextable
- [`as_flextable(`*`<data.frame>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.data.frame.md)
  : Transform and summarise a 'data.frame' into a flextable Simple
  summary of a data.frame as a flextable
- [`as_flextable(`*`<gam>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.gam.md)
  : Transform a 'gam' model into a flextable
- [`as_flextable(`*`<glm>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.glm.md)
  : Transform a 'glm' object into a flextable
- [`as_flextable(`*`<grouped_data>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.grouped_data.md)
  : Transform a 'grouped_data' object into a flextable
- [`as_flextable(`*`<htest>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.htest.md)
  : Transform a 'htest' object into a flextable
- [`as_flextable(`*`<kmeans>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.kmeans.md)
  : Transform a 'kmeans' object into a flextable
- [`as_flextable(`*`<lm>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.lm.md)
  : Transform a 'lm' object into a flextable
- [`as_flextable(`*`<merMod>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<lme>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<gls>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<nlme>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<brmsfit>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<glmmTMB>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  [`as_flextable(`*`<glmmadmb>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md)
  : Transform a 'merMod' or 'lme' object into a flextable
- [`as_flextable(`*`<pam>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.pam.md)
  : Transform a 'pam' object into a flextable
- [`as_flextable(`*`<summarizor>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.summarizor.md)
  : Transform a 'summarizor' object into a flextable
- [`as_flextable(`*`<table>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.table.md)
  : Transform a 'table' object into a flextable
- [`as_flextable(`*`<tabular>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md)
  : Transform a 'tables::tabular' object into a flextable
- [`as_flextable(`*`<tabulator>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md)
  : Transform a 'tabulator' object into a flextable
- [`as_flextable(`*`<xtable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.xtable.md)
  : Transform a 'xtable' object into a flextable
- [`continuous_summary()`](https://davidgohel.github.io/flextable/dev/reference/continuous_summary.md)
  : Summarize continuous variables as a flextable
- [`compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/compact_summary.md)
  : Compact Summary of a Dataset
- [`as_grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_grouped_data.md)
  : Insert group-label rows into a data frame
- [`proc_freq()`](https://davidgohel.github.io/flextable/dev/reference/proc_freq.md)
  : Frequency table
- [`shift_table()`](https://davidgohel.github.io/flextable/dev/reference/shift_table.md)
  : Create a shift table

## Headers, footers and structural changes

Add or modify header rows, footer rows, or body rows. Set column labels.
Remove rows, columns, or entire parts (header, body, footer) from the
table.

- [`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md)
  : Add a header row with spanning labels
- [`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md)
  : Add full-width rows to the header
- [`add_header()`](https://davidgohel.github.io/flextable/dev/reference/add_header.md)
  : Add header rows with one value per column
- [`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md)
  : Add a footer row with spanning labels
- [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
  : Add full-width rows to the footer
- [`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md)
  : Add footer rows with one value per column
- [`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md)
  : Add body rows with one value per column
- [`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md)
  : Add a body row with spanning labels
- [`separate_header()`](https://davidgohel.github.io/flextable/dev/reference/separate_header.md)
  : Split column names using a separator into multiple rows
- [`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md)
  : Rename column labels in the header
- [`set_header_df()`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md)
  [`set_footer_df()`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md)
  : Replace the entire header or footer from a data frame
- [`delete_part()`](https://davidgohel.github.io/flextable/dev/reference/delete_part.md)
  : Delete flextable part
- [`delete_rows()`](https://davidgohel.github.io/flextable/dev/reference/delete_rows.md)
  : Delete flextable rows
- [`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md)
  : Delete flextable columns

## Merge cells

Combine adjacent cells horizontally or vertically to create spanning
cells. Useful for grouped headers or repeated values.

- [`merge_at()`](https://davidgohel.github.io/flextable/dev/reference/merge_at.md)
  : Merge flextable cells into a single one
- [`merge_h()`](https://davidgohel.github.io/flextable/dev/reference/merge_h.md)
  : Merge flextable cells horizontally
- [`merge_h_range()`](https://davidgohel.github.io/flextable/dev/reference/merge_h_range.md)
  : Rowwise merge of a range of columns
- [`merge_none()`](https://davidgohel.github.io/flextable/dev/reference/merge_none.md)
  : Delete flextable merging information
- [`merge_v()`](https://davidgohel.github.io/flextable/dev/reference/merge_v.md)
  : Merge flextable cells vertically

## Format cell values

Control how values are displayed: number of decimals, date formats,
thousand separators, currency symbols. Use colformat\_\* functions for
column-wide formatting.

- [`colformat_char()`](https://davidgohel.github.io/flextable/dev/reference/colformat_char.md)
  : Format character cells
- [`colformat_date()`](https://davidgohel.github.io/flextable/dev/reference/colformat_date.md)
  : Format date cells
- [`colformat_datetime()`](https://davidgohel.github.io/flextable/dev/reference/colformat_datetime.md)
  : Format datetime cells
- [`colformat_double()`](https://davidgohel.github.io/flextable/dev/reference/colformat_double.md)
  : Format double cells
- [`colformat_image()`](https://davidgohel.github.io/flextable/dev/reference/colformat_image.md)
  : Format cells as images
- [`colformat_int()`](https://davidgohel.github.io/flextable/dev/reference/colformat_int.md)
  : Format integer cells
- [`colformat_lgl()`](https://davidgohel.github.io/flextable/dev/reference/colformat_lgl.md)
  : Format logical cells
- [`colformat_num()`](https://davidgohel.github.io/flextable/dev/reference/colformat_num.md)
  : Format numeric cells with format()
- [`set_formatter()`](https://davidgohel.github.io/flextable/dev/reference/set_formatter.md)
  : Set column formatter functions
- [`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md)
  : Replace displayed text with labels

## Compose rich content

Create cells with mixed content: combine text, images, plots, and
formatted chunks in a single cell. Use compose() with as_paragraph().

- [`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
  [`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
  : Set cell content from paragraph chunks
- [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
  : Build a paragraph from chunks
- [`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
  : Append chunks to flextable content
- [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)
  : Prepend chunks to flextable content
- [`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
  : Add footnotes to flextable

## Content chunks

Building blocks for rich cell content. Use inside as_paragraph() or
compose(): text formatting (as_b, as_i), images (as_image, gg_chunk),
links (hyperlink_text), equations (as_equation).

- [`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)
  : Text chunk
- [`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md)
  : Bold chunk
- [`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md)
  : Italic chunk
- [`as_strike()`](https://davidgohel.github.io/flextable/dev/reference/as_strike.md)
  : Strikethrough chunk
- [`as_sub()`](https://davidgohel.github.io/flextable/dev/reference/as_sub.md)
  : Subscript chunk
- [`as_sup()`](https://davidgohel.github.io/flextable/dev/reference/as_sup.md)
  : Superscript chunk
- [`as_highlight()`](https://davidgohel.github.io/flextable/dev/reference/as_highlight.md)
  : Highlight chunk
- [`colorize()`](https://davidgohel.github.io/flextable/dev/reference/colorize.md)
  : Colorize chunk
- [`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md)
  : Bracket chunk
- [`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)
  : Hyperlink chunk
- [`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md)
  : Equation chunk
- [`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md)
  : Word dynamic field chunk
- [`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md)
  : Image chunk
- [`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md)
  : ggplot chunk
- [`plot_chunk()`](https://davidgohel.github.io/flextable/dev/reference/plot_chunk.md)
  : Mini plot chunk
- [`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md)
  : Grid Graphics chunk
- [`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md)
  : Mini barplot chunk
- [`linerange()`](https://davidgohel.github.io/flextable/dev/reference/linerange.md)
  : Mini linerange chunk

## Apply themes

Apply predefined visual themes to quickly style the entire table. Themes
set fonts, colors, borders, and padding in one call.

- [`theme_alafoli()`](https://davidgohel.github.io/flextable/dev/reference/theme_alafoli.md)
  : Apply alafoli theme
- [`theme_apa()`](https://davidgohel.github.io/flextable/dev/reference/theme_apa.md)
  : Apply APA theme
- [`theme_booktabs()`](https://davidgohel.github.io/flextable/dev/reference/theme_booktabs.md)
  : Apply booktabs theme
- [`theme_borderless()`](https://davidgohel.github.io/flextable/dev/reference/theme_borderless.md)
  : Apply borderless theme
- [`theme_box()`](https://davidgohel.github.io/flextable/dev/reference/theme_box.md)
  : Apply box theme
- [`theme_tron()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron.md)
  : Apply tron theme
- [`theme_tron_legacy()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron_legacy.md)
  : Apply tron legacy theme
- [`theme_vader()`](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md)
  : Apply Sith Lord Darth Vader theme
- [`theme_vanilla()`](https://davidgohel.github.io/flextable/dev/reference/theme_vanilla.md)
  : Apply vanilla theme
- [`theme_zebra()`](https://davidgohel.github.io/flextable/dev/reference/theme_zebra.md)
  : Apply zebra theme

## Style text and cells

Control typography and cell appearance: font family, size, color, bold,
italic, background color, text highlighting.

- [`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md)
  : Set formatting properties on a flextable selection
- [`font()`](https://davidgohel.github.io/flextable/dev/reference/font.md)
  : Set font
- [`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md)
  : Set font size
- [`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md)
  : Set bold font
- [`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md)
  : Set italic font
- [`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md)
  : Set font color
- [`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md)
  : Set text highlight color
- [`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md) :
  Set background color
- [`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md)
  : Create text formatting with flextable defaults

## Alignment and spacing

Control text alignment (left, center, right), vertical alignment, cell
padding, line spacing, and text rotation.

- [`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  [`align_text_col()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  [`align_nottext_col()`](https://davidgohel.github.io/flextable/dev/reference/align.md)
  : Set text alignment
- [`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)
  : Set vertical alignment
- [`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md)
  : Set paragraph paddings
- [`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md)
  : Set line spacing
- [`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md)
  : Rotate cell text
- [`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md)
  : Set tabulation marks configuration
- [`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md)
  : Make blank columns transparent

## Borders

Add, remove, or customize cell borders. Use hline/vline for single
lines, border_inner/border_outer for bulk operations, surround for
highlighting.

- [`fp_border_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_border_default.md)
  : Create border formatting with flextable defaults
- [`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md)
  : Set horizontal borders below selected rows
- [`hline_bottom()`](https://davidgohel.github.io/flextable/dev/reference/hline_bottom.md)
  : Set the bottom border of a table part
- [`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md)
  : Set the top border of a table part
- [`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md)
  : Set vertical borders to the right of selected columns
- [`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md)
  : Set the left border of the table
- [`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)
  : Set the right border of the table
- [`border_inner()`](https://davidgohel.github.io/flextable/dev/reference/border_inner.md)
  : Set all inner borders
- [`border_inner_h()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_h.md)
  : Set inner horizontal borders
- [`border_inner_v()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_v.md)
  : Set inner vertical borders
- [`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md)
  : Set outer borders
- [`border_remove()`](https://davidgohel.github.io/flextable/dev/reference/border_remove.md)
  : Remove borders
- [`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md)
  : Surround cells with borders

## Table and column dimensions

Control table width, column widths, and automatic sizing. Use autofit()
for automatic adjustment, width() for manual control.

- [`width()`](https://davidgohel.github.io/flextable/dev/reference/width.md)
  : Set columns width
- [`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
  : Adjust cell widths and heights
- [`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md)
  : Fit a flextable to a maximum width
- [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  : Set table layout and width properties

## Row height and pagination

Control row heights and how tables break across pages. Use paginate() to
split long tables, keep_with_next to prevent orphan rows.

- [`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md)
  [`height_all()`](https://davidgohel.github.io/flextable/dev/reference/height.md)
  : Set flextable rows height
- [`hrule()`](https://davidgohel.github.io/flextable/dev/reference/hrule.md)
  : Set how row heights are determined
- [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)
  : Prevent page breaks inside a flextable
- [`keep_with_next()`](https://davidgohel.github.io/flextable/dev/reference/keep_with_next.md)
  : Set Word 'Keep with next' instructions

## Get dimensions

Query table dimensions: number of rows, columns, pixel sizes. Useful for
dynamic layouts and conditional formatting.

- [`dim(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/dim.flextable.md)
  : Get column widths and row heights of a flextable
- [`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
  : Calculate optimal column widths and row heights
- [`flextable_dim()`](https://davidgohel.github.io/flextable/dev/reference/flextable_dim.md)
  : Get overall width and height of a flextable
- [`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md)
  : Number of rows of a part
- [`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md)
  : Number of columns

## Caption and labels

Add table captions for cross-referencing in documents. Captions appear
above or below the table and can be numbered automatically.

- [`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)
  : Set flextable caption

## Save to files

Export flextables to standalone files: Word (.docx), PowerPoint (.pptx),
HTML, RTF, or images (PNG, PDF, SVG).

- [`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md)
  : Save flextable objects in a 'Word' file
- [`save_as_pptx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_pptx.md)
  : Save flextable objects in a 'PowerPoint' file
- [`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md)
  : Save flextable objects in an 'HTML' file
- [`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md)
  : Save flextable objects in an 'RTF' file
- [`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md)
  : Save a flextable in a 'png' or 'svg' file

## Integrate with R Markdown and Quarto

Functions for rendering flextables in R Markdown, Quarto, and knitr
documents. Automatic rendering is usually handled by knit_print.

- [`knit_print(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
  : Render flextable with 'knitr'
- [`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md)
  : Print a flextable inside knitr loops and conditionals
- [`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md)
  : data.frame automatic printing as a flextable
- [`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md)
  : Set data.frame automatic printing as a flextable
- [`use_model_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_model_printer.md)
  : Set automatic flextable printing for models

## Integrate with officer (Word/PowerPoint)

Add flextables to Word and PowerPoint documents created with the officer
package. Use body_add_flextable for Word, ph_with for PowerPoint.

- [`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md)
  : Add flextable into a Word document
- [`body_replace_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/body_replace_flextable_at_bkm.md)
  : Add flextable at bookmark location in a Word document
- [`ph_with(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md)
  : Add a flextable into a PowerPoint slide
- [`rtf_add(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/rtf_add.flextable.md)
  : Add a 'flextable' into an RTF document

## Other output formats

Convert flextables to HTML strings, plots, grobs, or interactive
widgets.

- [`print(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/print.flextable.md)
  : Print a flextable
- [`to_html(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)
  : Get HTML code as a string
- [`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md)
  : Convert a flextable to an HTML object
- [`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)
  : Wrap a flextable for use with patchwork
- [`plot(`*`<flextable>`*`)`](https://davidgohel.github.io/flextable/dev/reference/plot.flextable.md)
  : Plot a flextable
- [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
  : Render a flextable as a graphic object
- [`plot(`*`<flextableGrob>`*`)`](https://davidgohel.github.io/flextable/dev/reference/plot.flextableGrob.md)
  : plot a flextable grob
- [`dim(`*`<flextableGrob>`*`)`](https://davidgohel.github.io/flextable/dev/reference/dim.flextableGrob.md)
  : Get optimal width and height of a flextable grob

## Global defaults

Set default formatting options that apply to all new flextables: fonts,
colors, borders, padding. Reduces repetitive code.

- [`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
  [`init_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
  : Modify flextable defaults formatting properties
- [`get_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/get_flextable_defaults.md)
  : Get flextable defaults formatting properties

## Utilities

Helper functions for conditional display (void), row positioning
(before), and value formatting (fmt\_\*).

- [`fmt_2stats()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md)
  [`fmt_summarizor()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md)
  : Format summarizor statistics as text
- [`fmt_avg_dev()`](https://davidgohel.github.io/flextable/dev/reference/fmt_avg_dev.md)
  : Format mean and standard deviation as text
- [`fmt_dbl()`](https://davidgohel.github.io/flextable/dev/reference/fmt_dbl.md)
  : Format numbers as doubles
- [`fmt_header_n()`](https://davidgohel.github.io/flextable/dev/reference/fmt_header_n.md)
  : Format count as '(N=XX)' for column headers
- [`fmt_int()`](https://davidgohel.github.io/flextable/dev/reference/fmt_int.md)
  : Format numbers as integers
- [`fmt_n_percent()`](https://davidgohel.github.io/flextable/dev/reference/fmt_n_percent.md)
  : Format count and percentage as text
- [`fmt_pct()`](https://davidgohel.github.io/flextable/dev/reference/fmt_pct.md)
  : Format numbers as percentages
- [`fmt_signif_after_zeros()`](https://davidgohel.github.io/flextable/dev/reference/fmt_signif_after_zeros.md)
  : Format with significant figures after zeros
- [`before()`](https://davidgohel.github.io/flextable/dev/reference/before.md)
  : Detect rows before a given value
- [`void()`](https://davidgohel.github.io/flextable/dev/reference/void.md)
  : Clear the displayed content of selected columns
