# display_parser -----


#' @importFrom stringr str_extract_all str_split str_replace_all
#' @importFrom R6 R6Class
#' @importFrom dplyr left_join select distinct group_by_ do summarise full_join
#' @importFrom purrr pmap_df map2_df pmap_chr
#' @importFrom tibble tibble add_column as_tibble
#' @importFrom lazyeval f_rhs f_lhs
display_parser <- R6Class(
  "display_parser",
  public = list(

    initialize = function( x, formatters, fprops ) {

      private$str <- x
      formatters <- map_df(formatters, function(x) {
        tibble(varname = as.character(lazyeval::f_lhs(x) ),
               expr = list(lazyeval::f_rhs(x) ) )
      })
      if( nrow(formatters) < 1 )
        formatters <- tibble(varname = character(0 ) )
      private$formatters <- formatters

      pattern_ <- "\\{\\{[\\w\\.\\_]+\\}\\}"
      r_expr <- str_extract_all(x, pattern = pattern_)[[1]]
      r_char <- str_split(x, pattern_)[[1]]

      str <- matrix( c(r_expr, r_char[-1]), byrow = TRUE, nrow = 2)
      is_expr <- matrix( c(rep(TRUE, length(r_expr)), rep(FALSE, length(r_expr))), byrow = TRUE, nrow = 2)

      str <- c( r_char[1], as.vector(str) )
      is_expr <- c( FALSE, as.vector(is_expr) )
      pos <- seq_along(str)

      data <- tibble(str = str, is_expr = is_expr, pos = pos)
      data$rexpr <- gsub("(^\\{\\{|\\}\\})", "", data$str)
      data$rexpr[!is_expr] <- NA

      if( !all( data$rexpr[!is.na(data$rexpr)] %in% formatters$varname ) )
        stop( shQuote(private$str), ": missing definition for display() 'formatters' arg ", call. = FALSE)

      private$data <- data

      lazy_f_id <- map_chr(fprops, fp_sign)
      private$extra_fp <- tibble( pr_id = map_chr(fprops, fp_sign) )
      if( length(fprops) ){
        private$extra_fp$varname <- names(fprops)
        names(fprops) <- lazy_f_id
      } else private$extra_fp$varname <- character(0)
      private$fprops <- fprops
    },


    get_fp = function(){
      private$fprops
    },

    tidy_data = function(data){
      dat <- private$data %>%
        left_join(private$formatters, by = c("rexpr"="varname") ) %>%
        left_join(private$extra_fp, by = c("rexpr"="varname") )

      dat <- pmap_df( dat, function(str, is_expr, pos, rexpr, expr, pr_id, data){
        if( is_expr ){
          eval_out <- eval(expr, envir = data )
          if( is.character(eval_out) )
            tibble( str = eval_out, type_out = "text",
                    id = seq_len(nrow(data)),
                    pos = pos, pr_id = pr_id)
          else if( inherits(eval_out, "image_entry") ){
            add_column(eval_out, type_out = "image",
                       id = seq_len(nrow(data)),
                       pos = pos, pr_id = pr_id)
          } else stop("could not get string from ", rexpr, "in ", private$str, ".", call. = FALSE)
        } else
          tibble( str = rep(str, nrow(data) ), type_out = "text",
                  id = seq_len(nrow(data)),
                  pos = pos, pr_id = pr_id )
      }, data = data )
      dat
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
      map_data <- tibble(id = id, col_key = keys)
      fp_signature <- fp_sign(fp)
      private$add_fp(fp, fp_signature)
      map_data$pr_id <- fp_signature
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
      refs <- map_df(self$get_fp(),
                         function(x, type)
                           tibble( format = format(x, type = type )),
                         type = type, .id = "pr_id")
      match_ <- match( dat$pr_id, refs$pr_id )
      dat$format <- refs$format[match_]
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
      nrow_data <- max(private$map_data$id)
      model_id <- ifelse( first, 1, nrow_data )
      ncol <- length(private$col_keys)

      map_data <- private$map_data
      map_data_new <- private$map_data
      map_data_new <- map_data_new[map_data_new$id %in% model_id, ]
      map_data_new <- map_df(seq_len(nrows), function(x, dat) {dat$id <- x; dat }, map_data_new )

      if( first ){
        map_data$id <- map_data$id + nrows
        map_data <- bind_rows(map_data, map_data_new)
      } else {
        map_data_new$id <- map_data_new$id + nrows
        map_data <- bind_rows(map_data, map_data_new)
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

    initialize = function( nrow_, col_keys ) {
      ncol_ <- length(col_keys)
      id <- rep( seq_len( nrow_ ), ncol_ )
      keys <- rep(col_keys, each = nrow_ )
      map_data <- tibble(id = id, col_key = keys)

      lazy_f <- map(col_keys, lazy_format_simple )
      lazy_f_id <- map_chr(lazy_f, fp_sign)
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
      all_ <- private$map_data$pr_id %>% unique() %>% map(function(x){
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
      data <- private$map_data %>%
        group_by(col_key, pr_id) %>%
        do({
          col_key <- unique( .$col_key )
          f_key <- unique(.$pr_id)
          dat <- all_fp[[f_key]]$tidy_data(data = dataset[.$id,,drop = FALSE])
          dat$id <- .$id[dat$id]
          dat
        }) %>% ungroup()
      data$pr_id_main <- data$pr_id
      data$pr_id <- NULL
      data %>% left_join(default_fp_t, by = c("col_key", "id") ) %>%
        mutate( pr_id = ifelse(is.na(pr_id_main), pr_id, pr_id_main ) ) %>%
        select(-pr_id_main)

    }


  )

)
