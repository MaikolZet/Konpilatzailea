CFLAGS=-Wall
CPPFLAGS= -std=c++11
CC= g++
SOURCES=parser.cpp main.cpp tokens.cpp

all: parser proba

.PHONY: clean

clean:
	rm parser.cpp parser.hpp parser parser.output tokens.cpp *~

parser.cpp: parser.y
	bison -r all -d -o $@ $^
parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $<

parser: $(SOURCES)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^

proba:  parser probaexpr.in 
	./parser <probaexpr.in
