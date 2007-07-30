CC	= gcc
CFLAGS	= -Wall -O2 -g -W
ALL_CFLAGS = $(CFLAGS) -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
PROGS	= blkparse blktrace verify_blkparse blkrawverify
LIBS	= -lpthread
SCRIPTS	= btrace

ALL = $(PROGS) $(SCRIPTS) btt/btt

all: $(ALL)

btt/btt:
	$(MAKE) -C btt

%.o: %.c
	$(CC) -o $*.o -c $(ALL_CFLAGS) $<

blkparse: blkparse.o blkparse_fmt.o rbtree.o act_mask.o
	$(CC) $(ALL_CFLAGS) -o $@ $(filter %.o,$^)

blktrace: blktrace.o act_mask.o $(LIBS)
	$(CC) $(ALL_CFLAGS) -o $@ $(filter %.o,$^) $(LIBS)

verify_blkparse: verify_blkparse.o
	$(CC) $(ALL_CFLAGS) -o $@ $(filter %.o,$^)

blkrawverify: blkrawverify.o
	$(CC) $(ALL_CFLAGS) -o $@ $(filter %.o,$^)

$(PROGS): | depend

docs:
	$(MAKE) -C doc all
	$(MAKE) -C btt docs

docsclean:
	$(MAKE) -C doc clean
	$(MAKE) -C btt clean

depend:
	@$(CC) -MM $(ALL_CFLAGS) *.c 1> .depend

INSTALL = install
prefix = /usr/local
bindir = $(prefix)/bin
mandir = $(prefix)/man
RPMBUILD = rpmbuild
TAR = tar

export prefix INSTALL TAR

dist: btrace.spec
	git-tar-tree HEAD btrace-1.0 > btrace-1.0.tar
	@mkdir -p btrace-1.0
	@cp btrace.spec btrace-1.0
	$(TAR) rf btrace-1.0.tar btrace-1.0/btrace.spec
	@rm -rf btrace-1.0
	@bzip2 btrace-1.0.tar

rpm: dist
	$(RPMBUILD) -ta btrace-1.0.tar.bz2

clean: docsclean
	-rm -f *.o $(PROGS) .depend btrace-1.0.tar.bz2
	$(MAKE) -C btt clean

install: all
	$(INSTALL) -m755 -d $(DESTDIR)$(bindir)
	$(INSTALL) -m755 -d $(DESTDIR)$(mandir)/man1
	$(INSTALL) -m755 -d $(DESTDIR)$(mandir)/man8
	$(INSTALL) $(ALL) $(DESTDIR)$(bindir)
	$(INSTALL) doc/*.1 $(DESTDIR)$(mandir)/man1
	$(INSTALL) doc/*.8 $(DESTDIR)$(mandir)/man8

ifneq ($(wildcard .depend),)
include .depend
endif
