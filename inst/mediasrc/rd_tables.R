tabular <- function(df, ...) {
  stopifnot(is.data.frame(df))

  align <- function(x) if (is.numeric(x)) "r" else "l"
  col_align <- purrr::map_chr(df, align)

  cols <- lapply(df, format, ...)
  contents <- do.call("paste",
                      c(cols, list(sep = " \\tab ", collapse = "\\cr\n#'   ")))

  paste("#' \\tabular{", paste(col_align, collapse = ""), "}{\n#'   ",
        paste0("\\strong{", names(df), "}", sep = "", collapse = " \\tab "), " \\cr\n#'   ",
        contents, "\n#' }\n", sep = "")
}

str <- "purpose	property	default value	HTML	docx	PDF	pptx
flextable alignment, supported values are 'left', 'center' and 'right'	ft.align	'center'	yes	yes	yes	no
Word option 'Allow row to break across pages' can be activated when TRUE.	ft.split	FALSE	no	yes	no	no
space between the text and the left/right border of its containing cell	ft.tabcolsep	8.0	no	no	yes	no
height of each row relative to its default height	ft.arraystretch	1.5	no	no	yes	no
left coordinates in inches	ft.left	1.0	no	no	no	yes
top coordinates in inches	ft.top	2.0	no	no	no	yes"
dat <- data.table::fread(str)
tabular(dat)

str <- "chunk option	purpose	set_caption	rmarkdown	bookdown
tab.cap.style	Word style name to use for table captions	no	yes	yes
tab.cap.pre	Prefix for numbering chunk (default to \"Table\")	no	yes	yes
tab.cap.sep	Suffix for numbering chunk (default to \": \")	no	yes	yes
tab.cap	Caption label	no	yes	yes
tab.id	Caption reference unique identifier	no	yes	no
label	Caption reference unique identifier	no	no	yes"
dat <- data.table::fread(str)
cat(tabular(dat))

dat <- data.frame("Output format" = c("HTML", "Word (docx)", "PowerPoint (pptx)", "PDF"),
           "pandoc minimal version" = c(">= 1.12", ">= 2.0", ">= 2.4", ">= 1.12"),
           check.names = FALSE, stringsAsFactors = FALSE)
cat(tabular(dat))
