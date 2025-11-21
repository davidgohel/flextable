# flextable: Functions for Tabular Reporting

The flextable package facilitates access to and manipulation of tabular
reporting elements from R.

The documentation of functions can be opened with command
[`help(package = "flextable")`](https://davidgohel.github.io/flextable/reference).

[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
function is producing flexible tables where each cell can contain
several chunks of text with their own set of formatting properties
(bold, font color, etc.). Function
[`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
lets customise text of cells.

The
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
function is used to transform specific objects into flextable objects.
For example, you can transform a crosstab produced with the 'tables'
package into a flextable which can then be formatted, annotated or
augmented with footnotes.

In order to reduce the homogenization efforts and the number of
functions to be called, it is recommended to define formatting
properties such as font, border color, number of decimals displayed
which will then be applied by default. See
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
for more details.

## Table Structure

A flextable is composed of three distinct parts:

- `header`: By default, contains one row with the column names from the
  data.frame

- `body`: Contains the actual data from the data.frame

- `footer`: Empty by default, but can contain content (commonly used for
  footnotes or \#' summary rows)

    ┌──────────────────┐
    │      HEADER      │  ← Column names, labels, spanning headers
    ├──────────────────┤
    │                  │
    │       BODY       │  ← Data rows
    │                  │
    ├──────────────────┤
    │      FOOTER      │  ← Summary rows, notes, footnotes (optional)
    └──────────────────┘

A basic flextable has:

- in the part 'header': 1 row with column names

- in the part 'body': as many rows as there are in the input data.frame

- no footer

Rows and columns can be added or removed to the basic flextable:

- Add new rows in header with
  [`add_header()`](https://davidgohel.github.io/flextable/dev/reference/add_header.md),
  [`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md),
  [`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md)
  and
  [`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md).

- Add new rows in footer with
  [`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md),
  [`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md),
  [`set_header_footer_df()`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md)
  and
  [`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md).

- Add new rows in body with
  [`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md)
  and
  [`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md).

- Delete columns with
  [`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md).

- Delete a part with
  [`delete_part()`](https://davidgohel.github.io/flextable/dev/reference/delete_part.md).

- Use column names to separate a simple header row into multiple nested
  rows with
  [`separate_header()`](https://davidgohel.github.io/flextable/dev/reference/separate_header.md).

## Selectors in flextable

Selectors are a core feature of flextable that allow you to specify
which parts (`part`), rows (`i`) and columns (`j`) should be affected by
formatting, styling, or content operations. See the corresponding
manual:
\<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

## See also

<https://davidgohel.github.io/flextable/>,
<https://ardata-fr.github.io/flextable-book/>,
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)

## Author

**Maintainer**: David Gohel <david.gohel@ardata.fr>

Authors:

- Panagiotis Skintzos <panagiotis.skintzos@ardata.fr>

Other contributors:

- ArData \[copyright holder\]

- Clementine Jager \[contributor\]

- Eli Daniels \[contributor\]

- Quentin Fazilleau \[contributor\]

- Maxim Nazarov \[contributor\]

- Titouan Robert \[contributor\]

- Michael Barrowman \[contributor\]

- Atsushi Yasumoto \[contributor\]

- Paul Julian \[contributor\]

- Sean Browning \[contributor\]

- Rémi Thériault ([ORCID](https://orcid.org/0000-0003-4315-6788))
  \[contributor\]

- Samuel Jobert \[contributor\]

- Keith Newman \[contributor\]
