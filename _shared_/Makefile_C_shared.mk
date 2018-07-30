
###   executable names

EXEC 			= test_$(PROJECT).exe
EXEC_ASAN 		= test_$(PROJECT)_asan.exe
EXEC_MSAN 		= test_$(PROJECT)_msan.exe  
EXEC_COV 		= test_$(PROJECT)_cov.exe
EXEC_LAF 		= test_$(PROJECT)_laf.exe
EXEC_PLAIN 		= test_$(PROJECT)_plain.exe
ALL_EXECS		= $(EXEC) $(EXEC_ASAN) $(EXEC_MSAN) $(EXEC_COV) $(EXEC_LAF) $(EXEC_PLAIN)

###   compile objects

OBJ 		= $(SRC:.c=.o)
OBJ_ASAN 	= $(SRC:.c=.o_asan)
OBJ_MSAN 	= $(SRC:.c=.o_msan)
OBJ_COV 	= $(SRC:.c=.o_cov)
OBJ_LAF 	= $(SRC:.c=.o_laf)
OBJ_PLAIN 	= $(SRC:.c=.o_plain)
ALL_OBJS	= $(OBJ) $(OBJ_ASAN) $(OBJ_MSAN) $(OBJ_COV) $(OBJ_LAF) $(OBJ_PLAIN)

###   tools settings

TOOLS_DIR	= /home/root/fuzz/install
# TOOLS_DIR	= ~/Desktop/tools
SHARED_DIR	= ../_shared_

GCC    	 	= afl-gcc
CLANG	 	= afl-clang
CLANG_FAST 	= afl-clang-fast
CLANG_FAST_LAF 	= $(TOOLS_DIR)/afl-llvm-passes/afl-clang-fast
CC_PLAIN	= gcc
CC    	 	= $(CLANG_FAST)

AFL_FUZZ 	= $(TOOLS_DIR)/afl-2.52b/afl-fuzz
AFL_FUZZ_PYTHIA	= $(TOOLS_DIR)/pythia/afl-fuzz
AFL_FUZZ_RB 	= $(TOOLS_DIR)/afl-rb/afl-fuzz
AFL_FUZZ_FAST 	= $(TOOLS_DIR)/aflfast/afl-fuzz
DRILLER		= $(SHARED_DIR)/run_driller.py

AFL_MONITOR 	= $(TOOLS_DIR)/afl-monitor/afl-monitor

CWTRIAGE	= $(TOOLS_DIR)/../../go/bin/cwtriage
CWDUMP		= $(TOOLS_DIR)/../../go/bin/cwdump
EXPLOITABLE	= $(TOOLS_DIR)/exploitable/exploitable/
CWDB_FILE	= crashwalk.db
CWTRIAGE_OUT   	= triage.txt

ANGR_GEN_DICT	= angr_gen.dict
# AFL_DICT_PATH 	= $(TOOLS_DIR)/pythia/dictionaries/sql.dict
AFL_DICT_PATH 	= $(ANGR_GEN_DICT)

CRASHES_DIR 	= crashes_dir

BROWSER 	= firefox

PLOT_DIR     	= _plot_out
DOX_DIR      	= _dox_out
MONITOR_DIR    	= _monitor_out

VISUALIZE_DOT	= result.dot
VISUALIZE_PNG	= result.png

###   lcov settings

LCOV_REPORT_DIR = _lcov_out
LCOV_INFO_FILE 	= coverage.info

############################################################################

RUN_FLAGS=-m none

ifeq ($(AFL), PYTHIA)
	RUN_AFL_FUZZ=$(AFL_FUZZ_PYTHIA)
else ifeq ($(AFL), RB)
	RUN_AFL_FUZZ=$(AFL_FUZZ_RB)
else ifeq ($(AFL), FAST)
	RUN_AFL_FUZZ=$(AFL_FUZZ_FAST)
else
	RUN_AFL_FUZZ=$(AFL_FUZZ)
endif

ifeq ($(EXEC), ASAN)
	RUN_EXEC=$(EXEC_ASAN)
else ifeq ($(EXEC), MSAN)
	RUN_EXEC=$(EXEC_MSAN)
else ifeq ($(EXEC), LAF)
	RUN_EXEC=$(EXEC_LAF)
else
	RUN_EXEC=$(EXEC)
	RUN_FLAGS=
endif

ifneq ($(USE_DICT),)
	AFL_DICT = -x $(AFL_DICT_PATH)
endif

CFLAGS = -Wall -Wno-unused-variable $(CFLAGS_LOCAL)
LFLAGS = $(LFLAGS_LOCAL)

CFLAGS_COV = $(CFLAGS) -fprofile-arcs -ftest-coverage
LFLAGS_COV = $(LFLAGS) -fprofile-arcs

###########################################################################

all:	$(ALL_EXECS)

init-fuzz:	# $(RUN_EXEC)
	$(RUN_AFL_FUZZ) $(RUN_FLAGS) -i $(TESTCASE_DIR) -o $(FINDINGS_DIR) $(AFL_DICT) ./$(RUN_EXEC) @@

fuzz:	# $(RUN_EXEC)
	$(RUN_AFL_FUZZ) $(RUN_FLAGS) -i- -o $(FINDINGS_DIR) $(AFL_DICT) ./$(RUN_EXEC) @@

plot:
	afl-plot $(FINDINGS_DIR) $(PLOT_DIR)
	ln -sf ./$(PLOT_DIR)/index.html afl_plot.html
	$(BROWSER) afl_plot.html

lcov:	
	mkdir -p temp_cov
	find $(FINDINGS_DIR) -name id* -type f -size +1c | grep -i queue | xargs -i cp {} temp_cov/	
	python $(SHARED_DIR)/run_tests.py $(EXEC_COV) temp_cov
	rm -rf temp_cov
	lcov --capture --directory . --output-file $(LCOV_INFO_FILE)
	genhtml $(LCOV_INFO_FILE) --output-directory $(LCOV_REPORT_DIR)
	ln -sf ./$(LCOV_REPORT_DIR)/index.html lcov_doc.html
	$(BROWSER) lcov_doc.html

dox:
	( cat ../_shared_/doxygen_for_C.conf ; echo "PROJECT_NAME=$(PROJECT)" ) | doxygen - 
	ln -sf ./_dox_out/html/index.html dox_doc.html
	$(BROWSER) dox_doc.html

cwtriage:
	mkdir -p $(CRASHES_DIR)
	find $(FINDINGS_DIR) -name id* -type f -size +1c | grep -i crashes | xargs -i cp {} $(CRASHES_DIR)/
	CW_EXPLOITABLE=$(EXPLOITABLE) $(CWTRIAGE) -root $(CRASHES_DIR) ./$(EXEC) @@
	$(CWDUMP) $(CWDB_FILE) > $(CWTRIAGE_OUT)
	$(BROWSER) $(CWTRIAGE_OUT)

monitor:
	mkdir -p $(MONITOR_DIR)
	$(AFL_MONITOR) -c -v -h $(MONITOR_DIR) $(FINDINGS_DIR)
	ln -sf ./$(MONITOR_DIR)/index.html afl-monitor_doc.html
	$(BROWSER) afl-monitor_doc.html

peruvian:	$(RUN_EXEC)
	rm -rf $(CRASHES_DIR)
	mkdir -p $(CRASHES_DIR)
	find $(FINDINGS_DIR)/crashes -name id* -type f -size +1c | xargs -i cp {} $(CRASHES_DIR)/
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master -name id* -type f -size +1c | grep -i crashes | xargs -i cp {} $(CRASHES_DIR)/
	AFL_SKIP_CRASHES=1 $(AFL_FUZZ) -C $(RUN_FLAGS) -i $(CRASHES_DIR) -o $(FINDINGS_DIR)_peruvian $(AFL_DICT) ./$(RUN_EXEC) @@	

visualize:
	python $(SHARED_DIR)/afl_visualize_results.py $(FINDINGS_DIR) $(VISUALIZE_DOT)
	dot -Tpng $(VISUALIZE_DOT) > $(VISUALIZE_PNG)
	$(BROWSER) $(VISUALIZE_PNG)

$(ANGR_GEN_DICT):	$(EXEC_PLAIN)
	python $(SHARED_DIR)/create_dict.py $(EXEC) > $(ANGR_GEN_DICT)

clean:
	rm -f $(ALL_EXECS) $(ALL_OBJS) *.gcno *.gcda $(LCOV_INFO_FILE) 

clean-results:
	rm -f $(ANGR_GEN_DICT) dox_doc.html lcov_doc.html afl_plot.html $(CWTRIAGE_OUT) $(CWDB_FILE) afl-monitor_doc.html .afl-monitor.state $(VISUALIZE_DOT) $(VISUALIZE_PNG)
	rm -rf $(LCOV_REPORT_DIR)
	rm -rf temp_cov
	rm -rf $(MONITOR_DIR)
	rm -rf $(PLOT_DIR)
	rm -rf $(DOX_DIR)
	rm -rf $(CRASHES_DIR)
	rm -rf findings*

clean-all: clean clean-results

############################################################################

###    parallel mode settings

parallel-init-fuzz: #	all $(ANGR_GEN_DICT)
	bash $(SHARED_DIR)/run_parallel_fuzz.sh $(PROJECT) $(TESTCASE_DIR) $(FINDINGS_DIR) \
		master $(AFL_FUZZ_PYTHIA) $(EXEC) 1 \
		slave_std $(AFL_FUZZ) $(EXEC) $(NR_FUZZERS_AFL) \
		slave_asan $(AFL_FUZZ) $(EXEC_ASAN) $(NR_FUZZERS_ASAN) \
		slave_msan $(AFL_FUZZ) $(EXEC_MSAN) $(NR_FUZZERS_MSAN) \
		slave_laf $(AFL_FUZZ) $(EXEC_LAF) $(NR_FUZZERS_LAF) \
		slave_rb $(AFL_FUZZ_RB) $(EXEC) $(NR_FUZZERS_RB) \
		slave_fast $(AFL_FUZZ_FAST) $(EXEC) $(NR_FUZZERS_FAST) \
		slave_qemu $(AFL_FUZZ) $(EXEC_PLAIN) $(NR_FUZZERS_QEMU) \
		slave_driller $(DRILLER) $(EXEC_PLAIN) $(NR_FUZZERS_DRILL) \
		.

parallel-fuzz:	# all $(ANGR_GEN_DICT)
	bash $(SHARED_DIR)/run_parallel_fuzz.sh $(PROJECT) - $(FINDINGS_DIR) \
		master $(AFL_FUZZ_PYTHIA) $(EXEC_PLAIN) 1 \
		slave_std $(AFL_FUZZ) $(EXEC) $(NR_FUZZERS_AFL) \
		slave_asan $(AFL_FUZZ) $(EXEC_ASAN) $(NR_FUZZERS_ASAN) \
		slave_msan $(AFL_FUZZ) $(EXEC_MSAN) $(NR_FUZZERS_MSAN) \
		slave_laf $(AFL_FUZZ) $(EXEC_LAF) $(NR_FUZZERS_LAF) \
		slave_rb $(AFL_FUZZ_RB) $(EXEC) $(NR_FUZZERS_RB) \
		slave_fast $(AFL_FUZZ_FAST) $(EXEC) $(NR_FUZZERS_FAST) \
		slave_qemu $(AFL_FUZZ) $(EXEC_PLAIN) $(NR_FUZZERS_QEMU) \
		slave_driller $(DRILLER) $(EXEC_PLAIN) $(NR_FUZZERS_DRILL) \

		.

parallel-kill:
	bash $(SHARED_DIR)/kill_parallel_fuzz.sh $(PROJECT) \
		master 1 \
		slave_std $(NR_FUZZERS_AFL) \
		slave_asan $(NR_FUZZERS_ASAN) \
		slave_msan $(NR_FUZZERS_MSAN) \
		slave_laf  $(NR_FUZZERS_LAF) \
		slave_rb $(NR_FUZZERS_RB) \
		slave_fast $(NR_FUZZERS_FAST) \
		slave_qemu $(NR_FUZZERS_QEMU) \
		slave_driller $(NR_FUZZERS_DRILL) \
		.

parallel-plot:
	afl-plot $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ $(PLOT_DIR)
	ln -sf ./$(PLOT_DIR)/index.html afl_plot.html
	$(BROWSER) afl_plot.html

parallel-visualize:
	python $(SHARED_DIR)/afl_visualize_results.py $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master $(VISUALIZE_DOT)
	dot -Tpng $(VISUALIZE_DOT) > $(VISUALIZE_PNG)
	$(BROWSER) $(VISUALIZE_PNG)

screen:
	screen -r afl_$(PROJECT)_master

screen-asan:
	screen -r afl_$(PROJECT)_slave_asan-1

screen-msan:
	screen -r afl_$(PROJECT)_slave_msan-1

screen-laf:
	screen -r afl_$(PROJECT)_slave_laf-1

screen-fast:
	screen -r afl_$(PROJECT)_slave_fast-1

screen-rb:
	screen -r afl_$(PROJECT)_slave_rb-1

screen-driller:
	screen -r afl_$(PROJECT)_slave_driller-1

screen-qemu:
	screen -r afl_$(PROJECT)_slave_qemu-1

import-stats:
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep std | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep asan | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep msan | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep laf | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep rb | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep fast | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep driller | wc --lines
	find $(FINDINGS_DIR)/fuzzer_$(PROJECT)_master/ -name *sync* | grep qemu | wc --lines

############################################################################


%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS) -DAFL_PERSISTENT_MODE

$(EXEC): $(OBJ) 
	$(CC) -o $@ $^ $(LFLAGS)

%.o_asan: %.c $(DEPS)
	AFL_USE_ASAN=1 $(GCC) -c -o $@ $< $(CFLAGS)

$(EXEC_ASAN): $(OBJ_ASAN)
	AFL_USE_ASAN=1 $(GCC) -o $@ $^ $(LFLAGS)

%.o_msan: %.c $(DEPS)
	AFL_USE_MSAN=1 $(CLANG) -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -c -o $@ $< $(CFLAGS)

$(EXEC_MSAN): $(OBJ_MSAN)
	AFL_USE_MSAN=1 $(CLANG) -o $@ $^ $(LFLAGS)

%.o_cov: %.c $(DEPS)
	$(GCC) -c -o $@ $< $(CFLAGS_COV)

$(EXEC_COV): $(OBJ_COV)
	$(GCC) -o $@ $^ $(LFLAGS_COV)

%.o_laf: %.c $(DEPS) 
	LAF_SPLIT_SWITCHES=1 LAF_TRANSFORM_COMPARES=1 LAF_SPLIT_COMPARES=1 $(CLANG_FAST_LAF) -c -o $@ $< $(CFLAGS) -DAFL_PERSISTENT_MODE

$(EXEC_LAF): $(OBJ_LAF) 
	LAF_SPLIT_SWITCHES=1 LAF_TRANSFORM_COMPARES=1 LAF_SPLIT_COMPARES=1 $(CLANG_FAST_LAF) -o $@ $^ $(LFLAGS) 

%.o_plain: %.c $(DEPS)
	$(CC_PLAIN) -c -o $@ $< $(CFLAGS) -DINPUT_STDIN 

$(EXEC_PLAIN): $(OBJ_PLAIN) 
	$(CC_PLAIN) -o $@ $^ $(LFLAGS)

