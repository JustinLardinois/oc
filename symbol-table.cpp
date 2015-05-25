// Justin Lardinois jlardino@ucsc.edu
// symbol-table.cpp - implementation file for symbol-table.h

#include "symbol-table.h"

// declared extern in header
std::vector<symbol_table*> symbol_stack;

int next_block = 1;
