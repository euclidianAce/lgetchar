CC = gcc
CFLAGS = -Wall -Wextra
LIBS = -llua

SRC = $(wildcard *.c)

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	TARGET = raw.so
else
	TARGET = raw.dll
endif

default: all

teal:
	tl check
	tl gen

$(TARGET):
	$(CC) $(CFLAGS) -fPIC $(SRC) -shared -o $(TARGET)

clean:
	rm -f *.o *.so *.dll
	rm -f $(filter-out tlconfig.lua, $(wildcard *.lua))

all: clean $(TARGET) teal

.PHONY: all clean
