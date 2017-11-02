//
//  ValueChartsTableViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartsTableViewCell.h"


@interface ValueChartsTableViewController : UITableViewController
@property (nonatomic,assign)ChartsType chartsType;
@property (nonatomic,assign)NSInteger tagId;
@end
