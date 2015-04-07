// Justin Lardinois jlardino@ucsc.edu
// main.cpp - main program for oc
// based on cppstrtok-code/cppstrtok.cpp and stringset-code-cpp/main.cpp

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
void cpplines (FILE* pipe, char* filename) {
   int linenr = 1;
   char inputname[LINESIZE];
   strcpy (inputname, filename);
   for (;;) {
      char buffer[LINESIZE];
      char* fgets_rc = fgets (buffer, LINESIZE, pipe);
      if (fgets_rc == NULL) break;
      chomp (buffer, '\n');
      printf ("%s:line %d: [%s]\n", filename, linenr, buffer);
      // http://gcc.gnu.org/onlinedocs/cpp/Preprocessor-Output.html
      int sscanf_rc = sscanf (buffer, "# %d \"%[^\"]\"",
                              &linenr, filename);
      if (sscanf_rc == 2) {
         printf ("DIRECTIVE: line %d file \"%s\"\n", linenr, filename);
         continue;
      }
      char* savepos = NULL;
      char* bufptr = buffer;
      for (int tokenct = 1;; ++tokenct) {
         char* token = strtok_r (bufptr, " \t\n", &savepos);
         bufptr = NULL;
         if (token == NULL) break;
         printf ("token %d.%d: [%s]\n",
                 linenr, tokenct, token);
      }
      ++linenr;
   }
}

void die(int exit_status) {
   set_exitstatus(exit_status);
   exit(get_exitstatus());
}

void usage() {
   fprintf(stderr,"Usage: %s [-ly] [-D string] program.oc",get_execname());
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
}

int main (int argc, char** argv) {
   set_execname (argv[0]);
   char* input_name = basename(parse_args(argc,argv));
   char* dot = strrchr(input_name,'.');
   if(dot == NULL || strcmp(dot,".oc")) usage();
   dot = '\0'; // chop off filename extension
   string str_file = string(input_name) + ".str";

   for (int argi = 1; argi < argc; ++argi) {
      char* filename = argv[argi];
      string command = CPP + " " + filename;
      printf ("command=\"%s\"\n", command.c_str());
      FILE* pipe = popen (command.c_str(), "r");
      if (pipe == NULL) {
         syserrprintf (command.c_str());
      }else {
         cpplines (pipe, filename);
         int pclose_rc = pclose (pipe);
         eprint_status (command.c_str(), pclose_rc);
      }
   }
   return get_exitstatus();
}

