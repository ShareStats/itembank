# Install development version of exams::
install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

n = length(all.item.paths)

# extract the path of each item that we want to 
# store the compiled files
folders <- gsub('/[^/]+$','', all.item.paths)

# extract the name of the item without extension
names <- gsub('.*/','', folders)

for (i in 1:n) {
  # use exam package to compile 
  # from path i
  # to path gsub i transform .Rmd to .html
  # (using the developers veresion)
  exams:::browse_exercise(
    # compile each .Rmd file...
    file = all.item.paths[i],
    # ...with a given name...
             name = names[i],
    # ...to a given folder.
             dir = folders[i])
}

## NOTE: It runs but stops when Error is given,
# e.g., wrong exsolution
  
  # compile to 
  # html
  # QTI 2.1
  # Testvision
  

