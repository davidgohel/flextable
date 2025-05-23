% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/printers.R
\name{save_as_pptx}
\alias{save_as_pptx}
\title{Save flextable objects in a 'PowerPoint' file}
\usage{
save_as_pptx(..., values = NULL, path)
}
\arguments{
\item{...}{flextable objects, objects, possibly named. If named objects, names are
used as slide titles.}

\item{values}{a list (possibly named), each element is a flextable object. If named objects, names are
used as slide titles. If provided, argument \code{...} will be ignored.}

\item{path}{PowerPoint file to be created}
}
\value{
a string containing the full name of the generated file
}
\description{
sugar function to save flextable objects in
an PowerPoint file.

This feature is available to simplify the work of users by avoiding
the need to use the 'officer' package. If it doesn't suit your needs,
then use the API offered by 'officer' which allows simple and
complicated things.
}
\note{
The PowerPoint format ignores captions (see \code{\link[=set_caption]{set_caption()}}).
}
\examples{
ft1 <- flextable(head(iris))
tf <- tempfile(fileext = ".pptx")
save_as_pptx(ft1, path = tf)

ft2 <- flextable(head(mtcars))
tf <- tempfile(fileext = ".pptx")
save_as_pptx(`iris table` = ft1, `mtcars table` = ft2, path = tf)
}
\seealso{
Other flextable print function: 
\code{\link{df_printer}()},
\code{\link{flextable_to_rmd}()},
\code{\link{gen_grob}()},
\code{\link{htmltools_value}()},
\code{\link{knit_print.flextable}()},
\code{\link{plot.flextable}()},
\code{\link{print.flextable}()},
\code{\link{save_as_docx}()},
\code{\link{save_as_html}()},
\code{\link{save_as_image}()},
\code{\link{save_as_rtf}()},
\code{\link{to_html.flextable}()}
}
\concept{flextable print function}
