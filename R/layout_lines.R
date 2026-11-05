#' @export
#' @title Arrange pieces of text into lines
#' @description Give the line of each piece of a text, from their widths, for
#' a maximum width. This is the part shared by [gen_grob()] and the packages that
#' draw rich text with 'grid'.
#'
#' A piece that makes the line too wide goes to the next line, except if it is
#' the first of its line. Spaces are dropped when they do not fit and at the start
#' of a line that follows an automatic line break; they are kept after a line
#' break of the text, as they were written. A line break ends its line, and gives
#' a line of its own if that line is empty.
#' @param width widths of the pieces.
#' @param newline,space logical vectors, `TRUE` for the line breaks and the spaces.
#' @param max_width maximum width of a line, `Inf` for no automatic line break.
#' @param first_line,hanging width removed from the first line, and from the other
#' lines.
#' @return An integer vector, the line of each piece, `0` for the dropped pieces.
#' @examples
#' layout_lines(
#'   width = c(2, 1, 2, 1, 3),
#'   newline = rep(FALSE, 5),
#'   space = c(FALSE, TRUE, FALSE, TRUE, FALSE),
#'   max_width = 5
#' )
#' @keywords internal
layout_lines <- function(
  width,
  newline,
  space,
  max_width,
  first_line = 0,
  hanging = 0
) {
  n <- length(width)
  line <- integer(n)
  cur_line <- 1L
  cur_width <- 0
  # is the current line still empty, and did the previous piece wrap it?
  line_empty <- TRUE
  just_wrapped <- FALSE
  # did the current line start from an automatic line break?
  line_from_wrap <- FALSE

  for (i in seq_len(n)) {
    previous_wrapped <- just_wrapped
    just_wrapped <- FALSE
    cur_width <- cur_width + width[i]
    available <- max_width - (if (cur_line == 1L) first_line else hanging)

    if (newline[i]) {
      line_from_wrap <- FALSE
      if (previous_wrapped) {
        cur_width <- 0
        next
      }
      if (line_empty) {
        line[i] <- cur_line
      }
      cur_line <- cur_line + 1L
      line_empty <- TRUE
      cur_width <- 0
    } else if (cur_width > available) {
      if (line_empty) {
        # the first piece of a line stays on it, even if it is too wide
        line[i] <- cur_line
        cur_line <- cur_line + 1L
        cur_width <- 0
        just_wrapped <- TRUE
        line_from_wrap <- TRUE
      } else {
        cur_line <- cur_line + 1L
        line_from_wrap <- TRUE
        if (space[i]) {
          line_empty <- TRUE
          cur_width <- 0
          just_wrapped <- TRUE
        } else {
          line[i] <- cur_line
          line_empty <- FALSE
          cur_width <- width[i]
        }
      }
    } else if (line_from_wrap && line_empty && space[i]) {
      cur_width <- 0
    } else {
      line[i] <- cur_line
      line_empty <- FALSE
    }
  }
  line
}

# columns of a line: consecutive pieces of a chunk are drawn together
layout_columns <- function(line, chunk) {
  col <- integer(length(line))
  kept <- which(line > 0L)
  new_col <- c(TRUE, line[kept][-1] != line[kept][-length(kept)] |
    chunk[kept][-1] != chunk[kept][-length(kept)])
  group <- cumsum(new_col)
  first_group <- group[!duplicated(line[kept])]
  col[kept] <- group - first_group[match(line[kept], unique(line[kept]))] + 1L
  col
}
