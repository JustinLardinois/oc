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

%token TOK_FUNCTION TOK_PROTOTYPE TOK_PARAMLIST TOK_DECLID
%token TOK_VARDECL TOK_RETURNVOID TOK_NEWSTRING TOK_INDEX

%right TOK_IF TOK_ELSE
%right '='
%left  TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%left  '+' '-'
%left  '*' '/' '%'
%right PREC_UPLUS PREC_UMINUS '!' TOK_NEW TOK_ORD TOK_CHR
%left  '[' '.' PREC_CALL
%nonassoc PREC_PAREN

%start start

%%

start        : program             { yyparse_astree = $1; }
             ;
program      : program structdef   { $$ = adopt1($1,$2); }
             | program function    { $$ = adopt1($1,$2); }
             | program statement   { $$ = adopt1($1,$2); }
             | program error '}'   { $$ = $1; }
             | program error ';'   { $$ = $1; }
             | /* empty */         { $$ = new_parseroot(); }
             ;
structdef    : structfields '}'    { free_ast($2);
                                     $$ = $1; }
             ;
structfields : TOK_STRUCT TOK_IDENT '{'
                                   { free_ast($3);
                                     $2->symbol = TOK_TYPEID;
                                     $$ = adopt1($1,$2); }
             | structfields fielddecl ';'
                                   { free_ast($3);
                                     $$ = adopt1($1,$2); }
             ;
fielddecl    : basetype TOK_IDENT  { $2->symbol = TOK_FIELD;
                                     $$ = adopt1($1,$2); }
             | basetype TOK_ARRAY TOK_IDENT
                                   { $3->symbol = TOK_FIELD;
                                     $$ = adopt2($2,$1,$3); }
             ;
basetype     : TOK_VOID            { $$ = $1; }
             | TOK_BOOL            { $$ = $1; }
             | TOK_CHAR            { $$ = $1; }
             | TOK_INT             { $$ = $1; }
             | TOK_STRING          { $$ = $1; }
             | TOK_IDENT           { $1->symbol = TOK_TYPEID;
                                     $$ = $1; }
             ;
function     : identdecl functionargs ')' block
                                   { free_ast($3);
                                     $$ = adoptf($1,$2,$4); }
             ;
functionargs : '('                 { $1->symbol = TOK_PARAMLIST;
                                     $$ = $1; }
             | '(' identdecl       { $1->symbol = TOK_PARAMLIST;
                                     $$ = adopt1($1,$2); }
             | functionargs ',' identdecl
                                   { free_ast($2);
                                     $$ = adopt1($1,$3); }
             ;
identdecl    : basetype TOK_IDENT  { $2->symbol = TOK_DECLID;
                                     $$ = adopt1($1,$2); }
             | basetype TOK_ARRAY TOK_IDENT
                                   { $3->symbol = TOK_DECLID;
                                     $$ = adopt2($2,$1,$3); }
             ;
block        : blockstmts '}'      { free_ast($2);
                                     $$ = $1; }
             | ';'                 { $$ = $1; }
             ;
blockstmts   : '{'                 { $1->symbol = TOK_BLOCK;
                                     $$ = $1; }
             | blockstmts statement
                                   { $$ = adopt1($1,$2); }
             ;
statement    : block               { $$ = $1; }
             | vardecl             { $$ = $1; }
             | while               { $$ = $1; }
             | ifelse              { $$ = $1; }
             | return              { $$ = $1; }
             | expr ';'            { free_ast($2);
                                     $$ = $1; }
             ;
vardecl      : identdecl '=' expr ';'
                                   { free_ast($4);
                                     $2->symbol = TOK_VARDECL;
                                     $$ = adopt2($2,$1,$3); }
             ;
while        : TOK_WHILE '(' expr ')' statement
                                   { free_ast2($2,$4);
                                     $$ = adopt2($1,$3,$5); }
             ;
ifelse       : TOK_IF '(' expr ')' statement %prec TOK_IF
                                   { free_ast2($2,$4);
                                     $$ = adopt2($1,$3,$5); }
             | TOK_IF '(' expr ')' statement TOK_ELSE statement
                                   { free_ast2($2,$4);
                                     free_ast($6);
                                     $1->symbol = TOK_IFELSE;
                                     adopt2($1,$3,$5);
                                     $$ = adopt1($1,$7); }
             ;
return       : TOK_RETURN ';'      { free_ast($2);
                                     $1->symbol = TOK_RETURNVOID;
                                     $$ = $1; }
             | TOK_RETURN expr ';' { free_ast($3);
                                     $$ = adopt1($1,$2); }
             ;
expr         : expr '=' expr       { $$ = adopt2($2,$1,$3); }
             | expr TOK_EQ expr    { $$ = adopt2($2,$1,$3); }
             | expr TOK_NE expr    { $$ = adopt2($2,$1,$3); }
             | expr TOK_LT expr    { $$ = adopt2($2,$1,$3); }
             | expr TOK_LE expr    { $$ = adopt2($2,$1,$3); }
             | expr TOK_GT expr    { $$ = adopt2($2,$1,$3); }
             | expr TOK_GE expr    { $$ = adopt2($2,$1,$3); }
             | expr '+' expr       { $$ = adopt2($2,$1,$3); }
             | expr '-' expr       { $$ = adopt2($2,$1,$3); }
             | expr '*' expr       { $$ = adopt2($2,$1,$3); }
             | expr '/' expr       { $$ = adopt2($2,$1,$3); }
             | expr '%' expr       { $$ = adopt2($2,$1,$3); }
             | '+' expr %prec PREC_UPLUS
                                   { $1->symbol = TOK_POS;
                                     $$ = adopt1($1,$2); }
             | '-' expr %prec PREC_UMINUS
                                   { $1->symbol = TOK_NEG;
                                     $$ = adopt1($1,$2); }
             | '!' expr            { $$ = adopt1($1,$2); }
             | TOK_ORD expr        { $$ = adopt1($1,$2); }
             | TOK_CHR expr        { $$ = adopt1($1,$2); }
             | allocator           { $$ = $1; }
             | call                { $$ = $1; }
             | '(' expr ')' %prec PREC_PAREN
                                   { free_ast2($1,$3);
                                     $$ = $2; }
             | variable            { $$ = $1; }
             | constant            { $$ = $1; }
             ;
allocator    : TOK_NEW TOK_IDENT '(' ')'
                                   { free_ast2($3,$4);
                                     $2->symbol = TOK_TYPEID;
                                     $$ = adopt1($1,$2); }
             | TOK_NEW TOK_STRING '(' expr ')'
                                   { free_ast($2);
                                     free_ast2($3,$5);
                                     $1->symbol = TOK_NEWSTRING;
                                     $$ = adopt1($1,$4); }
             | TOK_NEW basetype '[' expr ']'
                                   { free_ast2($3,$5);
                                     $1->symbol = TOK_NEWARRAY;
                                     $$ = adopt2($1,$2,$4); }
             ;
call         : callargs ')' %prec PREC_CALL
                                   { free_ast($2);
                                     $$ = $1; }
             ;
callargs     : TOK_IDENT '('       { $2->symbol = TOK_CALL;
                                     $$ = adopt1($2,$1); }
             | TOK_IDENT '(' expr  { $2->symbol = TOK_CALL;
                                     $$ = adopt2($2,$1,$3); }
             | callargs ',' expr   { free_ast($2);
                                     $$ = adopt1($1,$3); }
             ;
variable     : TOK_IDENT           { $$ = $1; }
             | expr '[' expr ']'   { free_ast($4);
                                     $2->symbol = TOK_INDEX;
                                     $$ = adopt2($2,$1,$3); }
             | expr '.' TOK_IDENT  { $3->symbol = TOK_FIELD;
                                     $$ = adopt2($2,$1,$3); }
             ;
constant     : TOK_INTCON          { $$ = $1; }
             | TOK_CHARCON         { $$ = $1; }
             | TOK_STRINGCON       { $$ = $1; }
             | TOK_FALSE           { $$ = $1; }
             | TOK_TRUE            { $$ = $1; }
             | TOK_NULL            { $$ = $1; }
             ;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}
