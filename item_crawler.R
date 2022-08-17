# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

for (i in 1:n) {
  
  print(all.item.paths[i])
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  line.nr = grep("exsection", text)
  
  print(text[line.nr])
  
  # replace word in text file using sed in bash
  # sed -i '' -E 's/<string-to-find>/<string-to-replace>/' <your-file-path>
  # run sed in bash through system()
  
}