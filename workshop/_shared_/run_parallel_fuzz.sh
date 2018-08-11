#!/bin/bash

###  PARAMS

if [ $# -lt  7 ]; 
    then echo "illegal number of parameters : $0 project_name test_dir (or - for continue) findings_dir fuzz_label afl_fuzz_exe fuzzed_exec nr_fuzzers [fuzz_label afl_fuzz_exe fuzzed_exec nr_fuzzers]*"
	exit;
fi

PROJECT=$1

EXEC=test_$PROJECT.exe 
EXEC_ASAN=test_"$PROJECT"_asan.exe 

TESTCASE_DIR=$2
FINDINGS_DIR=$3

###   

FUZZ_LABEL=$4
AFL_FUZZ=$5
FUZZ_EXEC=$6
NR_FUZZERS=$7

echo "[*] Starting master"
# echo "screen -dm -S afl_"$PROJECT"_$FUZZ_LABEL $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -M fuzzer_"$PROJECT"_$FUZZ_LABEL ./$FUZZ_EXEC @@"
set -x
# screen -dm -S afl_"$PROJECT"_$FUZZ_LABEL $AFL_FUZZ -i $TESTCASE_DIR -Q -o $FINDINGS_DIR -M fuzzer_"$PROJECT"_$FUZZ_LABEL ./$FUZZ_EXEC
screen -dm -S afl_"$PROJECT"_$FUZZ_LABEL $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -M fuzzer_"$PROJECT"_$FUZZ_LABEL ./$FUZZ_EXEC @@
set +x

if [ $# -ge 11 ];
    then 
	FUZZ_LABEL=$8
	AFL_FUZZ=$9
	FUZZ_EXEC=${10}
	NR_FUZZERS=${11}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		
	done
fi

if [ $# -ge 15 ];
    then 
	FUZZ_LABEL=${12}
	AFL_FUZZ=${13}
	FUZZ_EXEC=${14}
	NR_FUZZERS=${15}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -m none -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		

	done
fi

if [ $# -ge 19 ];
    then 
	FUZZ_LABEL=${16}
	AFL_FUZZ=${17}
	FUZZ_EXEC=${18}
	NR_FUZZERS=${19}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -m none -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		

	done
fi

if [ $# -ge 23 ];
    then 
	FUZZ_LABEL=${20}
	AFL_FUZZ=${21}
	FUZZ_EXEC=${22}
	NR_FUZZERS=${23}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		

	done
fi

if [ $# -ge 27 ];
    then 
	FUZZ_LABEL=${24}
	AFL_FUZZ=${25}
	FUZZ_EXEC=${26}
	NR_FUZZERS=${27}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		

	done
fi

if [ $# -ge 31 ];
    then 
	FUZZ_LABEL=${28}
	AFL_FUZZ=${29}
	FUZZ_EXEC=${30}
	NR_FUZZERS=${31}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC @@
	   set +x		

	done
fi

if [ $# -ge 35 ];
    then 
	FUZZ_LABEL=${32}
	AFL_FUZZ=${33} # QEmu
	FUZZ_EXEC=${34}
	NR_FUZZERS=${35}
	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i $AFL_FUZZ -Q -i $TESTCASE_DIR -o $FINDINGS_DIR -S fuzzer_"$PROJECT"_"$FUZZ_LABEL"-$i ./$FUZZ_EXEC
	   set +x		

	done
fi

if [ $# -ge 39 ];
    then 
	FUZZ_LABEL=${36}
	AFL_FUZZ=${37} # driller
	FUZZ_EXEC=${38}
	NR_FUZZERS=${39}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Starting $i slave $FUZZ_LABEL"
	   set -x
	   screen -dm -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i python $AFL_FUZZ $FINDINGS_DIR/fuzzer_"$PROJECT"_${32}-$i ./$FUZZ_EXEC
	   set +x		

	done
fi


