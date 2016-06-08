// Justin Lardinois jlardinois@ucsc.edu
// oil-generator.h - oil code generator for oc compiler

#ifndef __OIL_GENERATOR_H__
#define __OIL_GENERATOR_H__

#include <cstdio>

#include "astree.h"

void generate_oil(astree* root, FILE* outfile);

#endif
