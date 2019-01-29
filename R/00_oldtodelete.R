old_display_init <- function(x, formatters, fprops, df){

  # get formatters expressions as a list
  formatters_expr <- lapply(formatters, function(x) {
    try(labels(terms(x)), silent = TRUE)
  })

  if( any( invalid_expr <- sapply(formatters_expr, inherits, "try-error") ) ){
    invalid_expr <- paste0( "[", sapply( formatters[invalid_expr], format ), "]", collapse = ", " )
    stop("invalid formatters elements (right-hand side): ", invalid_expr, call. = FALSE)
  }

  # get formatters names
  formatters_varname <- sapply(formatters, function(x) {
    try(all.vars(x)[1], silent = TRUE)
  })


  if( any( invalid_varname <- sapply(formatters_varname, inherits, "try-error") ) ){
    invalid_expr <- paste0( "[", sapply( formatters[invalid_varname], format ), "]", collapse = ", " )
    stop("invalid formatters elements (left-hand side): ", invalid_expr, call. = FALSE)
  }

  x

  pattern_ <- "\\{\\{[\\w\\.\\_ ]+\\}\\}"
  matches_pos <- gregexpr(pattern = pattern_, text = x, perl = TRUE)[[1]]

  if( length(matches_pos) == 1 && matches_pos == -1 ){
    r_expr <- character(0)
  }else {
    r_expr <- mapply(function(x, pos, end) substr(x, pos, end ),
                     rep(x, length(matches_pos)),
                     matches_pos,
                     matches_pos + attr(matches_pos, "match.length") - 1, SIMPLIFY = FALSE )
    r_expr <- unlist( setNames(r_expr, NULL) )
  }
  r_char <- strsplit( gsub(pattern_, replacement = "@@@", x, perl = TRUE), "@@@")[[1]]


  r_char_pos <- seq_along(r_char) * 2 - 1
  r_expr_pos <- seq_along(r_expr) * 2
  data <- data.frame(str = c(r_char, r_expr),
                     is_expr = c(rep(FALSE, length(r_char)),
                                 rep(TRUE, length(r_expr)) ),
                     pos = c(r_char_pos, r_expr_pos),
                     stringsAsFactors = FALSE
  )
  data <- data[order(data$pos), , drop = FALSE]

  data$rexpr <- gsub("(^\\{\\{|\\}\\})", "", data$str)
  data$rexpr[!data$is_expr] <- NA

  if( !all( data$rexpr[!is.na(data$rexpr)] %in% formatters_varname ) ){
    stop( shQuote(x), ": missing definition for display() 'formatters' arg ", call. = FALSE)
  }

  data$pr_id <- rep(NA_character_, length(str))
  fprops_id <- sapply(fprops, fp_sign)
  if( length(fprops_id) ){
    data$pr_id[match( names(fprops), data$rexpr )] <- fprops_id
    fprops <- setNames(fprops, fprops_id)
  }
  fprops <- setNames(fprops, fprops_id)
  names(formatters) <- formatters_varname
  chunk_list <- list()
  for(i in seq_len(nrow(data))){
    if(is.na(data$rexpr[i])){
      str <- rep(data$str[i], nrow(df))
      chunk_list[[i]] <- as_chunk(x = str)
    } else {
      values <- with( df, eval(formatters[[data$rexpr[i]]][[3]]), props = fprops[[data$pr_id[i]]] )
      if( inherits(values, "chunk") ) {
        chunk_list[[i]] <- values
      } else
        chunk_list[[i]] <- as_chunk(values, props = fprops[[data$pr_id[i]]] )
    }

  }
  do.call(as_paragraph, chunk_list)
}
