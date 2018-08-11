#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "cjson.h"

int main(int argc, char** argv) {
    char buffer[100];
    int chars = read(0, buffer, 100);
    buffer[99] = '\0';
    printf("%s\n", cJSON_Print(cJSON_Parse(buffer)));
    return 0;
}