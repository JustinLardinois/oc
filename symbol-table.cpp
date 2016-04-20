// Justin Lardinois jlardino@ucsc.edu
// symbol-table.cpp - implementation file for symbol-table.h

#include "yyparse.h"

#include "symbol-table.h"

std::vector<symbol_table*> symbol_stack;
symbol_table struct_table;

// to be referenced during block traversal
symbol* current_function = nullptr;

int error_count = 0;

int next_block = 1;

int current_block = -1;

symbol* parse_expression(astree* node);

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

// kinda turned into a mess because reference types can be null
bool compatible_types(symbol* x , symbol* y){
   return
      x->attributes[ATTR_void] == y->attributes[ATTR_void] &&
      x->attributes[ATTR_bool] == y->attributes[ATTR_bool] &&
      x->attributes[ATTR_char] == y->attributes[ATTR_char] &&
      x->attributes[ATTR_int]  == y->attributes[ATTR_int]  &&
      x->attributes[ATTR_array] == y->attributes[ATTR_array] &&
      (x->attributes[ATTR_string] == y->attributes[ATTR_string] ||
      (x->attributes[ATTR_string] && y->attributes[ATTR_null]) ||
      (x->attributes[ATTR_null] && y->attributes[ATTR_null]) ||
      (x->attributes[ATTR_null] && y->attributes[ATTR_null])) &&
      (x->attributes[ATTR_typeid] == y->attributes[ATTR_typeid] ||
      (x->attributes[ATTR_typeid] && y->attributes[ATTR_null]) ||
      (x->attributes[ATTR_null] && y->attributes[ATTR_typeid]) ||
      (x->attributes[ATTR_null] && y->attributes[ATTR_null]));
}

void parse_struct(astree* node) {
   symbol* s = new symbol(node,0);
   s->attributes.set(ATTR_struct);
   s->attributes.set(ATTR_typeid);

   const string* struct_name = node->children[0]->lexinfo;

   // loop over fields
   for(unsigned int i = 1; i < node->children.size(); ++i) {
      if(s->fields == nullptr) s->fields = new symbol_table();

      astree* child = node->children[i];
      int token_code;
      symbol* field;
      const string* ident;

      if(child->symbol == TOK_ARRAY) {
         token_code = child->children[0]->symbol;
         field = new symbol(child->children[1],0);
         field->attributes.set(ATTR_array);
         ident = child->children[1]->lexinfo;
      } else {
         token_code = child->symbol;
         field = new symbol(child->children[0],0);
         ident = child->children[0]->lexinfo;
      }

      if(token_code == TOK_VOID) {
         errprintf("%d:%d:%d: struct fields may not be of type void\n",
            field->filenr,field->linenr,field->offset);
         error_count++;
      }

      field->attributes.set(yy_to_enum(token_code));
      field->attributes.set(ATTR_field);

      if(s->fields->count(ident)) {
         errprintf("%d:%d:%d: multiple fields named %s in struct %s\n",
            field->filenr,field->linenr,field->offset,ident,
            struct_name);
         error_count++;
      } else {
         s->fields->emplace(ident,field);
      }
   }

   if(struct_table.count(struct_name)) {
   // if this struct type has already been declared
      if(struct_table[struct_name]->fields == nullptr) {
      // if this struct type has been declared but not defined
         struct_table[struct_name] = s;
      } else { // if this struct has already been defined
         errprintf("%d:%d:%d: multiple definition of struct %s\n",
            node->filenr,node->linenr,node->offset,
            struct_name->c_str());
         error_count++;
      }
   } else { // if this struct type is not yet declared
      struct_table[struct_name] = s;
   }
}

// returns true if the two symbols have equivalent parameters
bool matching_parameters(symbol* x , symbol* y) {
   if(x->parameters == nullptr && y->parameters == nullptr) {
      return true;
   } else if(!(x->parameters != nullptr && y->parameters != nullptr)) {
      return false;
   } else if(x->parameters->size() != y->parameters->size()) {
      return false;
   } else {
      for(unsigned int i = 0; i < x->parameters->size(); i++) {
         attr_bitset xattrs = x->parameters->operator[](i)->attributes;
         attr_bitset yattrs = y->parameters->operator[](i)->attributes;
         if(!(xattrs[ATTR_void] == yattrs[ATTR_void] &&
              xattrs[ATTR_bool] == yattrs[ATTR_bool] &&
              xattrs[ATTR_char] == yattrs[ATTR_char] &&
              xattrs[ATTR_int] == yattrs[ATTR_int] &&
              xattrs[ATTR_string] == yattrs[ATTR_string] &&
              xattrs[ATTR_array] == yattrs[ATTR_array] &&
              xattrs[ATTR_typeid] == yattrs[ATTR_typeid])) {
            return false;
         }
      }
   }
   return true;
}

void parse_block(astree* node) {
   int this_blocknr = current_block;
   for(auto statement: node->children) {
      create_symbol_table(statement);
      current_block = this_blocknr;
   }
}

void parse_function(astree* node) {
   symbol* s = new symbol(node,0);
   int return_type;
   const string* function_name;

   // sort out return_type and function_name
   if(node->children[0]->symbol == TOK_ARRAY) {
      return_type = node->children[0]->children[0]->symbol;
      function_name = node->children[0]->children[1]->lexinfo;
      s->attributes.set(ATTR_array);
   } else {
      return_type = node->children[0]->symbol;
      function_name = node->children[0]->children[0]->lexinfo;
   }

   s->attributes.set(yy_to_enum(return_type));

   // block to be potentially populated with
   symbol_table* block = nullptr;

   // process parameter list
   vector<astree*>& params = node->children[1]->children;
   if(params.size()) {
      s->parameters = new vector<symbol*>();
      current_block = next_block;
      next_block++;
      block = new symbol_table();

      for(unsigned int i = 0; i < params.size(); ++i) {
         symbol* p = new symbol(params[i],current_block);
         p->attributes.set(ATTR_param);
         p->attributes.set(ATTR_variable);
         p->attributes.set(ATTR_lval);
         int param_type;
         const string* param_name;

         if(params[i]->symbol == TOK_ARRAY) {
            param_type = params[i]->children[0]->symbol;
            param_name = params[i]->children[1]->lexinfo;
            p->attributes.set(ATTR_array);
         } else {
            param_type = params[i]->symbol;
            param_name = params[i]->children[0]->lexinfo;
         }

         if(param_type == TOK_VOID) {
            errprintf("%d:%d:%d: function parameters may not be of "
               "type void\n",p->filenr,p->linenr,p->offset);
            error_count++;
         }

         p->attributes.set(yy_to_enum(param_type));
         s->parameters->push_back(p);
         block->emplace(param_name,p);
      }
   }

   if(symbol_stack[0]->count(function_name)){
   // if function already declared
      symbol* declaration = symbol_stack[0]->operator[](function_name);
      if(declaration->attributes[ATTR_function]) {
      // if function already defined
         errprintf("%d:%d:%d: multiple definition of function %s\n",
            node->filenr,node->linenr,node->offset,
            function_name->c_str());
         error_count++;
         return;
      } else { // if function declared but not defined
         if(matching_parameters(declaration,s)) {
            symbol_stack[0]->operator[](function_name) = s;
         } else {
            errprintf("%d:%d:%d: declaration of function %s "
               "incompatible with previous declaration\n",
               node->filenr,node->linenr,node->offset,
               function_name->c_str());
            error_count++;
            return;
         }
      }
   } else symbol_stack[0]->emplace(function_name,s);

   // handle function body if necessary
   if(node->symbol == TOK_PROTOTYPE) {
      s->attributes.set(ATTR_prototype);
   } else {
      s->attributes.set(ATTR_function);
      if(block == nullptr) {
         block = new symbol_table();
         current_block = next_block;
         next_block++;
      }
      symbol_stack.push_back(block);
      current_function = s;
      parse_block(node->children[2]);
      current_function = nullptr;
      symbol_stack.pop_back();
   }
}

void parse_vardecl(astree* node) {
   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_variable);
   s->attributes.set(ATTR_lval);
   int var_type;
   const string* var_name;

   if(node->children[0]->symbol == TOK_ARRAY) {
      var_type = node->children[0]->children[0]->symbol;
      var_name = node->children[0]->children[1]->lexinfo;
      s->attributes.set(ATTR_array);
   } else {
      var_type = node->children[0]->symbol;
      var_name = node->children[0]->children[0]->lexinfo;
   }

   s->attributes.set(yy_to_enum(var_type));

   bool emplace = true;

   if(symbol_stack.back()->count(var_name)) {
      errprintf("%d:%d:%d: variable %s already defined in current "
         "scope\n",s->filenr,s->linenr,s->offset,var_name->c_str());
      error_count++;
      emplace = false;
   }

   // at some point need to check if struct types are the same
   symbol* expr = parse_expression(node->children[1]);
   if(!compatible_types(s,expr)) {
      errprintf("%d:%d:%d: value of incompatible type assigned in "
         "declaration of variable %s\n",s->filenr,s->linenr,s->offset,
         var_name->c_str());
      error_count++;
   }

   if(emplace) {
      symbol_stack.back()->emplace(var_name,s);
   }
}

void parse_while(astree* node) {
   symbol* condition = parse_expression(node->children[0]);
   create_symbol_table(node->children[1]);
}

void parse_if(astree* node) {
   symbol* condition = parse_expression(node->children[0]);
   create_symbol_table(node->children[1]);
   if(node->symbol == TOK_IFELSE) {
      create_symbol_table(node->children[2]);
   }
}

symbol* parse_assignment(astree* node) {
   symbol* left = parse_expression(node->children[0]);
   symbol* right = parse_expression(node->children[1]);

   symbol* s = new symbol(node,current_block);
   s->attributes = left->attributes;
   s->attributes.reset(ATTR_lval);
   if(right->attributes[ATTR_vreg]) s->attributes.set(ATTR_vreg);
   else s->attributes.set(ATTR_vaddr);

   if(!left->attributes[ATTR_lval]) {
      errprintf("%d:%d:%d: attempt to assign value to non-variable "
         "expression\n",node->filenr,node->linenr,node->offset);
      error_count++;
   }

   // at some point need to check if struct types are the same
   if(!compatible_types(left,right)) {
      errprintf("%d:%d:%d: attempt to assign value to variable of "
         " disparate type\n",node->filenr,node->linenr,node->offset);
      error_count++;
   }

   return s;
}

symbol* parse_eq(astree* node) {
   symbol* left = parse_expression(node->children[0]);
   symbol* right = parse_expression(node->children[1]);

   if(!compatible_types(left,right)) {
      errprintf("%d:%d:%d: comparison of disparate types\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_bool);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_cmp(astree* node) {
   symbol* left = parse_expression(node->children[0]);
   symbol* right = parse_expression(node->children[1]);

   if(!left->attributes[ATTR_int] || !right->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: comparison of disparate types\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_bool);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_math(astree* node) {
   symbol* left = parse_expression(node->children[0]);
   symbol* right = parse_expression(node->children[1]);

   if(!left->attributes[ATTR_int] || !right->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: arithmetic operands must be integers\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_int);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_sign(astree* node) {
   symbol* op = parse_expression(node->children[0]);

   if(!op->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: sign applied to non-integer expression\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_int);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_bang(astree* node) {
   symbol* op = parse_expression(node->children[0]);

   if(!op->attributes[ATTR_bool]) {
      errprintf("%d:%d:%d: logical negation of non-boolean "
         "expression\n",node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_bool);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_ord(astree* node) {
   symbol* op = parse_expression(node->children[0]);

   if(!op->attributes[ATTR_char]) {
      errprintf("%d:%d:%d: ord operator applied to non-character "
         "expression\n",node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_int);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_chr(astree* node) {
   symbol* op = parse_expression(node->children[0]);

   if(!op->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: chr operator applied to non-integer "
         "expression\n",node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_char);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_new_struct(astree* node) {
   const string* struct_name = node->children[0]->lexinfo;

   if(struct_table.count(struct_name)) {
      if(struct_table[struct_name]->fields == nullptr) {
         errprintf("%d:%d:%d: instantiation of incomplete struct type"
            " %s\n", node->filenr,node->linenr,node->offset,
            struct_name->c_str());
         error_count++;
      }
   } else {
      errprintf("%d:%d:%d: struct type %s is undefined\n",
         node->filenr,node->linenr,node->offset,struct_name->c_str());
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_typeid);
   s->attributes.set(ATTR_vreg);
   s->attributes.set(ATTR_struct);
   return s;
}

symbol* parse_new_string(astree* node) {
   symbol* length = parse_expression(node->children[0]);

   if(!length->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: string length must be of type int\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(ATTR_string);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_new_array(astree* node) {
   int type = node->children[0]->symbol;
   if(type == TOK_TYPEID) {
      const string* struct_name = node->children[0]->lexinfo;
      if(!struct_table.count(struct_name)) {
         errprintf("%d:%d:%d: instantiation of array of unknown type "
            "%s\n",node->filenr,node->linenr,node->offset,struct_name);
         error_count++;
      }
   }

   symbol* length = parse_expression(node->children[1]);

   if(!length->attributes[ATTR_int]) {
      errprintf("%d:%d:%d: array length must be of type int\n",
         node->filenr,node->linenr,node->offset);
      error_count++;
   }

   symbol* s = new symbol(node,current_block);
   s->attributes.set(yy_to_enum(type));
   s->attributes.set(ATTR_array);
   s->attributes.set(ATTR_vreg);
   return s;
}

symbol* parse_expression(astree* node) {
   switch(node->symbol) {
      case '=':
         return parse_assignment(node);
      case TOK_EQ:
      case TOK_NE:
         return parse_eq(node);
      case TOK_LT:
      case TOK_LE:
      case TOK_GT:
      case TOK_GE:
         return parse_cmp(node);
      case '+':
      case '-':
      case '*':
      case '/':
      case '%':
         return parse_math(node);
      case TOK_POS:
      case TOK_NEG:
         return parse_sign(node);
      case '!':
         return parse_bang(node);
      case TOK_ORD:
         return parse_ord(node);
      case TOK_CHR:
         return parse_chr(node);
      case TOK_NEW:
         return parse_new_struct(node);
      case TOK_NEWSTRING:
         return parse_new_string(node);
      case TOK_NEWARRAY:
         return parse_new_array(node);
      case TOK_CALL:
      case TOK_IDENT:
      case TOK_INDEX:
      case TOK_FIELD:
      case TOK_INTCON:
      case TOK_CHARCON:
      case TOK_STRINGCON:
      case TOK_FALSE:
      case TOK_TRUE:
      case TOK_NULL:
         break;
   }
   return nullptr;
}

void create_symbol_table(astree* node) {
   switch(node->symbol) {
      case TOK_ROOT:
         // initialize symbol stack
         symbol_stack.push_back(new symbol_table());
         for(auto child: node->children) create_symbol_table(child);
         symbol_stack.pop_back();
         return;
      case TOK_STRUCT:
         return parse_struct(node);
      case TOK_FUNCTION:
      case TOK_PROTOTYPE:
         return parse_function(node);
      case TOK_BLOCK:
         symbol_stack.push_back(new symbol_table());
         current_block = next_block;
         next_block++;
         parse_block(node);
         symbol_stack.pop_back();
         return;
      case TOK_VARDECL:
         return parse_vardecl(node);
      case TOK_WHILE:
         return parse_while(node);
      case TOK_IF:
      case TOK_IFELSE:
         return parse_if(node);
      case TOK_RETURN:
      case TOK_RETURNVOID:
         return;
      default:
         parse_expression(node);
         return;
   }
}
