CC = gcc
CFLAGS = -Wall

all: Lab1

Lab1.o: Lab1.c

Lab1: Lab1.o

clean:
	rm -f *.o Lab1
