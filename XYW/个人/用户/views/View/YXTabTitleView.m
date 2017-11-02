//
//  YXTabTitleView.m
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import "YXTabTitleView.h"
#import "YX.h"

@interface YXTabTitleView()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *titleBtnArray;
@property (nonatomic, strong) NSMutableArray *numbLabels;
@property (nonatomic, strong) UIView  *indicateLine;
@property (nonatomic, strong) NSNumber *userID;

@end

@implementation YXTabTitleView

-(void)setTabNub:(YXTabItemBaseViewDelegateModel *)model
{
    UILabel *numberLabel = [self.numbLabels objectAtIndex:model.idx];
    if (numberLabel) {
        numberLabel.text = model.idx==0?[NSString stringWithFormat:@"%.0f％",model.number]:[NSString stringWithFormat:@"%f",model.number];
    }
}
-(void)reloadTabNumbData
{
    [self prepareData:self.userID];
}
-(instancetype)initWithTitleArray:(NSArray *)titleArray userId:(NSNumber *)userID{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _titleArray = titleArray;
        _titleBtnArray = [NSMutableArray array];
        _numbLabels = [NSMutableArray array];
        self.userID = userID;
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, kTabTitleViewHeight);
        CGFloat btnWidth = SCREEN_WIDTH/titleArray.count;
        
        for (int i=0; i<titleArray.count; i++) {
            UIView *tagView = [[UIView alloc]initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, kTabTitleViewHeight-8)];
            UITapGestureRecognizer *tapTag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTagView:)];
            [tagView addGestureRecognizer:tapTag];
            tagView.tag = i;
            //数字label
            UILabel *nubLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 12, btnWidth, 12)];
            nubLabel.textColor = i==0?[UIColor colorWithHexColorString:@"ff4a4b"]:[UIColor colorWithHexColorString:@"333333"];
            
            nubLabel.textAlignment = NSTextAlignmentCenter;
            nubLabel.font = [UIFont systemFontOfSize:11];
            nubLabel.tag = i+100;
            nubLabel.text = i==0?@"0％" : @"0";
            [_numbLabels addObject:nubLabel];
            [tagView addSubview:nubLabel];
            //标签名label
            UILabel *NameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, btnWidth, 15)];
            NameLabel.textColor = i==0?[UIColor colorWithHexColorString:@"ff4a4b"]:[UIColor colorWithHexColorString:@"333333"];
            NameLabel.textAlignment = NSTextAlignmentCenter;
            NameLabel.font = [UIFont systemFontOfSize:14];
            NameLabel.tag = i+200;
            NameLabel.text = _titleArray[i];
            [tagView addSubview:NameLabel];
            
            [self addSubview:tagView];
            [_titleBtnArray addObject:tagView];
        }
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, kTabTitleViewHeight-8, SCREEN_W, 8)];
        lineView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
        [self addSubview:lineView];
        _indicateLine = [[UIView alloc] initWithFrame:CGRectMake(btnWidth/2-30, kTabTitleViewHeight-9, 60, 1)];
        _indicateLine.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
        [self addSubview:_indicateLine];
    }
    [self prepareData:userID];
    return self;
}
-(void)prepareData:(NSNumber *)userID
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/social/info"] parameters:@{@"mid":userID} inView:nil sucess:^(id result) {
        DbLog(@"请求成功");
        if ([result isKindOfClass:[NSDictionary class]]) {
            {//视频
                UILabel *nubLabel = self.numbLabels[1];
                nubLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"videos"]];
            }{//关注
                UILabel *nubLabel = self.numbLabels[2];
                nubLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"follow"]];
            }{//粉丝
                UILabel *nubLabel = self.numbLabels[3];
                nubLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"fans"]];
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];
}

-(void)tapTagView:(UITapGestureRecognizer *)rec
{
    NSInteger tag = rec.view.tag;
    [self setItemSelected:tag];
    
    if (self.titleClickBlock) {
        self.titleClickBlock(tag);
    }
}
-(void)clickBtn : (UIButton *)btn{
    NSInteger tag = btn.tag;
    [self setItemSelected:tag];
    
    if (self.titleClickBlock) {
        self.titleClickBlock(tag);
    }
}

-(void)setItemSelected: (NSInteger)column{
    for (int i=0; i<_titleBtnArray.count; i++) {
        UIView *view = _titleBtnArray[i];
        if (i == column) {
            for (UILabel *label  in view.subviews) {
                label.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
            }
        }else{
            for (UILabel *label  in view.subviews) {
                label.textColor = [UIColor colorWithHexColorString:@"333333"];
            }
        }
    }
    if (column!=1) {//当前标签不是视频
        [self.videoTableView stopPlay];
    }
    CGFloat btnWidth = SCREEN_WIDTH/_titleBtnArray.count;
    _indicateLine.frame = CGRectMake(btnWidth/2-30+btnWidth*column, kTabTitleViewHeight-9, 60, 1);
}

@end
