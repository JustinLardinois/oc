.so Tmac.mm-etc
.if t .Newcentury-fonts
.INITR* \n[.F]
.SIZE 12 14
.ds HP 12 12 12 12 12 12 12\"       |heading point sizes
.TITLE CMPS-104A Spring\~2015 Project\~2 \
"Lexical Analyzer using \f[CB]flex\f[P]"
.RCS "$Id: asg2-scanner.mm,v 1.10 2015-04-09 17:45:07-07 - - $"
.PWD
.URL
.H 1 "Overview"
Augment your string table manager from the previous project
by adding to it a scanner written in
.V= flex .
Continue to use the module
.V= auxlib .
Include token creation routines in the modules
.V= astree ,
.V= auxlib ,
and
.V= lyutils 
from
.V= Assignments/util-code .
.SH=BVL
.MANPAGE=LI SYNOPSIS
.V= oc
.=V \|[ -ly ]
.=V \|[ -@
.IR flag \|.\|.\|.]
.=V \|[ -D
.IR string ]
.IR \|program \f[CB].oc\f[P]
.LE
.P
For this project,
given an input file called
.IV program .oc ,
you will generate output files called
.IV program .str
(as before) and also
.IV program .tok .
All specifications from project 1 apply to this project.
In addition, the
.V= -l
flag must turn on 
.V= yy_flex_debug .
.H 1 "Tokens in the \f[CB]oc\f[P] language"
The
.V= oc
language has the following tokens\(::
.ALX a ()
.LI
Special symbols\(::
.br
.V= \h'\\n[VCODENWIDTH]u'[]\&
.V= \0(\&
.V= \0)\&
.V= \0[\&
.V= \0]\&
.V= \0{\&
.V= \0}\&
.V= \0;\&
.V= \0,\&
.V= \0.\&
.V= \0=\&
.V= \0==\&
.V= \0!=\&
.V= \0<\&
.V= \0<=\&
.V= \0>\&
.V= \0>=\&
.V= \0+\&
.V= \0-\&
.V= \0*\&
.V= \0/\&
.V= \0%\&
.V= \0!\&
.br
Single-character tokens may be represented by their ASCII values,
but multiple-character tokens must be represented by a 
.V= bison -generated
set of names.
Note the hack that
.V= []
is a single token, 
added to the language to eliminate a difficult shift/reduce
conflict in project 3.
.LI
Reserved words\(::
.br
.V= \h'\\n[VCODENWIDTH]u'void
.V= \0bool
.V= \0char
.V= \0int
.V= \0string
.V= \0struct
.V= \0if
.V= \0else
.V= \0while
.V= \0return
.br
.V= \h'\\n[VCODENWIDTH]u'false
.V= \0true
.V= \0null
.V= \0ord
.V= \0chr
.V= \0new
.br
Reserved words may be just added to the scanner as patterns,
but must precede recognition of identifiers.
.LI
Identifiers are any sequence of upper- or lower-case ASCII (not Unicode)
letters, digits, and underscores, but may not begin with a digit.
.LI
Integer constants which consist of any sequence of decimal digits.
Octal and hexadecimal constants are not supported.
There is no floating point.
.LI
Character constants consist of a pair of single quote marks with a
single character or escape between them\(::
.ds ESCAPE \[rs]\[rs][\[rs]\[rs]'\[Dq]0nt]
.VTCODE* 1 \0('([\[ha]\[rs]\[rs]'\[rs]n]|\*[ESCAPE])')
.LI
String constants consist of a pair of double quote marks with zero
or more characters or escapes between them\(::
.VTCODE* 1 \
\0(\[rs]\[Dq]([\[ha]\[rs]\[rs]\[Dq]\[rs]n]|\*[ESCAPE])*\[rs]\[Dq])
Backslash, single quote, and newline may not appear in a character
or string constants unless escaped.
.LI
Comments and white space are consistent with the C preprocessor,
which removes comments from the input stream.
All C preprocessor statements are handled by
.V= cpp .
.LI
Output directives from
.V= cpp
of the form
.VCODE* 1 "# \f[I]line\f[CB] \[Dq]\f[I]filename\f[CB]\[Dq]"
must be scanned explicitly and used to indicate coordinates
for printing error messages from source code.
.LI
Also recognize invalid identifiers (beginning with a digit),
and invalid character and string constants (missing a final quote
or a character following an escape).
Make sure the scanner report does not show any jamming states.
.LE
.H 1 "The scanner"
Create a file
.V= scanner.l
which is used to generate 
.V= yylex.cc .
.ALX a ()
.LI
The only C code that should appear in the
.V= %{ \|.\|.\|. \|%}
at the start of your scanner should be
.V= #include
and
.V= #define
preprocessor statements.
In the first part of the scanner, use the following options\(::
.DS
.VTCODE* 1 "%option 8bit"
.VTCODE* 1 "%option debug"
.VTCODE* 1 "%option nodefault"
.VTCODE* 1 "%option nounput"
.VTCODE* 1 "%option noyywrap"
.VTCODE* 1 "%option verbose"
.VTCODE* 1 "%option warn"
.DE
.LI
Retrofit your first project so that the external variable
.V= "FILE *yyin"
is used to read the pipe from 
.V= cpp .
Every time
.V= yylex()
is called, it reads from that external variable.
Your main function will repeatedly call 
.V= yylex()
until it returnsa value of
.V= YYEOF .
.LI
The file
.V= misc-code/parser.y
contains a dummy parser which will not be called from this project,
but which must be included so that the internal names of tokens can be
printed.
Copy that file and be sure that your
.V= Makefile
uses it to build
.V= yyparse.h
and
.V= yyparse.cc .
The function
.V= get_yytname ,
given an integer symbol,
will return a string representation of that symbol.
.LI
In the parser provided,
the first group of token definitions will be used by the scanner
to return codes that are not represented by a single character.
The second group of tokens are not recognized by the scanner,
but are used in project 3 to edit the AST in order to prepare it for
the later projects.
.LE
.H 1 "A sample compiler"
Look in the directory
.VTCODE* 1 /afs/cats.ucsc.edu/courses/cmps104a-wm/Examples/e08.expr-smc
for a sample compiler for a simple language.
You will want to copy code from that directory,
especially the modules
.V= auxlib ,
.V= astree ,
and
.V= lyutils .
Copy the
.V= Makefile
as well and edit it as appropriate.
.ALX a ()
.LI
Module
.V= auxlib ,
which you are already using for project 1 has several useful
additions to the standard library,
and macros for generating debugging information.
.LI
Module 
.V= astree
has code useful for creating the abstract syntax tree,
which you will need for this project,
even though no AST will actually be assembled.
The scanner creates ASTs for each token that it finds.
.LI
Since an AST is a n-way tree with some nodes having an arbigrary
number of children,
it is easiest to represent the children by a C++
.V= vector<astree*>
field, for which
.V= push_back
can be used to add a new rightmost child.
.LI
Module
.V= lyutils
contains useful declarations and functions for interfacing with code
generated by 
.V= flex
and
.V= bison .
Do not include C code (except function calls) in your scanner.
Instead, make calls to functions in this module.
.H 1 "Output format"
Your program will produce output similar to that shown in here\(::
.DS
.VTCODE* 1 "# 16 \[Dq]foobar.oc\[Dq]"
.VTCODE* 1 "   2  16.003  264  TOK_KW_RETURN   (return)"
.VTCODE* 1 "   2  16.010   61  '='             (=)"
.VTCODE* 1 "   2  20.008  258  TOK_IDENT       (hello)"
.VTCODE* 1 "   2  20.010  271  TOK_LIT_INT     (1234)"
.VTCODE* 1 "   2  25.002  123  '{'             ({)"
.VTCODE* 1 "   2  26.008  272  TOK_LIT_STRING  (\[Dq]beep\[Dq])"
.DE
.ALX a ()
.LI
It models the information in the
.V= "struct astree_rep"
constucted by the scanner,
ignoring the pointers to other AST nodes,
which have not yet been determined.
Output will be printed to a file ending with the suffix
.V= \&.tok .
.LI
Everytime a file directive is found,
it is printed to the output token file,
and also scanned to update the coordinate information.
.LI
Each token is also printed to the output file in neatly aligned
columns\(::
.ALX i () "" 0
.LI
Index into filename vector, incremented for each
.V= # -directive.
.LI
The line number within the given file where the token was found.
.LI
The character offset of the first character of the token within
that line.
.LI
The integer token code stored in the AST node.
.LI
The name of the token as determined by
.V= get_yytname .
.LI
The lexical information associated with the token.
.LE
.LE
.H 1 "Fragments of a \f[CB]Makefile\f[P]"
Some of the macro definitions in the
.V= Makefile
might be\(::
.DS
.VTCODE* 1 "LSOURCES  = scanner.l"
.VTCODE* 1 "YSOURCES  = parser.y"
.VTCODE* 1 "CLGEN     = yylex.cc"
.VTCODE* 1 "HYGEN     = yyparse.h"
.VTCODE* 1 "CYGEN     = yyparse.cc"
.VTCODE* 1 "LREPORT   = yylex.output"
.VTCODE* 1 "YREPORT   = yyparse.output"
.DE
.ne 5
Then we may use
.V= flex
and
.V= bison
to build the scanner and parser with the following recipes\(::
.DS
.ds tab \0\0\0\0\0\0\0\0
.VTCODE* 1 "${CLGEN} : ${LSOURCES}
.VTCODE* 1 "\*[tab]flex --outfile=${CLGEN} ${LSOURCES} 2>${LREPORT}
.VTCODE* 1 "\*[tab]- grep -v '^  ' ${LREPORT}
\&
.VTCODE* 1 "${CYGEN} ${HYGEN} : ${YSOURCES}
.VTCODE* 1 \
"\*[tab]bison --defines=${HYGEN} --output=${CYGEN} ${YSOURCES}
.DE
.H 1 "Some utility code"
The subdirectory
.V= code/utility-code/
contains some files that should be incorporated into your compiler.
.ALX a ()
.LI
.V= astree.{h,cpp}
contains the definition and implemenetation
of an $n$-way abstract syntax tree.
.LI
.V= auxlib.{h,cpp}
are useful auxiliary functions.
.LI
.V= lyutils.{h,cpp}
are definitions of functions and variables exported by
.V= yylex
and
.V= yyparse ,
and some useful lexer functions.
.V= stringset.{h,cpp}
is the string set from project 1.
.LI
.V= yyparse.h
and
.V= parser.y
is a dummy header file and dummy parser to be used with project 2
and discarded with project 3.
.LE
.H 1 "What to Submit"
Submit
.V= README ,
.V= Makefile ,
.V= scanner.l ,
.V= parser.y
(for this project, the dummy parser),
and all of the header and C++ implementation files.
.E= "Do not"
submit the file generated by 
.V= flex .
.FINISH
