//
//  Logging.h
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//

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
