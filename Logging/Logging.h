//
//  Logging.h
//  Logging
//
//  Created by Sean Morrison on 2013-04-09.
//  Copyright (c) 2013 Sean Morrison. All rights reserved.
//

void LogInfo(NSString *message, ...);
void LogWarning(NSString *message, ...);
void LogError(NSString *message, ...);
void LogDebug(NSString *message, ...);
void LogAssert(BOOL statement, NSString *message, ...);
