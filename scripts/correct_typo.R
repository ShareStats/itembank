# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  

  
  # Only write file if changes need to be made
  if( !identical(grep("Interpretating", text), integer(0) ) ) {
  
    # Interpretating -> Interpreting
    text <- gsub("Interpretating", "Interpreting", text)
    line.nr = grep("Interpreting", text)  
  
    print(text[line.nr])
    writeLines(text, all.item.paths[i])
  }
  
}