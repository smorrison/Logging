//
//  LoggingTests.m
//  LoggingTests
//
//  Created by Sean Morrison on 2013-04-09.
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//

#import "LoggingTests.h"
#import "Logging.h"

@implementation LoggingTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testLogMessages
{
    LogAssert(YES, @"assert message");
    LogDebug(@"assert debug");
    LogInfo(@"assert info");
    LogWarning(@"assert warning");
    LogError(@"assert error");
}

@end
