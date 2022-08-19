errors <- readLines("errors.txt")

extraction.list <- strsplit(errors, split = ":")

error.file.paths <- sapply(extraction.list,"[[",1)

n = length(error.file.paths)

for (i in 1:n) {
  
  # Check if files can be read
  # file <- readLines(error.file.paths[i])
  # print(file[1])
  # This worked

  # convert to UTF8  
  writeLines(iconv(readLines(error.file.paths[i]), 
                   from = "", 
                   to = "UTF8"), 
             file(error.file.paths[i], encoding="UTF-8")
             )
  
}