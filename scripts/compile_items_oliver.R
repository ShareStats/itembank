#
# Usage: import functions and run compile_items(...) in base folder of the itembank
# see options below
# 

# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")

library(tools)
library(exams)

.needs_update <- function(source_file, destination_file, time_criterion_sec = 5) {
  dest_mtime = file.info(destination_file)$mtim 
  if (is.na(dest_mtime)) {
    return(TRUE)
  } else {
    time_diff = difftime(file.info(source_file)$mtim, dest_mtime, units = "secs")
    return(time_diff > time_criterion_sec)
  }
}

.get_files <- function(file_path, testrun) {
  # creates and checks filenames
  
  # extract the folder
  folder <- gsub('/[^/]+$','', file_path)
  name <- gsub('.*/','', folder)
  
  source_file = file.path(folder, paste0(name, ".", file_ext(file_path)))
  if (!file.exists(source_file)) {
    print(paste0("Error: Incorrectly named Rmd-file named in ", folder))
    return(NA)
  }
  
  if (testrun) {
    name <- paste0('testrun-', name)
  } 
  return(list(folder = folder,
              name = name,
              qti_name =  paste0(name, "-qti"),
              tv_name =  paste0(name, "-tv"),
              qti=file.path(folder, paste0(name, "-qti.zip")),
              html=file.path(folder, paste0(name, "1.html")),
              tv=file.path(folder, paste0(name, "-tv.zip"))))
}

compile_single_item <- function(file_path, 
                                html = FALSE, 
                                qti = FALSE,
                                testvision = FALSE,
                                testrun=TRUE,
                                force_recompile=FALSE) {
  error_msg = c()
  
  files = .get_files(file_path, testrun)
  if (is.na(files)) {
    return(paste('Item:', file_path,"; Error:", "Incorrect filename"))
  }
  
  tryCatch({
  if (html && (force_recompile||.needs_update(file_path, files$html))) {
    print("compile html")
    exams:::browse_exercise(
      file = file_path,
      name = files$name,
      dir = files$folder)
  }
  
  if (qti && (force_recompile||.needs_update(file_path, files$qti))) {
    ## To Compile to QTI 2.1 uncomment the following (3)lines
    print("compile qti")
    exams::exams2qti21(
      file = file_path,
      name = files$qti_name, 
      dir = files$folder)
  }
  
  if (testvision && (force_recompile||.needs_update(file_path, files$tv))) {
    ## To Compile to testVision uncomment the following (3)lines
    print("compile testvision")
    exams::exams2testvision(
      file = file_path,
      name = files$tv_name,
      schoice=list(enumerate = FALSE),
      dir = files$folder)
  }
  
  }, error = function(e){
    error_msg <- paste('Item:', files$name,"; Error:", conditionMessage(e))
  }  ) # end try
  
  return(error_msg)
}


compile_items <- function(html = TRUE, 
                          qti = TRUE,
                          testvision = TRUE,
                          testrun=FALSE,
                          force_recompile=FALSE) {
  # The function has the following options and default values:
  #
  #          html = TRUE,
  #          qti = TRUE,
  #          testvision = TRUE,
  #          testrun=FALSE          (if TRUE, all output files have the prefix "testrun-". These files are ignored by git)
  #          force_recompile=FALSE  (force recomiplie all items, not onyl those that need an update)
  #
  
  
  all.item.paths <- list.files(pattern = ".Rmd",  ignore.case = TRUE, recursive = TRUE)
  n = length(all.item.paths)
  
  print(getwd())
  print(n)
  
  errors = c()
  for (i in 1:n) {
    message(paste0("(", i, "/", n, ") ", all.item.paths[i]))
    error_msg = compile_single_item(file_path = all.item.paths[i], 
                                    html = html, 
                                    qti = qti,
                                    testvision = testvision, 
                                    testrun=testrun,
                                    force_recompile=force_recompile)
    errors = rbind(errors, error_msg)
  }
  errors
  
  write.table(errors, file = "errors.txt", sep = "\n",
              row.names = FALSE)
}

