% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge_flextable.R
\name{merge_h}
\alias{merge_h}
\title{Merge flextable cells horizontally}
\usage{
merge_h(x, i = NULL, part = "body")
}
\arguments{
\item{x}{\code{flextable} object}

\item{i}{rows where cells have to be merged.}

\item{part}{partname of the table where merge has to be done.}
}
\description{
Merge flextable cells horizontally when consecutive cells have
identical values. Text of formatted values are used to compare
values.
}
\examples{
dummy_df <- data.frame(
  col1 = letters,
  col2 = letters, stringsAsFactors = FALSE
)
ft_merge <- flextable(dummy_df)
ft_merge <- merge_h(x = ft_merge)
ft_merge
}
\seealso{
Other flextable merging function: 
\code{\link{merge_at}()},
\code{\link{merge_h_range}()},
\code{\link{merge_none}()},
\code{\link{merge_v}()}
}
\concept{flextable merging function}
