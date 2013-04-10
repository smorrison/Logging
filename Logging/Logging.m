//
//  Logging.m
//  Logging
//
//  Created by Sean Morrison on 2013-04-09.
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//

#import "Logging.h"

typedef enum {
    LOG_NONE,
    LOG_FAILED_ASSERT,
    LOG_DEBUG,
    LOG_ERROR,
    LOG_WARNING,
    LOG_INFO
} logCategory;

static void Log(logCategory category, NSString *message, va_list args);

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

void Log(logCategory category, NSString *message, va_list args)
{
    static NSString *applicationName;
    static dispatch_once_t onceToken;
    static NSDateFormatter *formatter;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        applicationName = [[[[NSBundle mainBundle] bundleURL] lastPathComponent] stringByDeletingPathExtension];
    });
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
    NSString *string = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@", [formatter stringFromDate:[NSDate date]], applicationName, @"", formattedMessage];
    NSLog(string);
#if !(__has_feature(objc_arc))
    [string release];
    [formattedMessage release];
#endif
}

