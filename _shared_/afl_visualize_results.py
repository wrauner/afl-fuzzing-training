import sys
from os import listdir
from sets import Set

if (len(sys.argv) != 3):
    print "Wrong number of input params\nUsage: sys.argv[0] afl_findings_dir output_dot_file"
    sys.exit()

path_afl_findings = sys.argv[1]
output_filename = sys.argv[2]

afl_queue_files = [f for f in listdir(path_afl_findings + "/queue/")]
afl_crashes_files = [f for f in listdir(path_afl_findings + "/crashes/")]
afl_hangs_files = [f for f in listdir(path_afl_findings + "/hangs/")]

# print afl_result_files

dot_graph = """digraph afl_results {  
 input [label=\"Input files\",shape=box]; """ + '\n';

external_fuzzers = Set()

def process_splice(file_name, result_name, box_color):
    dot_string = ""
    index_src = file_name.find(",src:")
    index_splice = file_name.find("splice")
    index_op = file_name.find(",op:");
    if index_splice >= 0:
        # print "Found splice in : " + file_name
        index_plus = file_name.find("+")
        file_id = file_name[:index_src]
        index_coma = file_id.find(",");
        if index_coma > 0:
           file_id = file_id[:index_coma]
        prev_name_1 = "id:" + file_name[index_src + len(",src:"):index_plus]
        prev_name_2 = "id:" + file_name[index_plus + 1:index_op]
        op_name = file_name[index_op + len(",op:"):]
        # print "op_name : " + op_name
        dot_string += '"' + prev_name_1 + '"' + " -> " + '"' + result_name + ":" + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n"
        dot_string += '"' + prev_name_2 + '"' + " -> " + '"' + result_name + ":"+ file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n"
        dot_string += '"' + result_name + ":" + file_id + '"' + " " + "[label=" + '"crash:' + file_id + "\", shape=box, color=" + box_color + "];\n"
        # print "dot_string : " + dot_string

    return dot_string
    

for file in afl_queue_files:
    # Converting filename id:000000,orig:hello.txt into: "id:000000" [label="hello.txt",shape=box]; input -> "id:000000";
    index_orig = file.find(",orig:")
    if (index_orig > 0):
        file_id = file[:index_orig]
        orig_name = file[index_orig + len(",orig:"):]
        dot_graph += '"' + file_id + '"' + " " + "[label=" + '"' + orig_name + "\", shape=box];\n";
        dot_graph += "input ->" + '"' + file_id + '"' + ";\n";
        continue

    index_sync = file.find(",sync:")
    if index_sync >= 0:
        file_id = file[:index_sync]
        fuzzer_name = file[index_sync + len(",sync:"):]
        index_coma = fuzzer_name.find(",")
        fuzzer_name = fuzzer_name[:index_coma]
        rindex_unders = fuzzer_name.rfind("_")
        fuzzer_name = fuzzer_name[rindex_unders+1:]
        external_fuzzers.add(fuzzer_name)
        dot_graph += '"' + fuzzer_name + '"' + " -> " + '"' + file_id + '"' + "\n"
        continue        

    index_src = file.find(",src:")
    index_splice = file.find("splice")
    index_op = file.find(",op:");
    if index_splice >= 0:
        index_plus = file.find("+")
        file_id = file[:index_src]
        prev_name_1 = "id:" + file[index_src + len(",src:"):index_plus]
        prev_name_2 = "id:" + file[index_plus + 1:index_op]
        op_name = file[index_op + len(",op:"):]
        dot_graph += '"' + prev_name_1 + '"' + " -> " + '"' + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n"
        dot_graph += '"' + prev_name_2 + '"' + " -> " + '"' + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n"
        continue
    
    # Converting "id:000001,src:000000,op:flip1,pos:3" [label="id:000001"]; into "id:000001"; "id:000000" -> "id:000001" [label="filp1,pos:3"];
    if (index_src > 0):
        file_id = file[:index_src]
        prev_name = "id:" + file[index_src + len(",src:"):index_op]
        op_name = file[index_op + len(",op:"):]
        # dot_graph += '"' + file_id + '"' + " " + "[label=" + '"' + orig_name + "\", shape=box];\n";
        dot_graph += '"' + prev_name + '"' + " -> " + '"' + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n";    


for file in afl_crashes_files:
    dot_result = process_splice(file, "crash", "red")
    if (len(dot_result) > 0):
        dot_graph += dot_result
        continue 

    index_src = file.find(",src:")
    index_coma = file.find(",")
    index_op = file.find(",op:")
    if (index_src > 0):
        file_id = file[:index_coma]
        prev_name = "id:" + file[index_src + len(",src:"):index_op]
        op_name = file[index_op + len(",op:"):]
        dot_graph += '"crash:' + file_id + '"' + " " + "[label=" + '"crash:' + file_id + "\", shape=box, color=red];\n"
        dot_graph += '"' + prev_name + '"' + " -> " + '"crash:' + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n"

for file in afl_hangs_files:
    dot_result = process_splice(file, "hang", "orange")
    if (len(dot_result) > 0):
        dot_graph += dot_result
        continue 

    print "Processing " + file
    index_coma = file.find(",")
    index_src = file.find(",src:")
    index_op = file.find(",op:");
    if (index_src > 0):
        file_id = file[:index_coma]
        prev_name = "id:" + file[index_src + len(",src:"):index_op]
        op_name = file[index_op + len(",op:"):]
        dot_graph += '"hang:' + file_id + '"' + " " + "[label=" + '"hang:' + file_id + "\", shape=box, color=orange];\n";
        dot_graph += '"' + prev_name + '"' + " -> " + '"hang:' + file_id + '"' + "[label=" + '"' + op_name + '"' + "]\n";    

for fuzzer in external_fuzzers:
    dot_graph += '"' + fuzzer + '"' + "[label=\"Imported from " + fuzzer + '"' + ",shape=box]; " + '\n';

dot_graph += "\n }\n";

result_file = open(output_filename,"w") 
result_file.write(dot_graph)  
result_file.close() 

