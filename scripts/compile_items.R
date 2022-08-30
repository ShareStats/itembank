# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

for (i in 1:n) {
  
  # use exam package to compile 
  # from path i
  # to path gsub i transform .Rmd to .html
  
  # compile to 
  # html
  # QTI 2.1
  # Testvision
  
  
}