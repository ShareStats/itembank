## A script to create the search array 
## locally in R instead of javascript
## Tasos P.
## 12/09/2022

library(jsonlite)

all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)
n <- length(all.item.paths)

folders <- gsub('/[^/]+$','', all.item.paths)
names <- gsub('.*/','', folders)

x <- c()
df <- list()
Errors <- c()
for(i in 1:n){
  tryCatch({
    x <- readLines(all.item.paths[i])
    ## Meat info
    lineMeta <- grep("Meta-information", x)  
    lnMeta <- seq(lineMeta[1] + 2, length(x), 1)
    xMeta <- x[lnMeta] 
    xMeta <- paste0(xMeta, collapse = ' \n ')
    xMeta <- gsub("/", " / ", xMeta)
    
    ## Question
    lineQ <- grep("Question", x) 
    lineS <- grep("Solution", x)
    lineAS <- grep("Answerlist", x)
    #lineAS[1]
    if(length(lineS)) {
      lineTo <- lineS
    } else if (length(lineAS)){
        lineTo <- lineAS[1]
    } else {
        lineTo <- lnMeta
    }
    
    lnQ <- seq(lineQ[1] + 2, lineTo-1, 1)
    xQ <- x[lnQ] 
    xQ <- paste0(xQ, collapse = "\n")
    xQ <- gsub('\n\n', '\n', xQ)
  
    ## Create dataframe
    df[[i]] <- data.frame('id' = i-1,
                       'url' = paste0("https://raw.githubusercontent.com/ShareStats/itembank/main/",all.item.paths[i]),
                       'title'= names[i],
                       'body' = xMeta,
                       'question' = xQ)
  }, error = function(e){
    Errors <<- rbind(Errors, paste0('i= ',i,' ItemURL: ', 'https://github.com/ShareStats/itembank/blob/main/',all.item.paths[i],"; Error:",conditionMessage(e)))
  }
  )
}

## See Errors
#Errors
#write.table(Errors, file = "Errors-to-Create-Array-in-R.txt", sep = "\n",row.names = FALSE)

## Convert df to JSON file
df <- do.call(rbind, df)
array <- toJSON(df)
#array
#write(array, "array.txt")
