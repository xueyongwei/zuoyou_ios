//
//  PingLunXiaoxiViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/7/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "XiaoxiSessionModel.h"
#import "MsgUserContentVersusCell.h"
#import "SocketManager.h"
#import "XiaoxiPinglunModel.h"
#import "PKDetailViewController.h"
@interface PingLunXiaoxiViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
@property (nonatomic,strong)XiaoxiSessionModel *model;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
