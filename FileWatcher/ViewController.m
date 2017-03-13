//
//  ViewController.m
//  FileWatcher
//
//  Created by wave on 2017/1/13.
//  Copyright © 2017年 wave. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//   /Users/wave/Library/Containers/com.FileWatcher/Data/Documents/TestFolder/12.jpg

    
}


-(void)mouseDown:(NSEvent *)event
{
    
    NSString *oldPath = @"/Users/wave/Library/Containers/com.FileWatcher/Data/Documents/TestFolder/未命名文件夹";
    NSString *newFileName = @"测试文件夹";
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];
    [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:oldPath] toURL:[NSURL fileURLWithPath:newPath] error:nil];
    NSLog( @"File renamed to %@", newFileName);
    
}



@end
