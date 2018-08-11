import sys
from os import listdir
from sets import Set

if (len(sys.argv) != 3):
    print "Wrong number of input params\nUsage: sys.argv[0] afl_findings_dir output_dot_file"
    sys.exit()

path_afl_findings = sys.argv[1]
output_filename = sys.argv[2]

dot_graph = "digraph afl_imports {\n" + "\tlayout=circo;\n" 

fuzzers = [f for f in listdir(path_afl_findings)]

nr_fuzzers = len(fuzzers)
# nr_imports = newTable("MyTable", nr_fuzzers, nr_fuzzers)
nr_imports = [[0 for x in range(nr_fuzzers)] for y in range(nr_fuzzers)]

print fuzzers
for fuzzer in fuzzers:
    dest_fuzzer = fuzzers.index(fuzzer)
    afl_queue_files = [f for f in listdir(path_afl_findings + "/" + fuzzer + "/queue/")]
    for file in afl_queue_files:
# afl_crashes_files = [f for f in listdir(path_afl_findings + "/crashes/")]
# afl_hangs_files = [f for f in listdir(path_afl_findings + "/hangs/")]
        index_orig = file.find(",orig:")
        if index_orig > 0:
            continue
        
        index_sync = file.find(",sync:")
        if index_sync >= 0:
            file_id = file[:index_sync]
            fuzzer_name = file[index_sync + len(",sync:"):]
            index_coma = fuzzer_name.find(",")
            fuzzer_name = fuzzer_name[:index_coma]
            # rindex_unders = fuzzer_name.rfind("_")
            # fuzzer_name = fuzzer_name[rindex_unders+1:]
            # external_fuzzers.add(fuzzer_name)
            # dot_graph += '"' + fuzzer_name + '"' + " -> " + '"' + file_id + '"' + "\n"
            if fuzzer_name in fuzzers:
                src_fuzzer_index = fuzzers.index(fuzzer_name)
                # print "src = " + str(src_fuzzer_index) + " dest = " + str(dest_fuzzer)
                nr_imports[src_fuzzer_index][dest_fuzzer] += 1
import_count = [0 for x in range(nr_fuzzers)]
export_count = [0 for x in range(nr_fuzzers)]

for src in range(nr_fuzzers):
    for dst in range(nr_fuzzers):
        import_count[dst] += nr_imports[src][dst]
        export_count[src] += nr_imports[src][dst]
        if nr_imports[src][dst] > 0:
            if nr_imports[src][dst] >= nr_imports[dst][src]:
                color = "blue"
            else:
                color = "grey"
            dot_graph += '\t' + '"' + fuzzers[src] + '"' + " -> " + '"' + fuzzers[dst] + '"' + "[label=" + str(nr_imports[src][dst]) + ", color=" + color + ", fontcolor=" + color + "];\n"; 
dot_graph += "\n }\n";

for x in range(nr_fuzzers):
    print fuzzers[x] + " imported = " + str(import_count[x]) + " exported = " + str(export_count[x]) + " out-in = " + str(export_count[x] - import_count[x])

result_file = open(output_filename,"w") 
result_file.write(dot_graph)  
result_file.close() 

