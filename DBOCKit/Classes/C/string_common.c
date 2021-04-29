//
//  string_common.c
//  DBOCKit
//
//  Created by WangYajun on 2021/4/27.
//

#include "string_common.h"
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


enum { RUNS_BYTE_ALIGNMENT = 16 };

size_t sizeAlign16(size_t n) {
    return (n + (RUNS_BYTE_ALIGNMENT - 1)) & ~(RUNS_BYTE_ALIGNMENT - 1);
}

char *mutableMemoryCopy(const char *first, ...) {
    if (!first) return "";

    char buffer[256] = { 0 };
    size_t bsz = strlen(first);
    memcpy(buffer, first, bsz);

    va_list ap;
    va_start(ap, first);

    while (1) {
        char *str = va_arg(ap, char *);
        if (!str) break;
        //
        size_t ssz = strlen(str);
        memcpy(buffer + bsz, str, strlen(str));
        bsz += ssz;
    }
    va_end(ap);

    size_t s = sizeAlign16(strlen(buffer));
    char *res = (char *)malloc(s);
    memcpy(res, buffer, strlen(buffer));
    res[strlen(buffer)] = '\0';
    return res;
}

void mutableMemoryCopyDest(char *dest, const char *first, ...) {
    if (NULL == first) return;
    //
    size_t bsz = 0, dsz = 0;
    if (NULL != dest) dsz = strlen(dest);
    //
    size_t fsz = strlen(first);
    if (dsz > 0) {
        bsz = dsz;
    }
    memcpy(dest + bsz, first, fsz);
    bsz += fsz;

    va_list ap;
    va_start(ap, first);
    while (1) {
        char *str = va_arg(ap, char *);
        if (!str) break;
        //
        memcpy(dest + bsz, str, strlen(str));
        bsz += strlen(str);
    }
    va_end(ap);
    dest[strlen(dest)] = '\0';
    printf("----->%ld %s \n", strlen(dest), dest);
}

int stringFormat(char *dest, const char *fmt, ...) {
    if (!dest || !fmt) return -1;
    //
    int res;
    va_list ap;
    va_start(ap, fmt);
    res = vsnprintf(dest, 512, fmt, ap);
    va_end(ap);
    return res;
}

int stringVSNPrintf(char *dest, const char *fmt, va_list ap) {
    if (!dest || !fmt || !ap) return -1;
    return vsnprintf(dest, 512, fmt, ap);
}
