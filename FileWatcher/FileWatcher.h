//
//  FileWatcher.h
//  MagicBoard_Mac
//
//  Created by wave on 2017/1/18.
//  Copyright © 2017年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, FileWatcherStatus){
    FileWatcherStateRemoved,
    FileWatcherStateCreated,
    FileWatcherStateRenamed,
    FileWatcherStateEdited
};

@interface FileWatcher : NSObject {
    void (^callbackBlock)(NSDictionary *, FileWatcherStatus);
    FSEventStreamRef eventStream;
}

-(id)initWithBlock:(void (^)(NSDictionary *,FileWatcherStatus))block;
-(void)openEventStream:(NSArray*)pathsToWatch latency:(NSTimeInterval)latency;
-(void)close;

@end
