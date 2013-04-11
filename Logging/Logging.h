//
//  Logging.h
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including  without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#define LOG_ASSERT(stmt, message, ...) \
do { \
    char *file = __FILE__; \
    char *ptr = strrchr(file, '/'); \
    if (ptr != NULL) { file = ++ptr; } \
    LogAssert((stmt), [NSString stringWithFormat:@"(%s:%d) %@", file, __LINE__, (message)], ##__VA_ARGS__); \
} while (0)

#define LOG_DEBUG(message, ...) \
do { \
    char *file = __FILE__; \
    char *ptr = strrchr(file, '/'); \
    if (ptr != NULL) { file = ++ptr; } \
    LogDebug([NSString stringWithFormat:@"(%s:%d) %@", file, __LINE__, (message)], ##__VA_ARGS__); \
} while (0)

#define LOG_INFO(message, ...) \
do { \
    char *file = __FILE__; \
    char *ptr = strrchr(file, '/'); \
    if (ptr != NULL) { file = ++ptr; } \
    LogInfo([NSString stringWithFormat:@"(%s:%d) %@", file, __LINE__, (message)], ##__VA_ARGS__); \
} while (0)

#define LOG_WARNING(message, ...) \
do { \
    char *file = __FILE__; \
    char *ptr = strrchr(file, '/'); \
    if (ptr != NULL) { file = ++ptr; } \
    LogWarning([NSString stringWithFormat:@"(%s:%d) %@", file, __LINE__, (message)], ##__VA_ARGS__); \
} while (0)

#define LOG_ERROR(message, ...) \
do { \
    char *file = __FILE__; \
    char *ptr = strrchr(file, '/'); \
    if (ptr != NULL) { file = ++ptr; } \
    LogError([NSString stringWithFormat:@"(%s:%d) %@", file, __LINE__, (message)], ##__VA_ARGS__); \
} while (0)

void LogInfo(NSString *message, ...);
void LogWarning(NSString *message, ...);
void LogError(NSString *message, ...);
void LogDebug(NSString *message, ...);
void LogAssert(BOOL statement, NSString *message, ...);
