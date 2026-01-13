In some of the files the include_supplement was missing the `recursive = TRUE` property. Therefore, these supplements (e.g. images) were not included in the HTML as base64 encoded sources. To add the missing property, the following steps were taken: 

* Find and replace all instances
  * Find by regex: `include_supplement\("(.*)?" *)`
  * Replace by `include_supplement(“$1”, recursive = TRUE)`
