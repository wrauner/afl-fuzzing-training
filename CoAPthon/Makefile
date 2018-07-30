
PROJECT		= CoAPthon

###   tools settings

TOOLS_DIR	= /home/root/fuzz/install

PY_AFL_FUZZ	= py-afl-fuzz
AFL_MONITOR 	= $(TOOLS_DIR)/afl-monitor/afl-monitor
AFL_DICT_PATH 	= $(TOOLS_DIR)/pythia/dictionaries/sql.dict

TESTCASE_DIR 	= testcase_dir_000
FINDINGS_DIR 	= findings_dir_000

CRASHES_DIR 	= crashes_dir
PLOT_DIR     	= _plot_out
MONITOR_DIR    	= _monitor_out

BROWSER 	= firefox

############################################################################

ifneq ($(USE_DICT),)
	AFL_DICT = -x $(AFL_DICT_PATH)
endif

############################################################################

init-fuzz:	
	$(PY_AFL_FUZZ) -i $(TESTCASE_DIR) -o $(FINDINGS_DIR) -T $(PROJECT) $(AFL_DICT) -m none python fuzz_deserialize.py @@

fuzz:	
	$(PY_AFL_FUZZ) -i - -o $(FINDINGS_DIR) -T $(PROJECT) $(AFL_DICT) -m none python fuzz_deserialize.py @@	

plot:
	afl-plot $(FINDINGS_DIR) $(PLOT_DIR)
	ln -sf ./$(PLOT_DIR)/index.html afl_plot.html
	$(BROWSER) afl_plot.html

peruvian:
	mkdir -p $(CRASHES_DIR)
	find $(FINDINGS_DIR) -name id* -type f | grep -i crashes | xargs -i cp {} $(CRASHES_DIR)/
	py-afl-fuzz -C -i $(CRASHES_DIR) -o $(FINDINGS_DIR)_peruvian -T $(PROJECT) $(AFL_DICT) -m none python fuzz_deserialize.py @@

clean:
	rm -f afl-monitor_doc.html afl_plot.html
	rm -rf $(MONITOR_DIR)
	rm -rf $(PLOT_DIR)

clean-results:
	rm -rf findings*


