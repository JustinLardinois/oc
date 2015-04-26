# Justin Lardinois jlardino@ucsc.edu
# Makefile for oc

ASG          = asg2
CPPHEADERS   = astree.h auxlib.h stringset.h lyutils.h
CPPSOURCES   = ${CPPHEADERS:.h=.cpp} main.cpp 
DELIVERABLES = ${CPPHEADERS} ${CPPSOURCES} ${LSOURCE} ${YSOURCE} \
               Makefile README
GPP          = g++ -g -O0 -Wall -Wextra -std=gnu++11
LCPPGEN      = yylex.cpp
LCPPGENO     = ${LCPPGEN:.cpp=.o}
LSOURCE      = scanner.l
OBJECTS      = ${CPPSOURCES:.cpp=.o} ${LCPPGENO}
YSOURCE      = parser.y

all: oc

oc: ${OBJECTS}
	${GPP} -o $@ $^

astree.o: astree.cpp astree.h auxlib.h lyutils.h stringset.h
	${GPP} -c $<

auxlib.o: auxlib.cpp auxlib.h
	${GPP} -c $<

lyutils.o: lyutils.cpp lyutils.h astree.h auxlib.h
	${GPP} -c $<

main.o: main.cpp auxlib.h stringset.h
	${GPP} -c $<

stringset.o: stringset.cpp stringset.h
	${GPP} -c $<

# three levels of hacks:
#    piping to grep to skip flex's diagnostic ouput
#    ANDing with true so make ignores grep's exit status
#    supressing echoing and then echoing a pretty command
${LCPPGEN}: ${LSOURCE}
	@ flex --outfile=${LCPPGEN} $< |& \
	grep -v -e "^  " -e "^flex version" || true && \
	echo "flex --outfile=${LCPPGEN} $<"

${LCPPGENO}: ${LCPPGEN}
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
