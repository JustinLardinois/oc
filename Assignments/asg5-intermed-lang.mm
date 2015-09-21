.so Tmac.mm-etc
.if t .Newcentury-fonts
.INITR* \n[.F]
.SIZE 12 14
.TITLE CMPS-104A Fall\~2012 Project\~5 \
"Code Emission\(:) \f[CB]oc\f[P] and \f[CB]oil\f[P]"
.RCS "$Id: asg5-intermed-lang.mm,v 1.147 2015-05-20 19:58:25-07 - - $"
.PWD
.URL
.GETST* OIL_GRAMMAR Figure_OIL_GRAMMAR
.GETST* TYPE_DECLS Figure_TYPE_DECLS
.GETST* NAME_MANGLING Figure_NAME_MANGLING
.GETST* OCL_GCC Figure_OCL_GCC
.GETST* OCLIB_OH Figure_OCLIB_OH
.GETST* OCLIB_OH_C Figure_OCLIB_OH_C
.GETST* OCLIB_OH_OC Figure_OCLIB_OH_OC
.GETST* OCLIB_C_1 Figure_OCLIB_C_1
.GETST* OCLIB_C_2 Figure_OCLIB_C_2
.GETST* SAMPLE_FAC_OC Figure_SAMPLE_FAC_OC
.GETST* SAMPLE_FAC_OIL Figure_SAMPLE_FAC_OIL
.ds INDENT \0\0\0\0\0\0\0\0
.nr Grammar_Pi \n[Pi]*11/4
.nr Margin_Pi \n[Pi]/2
.ds STICK \s+3\v'+1p'|\v'-1p'\s-3
.ds OBRACK \s+3[\s-3
.ds CBRACK \s+3]\s-3
.ds PICDOTS \[bu]\0\[bu]\0\[bu]
.ds ARROW \[->]\0
.nr CONT_INDENT \w'\*[ARROW]'-(2*\w'\*[STICK]')
.de *SI*V \" next words are small italic and then bold
.   nop \f[I]\s-3\\$1\s+3\f[P]\f[CB]\\$2\f[P]
.   *Continuation 2 \\$@
..
.de *SI*'V \" next words are small italic and quoted bold
.   nop \f[I]\s-3\\$1\s+3\f[P]`\f[CB]\\$2\f[P]'
.   *Continuation 2 \\$@
..
.de *'V*SI \" next words are small italic and quoted bold
.   nop `\f[CB]\\$1\f[P]'\f[I]\s-3\\$2\s+3\f[P]
.   *Continuation 2 \\$@
..
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
.   nop \*[ARROW]
.   *Continuation 1 \\$@
..
.de DECL
.   *Continuation 0 \\$@
..
.de CONT
.   LI \0
.   nop \h'\\n[CONT_INDENT]u'\h'5p'
.   *Continuation 0 \\$@
..
.de VS
.   nop \f[CB]\\$1\f[P]\f[I]\s-3\\$2\s+3\f[P]\f[CB]\\$3\f[P]
..
.de NOT_FINISHED
.   SP
.   br
.   S +12 +12
.   E= "This document is not finished."
.   br
.   S -12 -12
.   SP
..
.EQ
delim $$
.EN
.gkacc@over-def +' \[aa]
.char-nt *o' \[*o] \[*o]\*[+']
.ds-nt polumorphismos polumorphismos \
\[*p]\[*o]\[*l]\[*u]\[*m]\[*o]\[*r]\[*f]\[*i]\[*s]\[*m]\[*o']\[ts]
.H 1 Overview
An intermediate language is a very low level language used
by a compiler to perform optimizations and other changes
before emitting final assembly language for some particular
machine.
It generally matches common assembly language statement semantics,
but in a typeful manner.
.P
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
All of the requirements for all previous projects are included
in this project.
For any input file called
.IV program .oc 
emit an intermediate language file called
\f[I]program\f[P]\f[CB].oil\f[P],
which can then be compiled into assembly language using 
.V= gcc .
.DF L
.SP
.B1
.SP
.VL \n[Grammar_Pi] \n[Margin_Pi] 1
.RULE program *[ *R structdef *]... \
*[ *R stringdef *]... \
*[ *R type *SI IDENT *'V ;\& *]... \
*[ *R function *]...
.RULE structdef *'V struct *SI TYPEID \
*'V { *[ *R type *SI IDENT *'V ;\& *]... *'V } *'V ;\&
.RULE stringdef *'V char* *SI IDENT *'V = *SI STRINGCON *'V ;\&
.RULE function *R type *SI IDENT *'V ( parameters *'V ) fnbody
.RULE fnbody *'V { *[ *R statement *]... *'V } *| *'V ;
.RULE parameters *R type *SI IDENT *[ *'V , *R type *SI IDENT *]... \
*| *'V void
.RULE statement *SI LABEL *'V :;\&
.RULE \0 *[ *'V if *'V ( *[ *'V ! *] *R operand *'V ) *] \
*'V goto *SI LABEL *'V ;\&
.RULE \0 *'V return *[ *R operand *] *'V ;\&
.RULE \0 *[ *R type *] *SI IDENT *'V = *R expression *'V ;\&
.RULE \0 *'V*SI * IDENT *'V = *R expression *'V ;\&
.RULE \0 *[ *R type *SI IDENT *'V = *] \
*SI IDENT *'V ( *[ *R operand *[ *'V , *R operand *]... *] *'V ) *'V ;\&
.RULE expression *R operand *R binop *R operand *| unop *R operand \
*| *R selection *| operand
.RULE binop *'V + *| *'V - *| *'V * *| *'V / *| *'V % \
*| *'V == *| *'V != *| *'V < *| *'V <= *| *'V > *| *'V >=
.RULE unop *'V + *| *'V - *| *'V ! *| *'V * *| *'V (int) *| *'V (char)
.RULE selection *'V & *SI IDENT *'V [ *R operand *'V ] \
*| *'V & *SI IDENT *'V -> *SI IDENT
.RULE operand *SI IDENT *| *SI INTCON *| *SI CHARCON \
*| *'V sizeof *'V ( *R type *'V )
.RULE type *'V void *| *'V void* *| *'V char *| *'V char* \
*| *'V char** *| *'V char***
.RULE \0 *'V int *| *'V int* *| *'V int** *| *'V struct *SI*'V TYPEID *
.RULE \0 *'V struct *SI*'V TYPEID ** *'V struct *SI*'V TYPEID ***
.LE
.SP
.B2
.FG "\f[B]Grammar of \f[CB]oil\f[P]" "" 0 OIL_GRAMMAR
.DE
.DF L
.SP
.TS
expand tab(|); |l lw(115p) |l lw(121p) |.
_
T{
.fi
.DECL *V bool *SI IDENT
T}|T{
.fi
.DECL *V char *SI IDENT
T}|T{
.fi
.DECL *V bool[] *SI IDENT
T}|T{
.fi
.DECL *V char* *SI IDENT
T}
T{
.fi
.DECL *V char *SI IDENT
T}|T{
.fi
.DECL *V char *SI IDENT
T}|T{
.fi
.DECL *V char[] *SI IDENT
T}|T{
.fi
.DECL *V char* *SI IDENT
T}
T{
.fi
.DECL *V int *SI IDENT
T}|T{
.fi
.DECL *V int *SI IDENT
T}|T{
.fi
.DECL *V int[] *SI IDENT
T}|T{
.fi
.DECL *V int* *SI IDENT
T}
T{
.fi
.DECL *V string *SI IDENT
T}|T{
.fi
.DECL *V char* *SI IDENT
T}|T{
.fi
.DECL *V string[] *SI IDENT
T}|T{
.fi
.DECL *V char** *SI IDENT
T}
T{
.fi
.DECL *SI TYPEID *SI IDENT
T}|T{
.fi
.DECL *V struct *SI*V TYPEID * *SI IDENT
T}|T{
.fi
.DECL *SI*V TYPEID [] *SI IDENT
T}|T{
.fi
.DECL *V struct *SI*V TYPEID ** *SI IDENT
T}
_
.TE
.FG "\f[B]Type declarations in \f[CB]oc\f[P] and \f[CB]oil\f[P]" \
"" 0 TYPE_DECLS
.SP
.DE
.H 1 "Intermediate Language"
The intermediate language chosen here looks very much like C,
except that, for the most part, each
.V= oil
statement should be capable of translating into a single
assembly language instruction, or only a few.
Unlike most assembly languages,
.V= oil
is typed as to basic data types, namely char, int, and pointer.
The size of the int and pointer types are dependent on the underlying
architecture.
.P
The basic grammar of
.V= oil
is given in Figure \*[Figure_OIL_GRAMMAR],
and uses the same metanotation as was used in the definition of
.V= oc .
Figure \*[Figure_TYPE_DECLS]
shows the relationship between types in
.V= oc
and the corresponding C-compatible types in
.V= oil .
The extra types listed in
Figure \*[Figure_OIL_GRAMMAR]
but not in Figure \*[Figure_TYPE_DECLS]
are used only when the address operator
.=V ( & )
is applied to take the address of a field selection,
which is then dereferenced when applied.
.P
The intermediate language itself has three datatypes\(::
byte
.=V ( char )\(;;
signed integer
.=V ( int )\(;;
and a pointer type.
.H 2 "Program and Function Structure"
An
.V= oil
program is structured in a way similar to C,
except that it looks more like assembly language.
All code is either aligned with the left margin or indented by
8 spaces.
.ALX a ()
.LI
Structure definitions come first, with the 
.V= struct 
keyword and closing brace left-aligned,
and the fields indented, as in\(::
.DS
.VTCODE* 1 "struct s_foo {"
.VTCODE* 1 "\*[INDENT]char** f_foo_string_array;"
.VTCODE* 1 "\*[INDENT]struct s_foo* f_foo_pointer;"
.VTCODE* 1 "};"
.DE
.LI
Then all string constants are listed in the order they appear in the
program.
They are unlikely to be able to be used as immediate operands in
assembly language.
Global declarations are all left-aligned, as in\(::
.DS
.VTCODE* 1 "char* s1 = \[Dq]Hello, world!\[rs]n\[Dq];"
.DE
.LI
Then all global variable declarations that appeared in the
program,
but without initialization,
because in C,
static initialization is done at compile time.
.LI
Finally,
functions are emitted with one parameter per line.
The function name and the two braces are left aligned,
as are label statements,
but everything else is indented, as in\(::
.DS
.VTCODE* 1 "int __add (
.VTCODE* 1 "\*[INDENT]int _1_a,"
.VTCODE* 1 "\*[INDENT]int _1_b)"
.VTCODE* 1 "{"
.VTCODE* 1 "\*[INDENT]int i2 = _1_a + _1_b;"
.VTCODE* 1 "\*[INDENT]return i2;"
.VTCODE* 1 "}"
.DE
.LE
.H 2 "Statements"
Statements are all indented,
except for labels,
and all declarations of local variables must be initialized.
Expressions other than calls are restricted to three-address
instructions,
with a destination and at most two sources.
.ALX a ()
.LI
A label is emitted unindented on a line by itself.
It consists of a keyword from the source language followed by
the coordinates taken from the node.
.DS
.VTCODE* 1 "while_4_20_9:;"
.DE
.LI
A
.V= goto
statement may be conditional or unconditional,
and if conditional is preceded by an
.V= if
and an operand (possibly complemented) in parentheses.
.DS
.VTCODE* 1 "\*[INDENT]goto while_4_20_9;"
.VTCODE* 1 "\*[INDENT]if (b36) goto while_4_29_9;"
.DE
.LI
A
.V= return
statement may or may not have an operand,
depending on the requirements of the original
.V= oc
program.
.DS
.VTCODE* 1 "\*[INDENT]return _5_foobar;"
.VTCODE* 1 "\*[INDENT]return;"
.DE
.LI
An assignment statement takes an expression as an operand.
A type is present if the identifier has not previously been
declared,
and absent if it has.
.DS
.VTCODE* 1 "\*[INDENT]int i5 = _2_n + 45;"
.VTCODE* 1 "\*[INDENT]_2_n = i5;"
.VTCODE* 1 "\*[INDENT]char c4 = (char) _4_foo;"
.VTCODE* 1 "\*[INDENT]char* a5 = &_3_a[i6];"
.VTCODE* 1 "\*[INDENT]*a5 = i7"
.DE
.LI
A function call may only have operands in parentheses,
but may have as many as appropriate.
A void function has no assignment on the left.
All other functions must have it,
and the result is placed into a temporary.
.LE
.H 2 "Expressions"
Expressions are simple and restricted to three-address code.
.ALX a ()
.LI
Binary operators are the same as they are in 
.V= oc
and have already been type checked.
As in C,
0 means false and anything else means true.
.LI
The unary operators are also the same,
with the cast
.V= (int)
being substituted for
.V= ord ,
and
.V= (char)
being substituted for
.V= chr .
These represent actual machine instructions that must be issued.
.LI
Address computation for indexing and field selection is taken care
of by the back end,
alghough a type checker would normally assign offsets of fields in
structures and offsets of local variables from the frame pointer.
.ALX i ()
.LI
The type of a subscript address is the same as the type of the
array.
So if we have
.V= "char** _3_a" ,
then a subscripting operation might be\(::
.VTCODE* 1 "char** i5 = _3_a[_3_i];"
and when it is used, 
.V= i5
must be dereferenced, as in\(::
.VTCODE* 1 "_3_n = *i5;"
.VTCODE* 1 "*i5 = _3_n;"
depending on whether the dereference is an lvalue or an rvalue.
.LI
The type of a selection has one more level of pointer than
the declaration of a field.
So if a
.V= struct 
has a field
.V= "char** f_foo_bar;" ,
then the selection might be\(::
.VTCODE* 1 "char*** a9 = &_3_ptr->f_foo_bar;"
.LE
.LI
Figure \*[Figure_TYPE_DECLS]
show the types in 
.V= oc
and their corresponding types in
.V= oil .
Note that the asterisk representing a pointer cuddles up against the
following identifier,
not against the type.
.LI
There is no
.V= bool
data type,
it being replaced by
.V= char .
.LE
.DF L
.SP
.TS
center box tab(|); l l l l, l lfCB l lfCB.
Category|Format string|Format arguments|Example
_
Global names|\[Dq]__%s\[Dq]|identifier|__glovar
Local names|\[Dq]_%d_%s\[Dq]|block, identifier|_3_ix
Stmt labels|\[Dq]%s_%d_%d_%d\[Dq]|keyword, file, line, offset|if_4_21_9
Structure typeids|\[Dq]s_%s\[Dq]|structure_typeid|s_foo
Field names|\[Dq]f_%s_%s\[Dq]|structure_typeid, field_name|f_foo_bar
Virtual registers|\[Dq]%c%d\[Dq]|register_category, register_number|i67
.TE
.FG "\f[B]Summary of name mangling" "" 0 NAME_MANGLING
.SP
.DE
.H 2 "Name Mangling"
Assembly language generally uses a completely flat symbol table,
so names need to be mangled in order to avoid clashing global names
with various local scopes and the C library to which a program is
linked.
Figure \*[Figure_NAME_MANGLING]
shows the 
.V= fprintf (3)
format items and arguments to be used to mangle a name.
.ALX a ()
.LI
All global names, functions and global variables will be prefixed
with a double underscore
.=V ( __ ),
e.g., 
.=V `` __foo ''.
Global names belong to block 0.
.LI
Local names will be prefixed with a double underscore with a block
number between the underscores, as in 
.=V `` _1_n ''.
Local names belong to blocks whose number is greater than 0.
.LI
Statement labels are emitted with a keyword from the language followed
by the file number, line number, and offset from the token.
The following keywords are used\(::
.=V `` while '',
before a while expression\(;;
.=V `` break '',
the statement to transfer to for a false test\(;;
.=V `` else '',
to branch to if the if-test is false and there is an
.V= else \(;;
and
.=V `` fi '',
to skip the else part.
.LI
Structure names all have file scope and are just prefixed with
.=V `` s_ ''.
So the name of a
.V= "struct foo"
would be 
.V= s_foo .
.LI
Field names are prefixed with 
.=V `` f_ ''
and the name of the structure to which they belong.
So a field from
.V= "struct foo { int ix; };"
would be called
.V= f_foo_ix .
.LI
Virtual registers are just assigned numbers in sequence throughout the
entire program starting with 1, 2, 3, etc.
The letter used is
.V= c
for a
.V= char ,
.V= i
for an
.V= int ,
.V= s
for a
.*SI STRINGCON
address,
.V= p
for a direct data pointer,
and
.V= a
for an indirect (dereferenceable) address pointing at data.
E.g., 
.V= c1 ,
.V= i2 ,
.V= s3 ,
.V= p4 ,
.V= a5 .
.LI
Indirect addresses are the result of evaluating selections,
which must be dereferenced when used.
All other addresses are used directly.
.DS
.VTCODE* 1 "\*[INDENT]int* a6 = &_3_array[_3_i];"
.VTCODE* 1 "\*[INDENT]char** a8 = &_3_foo->f_foo_bar;"
.DE
.LE
.DF L
.SP
.B1
.SP
.ft CR
.nf
.eo
.pso cat -nv oil-examples/ocl | expand
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]oil-examples/ocl\f[P]" "" 0 OCL_GCC
.DE
.H 1 "Code Emission"
Code is emitted from the AST with the benefit of the the symbol table
and type checker.
Since the suffix
.V= oil
is not recognized by
.V= gcc ,
in order to make it compile the code,
the
.V= -x
option must be used.
Figure \*[Figure_OCL_GCC] shows a shell script that will compile
into an executable,
given the name of the executable.
.P
The file
.V= oclib.oh
is bilingual for both
.V= oc
and
.V= gcc .
.ALX a ()
.LI
Figure \*[Figure_OCLIB_OH] shows the bilingual source file.
.LI
Figure \*[Figure_OCLIB_OH_OC]
show the file preprocessed for
.V= oc ,
as will be seen by the
.V= oc
compiler when
.V= #include d
in an
.V= oc
program.
Note that the
.V= #define s
.V= EOF
and
.V= assert
are not shown in the preprocessed figures,
but will be used by the preprocessor to process an
.V= oc
program.
.LI
Figure \*[Figure_OCLIB_OH_C]
shows it preprocessed for
.V= gcc ,
with names mangled names correctly when
.V= __OCLIB_C__
is defined, 
as is done when 
.V= #include d
from
.V= oclib.c .
.LE
.P
Figures \*[Figure_OCLIB_C_1] and \*[Figure_OCLIB_C_2]
show the code for
.V= oclib.c ,
the library written in C.
.H 2 "Top Level Description"
First, a prolog is emitted,
then 
.\".IR "r\[a_]d\[i_]cis f\[i_]li\[o_]s f\[i_]li\[a_]sque"
the children of the root
are traversed in their own sequence to build the various parts
of the program.
.ALX a ()
.LI
Then all structure definitions are traversed and output as
described above, with names mangled,
and fields properly indented.
.LI
Next, all string constants are given names as described above.
This should not require a complete tree traversal.
Retrofit either the construction of the AST or the type checking
module to put all
.*SI STRINGCON
AST nodes into a queue.
.LI
Then all global variables,
immediate children of the root,
and output,
but without any initialization given to them by the source.
.LI
Then all functions are output,
as described below.
Finally a single function with the signature
.VTCODE* 1 "void __ocmain (void)"
is output,
containing all global initializations and statements.
.LE
.H 2 "Emitting Functions and Statements"
Function emission is done by a complete depth-first mostly post-order
traversal of the AST for that function.
Prototypes need not be emitted.
They are used only in type checking.
.ALX a ()
.LI
Output the function's return type,
mangled name,
and mangled parameter names.
Mangle the parameter names using the block number the function created.
.LI
Following that,
indented,
are the declarations of all of the parameters.
.LI
An opening brace, unindented, at the start of the function's body,
and a closing brace, unindented, after the function is finished.
.LI
A block simply has its children traversed.
.LI
A
.V= while
has two children.
For the 
.V= while
and
.V= break
labels, both use the serial number of the
.V= while
token.
.ALX i () "" 0
.LI
Emit\(::
.V= "while_%d_%d_%d:;"
unindented.
.LI
Emit the first child, unless it is an operand.
.LI
Emit\(::
.VI "if (!" operand ") goto break_%d_%d_%d;"
.LI
Emit the statement.
.LI
Emit\(::
.V= "goto while_%d_%d_%d;"
.LI
Emit\(::
.V= "break_%d_%d_%d:;" 
unindented.
.LE
.LI
For an
.V= if - else
statement, do the following\(::
.ALX i () "" 0
.LI
Emit the first expression, unless it is an operand.
.LI
Emit\(::
.V= "if (!" operand ") goto else_%d_%d_%d;"
.LI
Emit the second child (consequent statement).
.LI
Emit\(::
.V= "goto fi_%d_%d_%d;"
.LI
Emit\(::
.V= else_%d_%d_%d:;
unindented.
.LI
Emit the third child (alternate statement).
.LI
Emit
.V= fi_%d_%d_%d:;
unindented.
.LE
.LI
For an
.V= if
with no
.V= else ,
do the following\(::
.ALX i () "" 0
.LI
Emit the first expression, unless it is an operand.
.LI
Emit\(::
.V= "if (!" operand ") goto fi_%d_%d_%d;"
.LI
Emit the second child (consequent statement).
.LI
Emit
.V= fi_%d_%d_%d:;
unindented.
.LE
.LI
If a
.V= return
statement has an expression,
emit the expression, unless it is an operand,
then return the operand.
If not, just 
.V= return .
.LE
.H 2 "Emitting Expressions"
Expressions are always emitted using a strict depth-first post-order
traversal,
accumulating values into virtual registers.
This results in some redundant virtual registers,
but the back end can use copy propagation to remove them during
register allocation.
.ALX a ()
.LI
In each case of generating code into an operand,
generate a declaration of a virtual register with the appropriate
letter,
.V= b ,
.V= i ,
.V= a ,
or 
.V= p ,
and assign it the value of the expression thus evaluated.
.LI
The binary operators are the same in both
.V= oc
and
.V= oil ,
and after emitting an instruction,
record the register number in the AST node itself.
This will require adding yet another field.
Example\(::
.VTCODE* 1 "int i5 = _3_n + 1;"
.LI
Similarly,
handle the unary operators,
except that 
.V= ord
becomes
.V= (int)
and
.V= chr
becomes
.V= (char) .
.LI
An allocator uses a call to
.V= xcalloc()
to allocate the storage,
based on the type of allocator,
for some structure type
.IR T
and pointer number
.IR i \(::
.ALX i ()
.LI
.*'V new *SI TYPEID *'V ( *'V )
.IR \& \(::
.br
Emit\(::
.VI "struct " T "* p" i " = xcalloc (1, sizeof (struct " T "));"
.LI
.*'V new *'V string *'V ( *R expression *'V )
.IR \& \(::
.br
Emit the expression, unless it is an operand.
.br
Emit\(::
.VI "char* p" i " = xcalloc (" opnd ", sizeof (char));"
.LI
.*'V new *R basetype *'V [ *R expression *'V ]
.IR \& \(::
.br
Emit the expression, unless it is an operand.
.br
Emit one of the following, depending on the
.IR basetype \(::
.ALX \[bu] 0 "" 0 0
.LI
.VI "char* p" i " = xcalloc (" opnd ", sizeof (char));"
.LI
.VI "int* p" i " = xcalloc (" opnd ", sizeof (int));"
.LI
.VI "char** p" i " = xcalloc (" opnd ", sizeof (char*));"
.LI
.VI "struct " T "** p" i \
" = xcalloc (" opnd ", sizeof (struct " T "*));"
.LE
.LE
.LI
For a function call,
evaluate each of the arguments into registers,
and generate the call instruction.
A
.V= void
function is just called.
A
.=V non- void
function has its result captured into a register.
.LI
An
.*SI INTCON
must be emitted with leading zeros suppressed,
since 0077 means tha same thing as 77 in 
.V= oc ,
but it means 63 in C.
A
.*SI CHARCON
is emitted as is.
The constants 
.V= null
and
.V= false
are emitted as the literal
.V= 0 ,
and
.V= true
is emitted as the literal
.V= 1 .
.LI
Constants (except strings)
and variables are never captured in registers,
but instead are used as immediate operands.
.LE
.H 1 "An Example"
Figure \*[Figure_SAMPLE_FAC_OC] contains a sample 
.V= oc
program.
Figure \*[Figure_SAMPLE_FAC_OIL] contains the output file
generated from it,
except that the code generated from the
.V= #include
header file has been omitted.
It is assumed that
.V= cpp
here has recognized this file as the fifth file in
sequence and that the header file has generated 11 blocks
so that the code presented is the 12th block.
.EQ
delim off
.EN
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
.pso cat -nv oc-programs/oclib.oh | expand
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]oc-programs/oclib.oh\f[R]" "" 0 OCLIB_OH
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
.pso cpp oc-programs/oclib.oh | cat -nv | expand
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]cpp oc-programs/oclib.oh\f[P]" "" 0 OCLIB_OH_OC
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
.pso cpp -D__OCLIB_C__ oc-programs/oclib.oh | cat -nv | expand | sed '/^ *[0-9][0-9]* *$/d'
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]cpp -D__OCLIB_C__ oc-programs/oclib.oh" "" 0 OCLIB_OH_C
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
.pso cat -nv oc-programs/oclib.c | expand | sed '/\^L/,$d'
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]oc-programs/oclib.c\f[B], part 1\fR" "" 0 OCLIB_C_1
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
.pso cat -nv oc-programs/oclib.c | expand | sed -n '/\^L/,$p'
.ec
.fi
.ft R
.SP
.B2
.FG "\f[CB]oc-programs/oclib.c\f[B], part 2\fR" "" 0 OCLIB_C_2
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
     1  #include "oclib.oh"
     2  int fac (int n) {
     3     int f = 1;
     4     while (n > 1) {
     5        f = f * n;
     6        n = n - 1;
     7     }
     8     return f;
     9  }
    10  int n = 1;
    11  while (n <= 5) {
    12     puti (fac (n));
    13     endl ();
    14     n = n + 1;
    15  }
.ec
.fi
.ft R
.SP
.B2
.FG "Sample program \f[CB]fac.oc" "" 0 SAMPLE_FAC_OC
.DE
.DS
\&
.B1
.SP
.ft CR
.nf
.eo
     1  int __n;
     2  int __fac (
     3          int _12_n)
     4  {
     5          int _12_f = 1;
     6  while_5_2_3:;
     7          char b1 = _12_n > 1;
     8          if (!b1) goto break_5_2_3;
     9          int i1 = _12_f * _12_n;
    10          _12_f = i1;
    11          int i2 = _12_n - 1;
    12          _12_n = i2;
    13          goto while_5_2_3;
    14  break_5_2_3:
    15          return _12_f
    16  }
    17  void __ocmain (void)
    18  {
    19          __n = 1;
    20  while_5_11_0:;
    21          char b2 = __n <= 5;
    22          if (!b2) goto break_5_11_0;
    23          int i3 = __fac (__n);
    24          __puti (i3);
    25          __endl();
    26          int i4 = __n + 1;
    27          __n = i4;
    28          goto while_5_11_0;
    29  break_5_11_0:;
    30  }
.ec
.fi
.ft R
.SP
.B2
.FG "Sample generated \f[CB]fac.oil" "" 0 SAMPLE_FAC_OIL
.DE
.FINISH
