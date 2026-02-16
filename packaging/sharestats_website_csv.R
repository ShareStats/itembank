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
all.item.paths <- list.files(pattern = ".rmd", ignore.case = TRUE, recursive = TRUE)
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
    lnMeta <-  grep("Meta", x) # added May 2024
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
    df[[i]] <- data.frame('folder' = folders[i],
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


# Added May 2024 - Tasos --------------------------------------------------
metadf$extype <- sub("\\s+$", "", metadf$extype) # remove " " after "num" and "schoice"
# unique(metadf$extype) #check

# Clean the language field
metadf$`exextra[Language]`[grepl("ngl", metadf$`exextra[Language]`)] <- "English"
metadf$`exextra[Language]`[grepl('du',metadf$`exextra[Language]`) | grepl('Du',metadf$`exextra[Language]`)]<- 'Dutch'

metadf$`exextra[Language]`[!grepl('Dutch',metadf$`exextra[Language]`) & !grepl('English',metadf$`exextra[Language]`)]<- NA
#metadf$extype
#unique(metadf$`exextra[Language]`)
# -------------------------------------------------------------------------

metadf <- metadf %>% dplyr::select(exname,
                                   extype,
                                   exsection,
                                   `exextra[Type]`,
                                   `exextra[Program]`,
                                   `exextra[Language]`,
                                   `exextra[Level]`,
                                   `exextra[ID]`) %>%
  rename('ID' = `exextra[ID]`,
         'Name' = exname,
         'Item Type' = extype,
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
identical(metadf$Name_KEY, url_name_quest_df$Name_KEY) #no

# # Uncomment to Check differences locally ONLY
#in_quest_not_in_meta <- setdiff(url_name_quest_df$Name_KEY, metadf$Name_KEY)
#in_meta_not_in_quest <- setdiff(metadf$Name_KEY, url_name_quest_df$Name_KEY)
#write.table(url_name_quest_df[url_name_quest_df$Name_KEY %in% in_quest_not_in_meta, "folder"], "~/in_quest_not_in_meta.txt")
#write.table(metadf[metadf$Name_KEY %in% in_meta_not_in_quest, "Name"], "~/in_meta_not_in_quest.txt")

# Edit: Since the KEYS do not match, we merge the two tables
#  by **excluding**# the mismatches using 'inner_join()' below
fulldf <- inner_join(url_name_quest_df, metadf, by = 'Name_KEY')
# Due to typos, the KEYS are not unique and produce many-to-many relations warning
# As such the merged df has 9081 rows wheres the two tables that were merged have 9040 rows each.

# -------------------------------------------------------------------------
fulldf <- fulldf %>% 
  dplyr::select(-Name, -Name_KEY)
# make short-section column -----------------------------------------------
tmp <-  sub(",.*$", "", fulldf$Section) 
fulldf$SectionShort <- paste(sub("/.*$", "", tmp), sub(".*/", "", tmp), sep = "/")

# update Jan 2026: add time stamp column ----------------------------------
datedf <- read.table("date_df.txt", header = TRUE)
datedf$folder <- gsub('/[^/]+$','', datedf$item)
datedf <- data.frame('folder' = datedf$folder, 'date' = datedf$date)

# merge the 'datedf' to the 'fulldf' by folder
fulldf_w_date <- inner_join(fulldf, datedf, by = 'folder')
write.csv(fulldf_w_date, 'sharestats_website.csv')