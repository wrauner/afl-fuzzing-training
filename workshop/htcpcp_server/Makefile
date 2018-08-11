
### name of project used in all labels

PROJECT		= htcpcp_server

###   source files

# use this to select files to compile by names
SRC 		= htcpcp_server.c
# DEPS		= Makefile aql-parser.h aql-lexer.h lvm.h ../_shared_/Makefile_C_shared.mk

# use this to select files to compile by wildcards
# SRC 		= $(wildcard *.c)
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
NR_FUZZERS_ASAN	= 1
NR_FUZZERS_MSAN	= 1
NR_FUZZERS_LAF	= 1
NR_FUZZERS_RB	= 1
NR_FUZZERS_FAST	= 1
NR_FUZZERS_DRILL= 1

############################################################################

# flags specific for this executable

CFLAGS_LOCAL = 
LFLAGS_LOCAL = -lpthread

############################################################################

# whole shared content of Makefile from _shared_ directory

include ../_shared_/Makefile_C_shared.mk

############################################################################

# use this section to overwrite default settings from shared Makefile

AFL_DICT_PATH 	= $(TOOLS_DIR)/afl-2.52b/dictionaries/http.dict
init-fuzz:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

fuzz:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

peruvian:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

parallel-init-fuzz:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

parallel-fuzz:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

parallel-kill:
	"This code does not have a afl wrapper, so you need to use AFL_PRELOAD and desock from Preeny to fuzz it!"

