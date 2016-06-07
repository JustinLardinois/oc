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
   attr_bitset* attributes;
   symbol_table* fields;
   size_t filenr, linenr, offset;
   size_t blocknr;
   std::vector<const string*>* parameter_names;
   std::vector<symbol*>* parameters;
   const string* struct_name;
   symbol(astree* node , size_t blocknr);
   ~symbol();
};

extern int error_count;

void create_symbol_table(astree* node);

void dump_symbol_table(FILE* outfile);

void free_symbol_table();

#endif
