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

size_t SizeAlign16(size_t n) {
    return (n + (RUNS_BYTE_ALIGNMENT - 1)) & ~(RUNS_BYTE_ALIGNMENT - 1);
}

bool StringHasPrefix(const char *pre, const char *str) {
    return strncmp(pre, str, strlen(pre)) == 0;
}

bool StringHasSuffix(const char *suf, const char *str) {
    const char *res = strstr(str, suf);
    if (NULL == res) {
        return false;
    }
    return strncmp(suf, res, strlen(res)) == 0;
}

void StringSplit(const char *source, char *dest, const char *sep, int idx)  {
    char *token = NULL;
    char temp[1024] = {0};
    memcpy(temp, source, strlen(source));

    token = strtok(temp, sep);
    while(NULL != token) {
        if(idx-- <= 0) break;
        token = strtok(NULL, sep);
    }

    if(idx <= 0 && NULL != token) {
        memcpy(dest, token, strlen(token));
        return;
    }
    memcpy(dest, "", 0);
}

char *MutableMemoryCopy(const char *first, ...) {
    if (!first) return "";

    char buffer[1024] = { 0 };
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

    size_t s = SizeAlign16(strlen(buffer));
    char *res = (char *)malloc(s);
    memcpy(res, buffer, strlen(buffer));
    res[strlen(buffer)] = '\0';
    return res;
}

void MutableMemoryCopyDest(char *dest, const char *first, ...) {
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
//    printf("%ld %s \n", strlen(dest), dest);
}

int StringFormat(char *dest, const char *fmt, ...) {
    if (!dest || !fmt) return -1;
    //
    int res;
    va_list ap;
    va_start(ap, fmt);
    res = vsnprintf(dest, 512, fmt, ap);
    va_end(ap);
    return res;
}

int StringVSNPrintf(char *dest, const char *fmt, va_list ap) {
    if (!dest || !fmt || !ap) return -1;
    return vsnprintf(dest, 512, fmt, ap);
}
