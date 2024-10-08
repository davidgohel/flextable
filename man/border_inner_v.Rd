% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/borders.R
\name{border_inner_v}
\alias{border_inner_v}
\title{Set vertical inner borders}
\usage{
border_inner_v(x, border = NULL, part = "all")
}
\arguments{
\item{x}{a flextable object}

\item{border}{border properties defined by a call to \code{\link[officer:fp_border]{officer::fp_border()}}}

\item{part}{partname of the table (one of 'all', 'body', 'header', 'footer')}
}
\description{
The function is applying a vertical border to inner content of one
or all parts of a flextable.
}
\examples{
library(officer)
std_border <- fp_border(color = "orange", width = 1)

dat <- iris[c(1:5, 51:55, 101:105), ]
ft <- flextable(dat)
ft <- border_remove(x = ft)

# add inner vertical borders
ft <- border_inner_v(ft, border = std_border)
ft
}
\seealso{
Other borders management: 
\code{\link{border_inner}()},
\code{\link{border_inner_h}()},
\code{\link{border_outer}()},
\code{\link{border_remove}()},
\code{\link{hline}()},
\code{\link{hline_bottom}()},
\code{\link{hline_top}()},
\code{\link{surround}()},
\code{\link{vline}()},
\code{\link{vline_left}()},
\code{\link{vline_right}()}
}
\concept{borders management}
