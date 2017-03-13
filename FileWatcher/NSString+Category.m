//
//  NSString+Category.m
//  FileWatcher
//
//  Created by wave on 2017/1/13.
//  Copyright © 2017年 wave. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

-(NSString *)getUserName
{
    NSArray *array = [self componentsSeparatedByString:@"/"];
    
    NSString *userName = array[2];
    
    return userName;
}

///判断路径文件是否存在
- (BOOL)isExistAtPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:self];
    return isExist;
}


@end
