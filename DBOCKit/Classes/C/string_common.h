//
//  string_common.h
//  DBOCKit
//
//  Created by WangYajun on 2021/4/27.
//

#ifndef string_common_h
#define string_common_h

#include <stdio.h>

size_t sizeAlign16(size_t n);

/// 多个字符串拼接
/// ⚠️ ⚠️ ⚠️ 最后一个参数必须是NULL 作为结束标记
/// 
/// @example :
///  char *res = mutableMemoryCopy("1", "a", "9", NULL);
///
/// @param first first description
char *mutableMemoryCopy(const char *first, ...);

/// 多个字符串拼接
/// ⚠️ ⚠️ ⚠️ 最后一个参数必须是NULL 作为结束标记
/// 
/// @example :
///     char buffer[16] = { 0 };
///     mutableMemoryCpyDest(buffer, "a", "9", NULL);
///
/// @param dest buffer
/// @param first first description
void mutableMemoryCopyDest(char *dest, const char *first, ...);

/// 字符串格式化
/// @param dest dest description
/// @param fmt fmt description
int stringFormat(char *dest, const char *fmt, ...);


/// 字符串格式化
/// @param dest dest description
/// @param fmt fmt description
/// @param ap ap description
int stringVSNPrintf(char *dest, const char *fmt, va_list ap);

#endif /* string_common_h */
