% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/borders.R
\name{hline_top}
\alias{hline_top}
\title{Set top horizontal border}
\usage{
hline_top(x, j = NULL, border = NULL, part = "body")
}
\arguments{
\item{x}{a flextable object}

\item{j}{columns selection}

\item{border}{border properties defined by a call to \code{\link[officer:fp_border]{officer::fp_border()}}}

\item{part}{partname of the table (one of 'all', 'body', 'header', 'footer')}
}
\description{
The function is applying an horizontal border to the
top of one or all parts of a flextable. The line is the
top border of selected parts.
}
\examples{
library(officer)
big_border <- fp_border(color = "orange", width = 3)

ft <- flextable(head(iris))
ft <- border_remove(x = ft)

# add horizontal border on top
ft <- hline_top(ft, part = "all", border = big_border)
ft
}
\seealso{
Other borders management: 
\code{\link{border_inner}()},
\code{\link{border_inner_h}()},
\code{\link{border_inner_v}()},
\code{\link{border_outer}()},
\code{\link{border_remove}()},
\code{\link{hline}()},
\code{\link{hline_bottom}()},
\code{\link{surround}()},
\code{\link{vline}()},
\code{\link{vline_left}()},
\code{\link{vline_right}()}
}
\concept{borders management}
