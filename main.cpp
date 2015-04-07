// Justin Lardinois jlardino@ucsc.edu
// main.cpp - main program for oc
// based on cppstrtok-code/cppstrtok.cpp and stringset-code-cpp/main.cpp

#include <fstream>
#include <string>
using namespace std;

#include <errno.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

#include "auxlib.h"
#include "stringset.h"

const string CPP = "/usr/bin/cpp";
const size_t LINESIZE = 1024;

struct {
   int yy_flex_debug = 0;
   int yydebug = 0;
   string debug_flags = "";
   string cpp_arg = "";
} options;

// Chomp the last character from a buffer if it is delim.
void chomp (char* string, char delim) {
   size_t len = strlen (string);
   if (len == 0) return;
   char* nlpos = string + len - 1;
   if (*nlpos == delim) *nlpos = '\0';
}

// Run cpp against the lines of the file.
void cpplines (FILE* pipe) {
   int linenr = 1;
   for (;;) {
      char buffer[LINESIZE];
      char* fgets_rc = fgets (buffer, LINESIZE, pipe);
      if (fgets_rc == NULL) break;
      chomp (buffer, '\n');
      char* savepos = NULL;
      char* bufptr = buffer;
      for (int tokenct = 1;; ++tokenct) {
         char* token = strtok_r (bufptr, " \t\n", &savepos);
         bufptr = NULL;
         if (token == NULL) break;
         intern_stringset(token);
      }
      ++linenr;
   }
}

void die(int exit_status) {
   set_exitstatus(exit_status);
   exit(get_exitstatus());
}

void usage() {
   fprintf(stderr,"Usage: %s [-ly] [-D string] program.oc",
      get_execname());
   die(EXIT_FAILURE);
}

char* parse_args(int argc, char** argv) {
   const char* optstring = ":ly@::D:";
   opterr = 0;
   char c;
   while((c = getopt(argc,argv,optstring)) != -1) {
      switch(c) {
         case 'l':
            options.yy_flex_debug = 1;
            continue;
         case 'y':
            options.yydebug = 1;
            continue;
         case '@':
            if(optarg) options.debug_flags = optarg;
            continue;
         case 'D':
            options.cpp_arg = optarg;
            continue;
         case ':':
            eprintf("missing argument for option %c",optopt);
            die(EXIT_FAILURE);
         case '?':
            eprintf("unrecognized option %c",optopt);
            die(EXIT_FAILURE);
      } 
   }
   if(optind + 1 == argc) {
      return argv[optind]; // input program name
   }
   else usage();
   return NULL; // unreachable; shut up g++
}

int main (int argc, char** argv) {
   set_execname (argv[0]);
   char* program_name = parse_args(argc,argv);
   const string input_name = program_name;
   program_name = basename(program_name);
   char* dot = strrchr(program_name,'.');
   if(dot == NULL || strcmp(dot,".oc")) usage();
   dot = '\0'; // chop off filename extension
   const string str_file = string(program_name) + ".str";

   string command;
   if(options.cpp_arg == "") command = CPP + " " + input_name;
   else command = CPP + " -D " + options.cpp_arg + " " + input_name;

   FILE* pipe = popen (command.c_str(), "r");
   if (pipe == NULL) {
      syserrprintf (command.c_str());
   }else {
      cpplines (pipe);
      int pclose_rc = pclose (pipe);
      eprint_status (command.c_str(), pclose_rc);
   }

   ofstream ss_dump;
   ss_dump.open(str_file,ofstream::out);
   dump_stringset(ss_dump);
   ss_dump.close();

   return get_exitstatus();
}

