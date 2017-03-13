//
//  AppDelegate.m
//  FileWatcher
//
//  Created by wave on 2017/1/13.
//  Copyright © 2017年 wave. All rights reserved.
//

/*
    这个工具只能检测到文件的 新建/删除/修改/重命名 4个操作    其他操作(比如修改权限)都放在other里.
 */

#import "AppDelegate.h"
#import "FileWatcher.h"
#import "NSString+Category.h"
#import "MMFileItem.h"
#import <FinderSync/FinderSync.h>

#define DLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

@interface AppDelegate ()

@property (nonatomic,strong) FileWatcher *watcher;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        filePath = [filePath stringByAppendingPathComponent:@"TestFolder"];
        [[NSFileManager defaultManager]createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
        [self addPathToSharedItem:filePath];
    
        [self demoOne:filePath];
}

-(void)demoOne:(NSString *)filePath
{
        self.watcher = [[FileWatcher alloc] initWithBlock:^(NSDictionary *dict,FileWatcherStatus status) {
            
                if (status == FileWatcherStateCreated)
                {
                        DLog(@"created  --->  %@",dict);
                }
                else if (status == FileWatcherStateRemoved)
                {
                        DLog(@"removed  --->  %@",dict);
                }
                else if (status == FileWatcherStateRenamed)
                {
                        DLog(@"renamed  --->  %@",dict);
                }
                else if (status == FileWatcherStateEdited)
                {
                        DLog(@"edited  --->  %@",dict);
                }
                else if (status == FileWatcherStateOther)
                {
                        DLog(@"other  --->  %@",dict);
                }
        }];
        
        [self.watcher openEventStream:@[filePath] latency:0];
}

/// **************** folder operation **************** ///

-(void)_folderOperation:(NSDictionary *)dict path:(NSString *)path
{
}


/// **************** file operation **************** ///
-(void)_fileOperation:(NSDictionary *)dict path:(NSString *)path
{
}

/// add sidebar
-(void)addPathToSharedItem:(NSString *)path
{
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    
        LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,
                                                                   kLSSharedFileListFavoriteItems, NULL);
        if (favoriteItems)
        {

                LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(favoriteItems,
                                                                             kLSSharedFileListItemLast, NULL, NULL,
                                                                             url, NULL, NULL);
                if (item)
                {
                        CFRelease(item);
                }
        }
        
        if (favoriteItems)
        {
                CFRelease(favoriteItems);
        }

}




@end
