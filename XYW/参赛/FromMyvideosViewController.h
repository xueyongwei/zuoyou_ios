//
//  FromMyvideosViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"

@interface FromMyvideosViewController : ZYViewController
//要挑战的视频tagName
@property (nonatomic,copy) NSString *uploadTagName;
//要挑战的视频tagId
@property (nonatomic,copy) NSString *uploadTagId;
//要挑战的视频Id
@property (nonatomic,copy) NSString *contestantVideoId;
@end
