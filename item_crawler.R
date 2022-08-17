all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)
n = length(all.item.paths)

for (i in 1:n) {
  
  print(all.item.paths[i])
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  line.nr = grep("exsection", text)
  
  print(text[line.nr])
  
}