//
//  PKFansViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/6/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseViewController.h"
#import "BangDanModel.h"
#import "BangdanTableViewCell.h"
#import "Bangdan1TableViewCell.h"
#import "Bangdan2TableViewCell.h"
#import "Bangdan3TableViewCell.h"

#import "UHCenterViewController.h"
@protocol  MyVideoDelegate <NSObject>
- (void)delegatePlayVideo;
@end

@interface PKFansViewController :BaseTableViewController<BDTableViewCellDelegate>
@property (nonatomic,assign)NSInteger pkID;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,weak)id<MyVideoDelegate> delegate;
@end
