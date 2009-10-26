HERE	:=	$(shell pwd)
PACKAGE :=	rteval
VERSION :=      $(shell awk '/Version:/ { print $$2 }' ${PACKAGE}.spec)
D	:=	10

runit:
	[ -d ./run ] || mkdir run
	python rteval/rteval.py -D -v --workdir=./run --loaddir=./loadsource --duration=$(D) -f ./rteval/rteval.conf -i ./rteval rteval

sysreport:
	python rteval/rteval.py -v --workdir=./run --loaddir=./loadsource --duration=$(D) --sysreport

clean:
	rm -f *~ rteval/*~ rteval/*.py[co] *.tar.bz2

realclean: clean
	rm -rf run tarball rpm

install:
	python setup.py --dry-run install

tarfile:
	rm -rf tarball && mkdir -p tarball/rteval-$(VERSION) tarball/rteval-$(VERSION)/server tarball/rteval-$(VERSION)/sql
	cp -r rteval tarball/rteval-$(VERSION)
	cp -r doc/ tarball/rteval-$(VERSION)
	cp Makefile setup.py rteval.spec COPYING tarball/rteval-$(VERSION)
	cp server/database.py server/rtevaldb.py server/rteval_xmlrpc.py server/xmlrpc_API1.py tarball/rteval-$(VERSION)/server
	cp server/apache-rteval.conf.tpl server/gen_config.sh tarball/rteval-$(VERSION)/server
	cp server/README tarball/rteval-$(VERSION)/README.xmlrpc
	cp sql/rteval-1.0.sql tarball/rteval-$(VERSION)/sql
	tar -C tarball -cjvf rteval-$(VERSION).tar.bz2 rteval-$(VERSION)

rpm:	tarfile
	rm -rf rpm
	mkdir -p rpm/{BUILD,RPMS,SRPMS,SOURCES,SPECS}
	cp rteval-$(VERSION).tar.bz2 rpm/SOURCES
	cp rteval.spec rpm/SPECS
	cp loadsource/* rpm/SOURCES
	rpmbuild -ba --define "_topdir $(HERE)/rpm" rpm/SPECS/rteval.spec

help:
	@echo ""
	@echo "rteval Makefile targets:"
	@echo ""
	@echo "        runit:     do a short testrun locally [default]"
	@echo "        rpm:       run rpmbuild"
	@echo "        tarfile:   create the source tarball"
	@echo "        install:   install rteval locally"
	@echo "        clean:     cleanup generated files"
	@echo "        sysreport: do a short testrun and generate sysreport data"
	@echo ""
