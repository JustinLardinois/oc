%{
// Justin Lardinois jlardino@ucsc.edu
// scanner.l - lex scanner for oc language

#include "lyutils.h"
%}

%option 8bit
%option debug
%option nodefault
%option nounput
%option noyywrap
%option verbose
%option warn

LETTER         [A-Za-z]
DIGIT          [0-9]
LDU            {LETTER}|{DIGIT}|_
CHAR           ([^\\'\n]|\\[\\'"0nt])
IDENT          ({LETTER}|_)({LDU})*
INT_CONST      {DIGIT}+ 
CHAR_CONST     ('{CHAR}')
STR_CONST      (\"([^\\"\n]|\\[\\'"0nt])*\")

INV_IDENT      {DIGIT}(LDU}*({LETTER}|_){LDU}*
INV_CHAR_CONST ('((\\[^\\'"0nt]|{CHAR}[^'])+)['\n])|('')
INV_STR_CONST  \"(({CHAR}(\\[^\\'"0nt]){CHAR})+)[\"\n]|(\"({CHAR}*)\n)

%%

"#".*          { lexer_include(); }
[ \t]+         { }
\n             { lexer_newline(); }

"void"         { yylval_token("void"); }
"bool"         { yylval_token("bool"); }
"char"         { yylval_token("char"); }
"int"          { yylval_token("int");  }
"string"       { yylval_token("string"); }
"struct"       { yylval_token("struct"); }
"if"           { yylval_token("if"); }
"else"         { yylval_token("else"); }
"while"        { yylval_token("while"); }
"return"       { yylval_token("return"); }
"false"        { yylval_token("false"); }
"true"         { yylval_token("true"); }
"null"         { yylval_token("null"); }
"ord"          { yylval_token("ord"); }
"chr"          { yylval_token("chr"); }
"new"          { yylval_token("new"); }

{IDENT}        { yylval_token(IDENT); }
{INT_CONST}    { yylval_token(INT_CONST); }
{CHAR_CONST}   { yylval_token(CHAR_CONST); }
{STR_CONST}    { yylval_token(STR_CONST); }

%%
