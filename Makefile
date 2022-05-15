CFLAGS=-Wall
CPPFLAGS=
CC= g++
SOURCES=parser.cpp main.cpp tokens.cpp Kodea.cpp

all: parser proba

.PHONY: clean

clean:
	rm parser.cpp parser.hpp parser tokens.cpp

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $<

parser: $(SOURCES) Kodea.h Lag.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(SOURCES)

proba:  parser probak/proba1.dat probak/proba2.dat
	echo "probak/proba1.dat"
	./parser < probak/proba1.dat
	echo "probak/proba2.dat"
	./parser < probak/proba2.dat
	echo "probak/proba3.dat"
	./parser < probak/proba3.dat
	echo "probak/proba4.dat"
	./parser < probak/proba4.dat
	echo "probak/proba5.dat"
	./parser < probak/proba5.dat
	echo "probak/proba6.dat"
	./parser < probak/proba6.dat
	echo "probak/proba7.dat"
	./parser < probak/proba7.dat
	
