//
//  VersusListViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"
#import "VersusNormalTableViewCell.h"
#import "PKDetailViewController.h"

@interface VersusListViewController : ZYTableViewController
@property (nonatomic,copy) NSString *requestURL;
@property (nonatomic,assign) BOOL noMoreDataPage;
@property (nonatomic,copy) NSString *noMoreDataMessage;
@property (nonatomic,assign)BOOL shouldCareWhetherCanScroll;

@end
