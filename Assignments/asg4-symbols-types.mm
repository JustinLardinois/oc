.so Tmac.mm-etc
.if t .Newcentury-fonts
.INITR* \n[.F]
.SIZE 12 14
.GETST* TYPECHECK Figure_TYPECHECK
.GETST* SYMBOL_NODE Figure_SYMBOL_NODE
.GETST* SYM_EXAMPLE Figure_SYM_EXAMPLE
.GETST* SYM_TABLE Figure_SYM_TABLE
.GETST* ATTRS_C_SETS Figure_ATTRS_C_SETS
.TITLE CMPS-104A Fall\~2014 Project\~4 "Symbols and Type Checking"
.RCS "$Id: asg4-symbols-types.mm,v 1.73 2015-05-13 14:32:08-07 - - $"
.PWD
.URL
.nr Margin_Pi \n[Pi]/2
.de ->
.   nop \[->]
.   *Continuation 0 \\$@
..
.de RULE
.   br
.   nop \0
.   *Continuation 0 \\$@
..
.de *IV
.   IV \\$1 \\$2
.   *Continuation 2 \\$@
..
.nr ATTR_COUNT 0
.de ATTR
.   V= \\$1 \\$2
.   ds ATTR_NAME\\n[ATTR_COUNT] \\$1
.   nr ATTR_COUNT \\n[ATTR_COUNT]+1
..
.de ATTR_PRINT
.   nr ATTR_INDEX 0
.   br
.   ft CB
.   br
.   ds ENUM_PREFIX \h'\\n[VCODENWIDTH]u'enum {
.   nr ENUM_UNITS \w'\\*[ENUM_PREFIX]'
.   nop \\*[ENUM_PREFIX]
.   nr USED_UNITS \\n[ENUM_UNITS]
.   nr MAX_UNITS 343600
.   while \\n[ATTR_INDEX]<\\n[ATTR_COUNT] \{\
.      ds CURR_ATTR ATTR_\\*[ATTR_NAME\\n[ATTR_INDEX]],
.      nr CURR_UNITS \w'\\*[CURR_ATTR]'
.      nr NEXT_UNITS \\n[USED_UNITS]+\\n[CURR_UNITS]
.      ie \\n[NEXT_UNITS]<\\n[MAX_UNITS] \{\
.         nr USED_UNITS \\n[NEXT_UNITS]
.      \}
.      el \{\
.         br
.         nop \h'\\n[ENUM_UNITS]u'
.         nr USED_UNITS \\n[ENUM_UNITS]
.      \}
.      nop \\*[CURR_ATTR]
.      nr ATTR_INDEX \\n[ATTR_INDEX]+1
.   \}
.   br
.   nop \h'\\n[VCODENWIDTH]u'};
.   ft P
.   br
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
A symbol table maintains all of the identifiers in a program so
that they can be looked up when referenced.
Every time a symbol definition is found,
it is entered into the symbol table,
and every time a reference is found, 
it is looked up in the symbol table.
It also maintains scope and range information,
information that determines from where a symbol may be referenced.
.P
Another important part of a compiler is the type checking mechanism,
which is used to verify that operators and functions are passed
types of an appropriate nature and return results that are consistent.
This is done by adding attributes to each node of the AST,
although only declaration and expression nodes have non-null
attributes.
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
The semantic routines of this project will be called after the
parser has returned to the main program.
For any input file called
.IV program .oc 
generate a symbol table file called
\f[I]program\f[P]\f[CB].sym\f[P].
In addition,
change the AST printing function from the previous project
so that it prints out all attributes in each node on each line
after the information required in the previous project.
Thus, the AST file for this project will have more information in
it than for the previous project.
.H 1 "Symbols in \f[CB]oc\f[P]"
Symbols in
.V= oc
are all identifiers,
since there is no possibility of user-overloading of operators.
The symbol table module in
.V= oc
must maintain multiple symbol tables,
for function and variable names,
for type names,
and for fields of structures.
There are three classes of identifiers\(::
.ALX a () 4
.LI
.BR "Type names\(::"
Type names consist of the reserved words
.V= void ,
.V= bool ,
.V= char ,
.V= int ,
.V= string ,
and identifier names defined via 
.V= struct
definitions.
All type names are global and exist in a name space separate from
those of ordinary identifiers,
so type identifiers are entered into the type name table.
.LI
.BR "Field names\(::"
Field names are identifiers which may only be used immediately
following the dot
.=V ( . )
operator for field selection.
The same field name may be used in different
.V= struct
definitions without conflict, and hence are all global.
Each
.V= struct
definition causes a separate field symbol table to be created
and accessed from the type name table.
.LI
.BR "Function and variable names\(::"
All function and variable identifiers are entered into the
identifier symbol tables.
All functions have global scope,
but variables may have global or local scope,
which is nested arbitrarily deeply.
A variable declared in a local scope hides an identifier
with the same name in a more global scope.
Variables in disjoint scopes may have the same name.
A variable may only be referenced from the point of declaration
to the end of the scope in which it is declared.
.LE
.H 2 "Categories and types in \f[CB]oc\f[P]"
There are three categories of types in 
.V= oc ,
and each has groups of types within it.
Each identifier and field has a particular type associated with it,
and each
.V= struct
defines a new type by name.
Type checking of functions is done by structural equivalence
but checking of variables is done via name equivalence.
.ALX a () 4
.LI
The void type
is neither primitive nor reference.
.ALX i () 4
.LI
.V= void \(::
may only be used as the return type of a function.
It is an error to declare variables, parameters,
or fields of this type.
.LE
.LI
Primitive types are represented inline inside 
.V= struct s
and local or global variables, and whose values disappear when
the block containing them leaves its scope,
or the
.V= struct
containing them becomes unreachable.
.ALX i () 4
.LI
.V= bool \(::
has constants
.V= false
and
.V= true ,
and is an 8-bit byte.
.LI
.V= char \(::
is an 8-bit byte.
Values between
.V= 0x00
and
.V= 0x7F
are ASCII characters,
and values between
.V= 0x80
and
.V= 0xFF
are locale dependent.
.LI
.V= int \(::
is a signed two's complement integer.
.LE
.LI
Reference types are pointers to objects on the heap.
They themselves may be local, global, or fields, as may primitive
types,
but all object types reside on the heap.
Pointer arithmetic is prohibited.
.ALX i () 4
.LI
.V= null \(::
has the single constant
.V= null .
The syntax prevents it from being used in a type declaration.
.LI
.V= string \(::
is effectivly an array of characters and has
string constants associated with it.
Its size is fixed when allocated.
The length of the string contained in the array varies
up to the maximum allocated length,
depending on where the null plug
.=V ( '\[rs]0' )
is placed.
Strings are stored in the same format as in C.
.LI
.V= struct
.IR typeid \(::
may have as many fields as needed inside of it.
It may contain both primitive and reference types.
.LI
.IV base []\fR\(::\fP
contains a collection of other elements,
all of which are of the same type,
which may be either primitive or reference types.
Its base type may not be an array type.
This is the only polymorphic type.
.LE
.LE
.H 2 "Attributes for types and properties"
Each node in the AST has a set of attributes associated with it,
as does each entry in the symbol tables.
Attributes indicate properties associated with parts of the AST
and are used for code generation.
The attributes are gathered into several categories\(::
.ALX a () 4
.LI
Type attributes, all of which are mutually exclusive\(::
.ATTR void ,
.ATTR bool ,
.ATTR char ,
.ATTR int ,
.ATTR null ,
.ATTR string ,
and
.ATTR struct .
If the
.V= struct
attribute is present, an associated typeid must also be present.
.LI
The
.ATTR array
attribute which may occur with any primitive or reference type.
Arrays of arrays are not permitted.
.LI
Attributes describing typeids, identifiers, and fields
are mutually exclusive\(::
.ATTR function ,
.ATTR variable ,
.ATTR field ,
and
.ATTR typeid .
In addition, the
.ATTR param
attribute is set if the variable is in a function's parameter list.
.LI
The
.ATTR lval
attribute appears on any node in the AST which can receive an
assignment.
This includes all variables (global, local, or parameter) and the
result of the indexing
.=V ( [] )
and selector
.=V ( .\& )
operators.
.LI
The
.ATTR const 
attribute is set on all constants of type
.V= bool ,
.V= char ,
.V= int ,
.V= null ,
and
.V= string .
The
.V= lval
and
.V= const
attributes are mutually exclusive.
.LI
The
.ATTR vreg
attribute is set on interior nodes that hold a computed value
and the
.ATTR vaddr
attribute on a computed address referring to a location in memory.
They are mutually exclusive.
They represent virtual registers used in code generation.
.LE
.P
Attributes can be represented as an enumeration,
with 
.ATTR bitset_size ,
the last attribute,
having the largest magnitude.
.DS
.fi
.ATTR_PRINT
.VTCODE* 1 "using attr_bitset = bitset<ATTR_bitset_size>;"
.DE
.H 2 "Polymorphism"
Polymorphism is present in many languages and derives from the Greek
\*[polumorphismos],
meaning ``having many forms''.
.ALX a () 4
.LI
Universal polymorphism\(::
.ALX i () 4
.LI
Parametric polymorphism (universal),
implemented as generics in Java,
and as templates in C++,
allows type parameters to be passed into data structures.
In 
.V= oc ,
only arrays exhibit limited parametric polymorphism,
in that there can be an array of any other type except arrays.
.LI
Inclusion polymorphism (universal),
known also as inheritance in object-oriented
programming lanugages,
allows function overriding.
None in
.V= oc .
.LE
.LI
Ad hoc polymorphism\(::
.ALX i () 4
.LI
Overloading polymorphism (ad hoc)
means that the same function or operator may be defined
multiple times and selected based on the types of its arguments.
In
.V= oc
operator overloading is permitted only for the assignment and
comparison operators,
which can have many types as arguments,
provided that they are compatible,
and for the indexing operator,
whose left operand may be an array of any type, or a string.
No functions or other operators are overloaded.
.LI
Conversion polymorphism (ad hoc)
has arguments to functions implicitly converted from one type to
another in order to satisfy parameter passing.
None in
.V= oc .
.LE
.LE
.P
.DF L
.SP
.TS
center box tab(|); lew(219p) | le.
.SP
T{
.fi
.na
.RULE *R identdecl *'V = *I compatible ->
.RULE *'V while *'V ( *V bool *'V ) ->
.RULE *'V if *'V ( *V bool *'V ) ->
.RULE *'V return *I compatible ->
.RULE *I any *V lval *'V = *I any -> *I any *V vreg
.RULE *I any *'V == *I any -> *V bool *V vreg
.RULE *I any *'V != *I any -> *V bool *V vreg
.RULE *I primitive *'V < *I primitive -> *V bool *V vreg
.RULE *I primitive *'V <= *I primitive -> *V bool *V vreg
.RULE *I primitive *'V > *I primitive -> *V bool *V vreg
.RULE *I primitive *'V >= *I primitive -> *V bool *V vreg
.RULE *V int *'V + *V int -> *V int *V vreg
.RULE *V int *'V \- *V int -> *V int *V vreg
.RULE *V int *'V * *V int -> *V int *V vreg
.RULE *V int *'V / *V int -> *V int *V vreg
.RULE *V int *'V % *V int -> *V int *V vreg
.RULE *'V + *V int -> *V int *V vreg
.RULE *'V - *V int -> *V int *V vreg
T}|T{
.fi
.na
.RULE *'V ! *V bool -> *V bool *V vreg
.RULE *'V ord *V char -> *V int *V vreg
.RULE *'V chr *V int -> *V char *V vreg
.RULE *'V new *SI TYPEID *'V ( *'V ) -> *SI TYPEID *V vreg
.RULE *'V new *'V string *'V ( *V int *'V ) -> *V string *V vreg
.RULE *'V new *I base *'V [ *V int *'V ] -> *IV base [] *V vreg
.RULE *SI IDENT *'V ( *I compatible *'V ) -> *I lookup *V vreg
.RULE *SI IDENT -> *I lookup
.RULE *IV base [] *'V [ *V int *'V ] \
-> *I base *V vaddr *V lval
.RULE *'V string *'V [ *V int *'V ] -> *V char *V vaddr *V lval
.RULE *SI IDENT *'V \&.\& *SI FIELD \
-> *I lookup *V vaddr *V lval
.RULE *SI INTCON -> *V int *V const
.RULE *SI CHARCON -> *V char *V const
.RULE *SI STRINGCON -> *V string *V const
.RULE *'V false -> *V bool *V const
.RULE *'V true -> *V bool *V const
.RULE *'V null -> *V null *V const
T}
.SP
.TE
.FG "\f[B]Type checking grammar\f[P]" "" 0 TYPECHECK
\&
.DE
.H 2 "Type checking"
Type checking involves a post-order depth-first
traversal of the AST.
A detailed partial context-sensitive type checking grammar is shown in
Figure \*[Figure_TYPECHECK].
The following names are used\(::
.IR primitive
is any primitive type,
.IR base
is any type that can be used as a base type for an array,
and
.IR any
is either primitive or reference.
.ALX a () 4
.LI
Two types are
.IR compatible
if they are exactly the same type,
or if one type is any reference type and the other is
.V= null .
In the type checking grammar, in each rule, 
types in italics must be substituted consistently by compatible types.
Types are compatible only if the
.V= array
attribute is on for both or off for both.
.LI
When the right side of a production is empty,
there are no type attributes.
Only expressions have type attributes, not statements.
.LI
The result type of assignment
.=V ( = )
is the type of its left operand.
.LI
Fields following a selector have the
.V= field
attribute, but no type attribute,
since their type depends on the structure from which they
are selected.
.LI
Identifiers
have the type attributes that they derive from the symbol table.
In addition,
either the 
.V= function
or
.V= variable
attribute will be present,
and for variables that are parameters,
also the
.V= param
attribute.
All variables also have the
.V= lval
attribute.
.LI
Field selection sets the selector
.=V ( .\& )
attribute as follows\(::
The left operand must be a 
.V= struct
type or an error message is generated.
Look up the field in the structure and copy its type
attributes to the selector,
removing the
.V= field
attribute and adding the
.V= vaddr
attribute.
.LI
For a
.V= CALL ,
evaluate the types of each of the arguments,
and look up the function in the identifier table.
Then verify that the arguments are compatible with the
parameters and error if not,
or if the argument and parameter lists are not of the same length.
The 
.V= CALL
node has the result type of the function,
with the
.V= vreg
attribute.
.LI
The expression operand of both
.V= if
and
.V= while
must be of type
.V= bool .
.LI
If the function's return type is not
.V= void ,
then it must have an expression which is compatible with
the declared return type.
It is an error for a
.V= return 
statement to have an operand if the function's return type is
.V= void .
A global
.V= return
statement is considered to be in a
.V= void
function.
.LI
The indexing operator for an array returns the address of one of
its elements,
and for a string, the address of one of its characters.
.LE
.DF L
.SP
.TS
allbox tab(|); lfCB |lw(255p).
struct symbol {|T{
.fi
Each node in the symbol table must have information associated
with the identifier.
It will be simpler to make nodes in all of the symbol
tables identical,
and null out unnecessary fields.
T}
attr_bitset attributes;|T{
.fi
Symbol attributes,
as described earlier.
T}
symbol_table* fields;|T{
.fi
A pointer to the field table if this symbol is a 
.V= struct 
(if the
.V= typeid
attribute is present).
Null otherwise.
T}
size_t filenr, linenr, offset;|T{
.fi
The index into the filename vector,
along with the line number and offset where this symbol was declared.
T}
size_t block_nr;|T{
.fi
The block number to which this symbol belongs.
Block 0 is the global block,
and positive increasing sequential numbers being
assigned to nested blocks.
T}
vector<symbol*>* parameters;|T{
.fi
A symbol node pointer which points at the parameter list.
For a function,
points at a vector of parameters.
Null otherwise.
T}
.TE
.FG "\f[B]Symbol table node\f[P]" "" 0 SYMBOL_NODE
\&
.DE
.H 1 "Symbol tables"
Symbol tables must be maintained for identifiers,
.V= struct s,
and for each
.V= struct ,
a field table.
Figure \*[Figure_SYMBOL_NODE]
contains declarations for type
.V= symbol 
in the left column and descriptions in the right column.
A symbol table is just a hash table with the identifier as the key
and a symbol as the value\(::
.VTCODE* 1 "using symbol_table = unordered_map<string*,symbol*>;"
.VTCODE* 1 "using symbol_entry = symbol_table::value_type;
Each entry in the symbol table is a
.V= "pair<const string*,symbol*>" .
The key is a pointer into the 
.V= stringset
as returned by the intern function.
This key is the same pointer as found in the AST node of the
identifier definition.
.H 2 "The structure and field tables"
All structures and fields belong to block 0 (by default),
since no structure definitions may be local.
Structure and field names are in separate namespaces from that of
identifiers.
Maintain a
.V= symbol_table
containing all structure definitions,
with the type name as the key and a field table as the value.
Each structure definition points at its own field table.
.H 2 "The symbol-stack data structure"
When handling nested symbol tables,
it is necessary to efficiently
create a new scope on entry,
look up symbols quickly in $ O ( 1 ) $ time.
.ALX a () 4
.LI
Maintain a vector of symbol tables,
with each entry in the vector representing an open block\(::
.V= "vector<symbol_table*> symbol_stack;
.LI
Maintain a global counter
.V= next_block
which is initially set to 1 and represents the next block number
to be used.
Each block must be unique.
.LI
When entering a block,
increment
.V= next_block
and push
.V= nullptr
onto the top of the symbol stack.
.LI
When leaving a block,
pop the top of the symbol stack.
.LI
When defining an identifier,
define a new
.V= symbol
and insert it into the symbol table at the top of the
.V= symbol_stack.
Create the symbol table if it is null.
Not all blocks have symbols,
so do not create a symbol table for a given block until it has
at least one symbol defined in it.
.LI
When searching for an identifier,
start with the top of the symbol stack and check each non-null
pointer to a symbol table,
searching downward.
Local identifiers hide more global ones.
.LE
.H 1 "Traversing the abstract syntax tree"
Write a function that does a depth-first traversal of
the abstract syntax tree.
At this point,
you may assume it is correctly constructed.
If not, go back and fix your parser.
.ALX a () 4
.LI
For all nodes not involving declarations,
proceed left to right in a depth-first post-order traversal,
assigning attributes as necessary.
All identifiers must be declared before they are used,
except when a
.*SI TYPEID
declares a field of a structure,
so the scan must be done from left to right,
with all declarations preceding all references.
.LI
Whenever a structure definition is found,
create a new entry in the structure hash,
using the typeid as a key.
The block number is 0 because structures are declared globally.
Then create a hash table
and insert each field into that hash table,
pointed at by this structure table entry.
Field names are also in block 0.
.LI
The structure name must be inserted into the structure hash
before the field table is processed,
because type type of a field may be the structure itself.
.LI
If a structure name is found that is not in the hash,
insert it with a null pointer for the field table.
If it later becomes defined,
fill in the fields.
.LI
If an incomplete structure has a field selected from it,
or if it follows
.V= new ,
or if it used in a declaration of other than a field,
print an error message about referring to an incomplete type.
.LI
All other identifiers are inserted into the main symbol tables.
.LI
Whenever you see a block,
increment the global block count and push that number on the
block count stack.
Then store the block number in the AST node and traverse the block.
When leaving a block,
pop the block number from the stack.
Each block will have a unique number,
with 0 being the global block,
and the others numbered in sequence 1, 2, 3, etc.
.LI
Whenever you see a function or prototype,
perform the block entering operation,
and traverse the function.
Treat the function as if it were a block.
The parameters are inserted into the symbol table as owned
by the function's block.
.LI
If the function is already in the symbol table,
but only as a prototype,
match the prototype of the new function with the previous one
of the same name.
If they differ, print an error message.
If the function is already in the symbol table as a function,
print an error message about a duplicate declaration.
.LI
If the function is not in the symbol table,
enter it,
along with its parameters.
If this is an actual function,
traverse the block as you normally would,
with the block number being the next one in line.
A function creates at least two blocks,
one for itself,
and one for the block of statements that it owns.
.LI
Whenever you see a variable declaration,
look it up in the symbol table.
Print a duplicate declaration error message if it is in
the symbol table at the top of the symbol vector stack.
.LI
If it is not found,
enter it into the symbol table at the top of the symbol stack
and set the attributes and other fields as appropriate.
.LI
In the scanner and parser,
error messages were printed using a global co\[:o]rdinate maintained by
the scanner.
In this assignment and the next,
all error messages must be the co\[:o]rdinates in some appropriate
AST node, since the global co\[:o]rdinate at this time indicates end of
file.
.LE
.DF L
.SP
.B1
.SP
.ft CR
.nf
.in \n[Pi]
struct node { int foo; node link; }
node func (node head, int length) {
   int a = 0; string b = ""; node c = new node();
   if (a < 3) { int d = 8; a = length; c = c.link; }
         else { string e = ""; 
                if (0 == 0) { int f = 8; }
                       else { int g = 9; }
              }
}
node h = func (null, 10);
.SP
.B2
.FG "\f[B]Example program used to illustrate \f[CB].sym\fP file\fR" \
"" 0 SYM_EXAMPLE
\&
.B1
.SP
.ft CR
.nf
.in \n[Pi]
node (0.1.7) {0} struct "node"
   foo (0.1.18) field {node} int
   link (0.1.27) field {node} struct "node"

func (0.2.5) {0} struct "node" function
   head (0.2.15) {1} struct "node" variable lval param
   length (0.2.24) {1} int variable lval param

   a (0.3.7) {1} int variable lval
   b (0.3.14) {1} string variable lval
   c (0.3.24) {1} struct "node" variable lval
      d (0.4.19) {2} int variable lval
      e (0.5.17) {3} string variable lval
         f (0.6.30) {4} int variable lval
         g (0.7.30) {5} int variable lval

h (0.8.5) {0} struct "node" variable lval
.SP
.B2
.ds FIGSYM Figure \*[Figure_SYM_EXAMPLE]
.FG "\f[B]Sample output to \f[CB].sym\fB file from \*[FIGSYM]\fR" \
"" 0 SYM_TABLE
\&
.DE
.H 1 "Generated output"
You must generate all output from the previous projects,
and in addition, create a file with the symbol table in it
with a suffix of
.V= \&.sym .
In addition,
additional information will be printed into the
.V= \&.ast
file when traversing and printing the AST.
Figure \*[Figure_SYM_TABLE]
shows some sample output to the
.V= \&.sym
file for some sample input shown in
Figure \*[Figure_SYM_EXAMPLE].
.ALX a () 4
.LI
Retrofit your scanner so that new fields are added to a token node
when created\(::
.V= "attr_bitset attributes" ,
initialized to 0,
a block number initialized to 0,
and a pointer to a structure table node,
initialized to null,
.LI
Retrofit your parser so that its output lines look like\(::
.VTCODE* 1 "'+' \[Dq]+\[Dq] (0.6.3) {4} int vreg"
.VTCODE* 1 "IDENT \[Dq]foo\[Dq] (0.6.8) {4} int variable (0.2.9)
.VTCODE* 1 \
"IDENT \[Dq]bar\[Dq] (0.7.3) {5} struct \[Dq]node\[Dq] variable (0.3.7)"
Following the token coordinate is the block number in which the
node occurs,
and then the various attributes associated with that node.
For identifiers,
the last number is the coordinate of the declaration.
.LI
In the traversal described above,
put a block number on every node in the tree,
as well as appropriate attributes.
If the
.V= struct
attribute is set,
also print the name of the structure.
For variables, functions, typeids, and fields,
print out the co\[:o]rdinates of the defining occurrence
of that identifier.
This means that you AST file must be generated after the
symbol table semantic routines traverse the AST.
.LI
Output to the
.V= \&.sym
file should show all identifiers, typeids, and fields listed in
the same order as on input,
i.e.,
sorted by serial number.
.LI
For each definition of a variable, function, structure, or
field,
print out the same information into the
.V= \&.sym
file.
List all global definitions against the left margin
and all field, parameter,
and local definitions indented by three spaces.
Print an empty line in front of each global definition and
between the parameter list and local variables.
.LE
.FINISH
