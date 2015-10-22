CC=gcc
CFLAGS=-W -Wall -g -std=c99 `pkg-config --cflags opencv`
BUILDIRD=/root/antd/plugins
EXT=dylib
PLUGINS= camviewer.$(EXT)
PLUGINSDEP = plugin.o dbhelper.o dictionary.o utils.o
PLUGINLIBS = -lsqlite3 `pkg-config --libs opencv`

main: $(PLUGINSDEP) $(PLUGINS)

%.o: %.c
		$(CC) $(CFLAGS) -c $< -o $@


%.$(EXT): %.o 
		$(CC) $(CFLAGS) $(PLUGINLIBS) -shared -o $(BUILDIRD)/$(basename $@).$(EXT) \
		$(PLUGINSDEP) $(basename $@).o

clean:
		-rm -f *.o *.dylib

pclean:clean
		-rm *.o

.PRECIOUS: %.o
