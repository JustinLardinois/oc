// Justin Lardinois jlardino@ucsc.edu
// astree.cpp - implementation file for astree.h

#include <assert.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "astree.h"
#include "stringset.h"
#include "lyutils.h"
#include "yyparse.h"

astree::astree (int symbol, int filenr, int linenr,
                int offset, const char* clexinfo):
        symbol (symbol), filenr (filenr), linenr (linenr),
        offset (offset), lexinfo (intern_stringset (clexinfo)),
        struct_name (nullptr) {
   DEBUGF ('f', "astree %p->{%d:%d.%d: %s: \"%s\"}\n",
           (void*) this, filenr, linenr, offset,
           get_yytname (symbol), lexinfo->c_str());
}

astree* adopt1 (astree* root, astree* child) {
   root->children.push_back (child);
   DEBUGF ('a', "%p (%s) adopting %p (%s)\n",
           root, root->lexinfo->c_str(),
           child, child->lexinfo->c_str());
   return root;
}

astree* adopt2 (astree* root, astree* left, astree* right) {
   adopt1 (root, left);
   adopt1 (root, right);
   return root;
}

astree* adopt1sym (astree* root, astree* child, int symbol) {
   root = adopt1 (root, child);
   root->symbol = symbol;
   return root;
}

astree* adoptf(astree* identdecl , astree* params , astree* block) {
   astree* root;
   if(block->lexinfo->c_str()[0] == ';') {
      free_ast(block);
      root =  new astree(TOK_PROTOTYPE,identdecl->filenr,
         identdecl->linenr,identdecl->offset,"");
      adopt2(root,identdecl,params);
   }else {
      root = new astree(TOK_FUNCTION,identdecl->filenr,
         identdecl->linenr,identdecl->offset,"");
      adopt2(root,identdecl,params);
      adopt1(root,block);
   }
   return root;
}


static void dump_node (FILE* outfile, astree* node) {
   const char *tname = get_yytname (node->symbol);
   if (strstr (tname, "TOK_") == tname) tname += 4;
   fprintf(outfile,"%s \"%s\" (%zu.%zu.%zu) {%zu}%s",tname,
      node->lexinfo->c_str(),node->filenr,node->linenr,node->offset,
      node->blocknr,
      stringify_attributes(node->attributes,node->struct_name).c_str());
   if(node->symbol == TOK_IDENT) {
      fprintf(outfile," (%zu.%zu.%zu)",node->dfilenr,node->dlinenr,
         node->doffset);
   }
}

static void dump_astree_rec (FILE* outfile, astree* root,
                             int depth) {
   if (root == NULL) return;
   const char* indent = "|  ";
   for(int i = 0; i < depth; i++) fprintf(outfile,indent);
   dump_node (outfile, root);
   fprintf (outfile, "\n");
   for (size_t child = 0; child < root->children.size();
        ++child) {
      dump_astree_rec (outfile, root->children[child],
                       depth + 1);
   }
}

void dump_astree (FILE* outfile, astree* root) {
   dump_astree_rec (outfile, root, 0);
   fflush (NULL);
}

void yyprint (FILE* outfile, unsigned short toknum,
              astree* yyvaluep) {
   if (is_defined_token (toknum)) {
      dump_node (outfile, yyvaluep);
   }else {
      fprintf (outfile, "%s(%d)\n",
               get_yytname (toknum), toknum);
   }
   fflush (NULL);
}


void free_ast (astree* root) {
   while (not root->children.empty()) {
      astree* child = root->children.back();
      root->children.pop_back();
      free_ast (child);
   }
   DEBUGF ('f', "free [%p]-> %d:%d.%d: %s: \"%s\")\n",
           root, root->filenr, root->linenr, root->offset,
           get_yytname (root->symbol), root->lexinfo->c_str());
   delete root;
}

void free_ast2 (astree* tree1, astree* tree2) {
   free_ast (tree1);
   free_ast (tree2);
}

string stringify_enum(int attr, const string* struct_name) {
   switch(attr) {
      case ATTR_void:
         return "void";
      case ATTR_bool:
         return "bool";
      case ATTR_char:
         return "char";
      case ATTR_int:
         return "int";
      case ATTR_null:
         return "null";
      case ATTR_string:
         return "string";
      case ATTR_struct:
         return "struct \"" + *struct_name + "\"";
      case ATTR_array:
         return "array";
      case ATTR_function:
         return "function";
      case ATTR_prototype:
         return "prototype";
      case ATTR_variable:
         return "variable";
      case ATTR_field:
         return "field";
      case ATTR_typeid:
         return "typeid";
      case ATTR_param:
         return "param";
      case ATTR_lval:
         return "lval";
      case ATTR_const:
         return "const";
      case ATTR_vreg:
         return "vreg";
      case ATTR_vaddr:
         return "vaddr";
   }
   return ""; // shut up g++
}

string stringify_attributes(const attr_bitset& attributes,
   const string* struct_name) {

   string a = "";

   for(int i = 0; i < ATTR_bitset_size; ++i) {
      if(attributes[i]) a += " " + stringify_enum(i,struct_name);
   }

   return a;
}

RCSC("$Id: astree.cpp,v 1.6 2015-04-09 19:31:47-07 - - $")

