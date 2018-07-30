#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <unistd.h>
#include <sys/stat.h>
#include <assert.h>

// #define printf(...)

#define MAX_FILE_SIZE (1024)

#define DISPLAY_INPUT_HEX 1

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
		printf("%02hhX ", buffer[i] & 0xff);
	printf("\n");
#endif // #ifdef DISPLAY_INPUT_HEX

#ifdef DISPLAY_INPUT_PLAIN
 	printf("-----------------------------\n%s\n-------------------------\n", buffer);
#endif // #ifdef DISPLAY_INPUT_PLAIN

	fclose(file_desc);
	return buffer;
}

inline int my_strncmp(char* ptr1, char* ptr2, int len)
  __attribute__((always_inline));

inline int my_strncmp(char* ptr1, char* ptr2, int len) 
{
	int nr_matched_chars = 0;
	if (len > 0 && ptr1[0] == ptr2[0]) {
		if (len > 1 && ptr1[1] == ptr2[1]) {
			if (len > 2 && ptr1[2] == ptr2[2]) {
				if (len > 3 && ptr1[3] == ptr2[3]) {	
					if (len > 4 && ptr1[4] == ptr2[4]) {
						if (len > 5 && ptr1[5] == ptr2[5]) {
							if (len > 6 && ptr1[6] == ptr2[6]) {
								if (len > 7 && ptr1[7] == ptr2[7]) {
									if (len > 8 && ptr1[8] == ptr2[8]) {	
										if (len > 9 && ptr1[9] == ptr2[9]) {
											if (len > 10)
												return strncmp(ptr1,ptr2, len);
										} else nr_matched_chars = 9;
									} else nr_matched_chars = 8;
								} else nr_matched_chars = 7;
							} else nr_matched_chars = 6;
						} else nr_matched_chars = 5;
					} else nr_matched_chars = 4;
				} else nr_matched_chars = 3;
			} else nr_matched_chars = 2;
		} else nr_matched_chars = 1;
	} else nr_matched_chars = 0;

	printf("%s : nr_matched_chars = %d\n", __FUNCTION__, nr_matched_chars);
	if (nr_matched_chars == len)
		return 0;
	else 
		return (ptr1[nr_matched_chars] > ptr2[nr_matched_chars]);
}

volatile uint32_t MAGICNUMBER = 0x34333132;

#define __BUG__ do { printf("LINE = %d\n", __LINE__); hit_nr++; /* assert(__LINE__ % ptr_data[0] % 3); */ } while(0)

int test_cmp(char* ptr_data, size_t data_size) 
{

    int hit_nr = 0;

    if (ptr_data == NULL)
    {
        printf("Configuration syntax error");
        return 1;
    }
    
    uint32_t magic = *(uint32_t*) ptr_data;
    
    if (magic != MAGICNUMBER) {
        printf("Bad magic number");
    } else {
        __BUG__;
        return 2;
    }

    if (magic >= MAGICNUMBER || (uint16_t)magic >= 0x4142) {
        printf("Magic is higher than limit"); __BUG__;
    } else {
        printf("LINE = %d", __LINE__); 
        return 3;
    }

    switch(magic) {
	case 1:
		printf("Magic is 1");
		__BUG__;
		break;
	case 0x10a1:
		printf("Magic is 0x10a1");
		__BUG__;
		break;
	case 0x20a2b2:
		printf("Magic is 0x20a2b2");
		__BUG__;
		break;
	case 0x30a3b3c3:
		printf("Magic is 0x30a3b3c3");
		__BUG__;
		break;
    }

    char* directive = NULL;
    
    // initialize(config);
    if (data_size > 4 + strlen("crashstring") + 1) 
    {
        directive = ptr_data + 4;
        printf("%s\n", directive);
    } else return -1;
        
       // int strcmp(const char *s1, const char *s2);
       // Compare the strings s1 with s2.
        
    if(!strcmp(directive, "crashstring")) 
    {
	assert(1!=0);
        __BUG__;
    } 
       // int strncmp(const char *s1, const char *s2, size_t n);
       //       Compare at most n bytes of the strings s1 and s2.

    if(!my_strncmp(directive, "!et_pt*on", 9)) 
    {
        __BUG__;
    } 

    if(!strncmp(directive, "sytoxtbon", 9)) 
    {
        __BUG__;
    } 
       // int strcasecmp(const char *s1, const char *s2);
       //       Compare the strings s1 and s2 ignoring case.
       // 
    if(!strcasecmp(directive, "SeT+PtIon"))
    {
        __BUG__;
    }

       // int strncasecmp(const char *s1, const char *s2, size_t n);
       //        Compare the first n characters of the strings s1 and s2 ignoring case.
    if(!strncasecmp(directive, "XeR=GtIon", 9))
    {
        __BUG__;
    }

       // int strcoll(const char *s1, const char *s2);
       //        Compare the strings s1 with s2 using the current locale.

    if(!strcoll(directive, "LoRoGtIonca"))
    {
        __BUG__;
    }

       // char *strstr(const char *haystack, const char *needle);
       //       Find  the  first occurrence of the substring needle in the string haystack, returning a pointer
       //       to the found substring.
    if(strstr(directive, "AbCdEGtIon") != NULL)
    {
        __BUG__;
    }
       
       // size_t strspn(const char *s, const char *accept);
       //       Calculate the length of the starting segment in the string s that consists entirely of bytes in
       //       accept.
    if(strspn(directive, "aBcdefghijklmnRoGtIn") > 15)
    {
        __BUG__;
    }
       
       //       1-byte wide compares 
    
       // char *index(const char *s, int c);
       //       Return a pointer to the first occurrence of the character c in the string s.
    if(index(directive, 'b') != NULL)
    {
        __BUG__;
    }

       // char *rindex(const char *s, int c);
       //       Return a pointer to the last occurrence of the character c in the string s.
    if(index(directive, 'c') != NULL)
    {
        __BUG__;
    }

       // char *strchr(const char *s, int c);
       //       Return a pointer to the first occurrence of the character c in the string s.
    if(strchr(directive, 'x') != NULL)
    {
        __BUG__;
    }

       // char *strrchr(const char *s, int c);
       //        Return a pointer to the last occurrence of the character c in the string s.
    if(strrchr(directive, 'e') != NULL)
    {
        __BUG__;
    }

       // char *strpbrk(const char *s, const char *accept);
       //       Return  a  pointer  to  the  first occurrence in the string s of one of the bytes in the string
       //       accept.
    if(strpbrk(directive, "ab.cept_string") == NULL)
    {
        __BUG__;
    }

       // size_t strcspn(const char *s, const char *reject);
       //       Calculate the length of the initial segment of the string s which does not contain any of bytes
       //       in the string reject,
    if(strcspn(directive, "abc_XeRoGtIon") > 20)
    {
        __BUG__;
    }

// cases difficult with dictionary
   
    char new_buffer_1[10];
    char new_buffer_2[10];
    char new_buffer_3[10];
   
    for (int i=0; i<10; ++i)
    {
        new_buffer_1[9-i] = directive[i];
        new_buffer_2[i] = directive[i] + 1;
        new_buffer_3[i] = directive[i] ^ 85;
    }
   
    if(!strcmp(new_buffer_1, "crashstring"))
    {
        __BUG__;
    }
    if(!strncasecmp(new_buffer_2, "XeRoGtIon", 9))
    {
        __BUG__;
    }
    if(!strncmp(new_buffer_3, "setoption", 9))
    {
        __BUG__;
    } 

    if(!my_strncmp(new_buffer_1, "crashstr", 8))
    {
        __BUG__;
    }

    printf("hit_nr = %d\n", hit_nr);
       
    return 0;
}

#ifdef INPUT_STDIN

int main(int argc, char** argv) 
{
    char global_pkt_buf[MAX_FILE_SIZE+1];

    ssize_t global_data_size = read(STDIN_FILENO, global_pkt_buf, MAX_FILE_SIZE);
    global_pkt_buf[global_data_size] = 0;

    printf("size of input data = %d\n", (int) global_data_size);
	
#else

char *global_pkt_buf = NULL;
size_t global_data_size = 0;

int main( int argc, char * argv[] )
{

#ifdef AFL_PERSISTENT_MODE
//    while (__AFL_LOOP(1000)) {
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

#endif

	printf("start testing!!\n");

        int result = test_cmp(global_pkt_buf, global_data_size);

        printf("\nresult = %d\n", result);
        printf("\nfinished testing!!\n");

#ifdef AFL_PERSISTENT_MODE
// 	}
#endif // #ifdef AFL_PERSISTENT_MODE

	return 0;
}

