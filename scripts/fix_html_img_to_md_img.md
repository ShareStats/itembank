To fix this issues where html image tags where used in the Rmd files instead of the Markdown image tags, the following steps were executed:

* Within an Editor which allows searh and replace by Regex, do the following search and replace
  * Search on `<img src=\"(.+?)\.(png|jpg|gif)\"(.|[\n\r])*?\/>`
  * Replace by `![]($1.$2)`
* As check if any files with the issue remain, execute the following (regex) search `<img`
