There were typos in the language metadata value (for key `exextra[Language]`). The below steps use regex search and replace to fix these.

* Ensure there is at least one space after metadata tag
  * Search `exextra\[Language\]:([a-zA-Z]+)` replace with `exextra\[Language\]: $1`
* Ensure there is not more than one space after metadata tag
  * Search `exextra\[Language\]:  +([a-zA-Z]+)` replace with `exextra\[Language\]: $1`
* Replace all English typos to English value by checking any metadata language value containing a "e" or "E"
  * Search `exextra\[Language\]: [a-zA-Z]*[e|E][a-zA-Z]*` replace with `exextra\[Language\]: English`
* Replace all Dutch typos to English value by checking any metadata language value containing a "d" or "D"
  * Search `exextra\[Language\]: [a-zA-Z]*[d|D][a-zA-Z]*` replace with `exextra\[Language\]: Dutch`
* Check for any occurrences which are not English or Dutch by searching: `exextra\[Language\]\: ((?!Dutch)(?!English))`
  * Replace by hand or create a new regex.
