CC = gcc
CFLAGS = -Wall -fPIC
LIBS = -llua
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
TARGET = lgetchar.so
else
TARGET = lgetchar.dll
endif

default: $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ $(LIBS)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -shared -o $(TARGET)

clean:
	rm $(wildcard *.dll *.o *.so)

all: clean $(TARGET)