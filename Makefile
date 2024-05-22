remove_embedded_packages:
	find . -name \*-ItemFolder.zip -type f -delete
	find . -name \*-qti.zip -type f -delete
	find . -name \*-tv.zip -type f -delete
	find . -name \*.html -type f -delete

clean:
	rm packages/ -rf

fingerprint_file: # next package build (tarballs or compile), will only generate items that were changed since than
	python -c "import packaging; packaging.save_fingerprints()"

tarballs_zipped:
	python -c 'import packaging as p; p.file_table(formats=("zip")); p.tarballs()'
	rm packages/files.tsv -f

tarballs:
	python -c 'import packaging as p; p.file_table(formats=("tar")); p.tarballs()'
	rm packages/files.tsv -f

compile:
	python -c 'import packaging; packaging.file_table(formats=("html", "qti", "tv"))' # compile instructions
	Rscript packaging/compile.R
	rm packages/files.tsv -f

checksums:
	cd packages; \
	find ./ -type f -print0  | xargs -0 sha256sum > checksums.txt; \

website:
	mkdir -p docs; \
	mv packages/html/* docs/ -f 2>/tmp/AVOIDERROR; \
	cd docs/; \
	tree -H '.' \
		-L 4 --noreport --charset utf-8 -P "*.html" -C  \
		-T "Packages ($(shell date))" > items.html ; \
	cd .. ; \
	python -c 'import packaging as p; p.format_website("docs/items.html")'; \
	python -c 'import packaging as p; p.errorlog2html("docs/last-errors.txt", "docs/last-errors.html")' \


sharestats_website_csv:
	mkdir -p docs; \
	Rscript packaging/sharestats_website_csv.R; \
	mv sharestats_website.csv docs/
