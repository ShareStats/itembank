# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

for (i in 1:n) {
  
  # Check if files can be read
  # file <- readLines(error.file.paths[i])
  # print(file[1])
  # This worked

  # convert al items to UTF8  
  writeLines(iconv(readLines(all.item.paths[i]), 
                   from = "", 
                   to = "UTF8"), 
             file(all.item.paths[i], encoding="UTF-8")
             )
  
}