//
//  Logging.m
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
} LogCategory;

static void Log_(LogCategory category, NSString *message, va_list args);
static dispatch_queue_t LoggerDispatchQueue();
static dispatch_io_t LoggerStdoutDispatchChannel();
static dispatch_io_t LoggerStderrDispatchChannel();
static dispatch_io_t LoggerDispatchChannel();

void LogInfo(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log_(LOG_INFO, message, arglist);
    va_end(arglist);
}

void LogWarning(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log_(LOG_WARNING, message, arglist);
    va_end(arglist);
}

void LogError(NSString *message, ...)
{
    va_list arglist;
    va_start(arglist, message);
    Log_(LOG_ERROR, message, arglist);
    va_end(arglist);
}

void LogDebug(NSString *message, ...)
{
#ifdef DEBUG
    va_list arglist;
    va_start(arglist, message);
    Log_(LOG_DEBUG, message, arglist);
    va_end(arglist);
#endif
}

void LogAssert(BOOL statement, NSString *message, ...)
{
    if (!statement) {
        va_list arglist;
        va_start(arglist, message);
        Log_(LOG_FAILED_ASSERT, message, arglist);
        va_end(arglist);
    }
}

void LogStartup()
{
    LoggerDispatchQueue();
    LoggerStdoutDispatchChannel();
    LoggerDispatchChannel();
}

void LogShutdown()
{
    dispatch_io_close(LoggerStdoutDispatchChannel(), DISPATCH_IO_STOP);
    dispatch_io_close(LoggerDispatchChannel(), DISPATCH_IO_STOP);
    dispatch_release(LoggerStdoutDispatchChannel());
    dispatch_release(LoggerDispatchChannel());
    dispatch_release(LoggerDispatchQueue());
}

#pragma mark private

static const char * GetLoggingName()
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

static const char * GetCategoryName(LogCategory category)
{
    const char *categoryString = "";
    switch (category) {
        case LOG_FAILED_ASSERT:
            categoryString = " ASSERT";
            break;
        case LOG_DEBUG:
            categoryString = " DEBUG";
            break;
        case LOG_INFO:
            categoryString = " INFO";
            break;
        case LOG_WARNING:
            categoryString = " WARNING";
            break;
        case LOG_ERROR:
            categoryString = " ERROR";
            break;
        default:
            break;
    }
    return categoryString;
}

static dispatch_queue_t LoggerDispatchQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("logger", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

static dispatch_io_t LoggerStdoutDispatchChannel()
{
    static dispatch_io_t channel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channel = dispatch_io_create(DISPATCH_IO_STREAM, 1, LoggerDispatchQueue(), ^(int error){});
    });
    return channel;
}

static dispatch_io_t LoggerStderrDispatchChannel()
{
    static dispatch_io_t channel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channel = dispatch_io_create(DISPATCH_IO_STREAM, 2, LoggerDispatchQueue(), ^(int error){});
    });
    return channel;
}

static dispatch_io_t LoggerDispatchChannel()
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
            channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, fullPath, O_WRONLY|O_APPEND|O_CREAT, S_IREAD|S_IWRITE, LoggerDispatchQueue(), ^(int error){});
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

void Log_(LogCategory category, NSString *message, va_list args)
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    static pid_t processId;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"y-MM-dd HH:mm:ss.SSS"];
        processId = [[NSProcessInfo processInfo] processIdentifier];
    });
    NSDate *date = [[NSDate alloc] init];
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
    NSString *string = [[NSString alloc] initWithFormat:@"%@ [%d]%s %@\n", [formatter stringFromDate:date], processId, GetCategoryName(category), formattedMessage];
    const char *stringData = [string UTF8String];
    dispatch_queue_t queue = LoggerDispatchQueue();
    dispatch_io_t channel = LoggerDispatchChannel();
    dispatch_io_t stdoutChannel = LoggerStdoutDispatchChannel();
    dispatch_io_t stderrChannel = LoggerStderrDispatchChannel();
    dispatch_data_t dispatchData = dispatch_data_create(stringData, strlen(stringData) * sizeof(char), queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    dispatch_io_write(channel, 0, dispatchData, queue, ^(bool done, dispatch_data_t data, int error){});
    if (category == LOG_FAILED_ASSERT || category == LOG_WARNING) {
        dispatch_io_write(stderrChannel, 0, dispatchData, queue, ^(bool done, dispatch_data_t data, int error){});
    } else {
        dispatch_io_write(stdoutChannel, 0, dispatchData, queue, ^(bool done, dispatch_data_t data, int error){});
    }
    dispatch_release(dispatchData);
#if !(__has_feature(objc_arc))
    [string release];
    [formattedMessage release];
    [date release];
#endif
}
