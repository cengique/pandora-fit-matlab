# param_fitter autoconf file.
# Cengiz Gunay 2012-07-06

SHELL = /bin/sh

.SUFFIXES:
.SUFFIXES: .c

PACKAGE = pan_fit
TARNAME = pandora-fit-matlab
VERSION = 1.1b

DIRNAME = $(TARNAME)-$(VERSION)

# So that "help pan_fit" gives the contents file
SRCDIR  = $(DIRNAME)/$(PACKAGE)

all: 

dist: 
	mkdir -p $(SRCDIR) 
	cp -a \@* $(SRCDIR)
	cp -a unittest $(DIRNAME)
	cp -a *.m $(SRCDIR)/
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

