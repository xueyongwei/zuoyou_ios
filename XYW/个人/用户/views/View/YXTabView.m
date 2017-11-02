//
//  YXTabView.m
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import "YXTabView.h"
#import "UserInfoManager.h"

@interface YXTabView()<UIScrollViewDelegate>


@property (nonatomic, strong) UIScrollView *tabContentView;

@end

@implementation YXTabView
-(BOOL)isMe:(NSInteger)userId
{
    return [UserInfoManager isMeOfID:userId];
}
-(instancetype)initWithTabConfigArray:(NSArray *)tabConfigArray userId:(NSNumber *)userID block:(vcActionBlock)block{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.isMe = [self isMe:userID.integerValue];
        CGRect rect = self.isMe?CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-kTopBarHeight):CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-kBottomBarHeight-kTopBarHeight);
        self.frame = rect;
        
        NSMutableArray *titleArray = [NSMutableArray array];
        for (int i=0; i<tabConfigArray.count; i++) {
            NSDictionary *itemDic = tabConfigArray[i];
            [titleArray addObject:itemDic[@"title"]];
        }
        _tabTitleView = [[YXTabTitleView alloc] initWithTitleArray:titleArray userId:userID];
        
        __weak typeof(self) weakSelf = self;
        _tabTitleView.titleClickBlock = ^(NSInteger row){
            //NSLog(@"当前点击%zi",row);
            if (weakSelf.tabContentView) {
                weakSelf.tabContentView.contentOffset = CGPointMake(SCREEN_WIDTH*row, 0);
            }
        };
        
        [self addSubview:_tabTitleView];
        
        _tabContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tabTitleView.frame), SCREEN_WIDTH, CGRectGetHeight(self.frame) - CGRectGetHeight(_tabTitleView.frame))];
        _tabContentView.contentSize = CGSizeMake(CGRectGetWidth(_tabContentView.frame)*titleArray.count, CGRectGetHeight(_tabContentView.frame));
        _tabContentView.pagingEnabled = YES;
        _tabContentView.bounces = NO;
        _tabContentView.showsHorizontalScrollIndicator = NO;
        _tabContentView.delegate = self;
        [self addSubview:_tabContentView];
        
        for (int i=0; i<tabConfigArray.count; i++) {
            NSDictionary *info = tabConfigArray[i];
            NSString *clazzName = info[@"view"];
            Class clazz = NSClassFromString(clazzName);
            YXTabItemBaseView *itemBaseView = [[clazz alloc] init];
            itemBaseView.isMe = self.isMe;
            itemBaseView.delegate = _tabTitleView;
            itemBaseView.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
            itemBaseView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
            itemBaseView.userID = userID;
            [itemBaseView renderUIWithInfo:tabConfigArray[i] block:block];
            [_tabContentView addSubview:itemBaseView];
            if (i==1) {
                _tabTitleView.videoTableView = itemBaseView;
            }
        }
                         
    }
    return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger pageNum = offsetX/SCREEN_WIDTH;
    //NSLog(@"pageNum == %zi",pageNum);
    [_tabTitleView setItemSelected:pageNum];
}

@end
