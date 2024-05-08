
# UvA items  --------------------------------------------------------------

# read the items
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)
uva.item.paths <- grep(pattern = "uva", all.item.paths, ignore.case = TRUE, value = TRUE)
n.uva <- length(uva.item.paths)
n.uva

snmchoice.uva <-c()
for(i in 1:n.uva){
  x <- readLines(uva.item.paths[i])
  pattern <- "extype: ?[sm]choice"
  match_in_x <- grep(pattern, x, ignore.case = TRUE, value = TRUE)
  if(length(match_in_x)>0) snmchoice.uva <- rbind(snmchoice.uva, uva.item.paths[i])
}
unique(snmchoice.uva)

## Check if every item includes "Het correcte antwoord is: "
check <- data.frame('item'= integer(), 'yes/no'= integer())
for(i in 1:length(snmchoice.uva)){
  x <- readLines(snmchoice.uva[i])
  pattern <- "Het correcte antwoord is: "
  match_in_x <- grep(pattern, x)
  ifelse(length(match_in_x)>0,
         row <- c(snmchoice.uva[i], "YES"),
         row <- c(snmchoice.uva[i], "NO")) 
  check <- rbind(check, row)
}
length(which(check[,2] == 'YES'))== length(snmchoice.uva)#0


# write new Rmds ----------------------------------------------------------
for(i in 1:length(snmchoice.uva)){
  # remove asterisks
  #snmchoice.uva.noasterisk <- gsub("^\\*\\s*", "", readLines(snmchoice.uva[i]))
  Rmd <- readLines(snmchoice.uva[i])
  lineAnswerlist <- grep("Answerlist", Rmd)  
  lineSolution <- grep("Solution", Rmd)  
  
  firstchoiceline <- lineAnswerlist+3 #only for uva items
  lastchoiceline <- lineSolution-2  #only for uva items
  answerChoices <- Rmd[firstchoiceline:lastchoiceline]
  
  lineMeta <- grep("Meta-information", Rmd)  
  solutionlines <- c((lineSolution+2):(lineMeta-1))
  correctAnswer_position <- which(!is.na(match(answerChoices, Rmd[solutionlines])))
  correctAnswer <- answerChoices[correctAnswer_position]
  SolutionAnswerlist <- paste0(answerChoices, ': Incorrect')
  SolutionAnswerlist[correctAnswer_position] <- paste0(correctAnswer, ': Correct')
  
  newRmd <- paste0(c(Rmd[1:(lastchoiceline+1)],
                     "Solution",                                                                
                     "========",
                     "",
                     "Answerlist",
                     "----------",
                     "" ,
                     SolutionAnswerlist,
                     "",
                     Rmd[lineMeta:length(Rmd)]))
  writeLines(newRmd, snmchoice.uva[i])
  print(i)
  }



