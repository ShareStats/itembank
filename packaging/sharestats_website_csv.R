library(dplyr)
library(readr)

extractMeta <- function(file, convert2table = FALSE) {
  x <- read_lines(file)
  lnMeta <- grep("Meta-information", x)
  lnMeta <- seq(lnMeta + 2, length(x), 1)
  x <- x[lnMeta]
  names(x) <- gsub("(.*):.*", "\\1", x)
  x <- gsub(".*: (.*)", "\\1", x)
  x <- as.list(x)
  if(!convert2table) {
    x <- lapply(x, function(i) ifelse(i=="", NA, i))
    x <- x[!is.na(x)]
    return(x)
  } else {
    x <- t(do.call(rbind, x))
    return(data.frame(x))
  }
}

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

# Feb 2024 update ---------------------------------------------------------
# clean metadf$name
metadf <- metadf %>% 
  mutate(Name_KEY = gsub("-|_| |'", "", Name)) %>% 
  mutate(Name_KEY = tolower(Name_KEY)) %>% # to lower case
  mutate(Name_KEY = gsub("\\.rmd|\\.rdm$", "", Name_KEY, ignore.case = TRUE)) # remove .Rmd or .rmd or .Rdm from name
# clean $url_name_quest_df$name
url_name_quest_df <- url_name_quest_df %>% 
  mutate(Name_KEY = gsub("-|_| |'", "", name)) %>% 
  mutate(Name_KEY = tolower(Name_KEY))

# Merge tables ------------------------------------------------------------
# check if common key is identical
#identical(metadf$Name_KEY, url_name_quest_df$Name_KEY) #no
# Check differences!
#setdiff(url_name_quest_df$Name_KEY, metadf$Name_KEY)
#setdiff(metadf$Name_KEY, url_name_quest_df$Name_KEY)
# continue anyway (This should be fixed! upd: 23/2/2024)

fulldf <- right_join(url_name_quest_df, metadf, by = 'Name_KEY')

fulldf <- fulldf %>% 
  dplyr::select(-Name, -Name_KEY)
#which(is.na(fulldf$folder)) # still some cases missing
write.csv(fulldf, 'sharestats_website.csv')
