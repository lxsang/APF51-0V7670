CC=gcc
CFLAGS=-W -Wall -g -std=c99 `pkg-config --cflags opencv`
EXT=dylib
PLUGINS= camviewer.$(EXT)
 UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLUGINS_BASE=/root/workspace/ant-http/plugins
    BUILDIRD=/root/antd/plugins
endif
ifeq ($(UNAME_S),Darwin)
	BUILDIRD=.
	PLUGINS_BASE=/Users/mrsang/Documents/ushare/cwp/ant-http/plugins
endif
PLUGINSDEP = $(PLUGINS_BASE)/plugin.o $(PLUGINS_BASE)/dbhelper.o $(PLUGINS_BASE)/dictionary.o $(PLUGINS_BASE)/utils.o
PLUGINLIBS = -lsqlite3 `pkg-config --libs opencv`
UNAME_S := $(shell uname -s)
main: $(PLUGINSDEP) $(PLUGINS)

%.o: %.c
		$(CC) $(CFLAGS) -I$(PLUGINS_BASE) -c $< -o $@


%.$(EXT): %.o 
		$(CC) $(CFLAGS) $(PLUGINLIBS) -shared -o $(BUILDIRD)/$(basename $@).$(EXT) \
		$(PLUGINSDEP) $(basename $@).o

clean:
		-rm -f *.o $(BUILDIRD)/$(PLUGINS)

pclean:clean
		-rm *.o

.PRECIOUS: %.o
