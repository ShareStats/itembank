## ShareStats
## Tasos first test on parser
## 23/05/2022

library(tidyverse)

extractMeta <- function(file, convert2table = FALSE) {
  x <- read_lines(file)
  lnMeta <- grep("Meta-information", x)  
  lnMeta <- seq(lnMeta + 2, length(x), 1)
  x <- x[lnMeta] 
  names(x) <- gsub("(.*):.*", "\\1", x)
  x <- gsub(".*: (.*)", "\\1", x) 
  x <- as.list(x)
  if(!convert2table) {
    x <- lapply(x, function(i) ifelse(i=="", NA, i))
    x <- x[!is.na(x)]
    return(x)
  } else {
    x <- t(do.call(rbind, x))
    return(data.frame(x))
  }
}

#setwd("/Users/tasospsy/Google Drive/ShareStats/vufsw-nl/testfolder/")
#file <- "vufsw-alternative_hypothesis-0075-nl.Rmd"
#res <- foo(file)
#res

