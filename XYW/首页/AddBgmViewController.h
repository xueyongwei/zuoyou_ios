//
//  AddBgmViewController.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"

@interface AddBgmViewController : ZYViewController
@property (nonatomic,copy)NSString *movieMD5;//视频MD5
@property (nonatomic,copy) NSString *moviePath;
@property (nonatomic,assign)CGSize movieSize;//视频size
@property (nonatomic,copy) NSString *challenge;
@property (nonatomic,strong) UIImage *corverImage;
@property (nonatomic,copy) NSString *uploadTagId;
@property (nonatomic,copy) NSString *uploadTagName;
@property (nonatomic,copy) NSString *contestantVideoId;
@property (nonatomic,copy) NSString *videoId;
@end
