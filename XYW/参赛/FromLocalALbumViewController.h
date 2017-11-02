//
//  FromLocalALbumViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"

@interface XassetModel : NSObject
@property (nonatomic,strong) UIImage *thumbnail;//缩略图
@property (nonatomic,copy) NSURL *imageURL;//原图url
@property (nonatomic,assign) BOOL isSelected;//是否被选中
@end

@interface FromLocalALbumViewController : ZYViewController
//是否挑战
@property (nonatomic,copy)NSString *challenge;
//要挑战的视频tagName
@property (nonatomic,copy) NSString *uploadTagName;
//要挑战的视频tagId
@property (nonatomic,strong) NSNumber *uploadTagId;
//要挑战的视频Id
@property (nonatomic,strong) NSNumber *contestantVideoId;

@end
