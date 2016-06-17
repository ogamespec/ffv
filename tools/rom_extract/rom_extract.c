// FFV Rom Extract
// rom_extract <rom_name> <rom_addr> <size> <filename>

// Only FINAL FANTASY V rom is supported.

#define _CRT_SECURE_NO_WARNINGS  

#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    FILE *in;
    FILE *out;
    PUCHAR Buffer;
    LONG Length;

    if (argc != 5)
    {
        printf("rom_extract <ff5 rom_name> <rom_addr> <size 1MB max> <filename>\n");
        return -1;
    }

    in = fopen(argv[1], "rb");
    if (!in)
        return -2;

    out = fopen(argv[4], "wb");
    if (!out)
        return -3;

    Length = strtoul(argv[3], NULL, 0);

    if (Length < 0 || Length > 1024 * 1024)
        return -4;

    Buffer = (PUCHAR)malloc(Length);
    if (Buffer == NULL)
        return -5;

    fseek(in, strtoul(argv[2], NULL, 0) - 0xc00000, SEEK_SET);

    fread(Buffer, 1, Length, in);

    fwrite(Buffer, 1, Length, out);

    // Let the OS do the cleanup :P

    return 0;
}
