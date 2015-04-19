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
