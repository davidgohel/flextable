flextable R package
================

-   [API](#api)
-   [Installation](#installation)
-   [Quick demo](#quick-demo)

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/davidgohel/flextable.svg?branch=master)](https://travis-ci.org/davidgohel/flextable) [![Coverage Status](https://img.shields.io/codecov/c/github/davidgohel/flextable/master.svg)](https://codecov.io/github/davidgohel/flextable?branch=master) [![CRAN version](http://www.r-pkg.org/badges/version/flextable)](https://cran.r-project.org/package=flextable) ![](http://cranlogs.r-pkg.org/badges/grand-total/flextable) [![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

API
---

A tabular reporting tool that let R users create tables for reporting and control their formatting properties and their layout.

-   Manage headers
-   Format text, paragraphs, cells and border of any element
-   Separate data from displayed values
-   Outut availables are Microsoft Word, PowerPoint and HTML (as an `htmlwidgets` object).

Installation
------------

You can get the development version from GitHub:

``` r
devtools::install_github("davidgohel/oxbase")
devtools::install_github("davidgohel/flextable")
```

Quick demo
----------

`flextable` is designed for use with the `%>%` pipe operator. You can make this `%>%` operator available in your R workspace by loading package [`magrittr`](https://cran.r-project.org/package=magrittr).

``` r
library("magrittr")
library("flextable")
library("oxbase")
library("dplyr")
```

The following dataset will be used as input paramter of `flextable` call:

``` r
mydata <- iris %>% 
  group_by(Species) %>% 
  do( head(., n = 3) )
mydata
#> Source: local data frame [9 x 5]
#> Groups: Species [3]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width    Species
#>          <dbl>       <dbl>        <dbl>       <dbl>     <fctr>
#> 1          5.1         3.5          1.4         0.2     setosa
#> 2          4.9         3.0          1.4         0.2     setosa
#> 3          4.7         3.2          1.3         0.2     setosa
#> 4          7.0         3.2          4.7         1.4 versicolor
#> 5          6.4         3.2          4.5         1.5 versicolor
#> 6          6.9         3.1          4.9         1.5 versicolor
#> 7          6.3         3.3          6.0         2.5  virginica
#> 8          5.8         2.7          5.1         1.9  virginica
#> 9          7.1         3.0          5.9         2.1  virginica
```

The following styles are to be used later.

``` r
def_txt <- fp_text(font.size = 9, font.family = "Arial", color = "gray40")
def_head <- update(def_txt, font.size = 11, color = "gray20")
def_cell <- fp_cell( border = fp_border(color = "gray") )
```

First, define the flextable.

``` r
ft <- flextable(mydata, col_keys = c("Species", 
    "Sepal.Length", "Sepal.Width", "Petal.Length", 
    "Petal.Width") )
```

Add titles to header part.

``` r
ft <- flextable(mydata, col_keys = c("Species", 
    "Sepal.Length", "Sepal.Width", "Petal.Length", 
    "Petal.Width") ) %>%
  set_header_labels(Sepal.Length = "Length", 
             Sepal.Width = "Width",
             Petal.Length = "Length",
             Petal.Width = "Width", 
             Species = "Species" ) %>%
  add_header(Sepal.Length = "Sepal", 
             Sepal.Width = "Sepal",
             Petal.Length = "Petal",
             Petal.Width = "Petal", 
             Species = "Species") 
```

Merge some cells.

``` r
ft <- ft %>% 
  merge_h(part = "header") %>% 
  merge_v(part = "header") %>% 
  merge_v(j = "Species" ) 
```

Then apply some formatting properties :

``` r
ft <- ft %>% 
  theme_tron() %>% 
  autofit() 
```

<table class="tabwid">
<col width="55">
<col width="46">
<col width="40">
<col width="46">
<col width="40">
<thead>
<tr>
<td rowspan="2" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Species</span>
</p>
</td>
<td colspan="2" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Sepal</span>
</p>
</td>
<td colspan="2" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Petal</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Length</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Width</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Length</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(236,147,70,1.00);font-size:10px;font-style:normal;font-weight:bold;text-decoration:none;background-color:transparent;">Width</span>
</p>
</td>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="3" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">setosa</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">5.100</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.500</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.400</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">0.200</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">4.900</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.000</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.400</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">0.200</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">4.700</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.200</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.300</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">0.200</span>
</p>
</td>
</tr>
<tr>
<td rowspan="3" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">versicolor</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">7.000</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.200</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">4.700</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.400</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">6.400</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.200</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">4.500</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.500</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">6.900</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.100</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">4.900</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.500</span>
</p>
</td>
</tr>
<tr>
<td rowspan="3" class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">virginica</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">6.300</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.300</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">6.000</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">2.500</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">5.800</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">2.700</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">5.100</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">1.900</span>
</p>
</td>
</tr>
<tr>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">7.100</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">3.000</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">5.900</span>
</p>
</td>
<td class="cd86c2cabaccff902b15ac957451e7e4b">
<p style="margin:0pt;text-align:right;border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);padding-top:2pt;padding-bottom:2pt;padding-left:2pt;padding-right:2pt;background-color:transparent;">
<span style="font-family:'Arial';color:rgba(164,206,229,1.00);font-size:10px;font-style:normal;font-weight:normal;text-decoration:none;background-color:transparent;">2.100</span>
</p>
</td>
</tr>
</tbody>
</table>
<style> .cd23329214b05229bf7576dfa7e46ed67{border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.c7ce5fb6a0ff19b146f5bba807fd4f396{border-bottom: 1pt solid rgba(0,0,0,1.00);border-top: 1pt solid rgba(0,0,0,1.00);border-left: 1pt solid rgba(0,0,0,1.00);border-right: 1pt solid rgba(0,0,0,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.c434bb7769054949cda25732a9057647a{border-bottom: 1pt solid rgba(164,206,229,1.00);border-top: 1pt solid rgba(164,206,229,1.00);border-left: 1pt solid rgba(164,206,229,1.00);border-right: 1pt solid rgba(164,206,229,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.cd86c2cabaccff902b15ac957451e7e4b{border-bottom: 1pt solid rgba(164,206,229,1.00);border-top: 1pt solid rgba(164,206,229,1.00);border-left: 1pt solid rgba(164,206,229,1.00);border-right: 1pt solid rgba(164,206,229,1.00);background-color:rgba(0,0,0,1.00);margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.cd23329214b05229bf7576dfa7e46ed67{border-bottom: 0pt solid rgba(0,0,0,1.00);border-top: 0pt solid rgba(0,0,0,1.00);border-left: 0pt solid rgba(0,0,0,1.00);border-right: 0pt solid rgba(0,0,0,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.c7ce5fb6a0ff19b146f5bba807fd4f396{border-bottom: 1pt solid rgba(0,0,0,1.00);border-top: 1pt solid rgba(0,0,0,1.00);border-left: 1pt solid rgba(0,0,0,1.00);border-right: 1pt solid rgba(0,0,0,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.c434bb7769054949cda25732a9057647a{border-bottom: 1pt solid rgba(164,206,229,1.00);border-top: 1pt solid rgba(164,206,229,1.00);border-left: 1pt solid rgba(164,206,229,1.00);border-right: 1pt solid rgba(164,206,229,1.00);background-color:transparent;margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;}.cd86c2cabaccff902b15ac957451e7e4b{border-bottom: 1pt solid rgba(164,206,229,1.00);border-top: 1pt solid rgba(164,206,229,1.00);border-left: 1pt solid rgba(164,206,229,1.00);border-right: 1pt solid rgba(164,206,229,1.00);background-color:rgba(0,0,0,1.00);margin-top:0pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;vertical-align:middle;} </style>
