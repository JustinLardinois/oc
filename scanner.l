%{
// Justin Lardinois jlardino@ucsc.edu
// scanner.l - lex scanner for oc language

#include "lyutils.h"

#define YY_USER_ACTION { lexer_useraction(); }
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
SCHAR          ([^\\'"\n]|\\[\\'"0nt])

IDENT          ({LETTER}|_)({LDU})*
INTCON         {DIGIT}+ 
CHARCON        ('{CHAR}')
STRINGCON      (\"([^\\"\n]|\\[\\'"0nt])*\")

INV_IDENT      {DIGIT}({LDU}*({LETTER}|_){LDU}*)
INV_CHARCON    ('((\\[^\\'"0nt]|{CHAR}[^'])+)['\n])|('')
INV_STRINGCON  (\"{SCHAR}*\n)|((\"({SCHAR}*\\[^\\"0nt]{SCHAR}*)+)[\"\n])

%%

"#".*           { lexer_include(); }
[ \t]+          { }
\n              { lexer_newline(); }

"void"          { return yylval_token(TOK_VOID); }
"bool"          { return yylval_token(TOK_BOOL); }
"char"          { return yylval_token(TOK_CHAR); }
"int"           { return yylval_token(TOK_INT);  }
"string"        { return yylval_token(TOK_STRING); }
"struct"        { return yylval_token(TOK_STRUCT); }
"if"            { return yylval_token(TOK_IF); }
"else"          { return yylval_token(TOK_ELSE); }
"while"         { return yylval_token(TOK_WHILE); }
"return"        { return yylval_token(TOK_RETURN); }
"false"         { return yylval_token(TOK_FALSE); }
"true"          { return yylval_token(TOK_TRUE); }
"null"          { return yylval_token(TOK_NULL); }
"ord"           { return yylval_token(TOK_ORD); }
"chr"           { return yylval_token(TOK_CHR); }
"new"           { return yylval_token(TOK_NEW); }

{IDENT}         { return yylval_token(TOK_IDENT); }
{INTCON}        { return yylval_token(TOK_INTCON); }
{CHARCON}       { return yylval_token(TOK_CHARCON); }
{STRINGCON}     { return yylval_token(TOK_STRINGCON); }

"[]"            { return yylval_token(TOK_ARRAY); }
"("             { return yylval_token('('); }
")"             { return yylval_token(')'); }
"["             { return yylval_token('['); }
"]"             { return yylval_token(']'); }
"{"             { return yylval_token('{'); }
"}"             { return yylval_token('}'); }
";"             { return yylval_token(';'); }
","             { return yylval_token(','); }
"."             { return yylval_token('.'); }
"="             { return yylval_token('='); }
"=="            { return yylval_token(TOK_EQ); }
"!="            { return yylval_token(TOK_NE); }
"<"             { return yylval_token(TOK_LT); }
"<="            { return yylval_token(TOK_LE); }
">"             { return yylval_token(TOK_GT); }
">="            { return yylval_token(TOK_GE); }
"+"             { return yylval_token('+'); }
"-"             { return yylval_token('-'); }
"*"             { return yylval_token('*'); }
"/"             { return yylval_token('/'); }
"%"             { return yylval_token('%'); }
"!"             { return yylval_token('!'); }

{INV_IDENT}     { lexer_badtoken(yytext);
                  return yylval_token(TOK_IDENT); }
{INV_CHARCON}   { lexer_badtoken(yytext);
                  return yylval_token(TOK_CHARCON); }
{INV_STRINGCON} { lexer_badtoken(yytext);
                  return yylval_token(TOK_STRINGCON); }

.               { lexer_badchar(*yytext); }

%%
