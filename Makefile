# Justin Lardinois jlardino@ucsc.edu
# Makefile for oc

ASG          = asg2
CPPHEADERS   = astree.h auxlib.h stringset.h lyutils.h
CPPSOURCES   = ${CPPHEADERS:.h=.cpp} main.cpp
CLGEN        = yylex.cpp
CLGENO       = ${CLGEN:.cpp=.o}
DELIVERABLES = ${CPPHEADERS} ${CPPSOURCES} ${LSOURCE} ${YSOURCE} \
               Makefile README
GPP          = g++ -g -O0 -Wall -Wextra -std=gnu++11
LSOURCE      = scanner.l
OBJECTS      = ${CPPSOURCES:.cpp=.o} ${CLGENO}
YSOURCE      = parser.y

all: oc

oc: ${OBJECTS}
	${GPP} -o $@ $^

astree.o:

auxlib.o: auxlib.cpp auxlib.h
	${GPP} -c $<

main.o: main.cpp auxlib.h stringset.h
	${GPP} -c $<

stringset.o: stringset.cpp stringset.h
	${GPP} -c $<

# three levels of hacks:
#    piping to grep to skip flex's diagnostic ouput
#    ANDing with true so make ignores grep's exit status
#    supressing echoing and then echoing a pretty command
${CLGEN}: ${LSOURCE}
	@ flex --outfile=${CLGEN} $< |& \
	grep -v -e "^  " -e "^flex version" || true && \
	echo "flex --outfile=${CLGEN} $<"

${CLGENO}: ${CLGEN}
	${GPP} -c $<

clean:
	rm ${OBJECTS}

spotless: clean
	rm oc

ci: .git ${DELIVERABLES}
	git add $(filer-out $<,$^)
	git commit

.git:
	git init

deps:

submit: ${DELIVERABLES}
	checksource $^
	submit cmps104a-wm.s15 ${ASG} $^
