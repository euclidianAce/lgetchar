CC = gcc
CFLAGS = -Wall
LIBS = -llua
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
TARGET = lgetchar.dll

default: $(TARGET)

%.o: %.c
	$(CC) -fPIC $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -shared -o $(TARGET) $(LIBS)

clean:
	rm *.dll *.o

all: clean $(TARGET)