#****************************************************************************
#
# Makefile for cleaning purposes.
#
#****************************************************************************

WILDCARD:=*
EXTENSIONS_LIST = .aux .bbl .blg .log .out .toc .idx .lof .lot .brf .cpt "~"

clean:
	for ext in ${EXTENSIONS_LIST}; do \
#		echo $$ext; \
		find . -iname "${WILDCARD}$${ext}" -delete; \
	done
	echo "files with 'junk' file extensions deleted"

