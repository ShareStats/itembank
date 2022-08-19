# Check for typo in items
-r 'Interpretating' .

# replace Interpretating with Interpreting
find . -name '*.Rmd' -print0 | xargs -0 sed -i "" "s/Interpretating/Interpreting/g"