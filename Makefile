# Justin Lardinois jlardino@ucsc.edu
# Makefile for oc

CPPHEADERS   = auxlib.h stringset.h
CPPSOURCES   = ${CPPHEADERS:.h=.cpp} main.cpp
DELIVERABLES = ${CPPHEADERS} ${CPPSOURCES} Makefile README
GPP          = g++ -g -O0 -Wall -Wextra -std=gnu++11
OBJECTS      = ${CPPSOURCES:.cpp=.o}

all: oc

oc: ${OBJECTS}
	${GPP} -o $@ $^

auxlib.o: auxlib.cpp auxlib.h
	${GPP} -c $<

main.o: main.cpp auxlib.h stringset.h
	${GPP} -c $<

stringset.o: stringset.cpp stringset.h
	${GPP} -c $<

clean:
	rm ${OBJECTS}

spotless: clean
	rm oc

ci: ${DELIVERABLES}
	git add $<
	git commit

deps:

submit: ${DELIVERABLES}
	checksource $<
	submit cmps104a-wm.s15 asg1 $<
