//
//  XiaoxiViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/6/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@protocol XiaoxiViewControllerProtocol <NSObject>
-(void)prepareXiaoxi;
@end

@interface XiaoxiViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,weak) id<XiaoxiViewControllerProtocol> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
//@property (nonatomic,strong) NSArray *xiaoxiModels;
//-(void)reloadList;
@end
