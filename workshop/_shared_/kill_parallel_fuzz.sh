#!/bin/bash

###  PARAMS

if [ $# -lt  7 ]; 
    then echo "illegal number of parameters : $0 project_name fuzz_label nr_fuzzers [fuzz_label nr_fuzzers]*"
	exit;
fi

PROJECT=$1

FUZZ_LABEL=$2
NR_FUZZERS=$3

echo "[*] Killing master"
set -x
screen -S afl_"$PROJECT"_$FUZZ_LABEL -X quit
set +x

if [ $# -ge 5 ];
    then 
	FUZZ_LABEL=$4
	NR_FUZZERS=$5

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		
	done
fi

if [ $# -ge 7 ];
    then 
	FUZZ_LABEL=$6
	NR_FUZZERS=$7

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 9 ];
    then 
	FUZZ_LABEL=$8
	NR_FUZZERS=$9

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 11 ];
    then 
	FUZZ_LABEL=${10}
	NR_FUZZERS=${11}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 13 ];
    then 
	FUZZ_LABEL=${12}
	NR_FUZZERS=${13}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 15 ];
    then 
	FUZZ_LABEL=${14}
	NR_FUZZERS=${15}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 17 ];
    then 
	FUZZ_LABEL=${16}
	NR_FUZZERS=${17}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

if [ $# -ge 19 ];
    then 
	FUZZ_LABEL=${18}
	NR_FUZZERS=${19}

	for ((i=1;i<=NR_FUZZERS;i++));
	do
	   echo "[*] Killing $i slave $FUZZ_LABEL"
	   set -x
	   screen -S afl_"$PROJECT"_"$FUZZ_LABEL"-$i -X quit
	   set +x		

	done
fi

