//
//  ZYListViewController.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"
//数据列表控制器，下拉刷新，上拉加在
@interface ZYListViewController : ZYTableViewController

//请求列表数据，根据返回数据刷新tableView
-(void)requestListDataWithShortUrlStr:(NSString *)shortUrl param:(NSMutableDictionary *)param resultResolver:(void(^)(NSArray *result))resolver error:(void(^)(NSNumber *errorCode,NSString *errMsg))errorBlock;
//一下方法需要子类继承而不是重写
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end
