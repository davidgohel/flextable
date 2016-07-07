library(flextable)
library(oxbase)
library(dplyr)

def_txt <- pr_text(font.size = 9, font.family = "Arial")
def_head <- update(def_txt, color = "red")
def_cell <- pr_cell( border = pr_border(color = "gray") )

ft <- flextable(iris, select = c("Species", "break1",
                                 "Sepal.Length", "Sepal.Width", "break2",
                                 "Petal.Length", "Petal.Width")
                ) %>%
  set_header(Sepal.Length = list("Length", "Sepal"),
             Sepal.Width = list("Width", "Sepal"),
             Petal.Length = list("Length", "Petal"),
             Petal.Width = list("Width", "Petal"),
             Species = list("Species", "Species"))%>%
  style(def_head, part = "header") %>%
  style(def_txt, part = "body") %>%
  bg(color = "#CCCCEE", part = "header") %>%
  merge_v(j = c("Species") ) %>%
  border(border.bottom = pr_border(width=1, color = "red"), part = "all") %>%
  padding(padding = 1, part = "all")# %>%
  #autofit(add_w = .0) #%>%
optim_dim(ft)
dim(autofit(ft))
# pptx_file <- write_pptx("test.pptx", ft)
# browseURL(pptx_file)
# docx_file <- write_docx("test.docx", ft)
# browseURL(docx_file)
# unlink(docx_file)
# unlink(pptx_file)
