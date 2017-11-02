//
//  XiaoxiTopViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/7/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "XiaoxiSessionModel.h"
#import "MsgDetailTopTableViewCell.h"
#import "SocketManager.h"
#import "XIaoxiGitfModel.h"
@interface XiaoxiTopViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)XiaoxiSessionModel *model;
@end
