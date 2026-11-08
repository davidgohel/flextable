# Read an image as a native raster, with a cache

Read an image file as a native raster, which is much faster to draw than
a raster object with
[`grid::rasterGrob()`](https://rdrr.io/r/grid/grid.raster.html). The
raster is kept for the R session, so that an image used many times is
only decoded once. The file is read again if it has changed, and the
least recently used rasters are dropped when the cache becomes too
large.

This function is used by
[`gen_grob()`](https://davidgohel.github.io/flextable/reference/gen_grob.md)
and is exported for packages that draw the same images with 'grid'.
Package 'magick' is required.

## Usage

``` r
image_raster(path, width = NULL, height = NULL)
```

## Arguments

- path:

  path to the image file.

- width, height:

  size in inches at which an SVG file is rendered, they are ignored with
  other formats.

## Value

An object of class `nativeRaster`. An error is raised if the file can
not be read.
