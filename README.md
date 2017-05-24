flextable R package
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/davidgohel/flextable.svg?branch=master)](https://travis-ci.org/davidgohel/flextable) [![Build status](https://ci.appveyor.com/api/projects/status/github/davidgohel/flextable?branch=master)](https://ci.appveyor.com/project/davidgohel/flextable/branch/master) [![Coverage Status](https://img.shields.io/codecov/c/github/davidgohel/flextable/master.svg)](https://codecov.io/github/davidgohel/flextable?branch=master) [![version](http://www.r-pkg.org/badges/version/flextable)](https://CRAN.R-project.org/package=flextable) ![cranlogs](http://cranlogs.r-pkg.org./badges/flextable) [![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

flextable
---------

The flextable package provides a framework for easily create tables for reporting. Tables can be embedded within:

-   R Markdown documents and Shiny web applications.
-   Microsoft Word or PowerPoint documents.

Getting Started
---------------

An API is available to let R users create tables for reporting and control their formatting properties and their layout. A `flextable` object is a data.frame representation, it can be manipulated with functions that give control over:

-   headers content
-   text, paragraphs, cells and border formatting of any element
-   displayed values

There are articles on the flextable website that will help you get you to start quickly:

-   [Introduction to flextable](https://davidgohel.github.io/flextable/articles/overview.html)
-   [Function reference](https://davidgohel.github.io/flextable/reference/index.html)

The help pages can be read [here](https://davidgohel.github.io/flextable).

### Installation

``` r
install.packages("flextable")
```

You can get the development version from GitHub:

``` r
devtools::install_github("davidgohel/flextable")
```
