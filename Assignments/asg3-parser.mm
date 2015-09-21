.so Tmac.mm-etc
.if t .Newcentury-fonts
.INITR* \n[.F]
.SIZE 12 14
.TITLE CMPS-104A Spring\~2014 Project\~3 \
"LALR(1) Parser using \f[CB]bison\f[P]"
.RCS "$Id: asg3-parser.mm,v 1.7 2015-04-16 17:58:32-07 - - $"
.PWD
.URL
.GETST* META_NOTATION Figure_META_NOTATION
.GETST* OC_GRAMMAR Figure_OC_GRAMMAR
.GETST* OPER_PRECEDENCE Figure_OPER_PRECEDENCE
.GETST* EXAMPLE_CODE Figure_EXAMPLE_CODE
.GETST* EXAMPLE_AST Figure_EXAMPLE_AST
.GETST* CONFIG_OPTIONS Figure_CONFIG_OPTIONS
.GETST* PARSER_BEGIN Figure_PARSER_BEGIN
.nr Grammar_Pi \n[Pi]*11/4
.nr Margin_Pi \n[Pi]/2
.ds STICK \s+3\v'+1p'|\v'-1p'\s-3
.ds OBRACK \s+3[\s-3
.ds CBRACK \s+3]\s-3
.ds PICDOTS \[bu]\0\[bu]\0\[bu]
.ds ARROW \[->]\0
.nr ARROW_SIZE \w'\*[ARROW]'
.nr STICK_SIZE \w'\*[STICK] '
.nr CONT_ADJUST \n[ARROW_SIZE]-\n[STICK_SIZE]
.de *|
.   RB \*[STICK]
.   *Continuation 0 \\$@
..
.de *[
.   RI \*[OBRACK]
.   *Continuation 0 \\$@
..
.de *]
.   RI \*[CBRACK]
.   *Continuation 0 \\$@
..
.de *]...
.   RI \*[CBRACK]\|.\|.\|.\&
.   *Continuation 0 \\$@
..
.de RULE
.   LI "\\$[1]"
.   RI \*[ARROW]
.   *Continuation 1 \\$@
..
.de CONT
.   LI "\0"
.   RI \h'\\n[CONT_ADJUST]u'
.   *Continuation 0 \\$@
..
.nr SUBST_COUNT 0 1
.de SUBST_LIST
.   V= \\$[1] \\$[2]
.   ds SUBST_LIST_\\n+[SUBST_COUNT] \\$[1]
.   SETR SUBST_HEADER_\\n[SUBST_COUNT]
..
.de SUBST_PRINT_HN
.   GETHN SUBST_HEADER_\\n[SUBST_INDEX] SUBST_HN
.   substring SUBST_HN 0 -3
.   V= \\*[SUBST_LIST_\\n[SUBST_INDEX]]
.   nop (\\*[SUBST_HN])\\$[1]
..
.de SUBST_PRINT
.   nr SUBST_INDEX 0 1
.   while \\n+[SUBST_INDEX]<\\n[SUBST_COUNT] \{\
.      SUBST_PRINT_HN ,
.   \}
.   nop and
.   SUBST_PRINT_HN .
..
.H 1 Overview
Augment your string table and scanner by adding an
.V= oc
parser to the project.
The output of this project will be an abstract syntax tree written to
the file
.IV program .ast ,
in addition to the files generated from the previous two projects.
All specifications from the first two projects apply,
and in addition, the
.V= -y
flag must turn on
.V= yydebug .
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
The main function will open a pipe to the C preprocessor as before,
but will never call
.V= yylex() .
Instead it makes a single call to
.V= yyparse() ,
which will call
.V= yylex()
as needed.
When 
.V= yyparse()
returns, the main function will call a function to dump the AST.
The function
.V= yyparse()
calls
.V= yyerror()
to print an error message
whenever it detects a syntax error and has to recover.
The
.V= -y
flag must turn on the
.V= yydebug
switch.
Generate a file called
.IV program .ast
based on the input file name,
and also generate all files specified in earlier projects.
.DF L
.SP
.B1
.SP
.VL \n[Grammar_Pi] \n[Margin_Pi] 1
.LI "\*[OBRACK] \f[BI]x\f[R] \*[CBRACK]"
Brackets indicate the the symbols are optional.
.LI "\*[OBRACK] \f[BI]x\f[R] \*[CBRACK]\|.\|.\|.\&"
Brackets and three dots mean that the symbol(s)
occur zero or more times.
.LI "\f[BI]x\f[R] \*[STICK] \f[BI]y\f[R]"
A bar indicates alternation between its left and right operands.
.LI "`\f[CB]while\f[R]'"
Symbols representing themselves
and written in
.V= "Courier bold"
and quoted. 
.LI "symbol"
Nonterminal symbols in the grammar are written in lower case Roman.
.LI "\fI\s-3TOKEN\s+3\fP"
Token classes with lexical information
are written in \s-3\f[I]UPPER CASE SMALL ITALIC\f[R]\s+3.
.SP
.B2
.FG "\f[B]Metagrammar for \f[CB]oc\f[P]\f[R]" "" 0 META_NOTATION
.DE
.H 1 "The Metagrammar"
When reading the grammar of
.V= oc ,
it is important to distinguish between the grammar and the
metagrammar. 
the metagrammar is the grammar that describes the grammar.
You must also use your knowledge of C to fill in what
is only implied.
The metalanguage redundantly uses fonts and typography
to represent concepts for the benefit of those reading
this document via simple ASCII text.
It looks prettier in the Postscript version.
Note that the meta-brackets and meta-stick are slightly larger
than normal type.
The notation used is shown in Figure \*[Figure_META_NOTATION].
.DF L
.SP
.B1
.SP
.VL \n[Grammar_Pi] \n[Margin_Pi] 1
.RULE program *[ *R structdef *| *R function *| *R statement *]...
.RULE structdef *'V struct *SI TYPEID \
*'V { *[ *R fielddecl *'V ; *]... *'V }
.RULE fielddecl *R basetype *[ *'V [] *] *SI FIELD
.RULE basetype *'V void *| *'V bool *| *'V char *| *'V int \
*| *'V string *| *SI TYPEID
.RULE function *R identdecl \
*'V ( *[ *R identdecl *[ *'V , *R identdecl *]... *] *'V ) *R block
.RULE identdecl *R basetype *[ *'V [] *] *SI DECLID
.RULE block *'V { *[ *R statement *]... *'V } *| *'V ;
.RULE statement *R block *| *R vardecl *| *R while *| *R ifelse \
*| *R return *| *R expr *'V ;
.RULE vardecl *R identdecl *'V = *R expr *'V ;
.RULE while *'V while *'V ( *R expr *'V ) *R statement
.RULE ifelse *'V if *'V ( *R expr *'V ) *R statement \
*[ *'V else *R statement *]
.RULE return *'V return *[ *R expr *] *'V ;
.RULE expr *R expr *SI BINOP *R expr *| *SI UNOP *R expr \
*| *R allocator *| *R call *| *'V ( *R expr *'V )
.CONT *| *R variable *| *R constant
.RULE allocator *'V new *SI TYPEID *'V ( *'V ) \
*| *'V new *'V string *'V ( *R expr *'V )
.CONT *| *'V new *R basetype *'V [ *R expr *'V ]
.RULE call *SI IDENT *'V ( *[ *R expr *[ *'V , *R expr *]... *] *'V )
.RULE variable *SI IDENT *| *R expr *'V [ *R expr *'V ] \
*| *R expr *'V . *SI FIELD
.RULE constant *SI INTCON *| *SI CHARCON *| *SI STRINGCON \
*| *'V false *| *'V true *| *'V null
.LE
.SP
.B2
.FG "\f[B]Grammar of \f[CB]oc\f[P]\f[R]" "" 0 OC_GRAMMAR
.SP
.TS
center box tab(|); |l |l |l |l |lfCB |.
Precedence|Associativity|Arity|Fixity|\fROperators\FP
_
lowest|right|binary/ternary|matchfix|if\0 else
|right|binary|infix|\&=
|left|binary|infix|==\0 !=\0 <\0 <=\0 >\0 >=
|left|binary|infix|+\0 -
|left|binary|infix|*\0 /\0 %
|right|unary|prefix|+\0 -\0 !\0 new\0 ord\0 chr
|left|binary/variadic\0|postfix|T{
\fIe\fP[\fIe\fP]\0 \fIe\fP.\fIi\fP\0 \fIf\fP(\fI...\fP)
T}
highest|\[em]|unary|matchfix|(\fIe\fP)
.TE
.SP .5v
.FG "\f[B]Operator precedence in \f[CB]oc\f[R]" "" 0 OPER_PRECEDENCE
\&
.DE
.H 1 "The Grammar of \f[CB]oc\f[P]"
Figure \*[Figure_OC_GRAMMAR]
shows the context-free grammar of
.V= oc .
Your task is to translate that descriptive user-grammar into
LALR(1) form acceptable to
.V= bison .
You may, of course,
take advantage of 
.V= bison 's
ability to handle ambiguous grammars via the use of precedence
and associativity declarations.
The dangling
.V= else
problem should also be handled in that way.
.P
You will not be able to feed the grammar above to
.V= bison ,
because it will not be able to handle
.*SI BINOP
and
.*SI UNOP
as you might expect.
You will need to explicitly enumerate all possible rules
with operators in them.
However, using
.V= bison 's
operator precedence declarations,
the number of necessary rules will be reduced.
Figure \*[Figure_OPER_PRECEDENCE] shows 
operator precedence and associativity.
.P
There is actually more information there than that which will
be useful in 
.V= %left
and
.V= %right
declarations.
In addition,
it is necessary to eliminate the metagrammar's
optional and repetitive brackets,
a feature that
.V= bison
does not have.
.H 1 "Constructing the Abstract Syntax Tree"
The abstract syntax tree (AST) is constructed in such a way 
that all operators and operator-like tokens are the parents of
their operands, 
which are adopted as their children.
The children may be leaf nodes (identifiers or constants)
or other expressions.
Constants and identifiers are always leaf nodes.
In general,
interior nodes may have an arbitrarily large number of children.
This is the case wherever the grammar shows ``\|.\|.\|.\|''
indicating repetition.
.P
There are also several situations where the scanner can not
distinguish between tokens which have the same lexical structure,
but become different syntactically.
For example,
the operators
.V= +
and
.V= -
may be either unary or binary,
and a sequence of characters like
.V= -123
must be scanned as two separate tokens.
.P
Also,
the difference between an identifier and a type id can only
be determined by the parser, 
not the scanner,
as can the overloaded use of
.V= =
as either a variable declaration initializer or an assignment operator.
.H 2 "The Root Token"
At the root of the entire AST is the root token,
with code 
.SUBST_LIST TOK_ROOT .
This is a token synthesized by the parser,
since there are no characters at the beginning of the program
for the scanner to make with this.
The parser creates this root token as its first action,
when reducing the empty right hand side to a 
.V= program .
.br
.ne 5
.H 2 "Identifiers"
There are multiple different tokens all of which have the appearance of
being identifiers.
The scanner distinguishes and returns special token codes for
reserved words,
but returns all others as
.V= TOK_IDENT .
The parser must then substitute
.V= TOK_IDENT
depending on the context.
This makes the symbol table and type checker easier to implement.
.ALX a ()
.LI
In a field declaration,
substitute
.V= TOK_FIELD .
.LI
In a variable or function declaration,
substitute
.V= TOK_DECLID .
.SUBST_LIST TOK_DECLID
A
.V= TOK_DECLID
and a
.V= TOK_IDENT
are exactly the same,
except that the first appears in a declaration and the second in
a variable or function reference.
.LI
In a structure type declaration,
or a use of a structure type in a variable declaration or
function return type,
substitute
.V= TOK_TYPEID .
.LE
.H 2 "Structure Definitions"
A structure defines a new data type and may only appear as a global
statement.
The
.V= struct
keyword can serve as the root,
with the braces and internal semicolons being discarded.
The
.V= TYPEID
name is the first child,
similar to a call statement,
with each of the field definitions following as the other children
in their declared order.
The scanner will return the
.V= TYPEID
name as a
.V= TOK_IDENT ,
so change it to
.SUBST_LIST TOK_TYPEID .
.H 2 "Operators"
Operators are interior nodes whose children are their operands.
.H 3 "Binary operators"
The binary operators each have two children,
the left being the first,
and the right being the second.
.ALX a ()
.LI
The field selector
.=V ( . )
behaves syntactically as a binary operator,
but its right operand is a field selector,
not an identifier,
so change the right operand's token code to 
.SUBST_LIST TOK_FIELD .
.LI
The array indexing operator
.=V ( [\~] )
is syntactically a postfix matchfix operator.
Use the left bracket as the operator and change its token code to
.SUBST_LIST TOK_INDEX .
Discard the right bracket.
The left child is the left operand and the right child is
the expression between the brackets.
.H 3 "Unary operators"
The unary operators have one child each,
but since additon
.=V ( + )
and subtraction
.=V ( \- )
are overloaded,
at the time the parser has these operators adopt the child,
The token codes should be changed to
.SUBST_LIST TOK_POS
and
.SUBST_LIST TOK_NEG ,
respectively.
.H 3 "Variadic operators"
Variadic operators take a variable number of children as arguments.
They can take a variable number of arguments.
The only one in
.V= oc
is the
.V= TOK_CALL 
operator, whose first child is always an identifier,
and whose later children are the arguments found between the
parentheses of the argument list.
Use the left parenthesis as the operator itself and change its token
code to
.SUBST_LIST TOK_CALL 
before adopting the children.
Discard the right parenthesis.
.H 3 "Allocator operator \f[CB]new\f[P]"
The allocator operator
.V= new
is used to allocate a structure object or an array.
Since constructors are not supported,
.V= string
is treated as a special case.
.ALX a ()
.LI
If the word following
.V= new
is an
.V= IDENT ,
change the token code to
.V= TYPEID ,
and have
.V= TOK_NEW 
adopt it as its only child.
.LI
In the case of allocating an array,
change the token code to 
.SUBST_LIST TOK_NEWARRAY
as a binary operator and make the two children the
.V= TYPEID
and the dimension expression.
.LI
If a 
.V= string
is being allocated,
change the token code to
.SUBST_LIST TOK_NEWSTRING
as a unary operator with the expression as its child.
.br
.ne 5
.H 3 "Grouping parentheses"
Parentheses which are used to override precedence are discarded
from the abstrct syntax tree, since the tree structure itself
shows the order of evaluation.
The AST for the parenthesized expression is just the expression.
Both parentheses are discarded.
.H 2 "Statement Keywords as Operators"
The statement keywords
.V= while ,
.V= if ,
and
.V= return
have ``operands'' which will be adopted as their children.
These are not really operators in the sense of returning results,
but syntactically they function in the same way.
Blocks and variable declarations are also statements which must have
some kind of operator at the root.
.H 3 "The \f[CB]while\f[P] statement"
The 
.V= while
statement always has two ``operands'' and so should adopt two
children, the first one being the root of the expression,
and the second being the root of the statement following it.
Discard the parentheses around the expression.
.H 3 "The \f[CB]if\f[P]-\f[CB]else\f[P] statement"
The
.V= if
statement might have two or three children,
depending on whether or not the optional
.V= else
is present.
The first child is the expression 
and the second child is the statement following it.
Discard the parentheses around the expression.
.ALX a ()
.LI
If an
.V= else
is present,
the
.V= else
token is discarded and the
.V= if
token adopts the statement following the else as the third child.
Change the token code to
.SUBST_LIST TOK_IFELSE 
as a ternary operator.
.LI
If there is no
.V= else ,
then the two children are the expression and the statement.
.LE
.H 3 "The \f[CB]return\f[P] statement"
The
.V= return
keyword may or may not have an operand.
It is marked optional in the grammar,
because the parser has no way to determine whether or not an
operand to
.V= return
is required or prohibited.
The latter decision is made by later semantic routines.
The semicolon is discarded.
.ALX a ()
.LI
If
.V= return
has an expression, it is adopted as its child.
.LI
If not,
change the token code to
.SUBST_LIST TOK_RETURNVOID .
.LE
.H 3 "The block statement"
A block is a series of statements enclosed between braces.
The left brace has its token code changed to
.SUBST_LIST TOK_BLOCK ,
and adopts the roots of each of the interior statements.
The right brace is discarded.
.H 3 "The semicolons statement"
A semicolon by itself is just a vacuous block,
and the semicolon itself is the AST.
This also distinguishes a function definition from a prototype.
.H 3 "The expression statement"
When an expression is used as a statement,
the root of the expression becomes the root of the statement.
The semicolon is discarded.
.H 3 "The variable declaration statement"
A variable declaration has as its root the equal symbol which links the
actual declaration with its initial value.
The left child is an identifier declaration and the right
child is the expression.
To avoid confusion with the assignment operator,
the token code of the equal symbol here is changed to
.SUBST_LIST TOK_VARDECL .
.H 2 "Function Definitions"
The most complicated part of parsing global units is the function.
It has a prototype and either a body or just a semicolon.
The prototype consists of an identifier declaration and a parameter
list.
.P
It consists of a
.SUBST_LIST TOK_FUNCTION
with three children\(::
the identifier declaration,
the parameter list,
and the block.
For the parameter list, 
change the open parenthesis token code to 
.SUBST_LIST TOK_PARAMLIST
and have it adopt each of the parameters.
It will always be there but may possibly have no children.
Like
.V= TOK_ROOT ,
the
.V= TOK_FUNCTION
node can be spontaneously generated with the serial number of
the first token in the function.
.P
If instead of a block,
there is only a semicolon,
then the parent node in a function is a
.SUBST_LIST TOK_PROTOTYPE ,
and it has only two children.
.H 2 "Miscellaneous"
A few miscellaneous ideas do not strictly belong to a unique one
of the categories above.
.ALX a ()
.LI
.BR "Synthesized tokens\(::"
There are three tokens that are not identified and returned by
the scanner\(::
.V= TOK_ROOT ,
.V= TOK_FUNCTION ,
and
.V= TOK_PROTOTYPE .
Semantic actions that are part of the parser will create these
tokens.
Use the serial number
.V= 0.0.0
for 
.V= TOK_ROOT ,
and the serial number from the first token of a function for
.V= TOK_FUNCTION ,
or prototype for
.V= TOK_PROTOTYPE .
.LI
.BR "Identifier declarations\(::"
Identifier declarations are part of a declaration,
but otherwise can not exist on their own.
They are always associated with an initialized variable declaration,
a structure field,
or a parameter list,
or a function definition.
The type itself can serve as a root,
with the identifier being its child.
In the case of an array,
which is a generic data type,
the array token
.V= TOK_ARRAY
can be the root,
with the base type and identifier being children.
Note that
.V= TOK_ARRAY ,
lexical
.=V ( [] )
is a single token,
different from the left
.=V ( [ )
and and right 
.=V ( ] )
bracket tokens.
.LI
.BR "Substituted token codes\(::"
In order to make the later phases of the compiler simpler and
capable of having individual components chosen by a large
.V= switch
statement,
the parser substitutes a token code initialized by the scanner
to something else.
.LI
.BR "Parser's token codes\(::"
Following are the synthesized and substituted token codes
described above which are introduced by
the parser, with the sections wherein they were defined\(::
.P
.SUBST_PRINT
.LE
.DF L
.SP
.B1
.SP
.ft CR
.nf
     1	int fac (int n) {
     2	   int f = 1;
     3	   while (n > 1) {
     4	      f = f * n;
     5	      n = n - 1;
     6	   }
     7	   return f;
     8	}
     9	int n = 1;
    10	while (n <= 5) {
    11	   puti (fac (n));
    12	}
.SP
.B2
.FG "Example program" "" 0 EXAMPLE_CODE
.DE
.DF L
.SP
.B1
.SP
.ft CR
.nf
.in \n[Margin_Pi]
.ds ; |\0\0
ROOT "" 0.0.0
\*;FUNCTION "" 0.1.0
\*;\*;INT "int" 0.1.0
\*;\*;\*;DECLID "fac" 0.1.4
\*;\*;PARAM "(" 0.1.8
\*;\*;\*;INT "int" 0.1.9
\*;\*;\*;\*;DECLID "n" 0.1.13
\*;\*;BLOCK "{" 0.1.15
\*;\*;\*;VARDECL "=" 0.2.9
\*;\*;\*;\*;INT "int" 0.2.3
\*;\*;\*;\*;\*;DECLID "f" 0.2.7
\*;\*;\*;\*;INTCON "1" 0.2.9
\*;\*;\*;WHILE "while" 0.3.3
\*;\*;\*;\*;GT ">" 0.3.10
\*;\*;\*;\*;\*;IDENT "n" 0.3.8
\*;\*;\*;\*;\*;INTCON "1" 0.3.12
\*;\*;\*;\*;BLOCK "{" 0.3.14
\*;\*;\*;\*;\*;'=' "=" 0.4.8
\*;\*;\*;\*;\*;\*;IDENT "f" 0.4.6
\*;\*;\*;\*;\*;\*;'*' "*" 0.4.12
\*;\*;\*;\*;\*;\*;\*;IDENT "f" 0.4.10
\*;\*;\*;\*;\*;\*;\*;IDENT "n" 0.4.12
\*;\*;\*;\*;\*;'=' "=" 0.5.8
\*;\*;\*;\*;\*;\*;IDENT "n" 0.5.6
\*;\*;\*;\*;\*;\*;'-' "-" 0.5.12
\*;\*;\*;\*;\*;\*;\*;IDENT "n" 0.5.10
\*;\*;\*;\*;\*;\*;\*;INTCON "1" 0.5.12
\*;\*;\*;RETURN "return" 0.7.3
\*;\*;\*;\*;IDENT "f" 0.7.10
\*;VARDECL "=" 0.9.6
\*;\*;INT "int" 0.9.0
\*;\*;\*;DECLID "n" 0.9.8
\*;\*;INTCON "1" 0.9.4
\*;WHILE "while" 0.10.0
\*;\*;LE "<=" 0.10.9
\*;\*;\*;IDENT "n" 0.10.7
\*;\*;\*;INTCON "5" 0.10.12
\*;\*;BLOCK "{" 0.10.15
\*;\*;\*;CALL "(" 0.11.3
\*;\*;\*;\*;IDENT "puti" 0.11.9
\*;\*;\*;\*;CALL "(" 0.11.13
\*;\*;\*;\*;\*;IDENT "fac" 0.11.11
\*;\*;\*;\*;\*;IDENT "n" 0.11.15
.SP
.B2
.FG "Example AST" "" 0 EXAMPLE_AST
\&
.DE
.H 1 "Displaying the AST"
After constructing an AST from a file called
.IV program .oc ,
write a file called
.IV program .ast ,
containing a representation of the AST in text form,
printed using a depth-first pre-order traversal,
showing depth via indententation.
.P
Each line is indented to show its distance from the root,
with a line upward immediately to its right that points at its parent.
After the indentation print the symbolic token code,
lexical information in
double quotation marks,
and the serial number consisting of a file number,
a line number, and an offset.
During project 4,
this will also have type information following it.
.P
All global statements, functions, and declarations will appear
under the root,
.V= TOK_ROOT .
If an include file is present,
the contents of that file will also be printed
under
.V= TOK_ROOT
as well,
with only the file numbers leaving a clue as to where the code
originated.
The parser has no direct idea about the names of the files that the
tokens came from.
.P
The program shown in Figure \*[Figure_EXAMPLE_CODE]
would be printed as an AST as shown in Figure \*[Figure_EXAMPLE_AST].
To avoid clutter, the prefix
.V= TOK_
has been omitted from the printed tree.
The prefix was used in the C code to avoid possible name clashes.
The following, using pointer arithmetic,
can be used to eliminate the prefix\(::
.DS
.VTCODE* 1 "char *tname = get_yytname (symbol);"
.VTCODE* 1 "if (strstr (tname, \[Dq]TOK_\[Dq]) == tname) tname += 4;"
.DE
.DF L
.SP
.B1
.SP
.ft CB
.nf
.in \n[Margin_Pi]
%debug
%defines
%error-verbose
%token-table
%verbose
\&
%start start
\&
.B2
.FG "Parser configuration options" "" 0 CONFIG_OPTIONS
.SP
.B1
.SP
.ft CB
.nf
.in \n[Margin_Pi]
start    : program            { yyparse_astree = $1; }
         ;
program  : program structdef  { $$ = adopt1 ($1, $2); }
         | program function   { $$ = adopt1 ($1, $2); }
         | program statement  { $$ = adopt1 ($1, $2); }
         | program error '}'  { $$ = $1; }
         | program error ';'  { $$ = $1; }
         |                    { $$ = new_parseroot (); }
         ;
.SP
.B2
.FG "Beginning parser code" "" 0 PARSER_BEGIN
\&
.DE
.H 1 "The Parser"
Start out with a
.V= parser.y
which will generate a header file and a C source file.
Develop it incrementally,
possibly using routines from the example 
.V= expr-smc ,
bearing in mind that that code does not exactly fit this project.
Use the declarations shown in Figure \*[Figure_CONFIG_OPTIONS]
in section 1 of the grammar to configure your parser.
.P
Your program will need to perform some syntax error checking and
recovery,
although not much sophistication is required.
Use the code shown in Figure \*[Figure_PARSER_BEGIN]
at the beginning of your grammar section 
to set up the root of the AST and return it back to main.
When there is a syntax error,
an attempt to recover will be done by searching forward for a
closing brace or a semicolon.
.P
All other AST nodes are adopted by the root,
which is a synthetically manufactured token
(not created by the scanner).
The parser needs a way to communicate with the main function,
but has no communication results or parameters,
so the global variable
.V= yyparse_astree
will be used for that purpose.
.P
All actions in the parser should be simple.
Use function calls when that is not the case.
Actions should be of one of the following two forms\(::
.DS
.VTCODE* 1 "{ $$ = \fIsimple expression\fP; }
.VTCODE* 1 "{ $$ = \fIfncall (args\|.\|.\|.\|)\fP; }
.DE
Neatly line up all of the nonterminals in the first column,
all of the colon
.=V ( : ),
alternation 
.=V ( | ),
and action
.=V ( { )
characters so that the grammar is easy to read.
You should use
.V= valgrind
to detect memory errors,
although you can ignore memory leak.
A good set of options to use when compiling C code is
.VTCODE* 1 "gcc -g -O0 -Wall -Wextra -std=gnu99"
However, you may prefer to avoid
.V= -Wall
and
.V= -Wextra
with code generated by
.V= flex
and
.V= bison .
.FINISH
