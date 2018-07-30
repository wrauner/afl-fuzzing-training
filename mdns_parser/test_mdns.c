#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <assert.h>
#include <unistd.h>

#include "mdns.h"

#define MAX_FILE_SIZE (2056)
#define DISPLAY_INPUT_HEX 1

uint8_t *global_pkt_buf = NULL;
size_t global_data_size = 0;

uint8_t* read_data_from_file(const char *path, size_t *ptr_data_size)
{
	FILE *file_desc;
	int result = -1;
	uint8_t *buffer = NULL;

	if (path == NULL)
		return NULL;

	struct stat stat_str;
	result = stat(path, &stat_str);
	if (result != 0)
		return NULL;		

	file_desc = fopen(path, "r");
	if (file_desc == NULL)
		return NULL;
	size_t data_size = stat_str.st_size;

	buffer = malloc(data_size+1);
	if (buffer == NULL)
		return NULL;

	buffer[data_size] = 0;

	size_t data_size_read = fread(buffer, 1, data_size, file_desc);

	assert(data_size_read == data_size);
	*ptr_data_size = data_size;

#ifdef DISPLAY_INPUT_HEX
	for (int i=0; i<data_size+1; ++i)
		printf("%02hhX ", (unsigned char) (buffer[i] & 0xff));
	printf("\n");
#endif // #ifdef DISPLAY_INPUT_HEX

#ifdef DISPLAY_INPUT_PLAIN
 	printf("-----------------------------\n%s\n-------------------------\n", buffer);
#endif // #ifdef DISPLAY_INPUT_PLAIN

	fclose(file_desc);
	return buffer;
}

int mdns_count_list(struct rr_list *ptr)
{
	int i = 0;
	while (ptr)
	{
		ptr = ptr->next;
		i++;
	}
	return i;
}

#ifdef INPUT_STDIN

int main(int argc, char** argv) 
{
	char global_pkt_buf[MAX_FILE_SIZE+1];

#ifdef AFL_PERSISTENT_MODE
   while (__AFL_LOOP(1000)) {
#endif // #ifdef AFL_PERSISTENT_MODE


	ssize_t global_data_size = read(STDIN_FILENO, global_pkt_buf, MAX_FILE_SIZE);
	global_pkt_buf[global_data_size] = 0;

	printf("size of input data = %d\n", (int) global_data_size);

	printf("start parsing!!\n");

	struct mdns_pkt *parsed_pkt = NULL;
	parsed_pkt = mdns_parse_pkt(global_pkt_buf, global_data_size);
	printf("Parsed packet pointer = %p\n", parsed_pkt);
	if (parsed_pkt) 
		mdns_pkt_destroy(parsed_pkt);

	printf("finished parsing!!\n");

#ifdef AFL_PERSISTENT_MODE
	// }
#endif // #ifdef AFL_PERSISTENT_MODE

	return 0;
}
	
#else

int main( int argc, char * argv[] )
{

#ifdef AFL_PERSISTENT_MODE
    while (__AFL_LOOP(1000)) {
#endif // #ifdef AFL_PERSISTENT_MODE

	int i = 0;
	if (argc == 2) {
		global_pkt_buf = read_data_from_file(argv[1], &global_data_size);
	} else {
		printf("Wrong number of arguments = %d - should be 1!\n", argc-1);
		return -1;
	}

	printf("size of input data = %zu\n", global_data_size);
	if (global_data_size == 0)
	{
		printf("Data sample is empty!\n");
		return -1;
	}
		
	printf("start parsing!!\n");

	///////////////////////////////////////////////////////////////////////////////////////////

	struct mdns_pkt *parsed_pkt = NULL;
	parsed_pkt = mdns_parse_pkt(global_pkt_buf, global_data_size);
	printf("Parsed packet pointer = %p\n", parsed_pkt);

	if (parsed_pkt) 
	{	
		printf("	id = %u\n", parsed_pkt->id);
		printf("	flags = %x\n\n", parsed_pkt->flags);
		printf("	num_qn = %u\n", parsed_pkt->num_qn);
		printf("	rr_qn = %p\n", parsed_pkt->rr_qn);
		printf("	Questions in list = %d\n\n", mdns_count_list(parsed_pkt->rr_qn));
		printf("	num_ans_rr = %u\n", parsed_pkt->num_ans_rr);
		printf("	rr_ans = %p\n", parsed_pkt->rr_ans);
		printf("	Answer RRs in list = %d\n\n", mdns_count_list(parsed_pkt->rr_ans));
		printf("	num_auth_rr = %u\n", parsed_pkt->num_auth_rr);
		printf("	rr_auth = %p\n", parsed_pkt->rr_auth);
		printf("	Authority RR in list = %d\n\n", mdns_count_list(parsed_pkt->rr_auth));
		printf("	num_add_rr = %u\n", parsed_pkt->num_add_rr);
		printf("	rr_add = %p\n", parsed_pkt->rr_add);
		printf("	Additional RRs in list = %d\n\n", mdns_count_list(parsed_pkt->rr_add));
	}
	if (parsed_pkt) 
		mdns_pkt_destroy(parsed_pkt);

	///////////////////////////////////////////////////////////////////////////////////////////

	printf("finished parsing!!\n");

 	free(global_pkt_buf);

	return 0;

#ifdef AFL_PERSISTENT_MODE
	}
#endif // #ifdef AFL_PERSISTENT_MODE

}

#endif // #ifdef INPUT_STDIN

