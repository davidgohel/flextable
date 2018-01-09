library(webshot)
library(magrittr)
library(tibble)
library(dplyr)
library(purrr)
library(magick)

tables_ex <- tribble(
  ~url, ~selector,
  "https://davidgohel.github.io/flextable/articles/overview.html", "#introduction > div.tabwid > table",
  "https://davidgohel.github.io/flextable/articles/format.html", '#images > div > table',
  "https://davidgohel.github.io/flextable/articles/layout.html", '#add-the-dataset-as-header-rows > div > table',
  "https://davidgohel.github.io/flextable/articles/format.html", '#conditional-formatting > div:nth-child(4) > table',
  "https://davidgohel.github.io/flextable/articles/examples.html", '#complex-header > div:nth-child(15) > table',
  "https://davidgohel.github.io/flextable/articles/examples.html", '#time-series > div > table',
  "https://davidgohel.github.io/flextable/articles/examples.html", '#anova > div > table',
  "https://davidgohel.github.io/flextable/articles/overview.html", "#layout > div:nth-child(14) > table",
  "https://davidgohel.github.io/flextable/articles/overview.html", '#formating .tabwid table',
  "https://davidgohel.github.io/flextable/articles/examples.html", '#tables > div > table'
)

save_one_file <- function(url, selector){
  filename <- tempfile(fileext = ".png")
  webshot::webshot(url, filename, selector = selector, expand = 2, zoom = 4)
  filename
}

tables_ex$webshot_filepath <- purrr::map2_chr(tables_ex$url, tables_ex$selector, save_one_file)
tables_ex$order <- seq_along(tables_ex$webshot_filepath)
tables_ex$order[5] <- 8
tables_ex$order[8] <- 5
tables_ex <- tables_ex[order(tables_ex$order),]
# collage is made column by column
# then the columns are assembled in one image
make_col <- function(path, color, geometry) {
  tmp <- tempfile(fileext = ".png")
  image_read(path) %>%
    image_border(color = color, geometry = geometry) %>%
    image_append(stack = TRUE) %>% # append pictures vertically
    image_write(tmp)
  return(tmp)
}

tables_ex[-10,] %>%
  add_column(column = rep(1:3, length.out = nrow(tables_ex[-10,] ))) %>% # assign each tweet to a column
  group_by(column) %>%
  summarise(col_image = make_col(webshot_filepath, color = "white", geometry = "30x30")) %>%
  pull(col_image) %>%
  image_read() %>%
  image_append(stack = FALSE) %>% # append column pictures horizontally
  image_border(color = "white", geometry = "30x30") %>%
  image_write("flextable_collage.png") %>% browseURL()

