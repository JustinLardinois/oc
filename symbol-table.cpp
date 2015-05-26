// Justin Lardinois jlardino@ucsc.edu
// symbol-table.cpp - implementation file for symbol-table.h

#include "yyparse.h"

#include "symbol-table.h"

// declared extern in header
std::vector<symbol_table*> symbol_stack;

int next_block = 1;

symbol_table* create_symbol_table(astree* node) {
   switch(node->symbol) {
      case TOK_ROOT:
         for(auto child: node->children) {
            create_symbol_table(child);
         }
         break;
      case TOK_STRUCT:
      case TOK_FUNCTION:
      case TOK_PROTOTYPE:
      case TOK_BLOCK:
      case TOK_VARDECL:
      case TOK_WHILE:
      case TOK_IF:
      case TOK_IFELSE:
      case TOK_RETURN:
      case TOK_RETURNVOID:
         break;
   }

   return nullptr;
}
