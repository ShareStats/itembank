# Correct using MacOS bash

# Check for typo in items
grep -r 'Interpretating' .

# replace Interpretating with Interpreting
find . -name '*.Rmd' -print0 | xargs -0 sed -i "" "s/Interpretating/Interpreting/g"