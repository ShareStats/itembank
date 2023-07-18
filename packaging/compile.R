# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

compile_rmd <- function(fmt, file, name, dir) {
  edir = dirname(file)
  if (fmt == "html") {
    exams:::browse_exercise(file = file, name = name, dir = dir, edir = edir)
  } else if (fmt == "qti") {
    exams::exams2qti21(
      file = file, name = name, dir = dir, edir = edir,
      schoice = list(enumerate = FALSE)
    )
  } else if (fmt == "tv") {
    exams::exams2testvision(
      file = file, name = name, dir = dir, edir = edir,
      schoice = list(enumerate = FALSE)
    )
  }
}

tbl <- read.delim("packages/compl.instr", sep = "\t", header = TRUE)
error_log <- c(paste0("[ERROR LOG: ", date(), "]"))
warn_log <- c(paste0("[WARNING LOG: ", date(), "]"))
time <- format(Sys.time(), "%y%m%d_%H%M")

for (i in 1:nrow(tbl)) {
  fmt <- tbl[i, "format"]
  file <- tbl[i, "file"]
  name <- tbl[i, "name"]
  dir <- tbl[i, "dir"]
  tag <- paste0("[", name, ", ", fmt, "] ")
  tryCatch(compile_rmd(fmt, file, name, dir),
    error = function(e) {
      error_log <<- append(error_log, paste(tag, conditionMessage(e)))
    },
    warning = function(e) {
      warn_log <<- append(warn_log, paste(tag, conditionMessage(e)))
    }
  )
}

dir.create(file.path("packages", "log"), showWarnings = FALSE)

fl <- file.path("packages", "log", paste0("log-", time, "-error.txt"))
cat(error_log, file = fl, sep = "\n",  append = TRUE)

fl <- file.path("packages", "log", paste0("log-", time, "-warning.txt"))
cat(warn_log, file = fl, sep = "\n",  append = TRUE)
