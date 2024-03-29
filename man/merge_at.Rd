% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge_flextable.R
\name{merge_at}
\alias{merge_at}
\title{Merge flextable cells into a single one}
\usage{
merge_at(x, i = NULL, j = NULL, part = "body")
}
\arguments{
\item{x}{\code{flextable} object}

\item{i, j}{columns and rows to merge}

\item{part}{partname of the table where merge has to be done.}
}
\description{
Merge flextable cells into a single one. All
rows and columns must be consecutive.
}
\examples{
ft_merge <- flextable(head(mtcars), cwidth = .5)
ft_merge <- merge_at(ft_merge, i = 1:2, j = 1:2)
ft_merge
}
\seealso{
Other flextable merging function: 
\code{\link{merge_h}()},
\code{\link{merge_h_range}()},
\code{\link{merge_none}()},
\code{\link{merge_v}()}
}
\concept{flextable merging function}
