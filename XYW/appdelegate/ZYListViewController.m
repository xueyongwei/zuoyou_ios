//
//  ZYListViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYListViewController.h"

@interface ZYListViewController ()
@property (nonatomic,assign)NSInteger currentPageToRequestNewworkData;//要请求的数据的分页
@property (nonatomic,assign)BOOL isRequestingNewworkData;//正在请求数据
@end

@implementation ZYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageToRequestNewworkData = 1;
    self.isRequestingNewworkData = NO;
    [self customZYTableView];
}
-(void)customZYTableView
{
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPageToRequestNewworkData = 1;
        [wkSelf.tableView.mj_footer resetNoMoreData];
        [wkSelf prepareData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [wkSelf prepareData];
    }];
}
//子类在这里写准备数据，调用requestListDataWithShortUrlStr方法解析数据
-(void)prepareData{}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+5>self.dataSource.count) {//剩余的不足5条了
        DbLog(@"剩余的不到5条可供显示了");
        if (!self.isRequestingNewworkData && self.tableView.mj_footer.state != MJRefreshStateNoMoreData) {//没有正在请求数据,且还有数据
            //继续发起请求
            DbLog(@"我发起了数据请求");
            [self prepareData];
        }else{
            DbLog(@"但是并不需要去请求数据");
        }
    }
}
-(void)requestListDataWithShortUrlStr:(NSString *)shortUrl param:(NSMutableDictionary *)param resultResolver:(void(^)(NSArray *result))resolver error:(void(^)(NSNumber *errorCode,NSString *errMsg))errorBlock{
    
    if (self.isRequestingNewworkData) {
        DbLog(@"有正在进行的请求，先歇着吧");
        return;
    }
    //设置为正在请求数据
    self.isRequestingNewworkData = YES;
    __weak typeof(self) wkSelf = self;
    //添加分页信息
    [param setObject:@(self.currentPageToRequestNewworkData) forKey:@"pn"];
    //发起数据请求
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,shortUrl] parameters:param inView:nil sucess:^(id result) {
        DbLog(@"请求成功,result ＝ \n%@",result);
        [wkSelf.tableView.mj_header endRefreshing];
        if ([result isKindOfClass:[NSArray class]] ){//返回的是数组
            if ( ((NSArray *)result).count<1) {//并且没有了内容
                [wkSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{//还有数据
                if (wkSelf.currentPageToRequestNewworkData == 1) {//当前请求的是第一页，清理一下数据
                    [wkSelf.dataSource removeAllObjects];
                }
                [wkSelf.tableView.mj_footer endRefreshing];
                //数据请求成功，且还有数据，当前要请求的页数加1
                wkSelf.currentPageToRequestNewworkData ++;
            }
            resolver(result);
        }else{//列表页返回的不是数组
            [wkSelf.tableView.mj_footer endRefreshing];
            if ([result objectForKey:@"errCode"]) {//有错误信息
                errorBlock([result objectForKey:@"errCode"],[result objectForKey:@"errMsg"]);
            }
        }
        //可以发起下次请求了
        wkSelf.isRequestingNewworkData = NO;
    } failure:^(NSError *error) {
        wkSelf.isRequestingNewworkData = NO;
        [wkSelf.tableView.mj_header endRefreshing];
        [wkSelf.tableView.mj_footer endRefreshing];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
