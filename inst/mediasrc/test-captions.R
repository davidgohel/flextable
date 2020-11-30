# bookdown examples wth captions and cross ref -----
captions_example <- system.file(
  package = "flextable",
  "examples/rmd", "captions_example.Rmd")

dir_tmp <- tempfile(pattern = "dir")
dir.create(dir_tmp, showWarnings = FALSE, recursive = TRUE)
file.copy(captions_example, dir_tmp)
rmd_file <- file.path(dir_tmp, basename(captions_example))

file.copy(captions_example, to = rmd_file, overwrite = TRUE)

if(require("rmarkdown", quietly = TRUE)){
  render(input = rmd_file,
         output_format = word_document(),
         output_file = "doc.docx")
  render(input = rmd_file,
         output_format = pdf_document(latex_engine = "xelatex"),
         output_file = "doc.pdf")
  render(input = rmd_file,
         output_format = html_document(),
         output_file = "doc.html")

  # bookdown ----
  if(require("bookdown", quietly = TRUE)){
    render(input = rmd_file, output_format = word_document2(),
           output_file = "book.docx")
    render(input = rmd_file,
           output_format = pdf_document2(latex_engine = "xelatex"),
           output_file = "book.pdf")
    render(input = rmd_file,
           output_format = html_document2(),
           output_file = "book.html")

    # officedown ----
    if(require("officedown", quietly = TRUE)){
      render(input = rmd_file,
             output_format = markdown_document2(base_format=rdocx_document),
             output_file = "officedown.docx")
    }
  }
}
browseURL(dirname(rmd_file))

all_results <- list.files(pattern = "\\.(docx|pdf|html|pptx)$", path = dirname(rmd_file), full.names = TRUE)
for(i in all_results) browseURL(i)
