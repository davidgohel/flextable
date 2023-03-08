#' @noRd
#' @title make border top and bottom restructured
#' as hline. If two borders overlap, the largest is
#' choosen.
fortify_latex_borders <- function(x) {
  properties_df <- x[, .SD, .SDcols = c(
    "part", "col_id", "ft_row_id",
    "colspan", "rowspan",
    "border.width.top", "border.color.top",
    "border.width.bottom", "border.color.bottom",
    "border.width.left", "border.color.left",
    "border.width.right", "border.color.right",
    "background.color"
  )]
  col_id_levels <- levels(properties_df$col_id)
  properties_df[, c('vspan_id') := list(rleid(cumsum(.SD$colspan))), by = c("part", "col_id")]
  properties_df[, c('draw_hline') := list({
    z <- logical(nrow(.SD))
    z[length(z)] <- TRUE
    z
  }), by = c("part", "col_id", "vspan_id")]

  top <- dcast(properties_df, part + ft_row_id ~ col_id, value.var = "border.width.top")
  bottom <- dcast(properties_df, part + ft_row_id ~ col_id, value.var = "border.width.bottom")
  draw_hline <- dcast(properties_df, part + ft_row_id ~ col_id, value.var = "draw_hline")
  top_mat <- as.matrix(top[, 3:ncol(top)])
  bot_mat <- as.matrix(bottom[, 3:ncol(top)])

  # don't want the merged columns widths inside
  draw_hline_mat <- as.matrix(draw_hline[, 3:ncol(top)])
  bot_mat <- bot_mat*(draw_hline_mat > 0)

  new_row_n <- nrow(top) + 1

  if (new_row_n > 2) { # at least 3 rows
    # hlinemat is the top border and all bottom borders
    hlinemat <- matrix(0.0, nrow = new_row_n, ncol = ncol(top_mat))

    # add top border values
    hlinemat[1, ] <- top_mat[1, , drop = FALSE]
    # add bottom border values
    hlinemat[nrow(hlinemat), ] <- bot_mat[nrow(bot_mat), , drop = FALSE]

    # lines width in between must all have the same width, i.e. max observed width

    hlinemat[setdiff(seq_len(new_row_n), c(1, new_row_n)), ] <- pmax(bot_mat[-nrow(bot_mat), , drop = FALSE], top_mat[-1, , drop = FALSE])

    # now lets replace values
    bottom[, 3:ncol(top)] <- as.data.table(hlinemat[-1, ])
    top[1, 3:ncol(top)] <- as.data.table(hlinemat[1, , drop = FALSE])
    top[2:nrow(top), 3:ncol(top)] <- 0.0

    top <- melt(top,
      id.vars = c("part", "ft_row_id"),
      variable.name = "col_id",
      value.name = "border.width.top",
      variable.factor = FALSE
    )
    top$col_id <- factor(top$col_id, levels = col_id_levels)
    bottom <- melt(bottom,
      id.vars = c("part", "ft_row_id"),
      variable.name = "col_id",
      value.name = "border.width.bottom",
      variable.factor = FALSE
    )
    bottom$col_id <- factor(bottom$col_id, levels = col_id_levels)

    properties_df$border.width.bottom <- NULL
    properties_df$border.width.top <- NULL

    properties_df <- merge(
      x = properties_df,
      y = top,
      by = c("part", "ft_row_id", "col_id")
    )
    properties_df <- merge(
      x = properties_df,
      y = bottom,
      by = c("part", "ft_row_id", "col_id")
    )
  }
  properties_df
}

#' @importFrom data.table fifelse
latex_gridlines <- function(properties_df) {
  stopifnot(is.data.table(properties_df))

  x <- fortify_latex_borders(properties_df)

  # init computed latex instructions
  x[, c(
    "vborder_left", "vborder_right",
    "hborder_bottom", "hborder_top",
    "hborder_bottom_pre_vline", "hborder_bottom_post_vline"
  ) :=
    list(
      "", "",
      "~", "~",
      "", ""
    )]
  x[has_border(x, "left"), c("vborder_left") :=
      list(
        vline_token(w = .SD$border.width.left, cols = .SD$border.color.left)
      )]
  x[has_border(x, "right"), c("vborder_right") :=
      list(
        fcase(
          (as.integer(.SD$col_id) + .SD$rowspan) == (nlevels(.SD$col_id) + 1L),
          vline_token(w = .SD$border.width.right, cols = .SD$border.color.right),
          default = ""
        )
      )]
  vlines <- x[, .SD, .SDcols = c("part", "col_id", "ft_row_id", "vborder_left", "vborder_right")]
  setDF(vlines)

  is_transparent <- !has_background(x)

  if (is_transparent) {
    fun_hborder <- cline_token
  } else {
    fun_hborder <- hline_token
  }

  # generate hborder_top only for the first row
  x[
    x$ft_row_id %in% 1 & as.integer(x$part) == min(as.integer(x$part)),
    c("hborder_top") := list(fun_hborder(w = .SD$border.width.top, cols = .SD$border.color.top))
  ]
  # generate hborder_bottom for those that have bottom borders
  x[
    has_border(x, "bottom"),
    c("hborder_bottom") := list(fun_hborder(w = .SD$border.width.bottom, cols = .SD$border.color.bottom))
  ]
  if (is_transparent) {
    x[!x$draw_hline, c("hborder_bottom") := list({
      rep("ascline{0pt}{FFFFFF}", nrow(.SD))
    }), by = c("part", "col_id", "vspan_id")]

    x[x$hborder_top %in% "~", c("hborder_top") := list("ascline{0pt}{FFFFFF}")]
    hlines <- x[, list(
      hlines_b_strings = cline_intruction(.SD$hborder_bottom),
      hlines_t_strings = cline_intruction(.SD$hborder_top)
      ),
      by = c("part", "ft_row_id")]
    setDF(hlines)
  } else {
    # set hborder_bottom_pre_vline to '|' for the first column where there are bottom and left borders
    x[
      has_border(x, "bottom") & has_border(x, "left") & x$col_id %in% head(levels(x$col_id), 1),
      c("hborder_bottom_pre_vline") := list("|")
    ]
    # set hborder_bottom_post_vline to '|' where there are bottom and right borders
    x[, c("has_bdr_right") := list(
      shift(.SD[["border.width.left"]], type = "lead") > 0 &
        colalpha(shift(.SD[["border.color.left"]], type = "lead")) > 0
    ), by = c("part", "ft_row_id")]
    x[
      x[["has_bdr_right"]],
      c("hborder_bottom_post_vline") := list("|")
    ]
    # if cells are vertically merged, dont draw bottom borders nor their vertical columns/joins
    x[, c("hborder_bottom", "hborder_bottom_post_vline") :=
        list(
          data.table::fifelse(c(.SD$colspan[-1], 1) < 1, fun_hborder(w = .SD$border.width.bottom, cols = .SD$background.color), .SD$hborder_bottom),
          data.table::fifelse(c(.SD$colspan[-1], 1) < 1, "", .SD$hborder_bottom_post_vline)
        ), by = c("part", "col_id")]

    # reinit color and line size before drawing new h borders
    x_rulecolor_start <- x[x$col_id %in% head(levels(x$col_id), 1), ]
    x_rulecolor_start <- sprintf(
      "\\noalign{\\global\\arrayrulewidth %spt}\\arrayrulecolor[HTML]{%s}\n\n",
      format_double(x_rulecolor_start$border.width.left, 2),
      colcode0(x_rulecolor_start$border.color.left)
    )

    hlines <- x[, list(
      hlines_b_strings = hhline_instruction(.SD$hborder_bottom,
                                            pre_str = .SD$hborder_bottom_pre_vline,
                                            post_str = .SD$hborder_bottom_post_vline
      ),
      hlines_t_strings = hhline_instruction(.SD$hborder_top)
    ), by = c("part", "ft_row_id")]
    hlines$hlines_b_strings <- paste0(x_rulecolor_start, hlines$hlines_b_strings)
    setDF(hlines)
  }


  list(hlines = hlines, vlines = vlines)
}


# utils ----
## cline command for hline when no background
cline_cmd <- paste0(
  "\\providecommand{\\ascline}[3]{",
  "\\noalign{\\global\\arrayrulewidth #1}",
  "\\arrayrulecolor[HTML]{#2}\\cline{#3}}"
)

has_border <- function(x, side = c("left", "right", "top", "bottom")) {
  side_ <- match.arg(side, several.ok = FALSE)
  size_name <- paste0("border.width.", side_)
  col_name <- paste0("border.color.", side_)
  x[[size_name]] > 0 & colalpha(x[[col_name]]) > 0
}
has_background <- function(x) {
  any(colalpha(x$background.color) > 0)
}
vline_token <- function(w, cols, digits = 2) {
  size <- format_double(w, digits = digits)
  cols <- colcode0(cols)
  z <- sprintf("!{\\color[HTML]{%s}\\vrule width %spt}", cols, size)
  z
}

cline_token <- function(w, cols, digits = 2) {
  size <- format_double(w, digits = digits)
  colchar <- colcode0(cols)
  z <- sprintf("ascline{%spt}{%s}", w, colchar)
  z[w < .001|colalpha(cols)<1] <- "ascline{0pt}{FFFFFF}"
  z
}
hline_token <- function(w, cols, digits = 2) {
  size <- format_double(w, digits = digits)
  cols <- colcode0(cols)
  z <- sprintf(
    ">{\\arrayrulecolor[HTML]{%s}\\global\\arrayrulewidth=%spt}%s",
    cols, size, "-"
  )
  z
}

cline_intruction <- function(token) {
  rle_ <- rle(token)

  lengths <- rle_$lengths
  values <- rle_$values
  end_at <- cumsum(lengths)
  start_at <- end_at - (lengths-1)

  keep <- !values %in% c("ascline{0pt}{FFFFFF}", "~")
  if (sum(keep) < 1) return("")

  values <- values[keep]
  start_at <- start_at[keep]
  end_at <- end_at[keep]

  paste(sprintf("\\%s{%.0f-%.0f}", values, start_at, end_at), collapse = "")
}

hhline_instruction <- function(x, pre_str = character(length(x)), post_str = character(length(x))) {
  if (all(x %in% c("~", "|"))) {
    return("")
  }
  z <- paste0(pre_str, x, post_str)

  paste0("\\hhline{", paste0(z, collapse = ""), "}")
}



