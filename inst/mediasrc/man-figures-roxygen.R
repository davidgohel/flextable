dest_png <- list.files("man/figures")
df <- data.frame( man = gsub("fig\\_(.*)\\_([0-9]+)\\.png$", "\\1", basename(dest_png) ),
                  num = as.integer(gsub("fig\\_(.*)\\_([0-9]+)\\.png$", "\\2", basename(dest_png) )),
                  basename = basename(dest_png),
                  stringsAsFactors = FALSE)
df <- df[order(df$man, df$num),]
df <- split(df, df$man)
df <- lapply(df, function(x){
  str <- paste0("#' \\if{html}{\\figure{", x$basename, "}{options: width=100\\%}}")
  str <- paste0(str, collapse = "\n#' \n")
  str <- paste0("#' @section Figures:\n#' \n", str, "\n\n")
  str
})
cat(df$footnote)
