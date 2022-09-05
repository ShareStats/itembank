# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

# setwd("/Users/tasospsy/Google Drive/ShareStats/itembank/")
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
    ## To Compile to .html uncomment the following line
    # exams:::browse_exercise(
    
    ## To Compile to QTI 2.1 uncomment the following line
    # exams::exams2qti21(
    
    ## To Compile to testVision uncomment the following line
    exams::exams2testvision(
    
    ## Run all the rest as it is 
      # compile each .Rmd file...
      file = all.item.paths[i],
      
      # ...with a given name...
      name = names[i],
      
      # ...to a given folder.
      dir = folders[i])
  }, error = function(e){
    mist <<- rbind(mist, paste('Item:', names[i],"; Error:",conditionMessage(e)))
  }
  )
}
mist  

Item_Qti_Errors <- mist

write.table(Item_Qti_Errors, file = "Item_Qti_Errors.txt", sep = "\n",
            row.names = FALSE)
  

## QTI compilation
## because 'exams2qti21' gives a .zip file as output,
## we rename everything to <path-file>-qti.zip
Zips <- list.files(pattern = ".zip", ignore.case = TRUE, recursive = TRUE)
newZips <- gsub(".zip", "-qti.zip", Zips )
file.rename(Zips, newZips)
