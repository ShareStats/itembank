# Install development version of exams::
#install.packages("exams", repos = "http://R-Forge.R-project.org", dependencies = TRUE, type = "source")
library(exams)

compile_rmd <- function(fmt, file, name, dir) {
  edir = dirname(file)
  feedback = paste0("[", fmt, "] ", name, ": ", file)
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
  return(feedback)
}

# log files
time <- format(Sys.time(), "%y%m%d")
tbl <- read.delim("packages/files.tsv", sep = "\t", header = TRUE)
log_path <- file.path("packages", "log")
dir.create(log_path, showWarnings = FALSE)

error_fl <- file.path(log_path, paste0("log-", time, "-errors.txt"))
last_errors <- file.path(log_path, paste0("last-errors.txt"))
warn_fl <- file.path(log_path, paste0("log-", time, "-warnings.txt"))
last_warnings <- file.path(log_path, paste0("last-warnings.txt"))
norm_fl <- file.path(log_path, paste0("log-", time, ".txt"))
cat(paste0("[R ERROR LOG: ", date(), "]"), file = error_fl,
                      sep = "\n",  append = TRUE)
cat(paste0("[R WARNING LOG: ", date(), "]"), file = warn_fl,
                      sep = "\n",  append = TRUE)
cat(paste0("[R LOG: ", date(), "]"), file = norm_fl, sep = "\n",  append = TRUE)


for (i in 1:nrow(tbl)) {
  fmt <- tbl[i, "format"]
  file <- tbl[i, "file"]
  name <- tbl[i, "name"]
  dir <- tbl[i, "dir"]
  tag <- paste0("[", name, ", ", fmt, "] ")
  tryCatch(
    expr = {
      fb <- compile_rmd(fmt, file, name, dir)
      cat(fb, file = norm_fl, sep = "\n",  append = TRUE)
      print(fb)
    },
    error = function(e) {
      cat(paste(tag, conditionMessage(e)), file = error_fl,
                sep = "\n",  append = TRUE)
    },
    warning = function(e) {
      cat(paste(tag, conditionMessage(e)), file = warn_fl,
                sep = "\n",  append = TRUE)
    }
  )
}
file.copy(error_fl, last_errors, overwrite = TRUE)
file.copy(warn_fl, last_warnings, overwrite = TRUE)