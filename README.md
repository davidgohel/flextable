flextable R package
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![R build
status](https://github.com/davidgohel/flextable/workflows/R-CMD-check/badge.svg)](https://github.com/davidgohel/flextable/actions)
[![version](https://www.r-pkg.org/badges/version/flextable)](https://CRAN.R-project.org/package=flextable)
![cranlogs](https://cranlogs.r-pkg.org/badges/flextable) [![codecov test
coverage](https://codecov.io/gh/davidgohel/flextable/branch/master/graph/badge.svg)](https://codecov.io/gh/davidgohel/flextable)
![Active](https://www.repostatus.org/badges/latest/active.svg)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)

<a href="https://github.com/davidgohel/flextable"><img src="man/figures/logo.png" alt="flextable logo" align="right" /></a>
The flextable package provides a framework for easily create tables for
reporting and publications. Tables can be easily formatted with a set of
verbs such as `bold()`, `color()`, they can receive a header of more
than one line, cells can be merged or contain an image. The package make
it possible to build any table for publication from a \`data.frame’.

**Documentation**: <https://davidgohel.github.io/flextable/>

<img src="man/figures/fig_formats.png" width="170px" alt="flextable formats" align="left" />
Tables can be embedded within HTML, PDF, Word and PowerPoint documents
from R Markdown documents and within Microsoft Word or PowerPoint
documents with package officer. Tables can also be rendered as R plots
or graphic files (png, pdf and jpeg).

## Getting Started

An API is available to let R users create tables for reporting and
control their formatting properties and their layout. A `flextable`
object is a data.frame representation, it can be manipulated with
functions that give control over:

  - header, body and footer content
  - text, paragraphs, cells and border formatting of any element
  - displayed values

![](https://www.ardata.fr/img/illustrations/flextable_functions.svg)

There are articles on the flextable website that will help you get you
to start quickly:

  - [Introduction to
    flextable](https://davidgohel.github.io/flextable/articles/overview.html)
  - [Function
    reference](https://davidgohel.github.io/flextable/reference/index.html)

The help pages can be read
[here](https://davidgohel.github.io/flextable/).

### Installation

``` r
install.packages("flextable")
```

You can get the development version from GitHub:

``` r
devtools::install_github("davidgohel/flextable")
```

## Resources

### Online documentation

The help pages are located at <https://davidgohel.github.io/flextable/>.

### Getting help

This project is developed and maintained on my own time. If you have
questions about how to use the package, visit Stackoverflow and use tags
`flextable` and `r` [Stackoverflow
link](https://stackoverflow.com/questions/tagged/flextable+r)\! I
usually read them and answer when possible.

Don’t send me a private emails to get free R support or to ask questions
about using the package. They are systematically ignored except if you
are French in which case I send you a commercial proposal :)

## Contributing to the package

### Code of Conduct

Anyone getting involved in this package agrees to our [Code of
Conduct](https://github.com/davidgohel/flextable/blob/master/CONDUCT.md).

### Bug reports

When you file a [bug
report](https://github.com/davidgohel/flextable/issues), please spend
some time making it easy for me to follow and reproduce. The more time
you spend on making the bug report coherent, the more time I can
dedicate to investigate the bug as opposed to the bug report.

### Contributing to the package development

A great way to start is to contribute an example or improve the
documentation.

If you want to submit a Pull Request to integrate functions of yours,
please provide:

  - the new function(s) with code and roxygen tags (with examples)
  - a new section in the appropriate vignette that describes how to use
    the new function
  - corresponding tests in directory `tests/testthat`.

By using rhub (run `rhub::check_for_cran()`), you will see if everything
is ok. When submitted, the PR will be evaluated automatically on travis
and appveyor and you will be able to see if something broke.
