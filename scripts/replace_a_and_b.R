
# Replace (a) and (b) and (c) with 'A' 'B' 'C' ----------------------------

# read all items
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)
#uva.item.paths <- grep(pattern = "uva", all.item.paths, ignore.case = TRUE, value = TRUE)
#n.uva <- length(uva.item.paths)
n <- length(all.item.paths)

# Find items with '(a)' or '(b)' in answers -------------------------------
wrong.items <-c()
for(i in 1:n){
  x <- readLines(all.item.paths[i])
  pattern <- "\\* \\(a\\)" # if a then b or c
  match_in_x <- grep(pattern, x)
  if(length(match_in_x)>0) wrong.items <- rbind(wrong.items, all.item.paths[i])
}
length(wrong.items)
#for(val in 1:25) print(readLines(wrong.items[val])[grep("* \\(a\\)", readLines(wrong.items[val]))])

replace.foo <- function(text) {
  text <- gsub("\\(a\\)", "'A'", text)
  text <- gsub("\\(b\\)", "'B'", text)
  text <- gsub("\\(c\\)", "'C'", text)
}
for(i in 1:length(wrong.items)){
  rmd <- readLines(wrong.items[i])
  new.rmd <- replace.foo(rmd)
  writeLines(new.rmd, wrong.items[i])
}

# End