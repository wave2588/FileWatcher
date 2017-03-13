//
//  MMFileItem.h
//  FileWatcher
//
//  Created by wave on 2017/2/24.
//  Copyright © 2017年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFileItem : NSObject


@property (nonatomic,copy) NSString *id;                            /// 数据库id,不用管

@property (nonatomic,copy) NSString *file_id;                       /// 文件id

@property (nonatomic,copy) NSString *file_teamID;                   /// 文件所在的团队id

@property (nonatomic,copy) NSString *file_md5;                      /// 文件md5值

@property (nonatomic,copy) NSString *file_name;                     /// 文件名称

@property (nonatomic,copy) NSString *file_createUserName;           /// 文件创建者

@property (nonatomic,copy) NSString *file_createUserID;             /// 文件创建者id

@property (nonatomic,copy) NSString *file_createTime;               /// 文件创建时间

@property (nonatomic,copy) NSString *file_updateTime;               /// 文件更新时间,永远是最新的状态

@property (nonatomic,copy) NSString *file_downloadUrl;              /// 文件下载地址

@property (nonatomic,copy) NSString *file_localPath;                /// 文件本地路径

@property (nonatomic,copy) NSString *file_deleted;                  /// 判断当前文件是否是删除状态


@end
