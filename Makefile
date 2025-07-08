.PHONY: all clean compile tarballs tarballs_zipped checksums website sharestats_website_csv fingerprint_file

clean:
	rm -rf packages/

fingerprint_file: # next package build (tarballs or compile), will only generate items that were changed since than
	python -c "import packaging; packaging.save_fingerprints()"

tarballs_zipped:
	python -c 'import packaging as p; p.file_table(formats=("zip")); p.tarballs()'
	rm -f packages/files.tsv

tarballs:
	python -c 'import packaging as p; p.file_table(formats=("tar")); p.tarballs()'
	rm -f packages/files.tsv

compile:
	python -c 'import packaging; packaging.file_table()' # compile instructions
	Rscript packaging/compile.R
	rm -f packages/files.tsv

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
	@echo ' import packaging as p;\
			p.format_website("docs/items.html");\
			p.errorlog2html("packages/log/last-errors.txt", "docs/last-errors.html");\
			p.errorlog2html("packages/log/last-warnings.txt", "docs/last-warnings.html");'\
			| python


sharestats_website_csv:
	mkdir -p docs; \
	Rscript packaging/sharestats_website_csv.R; \
	mv sharestats_website.csv docs/