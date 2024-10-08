% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rtf_str.R
\name{rtf_add.flextable}
\alias{rtf_add.flextable}
\title{Add a 'flextable' into an RTF document}
\usage{
\method{rtf_add}{flextable}(x, value, ...)
}
\arguments{
\item{x}{rtf object, created by \code{\link[officer:rtf_doc]{officer::rtf_doc()}}.}

\item{value}{a flextable object}

\item{...}{unused arguments}
}
\description{
\code{\link[officer:rtf_add]{officer::rtf_add()}} method for adding
flextable objects into 'RTF' documents.
}
\examples{
library(flextable)
library(officer)

ft <- flextable(head(iris))
ft <- autofit(ft)

z <- rtf_doc()
z <- rtf_add(z, ft)

print(z, target = tempfile(fileext = ".rtf"))
}
