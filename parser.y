%{
// Justin Lardinois jlardino@ucsc.edu
// parser.y - dummy parser for scanner project

#include <cassert>

#include "lyutils.h"
#include "astree.h"

%}

%debug
%defines
%error-verbose
%token-table
%verbose

%token TOK_VOID TOK_BOOL TOK_CHAR TOK_INT TOK_STRING
%token TOK_IF TOK_ELSE TOK_WHILE TOK_RETURN TOK_STRUCT
%token TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%token TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON

%token TOK_BLOCK TOK_CALL TOK_IFELSE TOK_INITDECL
%token TOK_POS TOK_NEG TOK_NEWARRAY TOK_TYPEID TOK_FIELD
%token TOK_ORD TOK_CHR TOK_ROOT

%right TOK_IF TOK_ELSE
%right '='
%left  TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%left  '+' '-'
%left  '*' '/' '%'
%right PREC_UPLUS PREC_UMINUS '!' TOK_NEW TOK_ORD TOK_CHR
%left  PREC_INDEX PREC_MEMBER PREC_CALL
%nonassoc PREC_PAREN

%start program

%%

program      : /* empty */ | structdef | function | statement
             | program program
             ;
structdef    : TOK_STRUCT TOK_TYPEID '{' structfields '}'
             ;
structfields : /* empty */ | fielddecl ';' | structfields structfields
             ;
fielddecl    : basetype TOK_FIELD | basetype TOK_ARRAY TOK_FIELD
             ;
basetype     : TOK_VOID | TOK_BOOL | TOK_CHAR | TOK_INT
             | TOK_STRING | TOK_TYPEID
             ;
function     : identdecl '(' functionargs ')' block %prec PREC_FUNC
             ;
functionargs : /* empty */ | identdecl | functionargs ',' identdecl
             ;
identdecl    : basetype TOK_INITDECL | basetype TOK_ARRAY TOK_INITDECL
             ;
block        : '{' blockstmts '}' | ';'
             ;
blockstmts   : /* empty */ | statement | blockstmts blockstmts
             ;
statement    : block | vardecl | while | ifelse | return | expr ';'
             ;
vardecl      : identdecl '=' expr ';'
             ;
while        : TOK_WHILE '(' expr ')' statement
             ;
ifelse       : if | if TOK_ELSE statement
             ;
if           : TOK_IF '(' expr ')' statement
             ;
return       : TOK_RETURN ';' | TOK_RETURN expr ';'
             ;
expr         : expr '=' expr | expr TOK_EQ expr | expr TOK_NE expr
             | expr TOK_LT expr | expr TOK_LE expr | expr TOK_GT expr
             | expr TOK_GE expr | expr '+' expr | expr '-' expr
             | expr '*' expr | expr '/' expr | expr '%' expr
             | '+' expr %prec PREC_UPLUS | '-' expr %prec PREC_UMINUS
             | '!' expr | TOK_NEW expr | TOK_ORD expr | TOK_CHR expr
             | allocator | call | '(' expr ')' %prec PREC_PAREN
             | variable | constant
             ;
allocator    : TOK_NEW TOK_TYPEID '(' ')'
             | TOK_NEW TOK_STRING '(' expr ')'
             | TOK_NEW basetype '[' expr ']'
             ;
call         : TOK_IDENT '(' callargs ')' %prec PREC_CALL
             ;
callargs     : /* empty */ | expr | callargs ',' expr
             ;
variable     : TOK_IDENT | expr '[' expr ']' %prec PREC_INDEX
             | expr '.' TOK_FIELD %prec PREC_MEMBER
             ;
constant     : TOK_INTCON | TOK_CHARCON | TOK_STRINGCON | TOK_FALSE
             | TOK_TRUE | TOK_NULL
             ;
/*token   : '(' | ')' | '[' | ']' | '{' | '}' | ';' | ',' | '.'
        | '=' | '+' | '-' | '*' | '/' | '%' | '!'
        | TOK_VOID | TOK_BOOL | TOK_CHAR | TOK_INT | TOK_STRING
        | TOK_IF | TOK_ELSE | TOK_WHILE | TOK_RETURN | TOK_STRUCT
        | TOK_FALSE | TOK_TRUE | TOK_NULL | TOK_NEW | TOK_ARRAY
        | TOK_EQ | TOK_NE | TOK_LT | TOK_LE | TOK_GT | TOK_GE
        | TOK_IDENT | TOK_INTCON | TOK_CHARCON | TOK_STRINGCON
        | TOK_ORD | TOK_CHR | TOK_ROOT
        ;
*/
%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}
/*
static void* yycalloc (size_t size) {
   void* result = calloc (1, size);
   assert (result != NULL);
   return result;
}*/

