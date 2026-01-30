# Create date_df.txt file - Jan 2026
# Note: This is supposed to be run locally after cloning the github itembank repo
# and 'git pull' is updated. 

# Run: (or in terminal outside system())
# It takes ~3 minutes...
system(
  "git ls-files -z | xargs -0 -n1 -I{} -- git log -1 --format='%ai {}' {} > date_df.txt"
)

# Read and clean the output
df <- readLines("date_df.txt") |>
  (\(i) grep("\\.Rmd$", i, value = TRUE))() |> # keep only the Rmd files
  (\(i)strsplit(i, "\\s+"))() |> #split the string
  (\(i)lapply(i, \(x) c(x[1], x[4])))() |> #keep only the date and item sublists
  (\(i)data.frame(do.call(rbind, i)))() 
#head(df)
colnames(df) <- c("date", "item")
write.table(df, "date_df.txt", row.names = FALSE) # overwrite .txt file
