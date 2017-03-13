//
//  FileWatcher.m
//  MagicBoard_Mac
//
//  Created by wave on 2017/1/18.
//  Copyright © 2017年 wave. All rights reserved.
//

#import "FileWatcher.h"
#import "NSString+Category.h"

#define DLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

static FileWatcher *selfWatcher = nil;

@interface FileWatcher()

@property (nonatomic,strong) NSMutableDictionary *mDict;

@end


@implementation FileWatcher

static void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[]) {
    
    for(int i = 0; i < numEvents; i++)
    {
        FSEventStreamEventFlags flag = eventFlags[i];
        NSString *path = [(__bridge NSArray *)eventPaths objectAtIndex:i];
        
        NSString *userName = [path getUserName];
        NSString *trashPath = [NSString stringWithFormat:@"/Users/%@/.Trash",userName];
        NSURLRelationship outRelationship;
        NSError *error;
        BOOL existFile = [[NSFileManager defaultManager] getRelationship:&outRelationship ofDirectoryAtURL:[NSURL fileURLWithPath:path] toItemAtURL:[NSURL fileURLWithPath:trashPath] error:&error];

        if (![[path lastPathComponent] isEqualToString:@".DS_Store"] && [path rangeOfString:@".sb"].location == NSNotFound && [path rangeOfString:@"~."].location == NSNotFound)
        {
            if (!existFile || flag & kFSEventStreamEventFlagItemRemoved)
            {
                [selfWatcher.mDict setValue:@"removed" forKey:path];
            }
            else if (flag & kFSEventStreamEventFlagItemCreated)
            {
                [selfWatcher.mDict setValue:@"created" forKey:path];
            }
            else if(flag & kFSEventStreamEventFlagItemRenamed)
            {
                [selfWatcher.mDict setValue:@"renamed" forKey:path];
            }
            else
            {
                DLog(@"File  其他~   %@",path);
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [selfWatcher judgeFileStatus:selfWatcher.mDict];
    });
}

-(void)judgeFileStatus:(NSDictionary *)dict
{
    if (dict.count != 0)
    {
        FileWatcherStatus operationStatus;
        BOOL isOK = [self _moreDictHandle:dict];
        
        // 判断批量操作
        if (isOK && dict.count != 1)
        {
            NSString *status = [self _getMoreOperationStatus:dict];
            
            if ([status isEqualToString:@"created"])
            {
                operationStatus = FileWatcherStateCreated;
            }
            else if ([status isEqualToString:@"removed"])
            {
                operationStatus = FileWatcherStateRemoved;
            }
            else if ([status isEqualToString:@"renamed"])
            {
                operationStatus = FileWatcherStateRenamed;
            }
        }
        else
        {
            if (dict.count != 1)
            {
                operationStatus = FileWatcherStateRenamed;
            }
            
            NSString *status = dict.allValues.firstObject;
            if ([status isEqualToString:@"created"])
            {
                operationStatus = FileWatcherStateCreated;
            }
            else if ([status isEqualToString:@"removed"])
            {
                operationStatus = FileWatcherStateRemoved;
            }
            else if ([status isEqualToString:@"renamed"])
            {
                operationStatus = FileWatcherStateRenamed;
            }
        }
        
        callbackBlock(dict,operationStatus);
        
        [selfWatcher.mDict removeAllObjects];
    }
}


/// 判断是否是多个文件操作,多个文件操作只能都是删除,新建
-(BOOL)_moreDictHandle:(NSDictionary *)dict
{
    NSMutableSet *mSet = [NSMutableSet set];
    for (NSString *value in dict.allValues)
    {
        [mSet addObject:value];
    }
    
    if (mSet.count == 1)
    {
        return YES;
    }
    return NO;
}

/// 获取批量的操作类型
-(NSString *)_getMoreOperationStatus:(NSDictionary *)dict
{
    return dict.allValues.firstObject;
}




#pragma mark -
#pragma mark Initialization

-(id)initWithBlock:(void (^)(NSDictionary *,FileWatcherStatus status))block; {
    if ((self = [super init])) {
        
        selfWatcher = self;
        self.mDict = @{}.mutableCopy;
        callbackBlock = [block copy];
    }
    return self;
}

-(id)init {
    return [self initWithBlock:^(NSDictionary *dict,FileWatcherStatus status) {
    }];
}

#pragma mark -
#pragma mark Stream

-(void)openEventStream:(NSArray*)pathsToWatch latency:(NSTimeInterval)latency {
    [self close];
    if (![pathsToWatch count]) {
        pathsToWatch = [NSArray arrayWithObject:@"/"];
    }
    FSEventStreamContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    eventStream = FSEventStreamCreate(NULL,
                                      &fsevents_callback,
                                      &context,
                                      (__bridge CFArrayRef) pathsToWatch,
                                      kFSEventStreamEventIdSinceNow,
                                     (CFAbsoluteTime) latency,
                                      kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents
                                      );
    
    FSEventStreamScheduleWithRunLoop(eventStream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(eventStream);    
}

-(void)close {
    if (eventStream) {
        FSEventStreamStop(eventStream);
        FSEventStreamInvalidate(eventStream);
        eventStream = NULL;
    }
}

#pragma mark -

-(void)dealloc
{
    [self close];
    callbackBlock = nil;
}

@end




