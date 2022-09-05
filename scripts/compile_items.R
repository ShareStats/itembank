# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

#setwd("/Users/tasospsy/Google Drive/ShareStats/itembank/")
# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

# extract the path of each item that we want to 
# store the compiled files
folders <- gsub('/[^/]+$','', all.item.paths)

# extract the name of the item without extension
names <- gsub('.*/','', folders)

mist <- c()
for (i in 1:n) {
  tryCatch({
    ## To Compile to .html uncomment the following (3)lines
    #exams:::browse_exercise(
    #file = all.item.paths[i],
    #name = names[i]),

    
    ## To Compile to QTI 2.1 uncomment the following (3)lines
    # exams::exams2qti21(
    #file = all.item.paths[i],
    #name = paste0(names[i],"-qti"),
    
    ## To Compile to testVision uncomment the following (3)lines
    exams::exams2testvision(
    file = all.item.paths[i],
    name = paste0(names[i],"-tv"),
      
    # Leave the rest code as its for any compilation
      # ...to a given folder.
      dir = folders[i])
  }, error = function(e){
    mist <<- rbind(mist, paste('Item:', names[i],"; Error:",conditionMessage(e)))
  }
  )
}
mist  

Item_TV_Errors <- mist

write.table(Item_TV_Errors, file = "Item_TV_Errors.txt", sep = "\n",
            row.names = FALSE)
  






