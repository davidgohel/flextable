#' @importFrom data.table rbindlist setDF
rbind_match_columns <- function(list_df) {
  df <- rbindlist(list_df, use.names = TRUE, fill = TRUE)
  setDF(df)
  row.names(df) <- NULL
  df
}


check_formula_i_and_part <- function(i, part) {
  if (inherits(i, "formula") && part %in% c("header", "footer")) {
    stop("formulas are not supported in the 'header' and 'footer' parts.")
  }
  TRUE
}

absolute_path <- function(x) {
  if (length(x) != 1L) {
    stop("'x' must be a single character string")
  }
  epath <- path.expand(x)

  if (file.exists(epath)) {
    epath <- normalizePath(epath, "/", mustWork = TRUE)
  } else {
    if (!dir.exists(dirname(epath))) {
      stop(sprintf("directory of '%s' does not exist.", x), call. = FALSE)
    }
    cat("", file = epath)
    epath <- normalizePath(epath, "/", mustWork = TRUE)
    unlink(epath)
  }
  epath
}

#' @importFrom stats median median sd mad
#' @importFrom stats quantile
Q1 <- function(z) as.double(quantile(z, probs = .25, na.rm = TRUE, names = FALSE))
Q3 <- function(z) as.double(quantile(z, probs = .75, na.rm = TRUE, names = FALSE))
MEDIAN <- function(z) as.double(median(z, na.rm = TRUE))
MEAN <- function(z) as.double(mean(z, na.rm = TRUE))
SD <- function(z) as.double(sd(z, na.rm = TRUE))
MAD <- function(z) as.double(mad(z, na.rm = TRUE))
MIN <- function(z) as.double(min(z, na.rm = TRUE))
MAX <- function(z) as.double(max(z, na.rm = TRUE))
N <- function(z) length(z)
NAS <- function(z) sum(is.na(z))


as_bookmark <- function(id, str) {
  new_id <- UUIDgenerate()
  bm_start_str <- sprintf("<w:bookmarkStart w:id=\"%s\" w:name=\"%s\"/>", new_id, id)
  bm_start_end <- sprintf("<w:bookmarkEnd w:id=\"%s\"/>", new_id)
  paste0(bm_start_str, str, bm_start_end)
}

format_double <- function(x, digits = 2) {
  formatC(x, format = "f", digits = digits, decimal.mark = ".", drop0trailing = TRUE)
}

has_value <- function(x) {
  !is.null(x) && !is.na(x) && length(x) == 1
}

coalesce_options <- function(a = NULL, b = NULL) {
  if (is.null(a)) {
    return(b)
  }
  if (is.null(b)) {
    return(a)
  }
  if (length(b) == 1) {
    b <- rep(b, length(a))
  }
  out <- a
  out[!has_value(a)] <- b[!has_value(a)]
  out
}

mcoalesce_options <- function(...) {
  Reduce(coalesce_options, list(...))
}

safe_stat <- function(..., FUN = max, NA_value = NA_real_) {
  x <- na.omit(unlist(list(...)))
  if (length(x) > 0) {
    FUN(x)
  } else {
    NA_value
  }
}

safe_stat_ext <- function(..., FUN = max, NA_value = NA_real_, LENGTH = NULL) {
  x <- na.omit(unlist(list(...)))
  if (length(x) > 0 && (!is.numeric(LENGTH) || length(LENGTH) == 0 || is.na(LENGTH) || length(x) == LENGTH[1])) {
    FUN(x)
  } else {
    NA_value
  }
}

# metric units -----
cm_to_inches <- function(x) {
  x / 2.54
}
mm_to_inches <- function(x) {
  x / 25.4
}
convin <- function(unit, x) {
  unit <- match.arg(unit, choices = c("in", "cm", "mm"), several.ok = FALSE)
  if (!identical("in", unit)) {
    x <- do.call(paste0(unit, "_to_inches"), list(x = x))
  }
  x
}
convmeters <- function(unit, x) {
  unit <- match.arg(unit, choices = c("in", "cm", "mm"), several.ok = FALSE)
  if (identical("cm", unit)) {
    x <- x * 2.54
  } else if (identical("mm", unit)) {
    x <- x * 254
  }
  x
}

# check for gregexec -----
if (!"gregexec" %in% getNamespaceExports("base")) {
  # copied from R source, grep.R
  gregexec <- function(pattern, text, ignore.case = FALSE, perl = FALSE,
                       fixed = FALSE, useBytes = FALSE) {
    if (is.factor(text) && length(levels(text)) < length(text)) {
      out <- gregexec(
        pattern, c(levels(text), NA_character_),
        ignore.case, perl, fixed, useBytes
      )
      outna <- out[length(out)]
      out <- out[text]
      out[is.na(text)] <- outna
      return(out)
    }

    dat <- gregexpr(
      pattern = pattern, text = text, ignore.case = ignore.case,
      fixed = fixed, useBytes = useBytes, perl = perl
    )
    if (perl && !fixed) {
      ## Perl generates match data, so use that
      capt.attr <- c("capture.start", "capture.length", "capture.names")
      process <- function(x) {
        if (anyNA(x) || any(x < 0)) {
          y <- x
        } else {
          ## Interleave matches with captures
          y <- t(cbind(x, attr(x, "capture.start")))
          attributes(y)[names(attributes(x))] <- attributes(x)
          ml <- t(cbind(attr(x, "match.length"), attr(x, "capture.length")))
          nm <- attr(x, "capture.names")
          ## Remove empty names that `gregexpr` returns
          dimnames(ml) <- dimnames(y) <-
            if (any(nzchar(nm))) list(c("", nm), NULL)
          attr(y, "match.length") <- ml
          y
        }
        attributes(y)[capt.attr] <- NULL
        y
      }
      lapply(dat, process)
    } else {
      ## For TRE or fixed we must compute the match data ourselves
      m1 <- lapply(regmatches(text, dat),
        regexec,
        pattern = pattern, ignore.case = ignore.case,
        perl = perl, fixed = fixed, useBytes = useBytes
      )
      mlen <- lengths(m1)
      res <- vector("list", length(m1))
      im <- mlen > 0
      res[!im] <- dat[!im] # -1, NA
      res[im] <- Map(
        function(outer, inner) {
          tmp <- do.call(cbind, inner)
          attributes(tmp)[names(attributes(inner))] <- attributes(inner)
          attr(tmp, "match.length") <-
            do.call(cbind, lapply(inner, `attr`, "match.length"))
          # useBytes/index.type should be same for all so use outer vals
          attr(tmp, "useBytes") <- attr(outer, "useBytes")
          attr(tmp, "index.type") <- attr(outer, "index.type")
          tmp + rep(outer - 1L, each = nrow(tmp))
        },
        dat[im],
        m1[im]
      )
      res
    }
  }
}
