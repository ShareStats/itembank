remove_embedded_packages:
	find . -name \*-ItemFolder.zip -type f -delete
	find . -name \*-qti.zip -type f -delete
	find . -name \*-tv.zip -type f -delete
	find . -name \*.html -type f -delete

clean:
	rm packages/ -rf

fingerprint_file: # next package build (tarballs or compile), will only generate items that were changed since than
	python -c "import packaging; packaging.fingerprint_file()"

tarballs_zipped:
	python -c 'import packaging; packaging.compilation_file(formats=("zip"))' # compile instruction
	python -c "import packaging; packaging.tarballs()"
	rm packages/compl.instr -f

tarballs:
	python -c 'import packaging; packaging.compilation_file(formats=("tar"))' # compile instruction
	python -c "import packaging; packaging.tarballs()"
	rm packages/compl.instr -f

compile:
	python -c 'import packaging; packaging.compilation_file(formats=("qti", "tv"))' # compile instructions
	Rscript packaging/compile.R
	rm packages/compl.instr -f
	# FIXME no html files yet

webpage:
	cd packages; \
	find ./ -type f -print0  | xargs -0 sha256sum > checksums.txt; \
	tree -H '.' \
		-L 2 --noreport --charset utf-8 \
		-T "Packages ($(shell date))" > index.html
