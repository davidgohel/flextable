#' @title flextable: Functions for Tabular Reporting
#'
#' @description
#' The flextable package facilitates access to and manipulation of
#' tabular reporting elements from R.
#'
#' The documentation of functions can be opened with command `help(package = "flextable")`.
#'
#' `flextable()` function is producing flexible tables where each cell
#' can contain several chunks of text with their own set of formatting
#' properties (bold, font color, etc.). Function [mk_par()] lets customise
#' text of cells.
#'
#' Each cell holds a single paragraph composed of inline chunks
#' (see [as_paragraph()]). This means cell content is strictly
#' inline: bold, italic, links, images, equations, inline code, etc.
#' Block-level structures (multiple paragraphs, bullet lists,
#' headings or fenced code blocks) cannot be placed inside a cell.
#' Soft line breaks (`\n`) are however supported.
#'
#' The [as_flextable()] function is used to transform specific objects into
#' flextable objects. For example, you can transform a crosstab produced with
#' the 'tables' package into a flextable which can then be formatted,
#' annotated or augmented with footnotes.
#'
#' In order to reduce the homogenization efforts and the number of functions
#' to be called, it is recommended to define formatting properties such as
#' font, border color, number of decimals displayed which will then be applied
#' by default. See [set_flextable_defaults()] for more details.
#'
#' @section Table Structure:
#'
#' A flextable is composed of three distinct parts:
#'
#' - `header`: By default, contains one row with the column names from the data.frame
#' - `body`: Contains the actual data from the data.frame
#' - `footer`: Empty by default, but can contain content (commonly used for footnotes or #' summary rows)
#'
#'
#' ```
#'        HEADER         <- Column names, labels, spanning headers
#' --------------------
#'         BODY          <- Data rows
#' --------------------
#'        FOOTER         <- Summary rows, notes, footnotes (optional)
#' ```
#'
#' A basic flextable has:
#'
#' - in the part 'header': 1 row with column names
#' - in the part 'body': as many rows as there are in the input data.frame
#' - no footer
#'
#' Rows and columns can be added or removed to the basic flextable:
#'
#' - Add new rows in header with [add_header()], [add_header_row()],
#' [add_header_lines()] and [set_header_labels()].
#' - Add new rows in footer with [add_footer()], [add_footer_lines()],
#' [set_header_footer_df()] and [add_footer_row()].
#' - Add new rows in body with [add_body()] and [add_body_row()].
#' - Delete columns with [delete_columns()].
#' - Delete a part with [delete_part()].
#' - Use column names to separate a simple header row into multiple nested
#' rows with [separate_header()].
#'
#' @section Selectors in flextable:
#' Selectors are a core feature of flextable that allow you to specify which
#' parts (`part`), rows (`i`) and columns (`j`) should be affected by formatting,
#' styling, or content operations. See the corresponding manual:
#' <[`Selectors in flextable`][flextable_selectors]>.
#'
#' @seealso <https://davidgohel.github.io/flextable/>,
#' <https://ardata-fr.github.io/flextable-book/>, [flextable()]
#' @docType package
#' @aliases flextable-package
#' @name flextable-package
"_PACKAGE"
