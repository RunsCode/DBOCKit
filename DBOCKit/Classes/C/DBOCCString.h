//
//  string_common.h
//  DBOCKit
//
//  Created by WangYajun on 2021/4/27.
//

#ifndef dboc_c_string_h
#define dboc_c_string_h

#include <stdio.h>
#include <stdbool.h>

size_t SizeAlign16(size_t n);

bool StringHasPrefix(const char *pre, const char *str);
bool StringHasSuffix(const char *suf, const char *str);
void StringSplit(const char *source, char *dest, const char *sep, int idx);

/// 多个字符串拼接
/// ⚠️ ⚠️ ⚠️ 最后一个参数必须是NULL 作为结束标记
/// 
/// @example :
///  char *res = mutableMemoryCopy("1", "a", "9", NULL);
///
/// @param first first description
char *MutableMemoryCopy(const char *first, ...);

/// 多个字符串拼接
/// ⚠️ ⚠️ ⚠️ 最后一个参数必须是NULL 作为结束标记
/// 
/// @example :
///     char buffer[16] = { 0 };
///     mutableMemoryCpyDest(buffer, "a", "9", NULL);
///
/// @param dest buffer
/// @param first first description
void MutableMemoryCopyDest(char *dest, const char *first, ...);

/// 字符串格式化
/// @param dest dest description
/// @param fmt fmt description
int StringFormat(char *dest, const char *fmt, ...);

/// 字符串格式化
/// @param dest dest description
/// @param fmt fmt description
/// @param ap ap description
int StringVSNPrintf(char *dest, const char *fmt, va_list ap);

#endif /* dboc_c_string_h */
