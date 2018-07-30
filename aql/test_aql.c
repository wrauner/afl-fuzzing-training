#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <assert.h>
#include <unistd.h>

#include "aql.h"
#include "lvm.h"

#define MAX_FILE_SIZE (4096)
#define DISPLAY_INPUT_PLAIN 1

char* read_data_from_file(const char *path, size_t *ptr_data_size)
{
	FILE *file_desc;
	int result = -1;
	char *buffer = NULL;

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
		printf("%02hhX ", buffer[i] & 0xff);
	printf("\n");
#endif // #ifdef DISPLAY_INPUT_HEX

#ifdef DISPLAY_INPUT_PLAIN
 	printf("-----------------------------\n%s\n-------------------------\n", buffer);
#endif // #ifdef DISPLAY_INPUT_PLAIN

	fclose(file_desc);
	return buffer;
}

char *global_pkt_buf = NULL;
size_t global_data_size = 0;

#ifdef INPUT_STDIN

int main(int argc, char** argv) 
{
	char global_pkt_buf[MAX_FILE_SIZE+1];

	ssize_t global_data_size = read(STDIN_FILENO, global_pkt_buf, MAX_FILE_SIZE);
	global_pkt_buf[global_data_size] = 0;

	printf("size of input data = %d\n", (int) global_data_size);

	aql_adt_t parsed_aql;

	printf("start parsing!!\n");
	aql_status_t response = aql_parse(&parsed_aql, global_pkt_buf);

	printf("finished parsing!!\n");
	printf("Result = %d\n", response);

	return 0;
}
	
#else // #ifdef INPUT_STDIN

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
		
	aql_adt_t parsed_aql;

	printf("start parsing!!\n");
	aql_status_t response = aql_parse(&parsed_aql, global_pkt_buf);
	
	printf("finished parsing!!\n");
	printf("Result = %d\n", response);

 	free(global_pkt_buf);

	return 0;

#ifdef AFL_PERSISTENT_MODE
	}
#endif // #ifdef AFL_PERSISTENT_MODE

}

#endif // #infdef INPUT_STDIN

