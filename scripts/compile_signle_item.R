# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

testrun = FALSE  # if true, output file have the prefix "testrun-". These files will be ignored by git

#setwd("/Users/tasospsy/Google Drive/ShareStats/itembank/")
# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

# Enter the item name you want to compile
search_for_item = "vufgb-mediation-007-nl"

item_to_compile = grep(search_for_item, all.item.paths, value = TRUE)
 
# extract the path of each item that we want to 
# store the compiled files
folder <- gsub('/[^/]+$','', item_to_compile)

# extract the name of the item without extension
if (testrun) {
  name <- gsub('.*/','testrun-', folder)
} else {
  name <- gsub('.*/','', folder)
}


Errors <- c()

  tryCatch({
    ## To Compile to .html uncomment the following (3)lines
    exams:::browse_exercise(
    file    = item_to_compile,
    name    = name,
    dir     = folder)

    ## To Compile to QTI 2.1 uncomment the following (3)lines
    exams::exams2qti21(
    file = item_to_compile,
    name = paste0(name,"-qti"),
    schoice=list(enumerate = FALSE),
    dir  = folder)
    
    ## To Compile to testVision uncomment the following (3)lines
    exams::exams2testvision(
    file = item_to_compile,
    name = paste0(name,"-tv"),
    schoice=list(enumerate = FALSE),
    dir  = folder)

      }, error = function(e){
    Errors <<- rbind(Errors, paste('Item:', names[i],"; Error:",conditionMessage(e)))
  }
  )

Errors  

# write.table(Errors, file = "Errors-TV.txt", sep = "\n",
#             row.names = FALSE)
  






