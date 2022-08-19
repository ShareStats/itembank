# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  
  # Interpretating -> Interpreting
  if( grep("Interpretating", text) ) {
  
  line.nr = grep("Interpretating", text)
  
  print(text[line.nr])
  
  }
  
}