# -------------------------------------------------------------------------
# Compile Zip File 4/10/2022 ----------------------------------------------

# Function to list files --------------------------------------------------

List_All_Files <- function(patt){
  res <- list.files(pattern = patt, 
                   ignore.case = TRUE, 
                   recursive = TRUE)
  return(res)
} 

# List the relevant files -------------------------------------------------

All.paths <- List_All_Files(".Rmd") # I use .Rmd bc we know it is a unique key
Folders <- gsub('/[^/]+$','', All.paths)

init.dir <- getwd()
for (f in Folders){
  setwd(paste0(init.dir,"/", f))
  HTML<- List_All_Files(".html") # All html files
  ZIP <- List_All_Files(".zip")  # All zip files
  TXT <- List_All_Files(".txt")  # All txt files
  ALL <- List_All_Files(".") # everything else but folders
  ##  we do NOT want:
  OUT <- c(HTML, ZIP, TXT)
  ##  we do want:
  IN <- setdiff(x = ALL, y = OUT)
  zip(paste0(gsub('.*/','', f), "-ItemFolder.zip"), IN)
}








