CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld

DEF=-DRTMPDUMP_VERSION=\"v2.2a\"
OPT=-O2
CFLAGS=-Wall $(XCFLAGS) $(INC) $(DEF) $(OPT)
LDFLAGS=-Wall $(XLDFLAGS)
LIBS=-lssl -lcrypto -lz
#LIBS=-lgnutls -lz
THREADLIB=-lpthread
LIBRTMP=librtmp/librtmp.a
INCRTMP=librtmp/rtmp_sys.h librtmp/rtmp.h librtmp/log.h librtmp/amf.h
SLIBS=$(THREADLIB) $(LIBS)

EXT=

all:
	@echo 'use "make posix" for a native Linux/Unix build, or'
	@echo '    "make mingw" for a MinGW32 build'
	@echo 'use commandline overrides if you want anything else'

progs:	rtmpdump rtmpgw rtmpsrv rtmpsuck

posix linux unix osx:
	@$(MAKE) $(MAKEFLAGS) progs

mingw:
	@$(MAKE) CROSS_COMPILE=mingw32- LIBS="$(LIBS) -lws2_32 -lwinmm -lgdi32" THREADLIB= EXT=.exe $(MAKEFLAGS) progs

cygwin:
	@$(MAKE) XCFLAGS=-static XLDFLAGS="-static-libgcc -static" EXT=.exe $(MAKEFLAGS) progs

cross:
	@$(MAKE) CROSS_COMPILE=armv7a-angstrom-linux-gnueabi- INC=-I$(STAGING)/usr/include $(MAKEFLAGS) progs

clean:
	rm -f *.o rtmpdump$(EXT) rtmpgw$(EXT) rtmpsrv$(EXT) rtmpsuck$(EXT)
	@cd librtmp; $(MAKE) clean

FORCE:

$(LIBRTMP): FORCE
	@cd librtmp; $(MAKE) all CC="$(CC)" CFLAGS="$(CFLAGS)"

# note: $^ is GNU Make's equivalent to BSD $>
# we use both since either make will ignore the one it doesn't recognize

rtmpdump: rtmpdump.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(LIBS)

rtmpsrv: rtmpsrv.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpsuck: rtmpsuck.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpgw: rtmpgw.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpgw.o: rtmpgw.c $(INCRTMP) Makefile
rtmpdump.o: rtmpdump.c $(INCRTMP) Makefile
rtmpsrv.o: rtmpsrv.c $(INCRTMP) Makefile
rtmpsuck.o: rtmpsuck.c $(INCRTMP) Makefile
thread.o: thread.c thread.h
