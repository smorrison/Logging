//
//  Logging.m
//  Logging
//
//  Created by Sean Morrison on 2013-04-09.
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//

#import "Logging.h"
#include <sys/types.h>
#include <sys/stat.h>

typedef enum {
    LOG_NONE,
    LOG_FAILED_ASSERT,
    LOG_DEBUG,
    LOG_ERROR,
    LOG_WARNING,
    LOG_INFO
} logCategory;

static void Log(logCategory category, NSString *message, va_list args);
static const char * GetLoggingName();
static dispatch_io_t LogFileDispatchChannel();
static dispatch_queue_t LogFileDispatchQueue();

void LogInfo(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log(LOG_INFO, message, arglist);
    va_end(arglist);
}

void LogWarning(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log(LOG_WARNING, message, arglist);
    va_end(arglist);
}

void LogError(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log(LOG_ERROR, message, arglist);
    va_end(arglist);
}

void LogDebug(NSString *message, ...)
{
#ifdef DEBUG
    va_list arglist;
    va_start(arglist, message);
    Log(LOG_DEBUG, message, arglist);
    va_end(arglist);
#endif
}

void LogAssert(BOOL statement, NSString *message, ...)
{
    if (!statement) {
        va_list arglist;
        va_start(arglist, message);
        Log(LOG_FAILED_ASSERT, message, arglist);
        va_end(arglist);
    }
}

const char * GetLoggingName()
{
    static char *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *nsname = [[[[NSBundle mainBundle] bundleURL] lastPathComponent] stringByDeletingPathExtension];
        const char *cstring = [nsname fileSystemRepresentation];
        size_t length = strlen(cstring);
        name = calloc(length, sizeof(char));
        memcpy(name, cstring, length * sizeof(char));
    });
    return name;
}

void Log(logCategory category, NSString *message, va_list args)
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    static pid_t processId;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"y-MM-dd HH:mm:s.SSS"];
        processId = [[NSProcessInfo processInfo] processIdentifier];
    });
    NSDate *date = [[NSDate alloc] init];
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
    NSString *categoryString = @"";
    switch (category) {
        case LOG_FAILED_ASSERT:
            categoryString = @" ASSERT";
            break;
        case LOG_DEBUG:
            categoryString = @" DEBUG";
            break;
        case LOG_INFO:
            categoryString = @" INFO";
            break;
        case LOG_WARNING:
            categoryString = @" WARNING";
            break;
        case LOG_ERROR:
            categoryString = @" ERROR";
            break;
        default:
            break;
    }
    NSString *string = [[NSString alloc] initWithFormat:@"%@ [%d]%@ %@\n", [formatter stringFromDate:date], processId, categoryString, formattedMessage];
    const char *stringData = [string UTF8String];
    dispatch_queue_t queue = LogFileDispatchQueue();
    dispatch_io_t channel = LogFileDispatchChannel();
    dispatch_data_t dispatchData = dispatch_data_create(stringData, strlen(stringData) * sizeof(char), queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    dispatch_io_write(channel, 0, dispatchData, queue, ^(bool done, dispatch_data_t data, int error){});
    dispatch_release(dispatchData);
#if !(__has_feature(objc_arc))
    [string release];
    [formattedMessage release];
    [date release];
#endif
}

dispatch_queue_t LogFileDispatchQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("logger", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

dispatch_io_t LogFileDispatchChannel()
{
    static dispatch_io_t channel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *usersLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *name = [[NSString alloc] initWithFormat:@"%s", GetLoggingName()];
        NSString *logDirectory = [[usersLibrary stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:name];
        int result = mkdir([logDirectory fileSystemRepresentation], S_IRWXU);
        if (result != 0 && (errno != EEXIST)) {
            NSLog(@"couldn't create log directory, error: %s", strerror(errno));
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"y-MM-dd-HHmm"];
            NSDate *date = [[NSDate alloc] init];
            NSString *filename = [[NSString alloc] initWithFormat:@"%@.log", [formatter stringFromDate:date]];
            const char *fullPath = [[logDirectory stringByAppendingPathComponent:filename] fileSystemRepresentation];
            channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, fullPath, O_WRONLY|O_APPEND|O_CREAT, S_IREAD|S_IWRITE, LogFileDispatchQueue(), ^(int error){});
#if !(__has_feature(objc_arc))
            [filename release];
            [date release];
            [formatter release];
#endif
        }
#if !(__has_feature(objc_arc))
        [name release];
#endif
    });
    return channel;
}
