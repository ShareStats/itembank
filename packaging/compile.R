# Install development version of exams::
# install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

compile_rmd <- function(fmt, file, name, dir) {
  if (fmt == "html") {
    exams:::browse_exercise(file = file, name = name, dir = dir)
  } else if (fmt == "qti") {
    exams::exams2qti21(
      file = file, name = name, dir = dir,
      schoice = list(enumerate = FALSE)
    )
  } else if (fmt == "tv") {
    exams::exams2testvision(
      file = file, name = name, dir = dir,
      schoice = list(enumerate = FALSE)
    )
  }
}

tbl <- read.delim("packages/compl.instr", sep = "\t", header = TRUE)
error_log <- c(paste0("[[ERROR LOG: ", date(), "]]"))

for (i in 1:nrow(tbl)) {
  fmt <- tbl[i, "format"]
  file <- tbl[i, "file"]
  name <- tbl[i, "name"]
  dir <- tbl[i, "dir"]
  tag <- paste0("[", name, ", ", fmt, "] ")

  tryCatch(compile_rmd(fmt, file, name, dir),
    error = function(e) {
      error_log <<- append(error_log, paste(tag, "ERROR", conditionMessage(e)))
    },
    warning = function(e) {
      error_log <<- append(error_log, paste(tag, "WARN", conditionMessage(e)))
    }
  )
}

print(error_log)
cat(error_log, sep = "\n", file = "packages/compile-log.txt", append = TRUE)

