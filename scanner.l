%{
// Justin Lardinois jlardino@ucsc.edu
// scanner.l - lex scanner for oc language 
%}

%option 8bit
%option debug
%option nodefault
%option nounput
%option noyywrap
%option verbose
%option warn

LETTER       [A-Za-z]
DIGIT        [0-9]
IDENT        {LETTER}({LETTER}|{DIGIT})*
INT_CONST    {DIGIT}+
CHAR_CONST   (’([^\\’\n]|\\[\\’"0nt])’)
STR_CONST    (\"([^\\"\n]|\\[\\’"0nt])*\")
