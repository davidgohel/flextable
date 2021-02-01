library(pagedown)
library(knitr)

if(!require("doconv")){
  stop("please install doconv before using that script with command:\n",
       "remotes::install_github('ardata-fr/doconv')")
}
python_available(error = TRUE)
if(!docx2pdf_available()){
  install_docx2pdf()
}


captions_example <- system.file(
  package = "flextable",
  "examples/rmd", "captions_example.Rmd")

dir_tmp <- tempfile(pattern = "dir")
dir.create(dir_tmp, showWarnings = FALSE, recursive = TRUE)
file.copy(captions_example, dir_tmp)
rmd_file <- file.path(dir_tmp, basename(captions_example))

file.copy(captions_example, to = rmd_file, overwrite = TRUE)
opts_chunk$set(echo = FALSE, message = FALSE)

if(require("rmarkdown", quietly = TRUE)){
  render(input = rmd_file,
         output_format = word_document(),
         output_file = "rmarkdown-word.docx")
  render(input = rmd_file,
         output_format = pdf_document(latex_engine = "xelatex"),
         output_file = "rmarkdown-latex.pdf")
  render(input = rmd_file,
         output_format = html_document(),
         output_file = "rmarkdown-html.html")

  # bookdown ----
  if(require("bookdown", quietly = TRUE)){
    render(input = rmd_file, output_format = word_document2(),
           output_file = "book-word.docx")
    render(input = rmd_file,
           output_format = pdf_document2(latex_engine = "xelatex"),
           output_file = "book-pdf.pdf")
    render(input = rmd_file,
           output_format = html_document2(),
           output_file = "book-html.html")

    # officedown ----
    if(require("officedown", quietly = TRUE)){
      render(input = rmd_file,
             output_format = markdown_document2(base_format=rdocx_document),
             output_file = "officedown.docx")
    }
  }
}
browseURL(dirname(rmd_file))

docx_to_miniature(file.path(dirname(rmd_file), "rmarkdown-word.docx"),
                  width = 700,
                  fileout = "inst/fig_ref/test-caption-rmarkdown-docx.png")
docx_to_miniature(file.path(dirname(rmd_file), "book-word.docx"),
                  width = 700,
                  fileout = "inst/fig_ref/test-caption-book-word.png")

pdf_to_miniature(file.path(dirname(rmd_file), "rmarkdown-latex.pdf"),
                 width = 700,
                 fileout = "inst/fig_ref/test-caption-rmarkdown-pdf.png")
pdf_to_miniature(file.path(dirname(rmd_file), "book-pdf.pdf"),
                 width = 700,
                 fileout = "inst/fig_ref/test-caption-book-pdf.png")

chrome_print(file.path(dirname(rmd_file), "rmarkdown-html.html"), output = "inst/fig_ref/test-caption-rmarkdown-html.png",
             wait = 2, format = "png", scale = 2)
chrome_print(file.path(dirname(rmd_file), "book-html.html"), output = "inst/fig_ref/test-caption-book-html.png",
             wait = 2, format = "png", scale = 2)

docx_to_miniature(file.path(dirname(rmd_file), "officedown.docx"),
                  width = 700,
                  fileout = "inst/fig_ref/test-caption-officedown-docx.png")
