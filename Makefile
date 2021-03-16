NAME 	= 	./NormEZ.rb

DESTDIR = 	/usr/local/bin/
BIN 	= 	normez


all:
	@echo "Use 'make install' to install normez or 'make uninstall' to uninstall it"

install:
	mkdir -p ${DESTDIR}
	cp -f ${NAME} ${DESTDIR}${BIN}
	chmod 755 ${DESTDIR}${BIN}

uninstall:
	rm -f ${DESTDIR}${BIN}

.PHONY: all install uninstall
