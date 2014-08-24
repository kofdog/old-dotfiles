# cower - a simple AUR downloader

OUT        = cower
VERSION    = 11

SRC        = $(wildcard *.c)
OBJ        = $(SRC:.c=.o)
DISTFILES  = Makefile README.pod bash_completion zsh_completion config cower.c

PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

CPPFLAGS  := -DCOWER_VERSION=\"$(VERSION)\" $(CPPFLAGS)
CFLAGS    := -std=c99 -g -pedantic -Wall -Wextra -pthread $(CFLAGS)
LDFLAGS   := -pthread $(LDFLAGS)
LDLIBS     = -lcurl -lalpm -lyajl -larchive -lcrypto

bash_completiondir = /usr/share/bash-completion/completions

MANPAGES = \
	cower.1

all: $(OUT) doc

doc: $(MANPAGES)
cower.1: README.pod
	pod2man --section=1 --center="Cower Manual" --name="COWER" --release="cower $(VERSION)" $< $@

strip: $(OUT)
	strip --strip-all $(OUT)

install: all
	install -D -m755 cower $(DESTDIR)$(PREFIX)/bin/cower
	install -D -m644 cower.1 $(DESTDIR)$(MANPREFIX)/man1/cower.1
	install -D -m644 bash_completion $(DESTDIR)$(bash_completiondir)/cower
	install -D -m644 zsh_completion $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_cower
	install -D -m644 config $(DESTDIR)$(PREFIX)/share/doc/cower/config

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/cower \
		$(DESTDIR)$(MANPREFIX)/man1/cower.1 \
		$(DESTDIR)$(bash_completiondir)/cower \
		$(DESTDIR)$(PREFIX)/share/zsh/site-functions/_cower \
		$(DESTDIR)$(PREFIX)/share/doc/cower/config

dist: clean
	mkdir cower-$(VERSION)
	cp $(DISTFILES) cower-$(VERSION)
	sed "s/\(^VERSION *\)= .*/\1= $(VERSION)/" Makefile > cower-$(VERSION)/Makefile
	tar czf cower-$(VERSION).tar.gz cower-$(VERSION)
	rm -rf cower-$(VERSION)

distcheck: dist
	tar xf cower-$(VERSION).tar.gz
	$(MAKE) -C cower-$(VERSION)
	rm -rf cower-$(VERSION)

clean:
	$(RM) $(OUT) $(OBJ) $(MANPAGES)

.PHONY: clean dist doc install uninstall

