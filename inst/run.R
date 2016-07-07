library(flextable)
library(oxbase)
library(dplyr)
def_txt <- pr_text(font.size = 9, font.family = "Arial")
def_head <- update(def_txt, color = "red")
def_cell <- pr_cell( border = pr_border(color = "gray") )

dat <- mtcars %>% head() %>%
  select(gear, carb, am, drat, wt, qsec)
dat$img <- ""#"/Users/davidgohel/Documents/raster.png"

meta <- data.frame(col_keys = names(dat),
                   labels = c(rep("class", 3), rep("measure", 4)),
                   names_ = names(dat),
                   stringsAsFactors = FALSE)

ft <- flextable(dat) %>%
  # set_header(data_mapping = meta) %>%
  # display(i = ~ drat > 3.5,
  #   gear = format_that("sss {{ gear_ }} is cool {{ qsec_ }}", pr_par_ = p_r(padding = 5 ),
  #             gear_ = ftext(gear, pr_text(bold = TRUE, italic=TRUE, color="red") ),
  #             qsec_ = ftext(qsec, pr_text(bold = TRUE, italic=TRUE, color="blue" ) )
  #             ),
  #   # img = format_that("{{ img_ }} :(", img_ = external_img( img ) ),
  #   am = format_that("{{ am_ }}$", am_ = ftext( format_integer(am), t_i() ) ),
  #   qsec = format_simple(format_double(qsec, digits = 0) ),
  #   carb = format_that("# {{ carb_ }}", carb_ = ftext(carb, pr_text(italic=TRUE, color="blue") ) )
  #   ) %>%
  style(def_head, part = "header") %>%
  style(def_txt, part = "body") %>%

  bg(bg = "#CCCCEE", part = "header") %>%
  merge_v(j = c("am") ) %>%
  merge_h(i = 2 ) %>%
  style(i = ~ drat > 3.5, j = ~ am + gear + carb,
            pr_text(color="gray", italic = TRUE)) %>%
  border(
    border.top = pr_border(width=1, color= "orange"),
    border.bottom = pr_border(width=0),
   border.left = pr_border(width=0),
   border.right = pr_border(width=0),
    part = "header") %>%
  border(
    border.top = pr_border(width=1),
    border.bottom = pr_border(width=1),
    border.left = pr_border(width=0),
    border.right = pr_border(width=0),
    part = "body") %>%
  border(i = 1,
    border.top = pr_border(width=1, color = "orange"), part = "body") %>%
  padding(padding.left = 5, padding.right = 5, padding.bottom = 5, padding.top = 5, part = "all") %>%
  autofit(add_w = .2) %>%
  height(height = .15, part = "all")
# ft$header$rowheights[] <- .5
# ft$body$rowheights[] <- .15

# dim(ft)
print(tabwid(ft))
pptx_file <- write_pptx("test.pptx", ft)
browseURL(pptx_file)
# docx_file <- write_docx("test.docx", ft)
# browseURL(docx_file)
# unlink(docx_file)
# unlink(pptx_file)
