//
//  ZYTableViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"

@interface ZYTableViewController : ZYViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;

//此控制器里的tableView不用改变frame或者autoLyaout
- (instancetype)initWithStyle:(UITableViewStyle)style;
//刷新数据
-(void)refreshData:(void(^)(void))finishBlock;
@end
