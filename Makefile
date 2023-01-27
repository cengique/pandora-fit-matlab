# param_fitter autoconf file.
# Cengiz Gunay 2012-07-06

SHELL = /bin/sh

.SUFFIXES:
.SUFFIXES: .c

TARNAME = param_fitter
VERSION = 1.1b

DIRNAME = $(TARNAME)-$(VERSION)

all: 

dist: 
	mkdir -p $(DIRNAME)/$(TARNAME) # So that "help param_fitter" gives the contents file
	cp -a \@* $(DIRNAME)/$(TARNAME)
	cp -a unittest $(DIRNAME)
	cp -a *.m $(DIRNAME)/$(TARNAME)
	cp README.md $(DIRNAME)/
	cp COPYING $(DIRNAME)
	tar -cz --exclude-vcs --exclude=*~ -f $(DIRNAME).tar.gz $(DIRNAME)
	zip -r $(DIRNAME).zip $(DIRNAME)
	rm -rf $(DIRNAME)

distclean:
	rm -f *~
	rm -rf $(DIRNAME)

clean: 
	rm -f *~

