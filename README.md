flextable R package
================

-   [`flextable` API](#flextable-api)
    -   [Install `flextable`](#install-flextable)
    -   [Load `flextable`](#load-flextable)
    -   [Quick demo](#quick-demo)

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/davidgohel/flextable.svg?branch=master)](https://travis-ci.org/davidgohel/flextable) [![Coverage Status](https://coveralls.io/repos/davidgohel/flextable/badge.svg)](https://coveralls.io/r/davidgohel/flextable) [![CRAN version](http://www.r-pkg.org/badges/version/flextable)](https://cran.r-project.org/package=flextable) ![](http://cranlogs.r-pkg.org/badges/grand-total/flextable) [![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

`flextable` API
---------------

A tabular reporting tool that let R users create tables for reporting and control their formatting properties and their layout.

Features:

-   Manage headers
-   Format text, paragraphs, cells and border of any element
-   Separate data from displayed values
-   Outut availables are Microsoft Word, PowerPoint and HTML (as an `htmlwidgets` object).

### Install `flextable`

You can get the development version from GitHub:

``` r
devtools::install_github("davidgohel/flextable")
```

### Load `flextable`

`flextable` is designed for use with the `%>%` pipe operator. You can make this `%>%` operator available in your R workspace by loading package [`magrittr`](https://cran.r-project.org/package=magrittr).

``` r
library("flextable")
#> Loading required package: oxbase
library("magrittr")
```

### Quick demo

TBD
