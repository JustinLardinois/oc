// Justin Lardinois jlardino@ucsc.edu
// symbol-table.h - definitions for symbol table ADT

#ifndef __SYMBOL_TABLE_H__
#define __SYMBOL_TABLE_H__

#include <string>
#include <unordered_map>
#include <vector>

#include "astree.h"

struct symbol;
using symbol_table = std::unordered_map<const std::string*,symbol*>;
using symbol_entry = symbol_table::value_type;

struct symbol {
   attr_bitset& attributes;
   symbol_table* fields;
   size_t filenr, linenr, offset;
   size_t blocknr;
   std::vector<symbol*>* parameters;
   const string* struct_name;
   symbol(astree* node , size_t blocknr) :
      attributes(node->attributes), fields(nullptr) ,
      filenr(node->filenr) , linenr(node->linenr) ,
      offset(node->offset) , blocknr(blocknr) , parameters(nullptr) ,
      struct_name(nullptr) {}
};

extern int error_count;

void create_symbol_table(astree* node);

#endif
