#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

#include <time.h>

// Uncomment to change random number generator seeding implementation
// #define SRAND_NSEC 1

int test_random(void)
{

#ifndef SRAND_NSEC
   time_t t;
   /* Intializes random number generator using time() 
	(number of seconds since 00:00 Jan 1, 1970) */
   srand(time(&t));
#else
   struct timespec start;
   clock_gettime(CLOCK_REALTIME, &start);
   /* Intializes random number generator using clock_gettime() 
	(number of nanoseconds of realtime) */
   srand(start.tv_nsec);
#endif

   int x = rand();
   printf("Got x = %d x mod 1000 = %d\n", x, x%1000);
   switch(x % 1000) {

	case 0: printf("Got 0\n");
	break;
	
	case 1: printf("Got 1\n");
	break;   

	case 2: assert(0); // crash
	break;   
   }
   return(0);
}

#define MAX_FILE_SIZE (2056)

#ifdef INPUT_STDIN

int main(int argc, char** argv) 
{
	char global_pkt_buf[MAX_FILE_SIZE+1];
	ssize_t global_data_size = read(STDIN_FILENO, global_pkt_buf, MAX_FILE_SIZE);
	global_pkt_buf[global_data_size] = 0;

	test_random();

	return 0;
}
	
#else

int main(int argc, char *argv[])
{
	test_random();
	return(0);
}

#endif // #ifndef INPUT_STDIN

