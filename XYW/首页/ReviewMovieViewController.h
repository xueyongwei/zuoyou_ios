//
//  ReviewMovieViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseViewController.h"
#import "ZYHonCommonLayout.h"
@interface ReviewMovieViewController : BaseViewController
@property (nonatomic,copy)NSString *movieMD5;//视频MD5
@property (nonatomic,strong)NSURL *movieUrl;//视频uri
@property (nonatomic,strong)NSURL *ReferenceURL;//视频引用地址uri,计算原视频的md5用
@property (nonatomic,copy)NSString *moviePath;//视频path
@property (nonatomic,assign)CGSize movieSize;//视频size
@property (nonatomic,strong)UIImage *corverImage;//封面图
@property (nonatomic,strong) NSNumber *uploadTagId;//关联的tagID
@property (nonatomic,copy) NSString *uploadTagName;//要挑战的视频tagName
@property (nonatomic,strong) NSNumber *contestantVideoId;//挑战的视频（选）
@property (nonatomic,copy)NSString *challenge;//是否挑战已有视频
@property (nonatomic,copy) NSString *videoId; //视频的ID（个人主页选择的视频的话）
@end
