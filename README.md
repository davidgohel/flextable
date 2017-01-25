flextable R package
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/davidgohel/flextable.svg?branch=master)](https://travis-ci.org/davidgohel/flextable) [![Coverage Status](https://img.shields.io/codecov/c/github/davidgohel/flextable/master.svg)](https://codecov.io/github/davidgohel/flextable?branch=master) [![CRAN version](http://www.r-pkg.org/badges/version/flextable)](https://cran.r-project.org/package=flextable) ![](http://cranlogs.r-pkg.org/badges/grand-total/flextable) [![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

![tables chez Chartier](http://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Paris_Chartier_1304.jpg/640px-Paris_Chartier_1304.jpg)

flextable
---------

The flextable package provides a framework for easily creating tables for reporting. Tables created using the framework can be:

-   Embedded within R Markdown documents and Shiny web applications.
-   Embedded within Microsoft Word or PowerPoint documents.

Getting Started
---------------

An API is available to let R users create tables for reporting and control their formatting properties and their layout. A `flextable` object is a data.frame representation, it can be manipulated with functions that give control over:

-   headers managment
-   text, paragraphs, cells and border formatting of any element
-   displayed values

### Installation

You can get the development version from GitHub:

``` r
devtools::install_github("davidgohel/flextable")
```

There are articles on the flextable website that will help you get you to start quickly:

-   [Introduction to flextable](http://davidgohel.github.io/flextable/articles/introduction.html)
-   [Function reference](http://davidgohel.github.io/flextable/reference/index.html)
