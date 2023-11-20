## All in one table
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
                          'folder' = folders[i],
                          #'url' = paste0("https://raw.githubusercontent.com/ShareStats/itembank/main/",all.item.paths[i]),
                          'name'= names[i],
                          'question' = xQ)
  }, error = function(e){
    Errors <<- rbind(Errors, paste0('i= ',i,' ItemURL: ', 'https://github.com/ShareStats/itembank/blob/main/',all.item.paths[i],"; Error:",conditionMessage(e)))
  }
  )
}

## See Errors
#Errors
#write.table(Errors, file = "Errors-to-Create-Array-in-R.txt", sep = "\n",row.names = FALSE)
url_name_quest_df <- do.call(rbind, df)


# Meta-info Extraction ----------------------------------------------------
source('extractMeta_function.R')
ErrorsMI <- c()
metadf <-  list()
for(i in 1:n){
  tryCatch({
    metadf[[i]] <- extractMeta(all.item.paths[i]) %>% bind_rows()
  }, error = function(e){
    ErrorsMI <<- rbind(ErrorsMI, paste0('i= ',i,' ItemURL: ', 'https://github.com/ShareStats/itembank/blob/main/',all.item.paths[i],"; Error:",conditionMessage(e)))
  }
  )
}
metadf <- bind_rows(metadf)

metadf <- metadf %>% dplyr::select(exname,
                                   exsection,
                                   `exextra[Type]`,
                                   `exextra[Program]`,
                                   `exextra[Language]`,
                                   `exextra[Level]`) %>%
  rename('Name' = exname,
         'Section' = exsection,
         'Type' = `exextra[Type]`,
         'Program' = `exextra[Program]`,
         'Language' = `exextra[Language]`,
         'Level' = `exextra[Level]`)


# Merge tables ------------------------------------------------------------

fulldf <- right_join(url_name_quest_df, metadf, by = c("name" = "Name"))

write.csv(fulldf, 'fulldf.csv')
