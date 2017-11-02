//
//  ZYUploadMovieManager.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QiniuSDK.h>
@interface ZYUploadMovieModel : NSObject
@property (nonatomic,copy)NSString *corverPath;
@property (nonatomic,copy)NSString *moviePath;
@property (nonatomic,copy)NSString *movieMD5;
@property (nonatomic,assign)CGSize movieSize;
@property (nonatomic,copy)NSString *challenge;
@property (nonatomic,copy) NSString *uploadDescription;
@property (nonatomic,copy) NSString *uploadTagId;
@property (nonatomic,copy) NSString *uploadTagName;
@property (nonatomic,copy) NSString *contestantVideoId;
@end


@interface ZYUploadMovieManager : NSObject

//单例，上传管理器
+ (ZYUploadMovieManager *)defaultManager;
//添加一个上传任务，FIFO原则排队
-(void)addTastWithCorverPath:(NSString *)corverPath moviePath:(NSString *)moviePath movieMD5:(NSString *)md5 movieSize:(CGSize)size challenge:(NSString *)challenge tagID:(NSString *)tagID tagName:(NSString *)tagName contestantVideoId:(NSString *)contestantVideoId description:(NSString *)description;
@end
