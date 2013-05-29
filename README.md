# Simple log-file support for objective-c (MacOS X and iOS) projects

Provides `LogAssert(BOOL, NSString, ...), LogDebug(NSString, ...), LogInfo(NSString, ...), LogWarning(NSString, ...), LogError(NSString, ...), LogTodo(NSString, ...)`.

Also provides macros `LOG_ASSERT, ...` which add support for capturing the file/line number of the logging statement.

Provides a SHOULD_REIMPLEMENT() macro that will log methods that require reworking. This will provide a TODO in the resulting log file indicating the file/line#/method to be fixed.
##Example

Within a project LoggerTest, the app delegate has the following method:

``` 
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LOG_DEBUG(@"message");
}
```

This will create a directory ~/Library/Logs/LoggerTest/ and a new log file yyyy-MM-dd-HHmm.log with the statement:
`2013-04-11 11:36:36.649 [1294] DEBUG (AppDelegate.m:15) message`

#Requires

This code uses dispatch_io and therefore can only target Mac OSX 10.7 or better. Built and tested on 10.8.

#License

Generic MIT License