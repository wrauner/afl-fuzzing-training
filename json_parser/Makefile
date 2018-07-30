
### name of project used in all labels

PROJECT		= json_parser

###   source files

# use this to select files to compile by names
# SRC 		= aql-parser.c aql-lexer.c lvm.c test_aql.c
# DEPS		= Makefile aql-parser.h aql-lexer.h lvm.h ../_shared_/Makefile_C_shared.mk

# use this to select files to compile by wildcards
SRC 		= $(wildcard *.c)
DEPS		= Makefile $(wildcard *.h) ../_shared_/Makefile_C_shared.mk

############################################################################

# input / output directories

TESTCASE_DIR 	= testcase_dir_000
FINDINGS_DIR 	= findings_dir_000

############################################################################

###    parallel mode settings

# nr of different fuzzers
# master is pythia by default

NR_FUZZERS_AFL 	= 0
NR_FUZZERS_ASAN	= 0
NR_FUZZERS_MSAN	= 0
NR_FUZZERS_LAF	= 0
NR_FUZZERS_RB	= 0
NR_FUZZERS_FAST	= 0
NR_FUZZERS_DRILL= 1
NR_FUZZERS_QEMU = 1

############################################################################

# flags specific for this executable

CFLAGS_LOCAL = 
LFLAGS_LOCAL = 

############################################################################

# whole shared content of Makefile from _shared_ directory

include ../_shared_/Makefile_C_shared.mk

############################################################################

# use this section to overwrite default settings from shared Makefile

AFL_DICT_PATH 	= $(TOOLS_DIR)/afl-2.52b/dictionaries/json.dict
