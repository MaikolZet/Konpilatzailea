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

proba:  parser ./probak/proba1.in ./probak/proba2.in ./probak/proba3.in ./probak/probatxar1.in ./probak/probaBERRIA_1_.in ./probak/probaBERRIA_2_.in ./probak/probaBERRIATXARRA.in 
	./parser <./probak/proba1.in
	./parser <./probak/proba2.in
	./parser <./probak/proba3.in
	./parser <./probak/probatxar1.in
	./parser <./probak/probaBERRIA_1_.in
	./parser <./probak/probaBERRIA_2_.in
	./parser <./probak/probaBERRIATXARRA.in
