//
//  AppDelegate.m
//  FileWatcher
//
//  Created by wave on 2017/1/13.
//  Copyright © 2017年 wave. All rights reserved.
//

#import "AppDelegate.h"
#import "FileWatcher.h"
#import "NSString+Category.h"
#import "MMFileItem.h"
#import <FinderSync/FinderSync.h>

#import "JSTFileWatcher.h"

#define DLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

@interface AppDelegate ()

@property (nonatomic,strong) FileWatcher *watcher;

@property (nonatomic,strong) JSTFileWatcher *jsFileWatcher;

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
        
    }];
    
    [self.watcher openEventStream:@[filePath] latency:0];
}

/// **************** 文件夹操作 **************** ///

-(void)_folderOperation:(NSDictionary *)dict path:(NSString *)path
{

}


/// **************** 文件操作 **************** ///
-(void)_fileOperation:(NSDictionary *)dict path:(NSString *)path
{
        NSString *fileName = [path lastPathComponent];
        
        if (dict.count != 1)
        {
            DLog(@"重命名操作");
            return ;
        }
        
        NSString *flag = dict[path];
        
        if ([flag isEqualToString:@"created"])
        {
            DLog(@"%@  新建操作",fileName);
        }
        else if ([flag isEqualToString:@"removed"])
        {
            DLog(@"%@  删除操作",fileName);
        }
        else if ([flag isEqualToString:@"renamed"])
        {
            DLog(@"%@  renamed操作",fileName);
        }
}




/// **************** 文件夹/文件公用操作 **************** ///
-(void)_batchOperation:(NSDictionary *)dict
{
    DLog(@"批量操作");
}

-(void)_batchCreateFile
{

}

-(void)_batchRemoveFile
{
    
}

-(void)_removeFile:(MMFileItem *)item
{
    DLog(@"File Removed!  %@",item.file_localPath);
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
