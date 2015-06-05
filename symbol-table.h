// Justin Lardinois jlardino@ucsc.edu
// symbol-table.h - definitions for symbol table ADT

#include <bitset>
#include <string>
#include <unordered_map>
#include <vector>

#include "astree.h"

enum { ATTR_void, ATTR_bool, ATTR_char, ATTR_int, ATTR_null,
       ATTR_string, ATTR_struct, ATTR_array, ATTR_function,
       ATTR_prototype,
       ATTR_variable, ATTR_field, ATTR_typeid, ATTR_param,
       ATTR_lval, ATTR_const, ATTR_vreg, ATTR_vaddr,
       ATTR_bitset_size,
};
using attr_bitset = std::bitset<ATTR_bitset_size>;

struct symbol;
using symbol_table = std::unordered_map<const std::string*,symbol*>;
using symbol_entry = symbol_table::value_type;

struct symbol {
   attr_bitset attributes;
   symbol_table* fields;
   size_t filenr, linenr, offset;
   size_t blocknr;
   std::vector<symbol*>* parameters;
   symbol(astree* node , size_t blocknr) :
      fields(nullptr) , filenr(node->filenr) , linenr(node->linenr) ,
      offset(node->offset) , blocknr(blocknr) , parameters(nullptr) {}
};

extern int error_count;

void create_symbol_table(astree* node);
