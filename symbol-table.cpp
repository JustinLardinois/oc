// Justin Lardinois jlardino@ucsc.edu
// symbol-table.cpp - implementation file for symbol-table.h

#include "yyparse.h"

#include "symbol-table.h"

// declared extern in header
std::vector<symbol_table*> symbol_stack;
int error_count = 0;

int next_block = 1;

int yy_to_enum(int type) {
   switch(type) {
      case TOK_VOID:
         return ATTR_void;
      case TOK_BOOL:
         return ATTR_bool;
      case TOK_CHAR:
         return ATTR_char;
      case TOK_INT:
         return ATTR_int;
      case TOK_NULL:
         return ATTR_null;
      case TOK_STRING:
         return ATTR_string;
      case TOK_TYPEID:
         return ATTR_typeid;
      default:
         return 0;
   }
}

void parse_struct(astree* node) {
   symbol* s = new symbol(node,0);
   s->attributes.set(ATTR_struct);
   s->attributes.set(ATTR_typeid);

   // parse for struct fields
   for(unsigned int i = 1; i < node->children.size(); ++i) {
      if(s->fields == nullptr) s->fields = new symbol_table();

      astree* child = node->children[i];
      int type;
      symbol* field;
      const string* ident;

      if(child->symbol == TOK_ARRAY) {
         type = child->children[0]->symbol;
         field = new symbol(child->children[1],0);
         field->attributes.set(ATTR_array);
         ident = child->children[1]->lexinfo;
      } else {
         type = child->symbol;
         field = new symbol(child->children[0],0);
         ident = child->children[0]->lexinfo;
         s->fields->emplace(node->children[i]->lexinfo,
            new symbol(node->children[i],0));
      }

      if(type == TOK_VOID) {
         errprintf("%d:%d:%d: fields may not be of type void\n",
            field->filenr,field->linenr,field->offset);
         error_count++;
      }

      field->attributes.set(yy_to_enum(type));
      field->attributes.set(ATTR_field);
      s->fields->emplace(ident,field);
   }

   try {
      if(symbol_stack[0]->at(node->children[0]->lexinfo)->fields
         == nullptr) {
         symbol_stack[0]->emplace(node->children[0]->lexinfo,s);
      } else {
         errprintf("%d:%d:%d: multiple definition of struct %s\n",
            node->filenr,node->linenr,node->offset,
            node->children[0]->lexinfo->c_str());
         error_count++;
      }
   } catch(const std::out_of_range& oor) {
      symbol_stack[0]->emplace(node->children[0]->lexinfo,s);
   }
}

void create_symbol_table(astree* node) {
   switch(node->symbol) {
      case TOK_ROOT:
         // initialize symbol stack
         symbol_stack.push_back(new symbol_table());
         for(auto child: node->children) create_symbol_table(child);
         return;
      case TOK_STRUCT:
         return parse_struct(node);
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
}
