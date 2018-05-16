# display_parser -----


#' @importFrom R6 R6Class
display_parser <- R6Class(
  "display_parser",
  public = list(

    initialize = function( x, formatters, fprops ) {

      private$str <- x

      formatters_expr <- lapply(formatters, function(x) {
        try(labels(terms(x)), silent = TRUE)
      })

      if( any( invalid_expr <- sapply(formatters_expr, inherits, "try-error") ) ){
        invalid_expr <- paste0( "[", sapply( formatters[invalid_expr], format ), "]", collapse = ", " )
        stop("invalid formatters elements (right-hand side): ", invalid_expr, call. = FALSE)
      }


      formatters_varname <- sapply(formatters, function(x) {
        try(all.vars(x)[1], silent = TRUE)
      })


      if( any( invalid_varname <- sapply(formatters_varname, inherits, "try-error") ) ){
        invalid_expr <- paste0( "[", sapply( formatters[invalid_varname], format ), "]", collapse = ", " )
        stop("invalid formatters elements (left-hand side): ", invalid_expr, call. = FALSE)
      }

      formatters <- list(varname = formatters_varname, expr = formatters_expr)
      # if( length(formatters_varname) > 1 ) browser()
      private$formatters <- formatters

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

      if( !all( data$rexpr[!is.na(data$rexpr)] %in% formatters$varname ) ){
        stop( shQuote(private$str), ": missing definition for display() 'formatters' arg ", call. = FALSE)
      }

      data$pr_id <- rep(NA_character_, length(str))
      fprops_id <- sapply(fprops, fp_sign)
      if( length(fprops_id) ){
        data$pr_id[match( names(fprops), data$rexpr )] <- fprops_id
        fprops <- setNames(fprops, fprops_id)
      }
      private$data <- data
      private$fprops <- setNames(fprops, fprops_id)
    },


    get_fp = function(){
      private$fprops
    },

    tidy_data = function(data){

      dat <- private$data
      dat$expr <- lapply(seq_along(dat$str), function(x) NULL )
      dat$expr[match( private$formatters$varname, private$data$rexpr )] <- private$formatters$expr

      dat_expr <- dat[dat$is_expr,]

      eval_out <- lapply(dat_expr$expr,
                         function(x, data){
                           with( data, eval(parse(text = x) ) )
                           },
                         data = data)
      out_type <- rep(NA_character_, length(eval_out))

      out_type <- ifelse(sapply(eval_out, inherits, "character" ), "text", out_type )
      out_type <- ifelse(sapply(eval_out, inherits, "image_entry" ), "image", out_type )
      out_type <- ifelse(sapply(eval_out, inherits, "hyperlink_text" ), "htext", out_type )

      if(length(eval_out) < 1){
        dat_expr <- list( data.frame( str = character(0), type_out = character(0),
                    id = integer(0),
                    pos = integer(0), pr_id = character(0), stringsAsFactors = FALSE) )
      } else
        dat_expr <- mapply(function(x, type_out, pos, pr_id, n){
            if( is.character(x) ){
              x <- data.frame(str = x, stringsAsFactors = FALSE)
            }
            cbind( x, data.frame( type_out = type_out,
                               id = seq_len(n),
                               pos = pos, pr_id = pr_id, stringsAsFactors = FALSE) )
          }, x = eval_out, type_out = out_type, pos = dat_expr$pos, pr_id = dat_expr$pr_id, n = nrow(data),
          SIMPLIFY = FALSE )

      dat_str <- dat[!dat$is_expr,]
      dat_str <- mapply(function(x, pos, pr_id, n){

        data.frame( str = x, type_out = "text",
                    id = seq_len(n),
                    pos = pos, pr_id = pr_id, stringsAsFactors = FALSE)
      }, x = dat_str$str, pos = dat_str$pos, pr_id = dat_str$pr_id, n = nrow(data),
      SIMPLIFY = FALSE )

      rbind.match.columns(append(dat_expr, dat_str))
    }


  ),
  private = list(
    data = NULL,
    str = NULL,
    fprops = NULL,
    formatters = NULL,
    extra_fp = NULL

  )

)


# fp_structure -----
fp_structure <- R6Class(
  "fp_structure",
  public = list(

    initialize = function( nrow_, col_keys, fp ) {
      ncol_ <- length(col_keys)
      id <- rep( seq_len( nrow_ ), ncol_ )
      keys <- rep(col_keys, each = nrow_ )
      map_data <- data.frame(id = id, col_key = keys, stringsAsFactors = FALSE)
      fp_signature <- fp_sign(fp)
      private$add_fp(fp, fp_signature)
      map_data$pr_id <- rep(fp_signature, nrow_ )
      private$map_data <- map_data
      private$col_keys <- col_keys
    },

    set_fp = function(i, j, fp, id = fp_sign(fp) ){
      which_id <- private$map_data$id %in% i
      which_key <- private$map_data$col_key %in% j
      private$add_fp(fp, id)
      private$map_data$pr_id[which_id & which_key] <- id
      self
    },

    get_map = function(){
      private$map_data
    },

    get_map_format = function( type ){
      dat <- self$get_map()
      format_ = as.character( sapply(self$get_fp(), format, type = type ) )
      match_ <- match( dat$pr_id, names(self$get_fp()) )
      dat$format <- format_[match_]
      dat <- dat[, c("id", "col_key", "format") ]
      dat
    },

    get_fp = function(){
      private$fp_list
    },
    get_pr_id_at = function(i, j){
      which_id <- private$map_data$id %in% i
      which_key <- private$map_data$col_key %in% j
      private$map_data$pr_id[which_id & which_key]
    },
    set_pr_id_at = function(i, j, pr_id, fp_list){
      which_id <- private$map_data$id %in% i
      which_key <- private$map_data$col_key %in% j
      private$map_data$pr_id[which_id & which_key] <- pr_id

      for(id in seq_along(fp_list)){
        private$add_fp(fp_list[[id]], names(fp_list)[id])
      }

      self
    },
    add_rows = function(nrows, first){

      ncol <- length(private$col_keys)

      map_data <- private$map_data

      map_data_new <- data.frame(
        id = 0,
        col_key = private$col_keys,
        pr_id = names(private$fp_list)[length(private$fp_list)],
        stringsAsFactors = FALSE)
      map_data_new <- lapply(seq_len(nrows), function(x, dat) {dat$id <- x; dat }, map_data_new )
      map_data_new <- do.call(rbind, map_data_new)

      if( first ){
        if( nrow(map_data) > 0 ){
          pr_id <- map_data[map_data$id %in% 1,"pr_id"]
          map_data_new$pr_id <- pr_id
        }
        map_data$id <- map_data$id + nrows
        map_data <- rbind(map_data_new, map_data)
      } else {
        last_id <- 0
        if( nrow(map_data) > 0 ){
          last_id <- max(map_data$id)
          pr_id <- map_data[map_data$id %in% last_id,"pr_id"]
          map_data_new$pr_id <- pr_id
        }

        map_data_new$id <- map_data_new$id + nrows - 1 + last_id

        map_data <- rbind(map_data, map_data_new)
      }
      private$map_data <- map_data
      self
    }

  ),
  private = list(
    map_data = NULL,
    fp_list = NULL,
    col_keys = NULL,

    add_fp = function( fp, id = fp_sign(fp) ){
      private$fp_list[[id]] <- fp
      self
    }

  )

)



# display_structure -----
display_structure <- R6Class(
  "display_structure",
  inherit = fp_structure,
  public = list(

    initialize = function( nrow_, col_keys, lazy_f ) {
      ncol_ <- length(col_keys)
      id <- rep( seq_len( nrow_ ), ncol_ )
      keys <- rep(col_keys, each = nrow_ )
      map_data <- data.frame(id = id, col_key = keys, stringsAsFactors = FALSE)

      lazy_f_id <- sapply(lazy_f, fp_sign)
      lazy_f_init <- rep(lazy_f_id, each = nrow_ )

      for(i in seq_along(lazy_f_id)){
        private$add_fp(lazy_f[[i]], lazy_f_id[i])
      }
      map_data$pr_id <- lazy_f_init
      private$map_data <- map_data
      private$col_keys <- col_keys
    },

    get_all_fp = function(){
      all_fp <- self$get_fp()
      all_ <- private$map_data$pr_id
      all_ <- unique(all_)
      all_ <- lapply(all_, function(x){
        all_fp[[x]]$get_fp()
      })
      all_ <- all_[sapply(all_, length)>0]
      if( length(all_) > 0 ) {
        all_ <- Reduce(append, all_)
        all_ <- all_[!duplicated(names(all_))]
      }
      all_
    },

    get_map = function(fp_t, dataset){
      default_fp_t <- fp_t$get_map()
      all_fp <- self$get_fp()

      indices <- group_index(private$map_data, c("col_key", "pr_id"))
      indices_ref <- group_ref(private$map_data, c("col_key", "pr_id"))
      indices_dat <- tapply( private$map_data$id,
              INDEX = indices,
              FUN = function(id, data){
                data[id,,drop = FALSE]
              }, data = dataset, simplify = FALSE )
      indices_id <- split( private$map_data$id,indices)

      data <- mapply(function(data, formatr, col_key, pr_id, row_id ){
          dat <- formatr$tidy_data(data = data)

          dat$col_key <- rep(col_key, nrow(dat) )
          if( nrow(dat) )
            dat$id <- row_id[dat$id]
          else dat$id <- integer(0)

          if( !is.element("image_src", names(dat) ) ){
            dat$image_src <- rep(NA_character_, nrow(dat))
            dat$width <- rep(NA_real_, nrow(dat))
            dat$height <- rep(NA_real_, nrow(dat))
          }
          if( !is.element("href", names(dat) ) ){
            dat$href <- rep(NA_character_, nrow(dat))
          }

          dat
        },
        data = indices_dat,
        formatr = all_fp[indices_ref$pr_id],
        col_key = indices_ref$col_key, pr_id = indices_ref$pr_id,
        row_id = indices_id,
        SIMPLIFY = FALSE)
      data <- do.call(rbind, data)

      data$txt_fp <- data$pr_id
      data$pr_id <- NULL
      data <- merge(data, default_fp_t, by = c("col_key", "id"), all.x = TRUE, all.y = FALSE, sort = FALSE )
      data$pr_id <- ifelse(is.na(data$txt_fp), data$pr_id, data$txt_fp )
      data$txt_fp <- NULL

      data <- data[order(data$col_key, data$id, data$pos),c("col_key", "str", "type_out", "id", "pos", "image_src", "href", "width", "height", "pr_id")]
      data
    }


  )

)


rbind.match.columns <- function(list_df) {
  col <- unique(unlist(sapply(list_df, names)))

  list_df <- lapply(list_df, function(x, col) {
    x[, setdiff(col, names(x))] <- NA
    x
  }, col = col)
  list_df <- do.call(rbind, list_df)
  row.names(list_df) <- NULL
  list_df
}


