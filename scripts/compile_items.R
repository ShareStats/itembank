# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

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
    exams:::browse_exercise(
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
# use exam package to compile 
# from path i
# to path gsub i transform .Rmd to .html
# (using the developers veresion)
Item_Errors <- mist

write.table(Item_Errors, file = "Item_Errors.txt", sep = "\n",
            row.names = FALSE)
  
# compile to 
  # html
  # QTI 2.1
  # Testvision
  

