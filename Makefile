CFLAGS=-Wall
CPPFLAGS=
CC= g++
SOURCES=parser.cpp main.cpp tokens.cpp Kodea.cpp SinboloTaula.cpp SinboloTaulenPila.cpp

all: parser proba

.PHONY: clean

clean:
	rm parser.cpp parser.hpp parser tokens.cpp

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $<

parser: $(SOURCES) Kodea.h Lag.h SinboloTaula.h SinboloTaulenPila.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(SOURCES)

proba:  parser probak/proba1.in probak/proba2.in
	echo "probak/proba1.in"
	./parser < probak/proba1.in
	echo "probak/proba1.2.in"
	./parser < probak/proba1.2.in
	echo "probak/proba2.in"
	./parser < probak/proba2.in
	echo "probak/proba3.in"
	./parser < probak/proba3.in
	echo "probak/probaBERRIA_1_.in"
	./parser < probak/probaBERRIA_1_.in
	echo "probak/probaBERRIA_2_.in"
	./parser < probak/probaBERRIA_2_.in
	echo "probak/probaBERRIATXARRA.in"
	./parser < probak/probaBERRIATXARRA.in
	echo "probak/probatxar1.in"
	./parser < probak/probatxar1.in
	echo "probak/probaFor.in"
	./parser < probak/probaFor.in
	echo "probak/probaForTxar.in"
	./parser < probak/probaForTxar.in
	echo "probak/probaBool.in"
	./parser < probak/probaBool.in

	
