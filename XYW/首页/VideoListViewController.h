//
//  VideoListViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"

#import "VideoNormalTableViewCell.h"
#import "PKDetailViewController.h"

@interface VideoListViewController : ZYTableViewController
@property (nonatomic,strong)NSNumber *tagID;
@property (nonatomic,assign)BOOL cellTypeIsWithTag;
@property (nonatomic,copy)NSString *tagName;
@property (nonatomic,assign)BOOL shouldCareWhetherCanScroll;
@end
