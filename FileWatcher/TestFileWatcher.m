//
//  TestFileWatcher.m
//  FileWatcher
//
//  Created by wave on 2017/2/10.
//  Copyright © 2017年 wave. All rights reserved.
//

#import "TestFileWatcher.h"

#import <CoreServices/CoreServices.h>

@interface TestFileWatcher()

@property (nonatomic,assign) FSEventStreamRef stream;

@end

@implementation TestFileWatcher

- (id) initWithPath:(NSString *)path
{
    self = [super init];
    if (self != nil) {
        [self initializeEventStreamWithPath:path];
    }
    return self;
}

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    size_t i;
    for(i=0; i<numEvents; i++){
        
        FSEventStreamEventId eventId = eventIds[i];
        FSEventStreamEventFlags flag = eventFlags[i];
        NSString *path = [(__bridge NSArray *)eventPaths objectAtIndex:i];
        if (![[path lastPathComponent] isEqualToString:@".DS_Store"])
        {
            NSLog(@"for index:----->: %zu      %llu    %u    %@",i,eventId,(unsigned int)flag,path);
        }
        
    }
}

- (void) initializeEventStreamWithPath:(NSString *)path
{
    NSArray *pathsToWatch = [NSArray arrayWithObject:path];
    void *appPointer = (__bridge void *)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 0;
    
    self.stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (__bridge CFArrayRef) pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, //[lastEventId unsignedLongLongValue],
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(self.stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(self.stream);
}

@end
