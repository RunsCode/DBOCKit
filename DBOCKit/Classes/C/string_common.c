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

char *immutableCopyCat(const char *first, const char *second) {
    if (!first) return "";
    //
    size_t secondLength = 0;
    size_t firstLength = strlen(first);

    if (NULL != second) {
        secondLength = strlen(second);
    }

    size_t s = sizeAlign16(firstLength + secondLength);
    char *buffer = (char *)malloc(s);
    strcpy(buffer, first);

    if (NULL != second) {
        strcat(buffer, second);
    }
    return buffer;
}

void immutableCopyCatDest(char *dest, const char *str) {
    if (!dest || !str) {
        return;
    }

    if (strlen(str) <= 0) {
        return;
    }

    if (strlen(dest) <= 0) {
        strcpy(dest, str);
        return;
    }
    strcat(dest, str);
}

char *mutableCopyCat(const char *first, ...) {
    if (!first) return "";
    va_list ap;
    va_start(ap, first);
    char *res = (char *)first;
    while (1) {
        char *str = va_arg(ap, char *);
        if (!str) break;
        //
        res = immutableCopyCat(res, str);
    }
    va_end(ap);
    return res;
}

void mutableCopyCatDest(char *dest, const char *first, ...) {
    if (!dest || !first) return;
    //
    va_list ap;
    va_start(ap, first);
    immutableCopyCatDest(dest, first);
    while (1) {
        char *str = va_arg(ap, char *);
        if (!str) break;
        //
        immutableCopyCatDest(dest, str);
    }
    va_end(ap);
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
