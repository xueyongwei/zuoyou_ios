//
//  LiwuXiaoxiViewController.h
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
#import "XIaoxiGitfModel.h"
#import "PKDetailViewController.h"
@interface LiwuXiaoxiViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)XiaoxiSessionModel *model;
@end
