#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int main()
{
    char *p;
    unsigned long long x;
    sscanf("97", "%d", &x);
    float a = 0x1.p10;
    int a = 011;
    printf("%x\n", x);
    return 0;
}