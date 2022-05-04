#' @export
#' @title add latex dependencies
#' @description Manually add flextable latex dependencies to
#' the knitr session via [knit_meta_add()].
#'
#' When enabling caching in 'R Markdown' documents for PDF output,
#' the flextable cached result is used directly. Call `add_latex_dep()` in a
#' non cached chunk so that flextable latex dependencies are added
#' to knitr metadata.
#' @return NULL
#' @examples
#' add_latex_dep()
add_latex_dep <- function(){

  pandoc_to <- opts_knit$get("rmarkdown.pandoc.to")
  if(is.null(pandoc_to)) pandoc_to <- ""
  if(!grepl("latex", pandoc_to)){
    return(invisible(NULL))
  }

  fonts_ignore <- flextable_global$defaults$fonts_ignore
  fontspec_compat <- get_pdf_engine() %in% c("xelatex", "lualatex")
  if (!fonts_ignore && !fontspec_compat) {
    warning("Warning: fonts used in `flextable` are ignored because ",
            "the `pdflatex` engine is used and not `xelatex` or ",
            "`lualatex`. You can avoid this warning by using the ",
            "`set_flextable_defaults(fonts_ignore=TRUE)` command or ",
            "use a compatible engine by defining `latex_engine: xelatex` ",
            "in the YAML header of the R Markdown document.",
            call. = FALSE
    )
  }
  if (fontspec_compat) {
    usepackage_latex("fontspec")
  }
  usepackage_latex("multirow")
  usepackage_latex("multicol")
  usepackage_latex("colortbl")
  usepackage_latex("hhline")
  usepackage_latex("longtable")
  usepackage_latex("array")
  usepackage_latex("hyperref")
  invisible(NULL)
}

latex_str <- function(x, ft.align = "center",
                      ft.tabcolsep = 8,
                      ft.arraystretch = 1.5,
                      bookdown = FALSE) {
  dims <- dim(x)
  column_sizes <- dims$widths
  column_sizes_df <- data.frame(
    column_size = column_sizes,
    col_id = factor(x$col_keys, levels = x$col_keys),
    stringsAsFactors = FALSE
  )


  properties_df <- merge_table_properties(x)
  linespacing_df <- properties_df[, c("part", "ft_row_id", "col_id", "line_spacing")]
  dat <- latex_text_dataset(x, linespacing_df)

  # hhlines and vborders ----
  properties_df <- augment_borders(properties_df)

  # cell background color -----
  properties_df[, c("background_color") := list(
    latex_cell_bgcolor(.SD$background.color)
  )]

  # text direction ----
  properties_df[, c("text_direction_left", "text_direction_right") := list(
    latex_text_direction(.SD$text.direction, left = TRUE),
    latex_text_direction(.SD$text.direction, left = FALSE)
  )]

  # merge prop and text and sizes----
  cell_properties_df <- merge(properties_df, dat, by = c("part", "ft_row_id", "col_id"))
  cell_properties_df <- merge(cell_properties_df, column_sizes_df, by = c("col_id"))

  # update colspan -----
  cell_properties_df <- reverse_colspan(cell_properties_df)
  # add col sizes -----
  column_sizes_df <- calc_column_size(cell_properties_df, x$col_keys)
  cell_properties_df[, c("column_size") := NULL]
  cell_properties_df <- merge(cell_properties_df, column_sizes_df, by = c("part", "ft_row_id", "col_id"))

  # latex for multicolumn ----
  if ("fixed" %in% x$properties$layout) {
    augment_multicolumn_fixed(cell_properties_df)
  } else {
    augment_multicolumn_autofit(cell_properties_df)
  }

  # latex for multirow ----
  augment_multirow(cell_properties_df)

  # paste everything ----
  cell_properties_df[, c("txt") := list(
    paste0(
      .SD$multirow_left,
      .SD$text_direction_left,
      .SD$txt,
      .SD$text_direction_right,
      .SD$multirow_right
    )
  )]

  cell_properties_df[cell_properties_df$colspan < 1, c("txt") := list("")]

  cell_properties_df[, c("txt") := list(
    paste0(
      .SD$multicolumn_left,
      .SD$txt,
      .SD$multicolumn_right
    )
  )]
  cell_properties_df[
    cell_properties_df$rowspan < 1,
    c("txt") := list(
      NA_character_
    )
  ]
  setorderv(cell_properties_df, c("part", "ft_row_id", "col_id"))
  txt_data <- cell_properties_df[, list(txt = paste0(.SD$txt[!is.na(.SD$txt)], collapse = " & ")),
    by = c("part", "ft_row_id")
  ]

  # txt_data is now merged by row ----
  txt_data[, c("txt") := list(paste0(.SD$txt, " \\\\"))]
  setorderv(txt_data, c("part", "ft_row_id"))

  hhline_data <- extract_hhline_bottom(cell_properties_df)

  hhline_top_data <- augment_top_borders(cell_properties_df)
  txt_data <- merge(txt_data, hhline_top_data, by = c("part", "ft_row_id"), all.x = TRUE, all.y = TRUE)

  txt_data <- merge(txt_data, hhline_data, by = c("part", "ft_row_id"), all.x = TRUE, all.y = TRUE)
  setorderv(txt_data, cols = c("part", "ft_row_id"))
  txt_data <- augment_part_separators(txt_data)


  txt_data[, c("txt") := list(paste(
    .SD$hhline_top,
    .SD$txt, .SD$hhline,
    sep = "\n\n"
  ))]
  txt_data$part <- factor(as.character(txt_data$part),
    levels = c("header", "footer", "body")
  )
  setorderv(txt_data, c("part", "ft_row_id"))

  # finalize ----
  if ("fixed" %in% x$properties$layout) {
    column_sizes_latex <- sprintf("|p{%.2fin}", column_sizes)
  } else {
    column_sizes_latex <- rep("c", length(dims$widths))
  }

  tab_props <- opts_current_table()
  topcaption <- tab_props$topcaption
  caption <- latex_caption(x, bookdown = bookdown)
  align_tag <- latex_table_align()

  table_start <- sprintf(
    "\\begin{longtable}[%s]{%s}",
    align_tag, paste(column_sizes_latex, collapse = "")
  )
  table_end <- "\\end{longtable}"
  latex <- paste0(txt_data$txt, txt_data$part_sep, collapse = "\n\n")


  latex <- paste(
    sprintf("\\setlength{\\tabcolsep}{%spt}", format_double(ft.tabcolsep, 0)),
    sprintf("\\renewcommand*{\\arraystretch}{%s}", format_double(ft.arraystretch, 2)),
    # "\\begin{table}",
    table_start, if(topcaption) caption,
    paste(txt_data$txt[txt_data$part %in% "header"], collapse = ""),
    "\\endfirsthead",
    latex,
    if(!topcaption) caption,
    table_end,
    # "\\end{table}",
    sep = "\n\n"
  )

  latex
}
#' @importFrom data.table fcase
augment_multirow <- function(properties_df) {
  properties_df[, c("multirow_left", "multirow_right") :=
    list(
      fcase(
        .SD$colspan > 1,
        paste0(
          "\\multirow[",
          substr(.SD$vertical.align, 1, 1),
          "]{-",
          format_double(.SD$colspan, digits = 0),
          "}{*}{"
        ),
        default = ""
      ),
      fcase(.SD$colspan > 1, "}", default = "")
    )]
  properties_df
}

latex_colwidth <- function(x) {
  colwidths <- paste0(
    "\\dimexpr ", format_double(x$column_size, 2), "in+",
    format_double((x$rowspan - 1) * 2, digits = 0),
    "\\tabcolsep+",
    format_double(x$rowspan - 1, digits = 0),
    "\\arrayrulewidth"
  )
  colwidths
}


augment_multicolumn_autofit <- function(properties_df) {
  stopifnot(is.data.table(properties_df))

  properties_df[, c("multicolumn_left", "multicolumn_right") :=
    list(
      paste0(
        "\\multicolumn{",
        format_double(.SD$rowspan, digits = 0),
        "}{",
        .SD$vborder_left,
        ">{", .SD$background_color, "}",
        substr(.SD$text.align, 1, 1),
        .SD$vborder_right,
        "}{"
      ),
      "}"
    )]
  properties_df
}
augment_multicolumn_fixed <- function(properties_df) {
  stopifnot(is.data.table(properties_df))

  properties_df[, c("multicolumn_left", "multicolumn_right") :=
    list(
      paste0(
        "\\multicolumn{", format_double(.SD$rowspan, digits = 0), "}{",
        .SD$vborder_left,
        ">{", .SD$background_color,
        c("center" = "\\centering", left = "\\raggedright", right = "\\raggedleft")[.SD$text.align],
        "}",
        "p{", latex_colwidth(.SD), "}",
        .SD$vborder_right,
        "}{"
      ),
      "}"
    )]
  properties_df
}

augment_part_separators <- function(z) {
  part_separators <- merge(z[, c("part", "ft_row_id")],
    merge(z[, list(ft_row_id = max(.SD$ft_row_id)), by = "part"],
      data.frame(
        part = factor(c("header", "body", "footer"), levels = c("header", "body", "footer")),
        part_sep = c("\\endhead", "", "\\endfoot"),
        stringsAsFactors = FALSE
      ),
      by = c("part")
    ),
    by = c("part", "ft_row_id"), all.x = TRUE, all.y = FALSE
  )
  part_separators$part_sep[is.na(part_separators$part_sep)] <- ""
  setorderv(part_separators, c("part", "ft_row_id"))

  z <- merge(z, part_separators, by = c("part", "ft_row_id"))
  z
}

augment_top_borders <- function(properties_df) {
  hhline_top_data <- properties_df[
    properties_df$ft_row_id %in% 1 &
      as.integer(properties_df$part) == min(as.integer(properties_df$part)),
    list(
      hhline_top = paste0("\\hhline{", paste0(.SD$hhlines_top, collapse = ""), "}")
    ),
    by = c("part", "ft_row_id")
  ]
  dims <- unique(properties_df[, c("part", "ft_row_id")])
  hhline_top_data <- merge(dims, hhline_top_data, by = c("part", "ft_row_id"), all.x = TRUE, all.y = TRUE)
  hhline_top_data$hhline_top[is.na(hhline_top_data$hhline_top)] <- ""
  hhline_top_data
}

#' @importFrom data.table copy
#' @noRd
#' @title make border top and bottom restructured
#' as hline. If two borders overlap, the largest is
#' choosen.
as_border_latex <- function(x){
  properties_df <- copy(x)
  col_id_levels <- levels(properties_df$col_id)

  top <- dcast(properties_df, part + ft_row_id ~ col_id, value.var = "border.width.top")
  bottom <- dcast(properties_df, part + ft_row_id ~ col_id, value.var = "border.width.bottom")
  top_mat <- as.matrix(top[, 3:ncol(top)])
  bot_mat <- as.matrix(bottom[, 3:ncol(top)])

  new_row_n <- nrow(top) + 1

  if(new_row_n > 2){ # at least 3 rows

    hlinemat <- matrix(0.0, nrow = new_row_n, ncol = ncol(top_mat))

    hlinemat[1,] <- top_mat[1, , drop = FALSE]
    hlinemat[nrow(hlinemat),] <- bot_mat[nrow(bot_mat),, drop = FALSE]
    hlinemat[setdiff(seq_len(new_row_n), c(1, new_row_n)),] <- pmax(bot_mat[-nrow(bot_mat),, drop = FALSE], top_mat[-1,, drop = FALSE])

    # now lets replace values
    bottom[, 3:ncol(top)] <- as.data.table(hlinemat[-1,])
    top[1, 3:ncol(top)] <- as.data.table(hlinemat[1,, drop = FALSE])
    top[2:nrow(top), 3:ncol(top)] <- 0.0

    top <- melt(top,
                id.vars = c("part", "ft_row_id"),
                variable.name = "col_id",
                value.name = "border.width.top",
                variable.factor = FALSE)
    top$col_id <- factor(top$col_id, levels = col_id_levels)
    bottom <- melt(bottom,
                   id.vars = c("part", "ft_row_id"),
                   variable.name = "col_id",
                   value.name = "border.width.bottom",
                   variable.factor = FALSE)
    bottom$col_id <- factor(bottom$col_id, levels = col_id_levels)

    properties_df$border.width.bottom <- NULL
    properties_df$border.width.top <- NULL

    properties_df <- merge(
      x = properties_df,
      y = top,
      by = c("part", "ft_row_id", "col_id"))
    properties_df <- merge(
      x = properties_df,
      y = bottom,
      by = c("part", "ft_row_id", "col_id"))
  }

  properties_df
}


augment_borders <- function(properties_df) {
  stopifnot(is.data.table(properties_df))
  # hhlines and vborders ----

  properties_df <- as_border_latex(properties_df)
  properties_df[, c("vborder_left", "vborder_right", "hhlines_bottom", "hhlines_top") :=
    list(
      latex_vborder(w = .SD$border.width.left, cols = .SD$border.color.left),
      fcase(
        (as.integer(.SD$col_id) + .SD$rowspan) == (nlevels(.SD$col_id) + 1L),
        latex_vborder(w = .SD$border.width.right, cols = .SD$border.color.right),
        default = ""
      ),
      latex_hhline(w = .SD$border.width.bottom, cols = .SD$border.color.bottom),
      fcase(
        .SD$ft_row_id %in% 1 & as.integer(.SD$part) == min(as.integer(.SD$part)),
        latex_hhline(w = .SD$border.width.top, cols = .SD$border.color.top),
        default = "")
    )]
  void_merged_colspan <- function(hhline, colspan) {
    ifelse(c(colspan[-1], 1) < 1, "~", hhline)
  }
  properties_df[, c("hhlines_bottom") :=
    list(
      void_merged_colspan(.SD$hhlines_bottom, .SD$colspan)
    ), by = c("part", "col_id")]
  setorderv(properties_df, c("part", "col_id", "ft_row_id"))
  properties_df
}



# borders ----

latex_vborder <- function(w, cols, digits = 0) {
  size <- format_double(w, digits = 1)
  cols <- colcode0(cols)
  z <- sprintf("!{\\color[HTML]{%s}\\vrule width %spt}", cols, size)
  z
}

latex_hhline <- function(w, cols, digits = 0) {
  size <- format_double(w, digits = 1)
  is_transparent <- colalpha(cols) < 1
  cols <- colcode0(cols)
  z <- sprintf(
    ">{\\arrayrulecolor[HTML]{%s}\\global\\arrayrulewidth=%spt}-",
    cols, size
  )
  z[w < .001 | is_transparent] <- "~"
  z
}

extract_hhline_bottom <- function(cell_data) {
  was_dt <- is.data.table(cell_data)
  if (!was_dt) setDT(cell_data)
  setorderv(cell_data, c("part", "ft_row_id", "col_id"))

  hhline_inst <- function(x) {
    if (all(x %in% "~")) {
      return("")
    }
    paste0("\\hhline{", paste0(x, collapse = ""), "}")
  }

  hhline <- cell_data[,
    list(
      hhline = hhline_inst(.SD$hhlines_bottom)
    ),
    by = c("part", "ft_row_id")
  ]

  setDF(hhline)
  if (!was_dt) setDF(cell_data)

  hhline
}

cline_cmd <- paste0(
  "\\providecommand{\\docline}[3]{",
  "\\noalign{\\global\\setlength{\\arrayrulewidth}{#1}}",
  "\\arrayrulecolor[HTML]{#2}\\cline{#3}}"
)

# col/row spans -----
fill_NA <- function(x) {
  which.na <- c(which(!is.na(x)), length(x) + 1)
  values <- na.omit(x)

  if (which.na[1] != 1) {
    which.na <- c(1, which.na)
    values <- c(values[1], values)
  }
  diffs <- diff(which.na)
  return(rep(values, times = diffs))
}


reverse_colspan <- function(df) {
  setorderv(df, cols = c("part", "col_id", "ft_row_id"))
  df[, c("col_uid") := list(UUIDgenerate(n = nrow(.SD))), by = c("part", "ft_row_id")]
  df[df$colspan < 1, c("col_uid") := list(NA_character_)]
  df[, c("col_uid") := list(fill_NA(.SD$col_uid)), by = c("part", "col_id")]

  df[, c(
    "ft_row_id", "hhlines_bottom", "hhlines_top", "vborder_left", "vborder_right",
    "border.width.bottom", "border.color.bottom", "border.style.bottom",
    "border.width.left", "border.color.left", "border.style.left",
    "border.width.right", "border.color.right", "border.style.right"
  ) :=
    list(
      rev(.SD$ft_row_id),
      rev(.SD$hhlines_bottom),
      rev(.SD$hhlines_top),
      rev(.SD$vborder_left),
      rev(.SD$vborder_right),
      rev(.SD$border.width.bottom),
      rev(.SD$border.color.bottom),
      rev(.SD$border.style.bottom),
      rev(.SD$border.width.left),
      rev(.SD$border.color.left),
      rev(.SD$border.style.left),
      rev(.SD$border.width.right),
      rev(.SD$border.color.right),
      rev(.SD$border.style.right)
    ), by = c("col_uid")]
  # df[, c("ft_row_id") := list(rev(.SD$ft_row_id)), by = c("col_uid")]
  df[, c("col_uid") := NULL]
  setorderv(df, cols = c("part", "ft_row_id", "col_id"))
  df
}

calc_column_size <- function(df, levels) {
  z <- df[, c("col_id", "part", "ft_row_id", "rowspan", "column_size")]
  z$col_id <- factor(z$col_id, levels = levels)
  setorderv(z, cols = c("part", "ft_row_id", "col_id"))
  z[, c("col_uid") := list(UUIDgenerate(n = nrow(.SD))), by = c("part", "ft_row_id")]
  z[z$rowspan < 1, c("col_uid") := list(NA_character_)]
  z[, c("col_uid") := list(fill_NA(.SD$col_uid)), by = c("part", "ft_row_id")]
  z[, c("column_size") := list(sum(.SD$column_size, na.rm = TRUE)), by = c("part", "ft_row_id", "col_uid")]
  z[, c("col_uid", "rowspan") := NULL]
  setorderv(z, cols = c("part", "ft_row_id", "col_id"))
  setDT(z)
  z
}

# tools ----
#' @importFrom knitr knit_meta_add
#' @importFrom rmarkdown latex_dependency
usepackage_latex <- function(name, options = NULL) {
  knit_meta_add(list(latex_dependency(name, options)))
}

merge_table_properties <- function(x) {
  cell_data <- fortify_style(x, "cells")
  par_data <- fortify_style(x, "pars")
  setDT(cell_data)
  setDT(par_data)

  cell_data[, c("width", "height", "hrule") := NULL]
  cell_data <- merge(cell_data, fortify_width(x), by = "col_id")
  cell_data <- merge(cell_data, fortify_height(x), by = c("part", "ft_row_id"))
  # cell_data <- merge(cell_data, fortify_hrule(x), by = c("part", "ft_row_id"))
  cell_data <- merge(cell_data, fortify_span(x), by = c("part", "ft_row_id", "col_id"))

  oldnames <- grep("^border\\.", colnames(cell_data), value = TRUE)
  newnames <- paste0("paragraph.", oldnames)
  setnames(par_data, old = oldnames, new = newnames)
  cell_data <- merge(cell_data, par_data, by = c("part", "ft_row_id", "col_id"))
  cell_data$col_id <- factor(cell_data$col_id, levels = x$col_keys)
  setorderv(cell_data, c("part", "ft_row_id", "col_id"))
  cell_data
}

#' @importFrom utils compareVersion packageVersion
get_pdf_engine <- function() {
  if (compareVersion(as.character(packageVersion("rmarkdown")), "1.10.14") < 0) {
    stop("package rmarkdown >= 1.10.14 is required to use this function")
  }

  pandoc_args <- knitr::opts_knit$get("rmarkdown.pandoc.args")
  rd <- grep("--pdf-engine", pandoc_args)
  if (length(rd)) {
    engine <- pandoc_args[rd + 1]
  } else {
    engine <- "pdflatex"
  }
  engine
}


latex_caption <- function(x, bookdown) {
  tab_props <- opts_current_table()
  # caption str value
  bookdown_ref_label <- ref_label()
  std_ref_label <- NULL
  if(bookdown && !is.null(x$caption$autonum$bookmark)){
    std_ref_label <- x$caption$autonum$bookmark
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, x$caption$autonum$bookmark, ")")
  } else if(bookdown && !is.null(tab_props$id)){
    std_ref_label <- tab_props$id
    bookdown_ref_label <- paste0("(\\#", tab_props$tab.lp, tab_props$id, ")")
  }


  caption_label <- tab_props$cap
  if (!is.null(x$caption$value)) {
    caption_label <- x$caption$value
  }
  caption <- ""
  if (!is.null(caption_label)) {

    if (requireNamespace("commonmark", quietly = TRUE)) {
      gmatch <- gregexpr(pattern = "\\$[^\\$]+\\$", caption_label)
      equations <- regmatches(caption_label, gmatch)[[1]]
      names(equations) <- sprintf("EQUATIONN%.0f", seq_along(equations))
      regmatches(caption_label, gmatch) <- list(names(equations))
      caption_label <- commonmark::markdown_latex(caption_label)
      for(eq in names(equations)){
        caption_label <- gsub(eq, equations[eq], caption_label)
      }
    }

    caption <- paste0(
      "\\caption{",
      caption_label, "}",
      if (bookdown) {
        bookdown_ref_label
      } else if (!is.null(std_ref_label)) {
        sprintf("\\label{", tab_props$tab.lp, "%s}", std_ref_label)
      },
      "\\\\"
    )
  }
  caption
}

latex_table_align <- function() {
  ft.align <- opts_current$get("ft.align")
  if ("left" %in% ft.align) {
    align_tag <- "l"
  } else if ("right" %in% ft.align) {
    align_tag <- "r"
  } else {
    align_tag <- "c"
  }
  align_tag
}
