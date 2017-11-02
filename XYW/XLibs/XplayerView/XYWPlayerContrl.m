//
//  XYWPlayerContrl.m
//  XplayerView-Master
//
//  Created by 薛永伟 on 16/9/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XYWPlayerContrl.h"
@interface XYWPlayerContrl()<UIActionSheetDelegate>
@property (nonatomic,assign,readwrite)BOOL isShow;
@property (nonatomic,strong)UIView *bottomView;
@end
@implementation XYWPlayerContrl

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self custmView];
    }
    return self;
}
-(void)onMoreClick:(UIButton *)sender
{
    UIActionSheet *alert = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil];
    [alert showInView:[UIApplication sharedApplication].keyWindow];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        CoreSVPSuccess(@"举报成功！");
    }
}
-(void)custmView
{
    //是否已展示
    self.isShow = YES;
    //暂停按钮
    self.playOrpause = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"播放按钮"]];
    self.playOrpause.hidden = YES;
    [self addSubview:self.playOrpause];
    [self.playOrpause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(onMoreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(3);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(30);
    }];
    //底部条
    self.bottomView = [UIView new];
    self.bottomView.userInteractionEnabled = YES;
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tapBottom = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doNothing)];
    [self.bottomView addGestureRecognizer:tapBottom];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(@(60*SINGLE_LINE_WIDTH));
    }];
    //当前时间
    self.currentTimeLabel = [UILabel new];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
    self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.currentTimeLabel.text = @"--:--";
    CGSize size =  [@"88:88" sizeWithFont:[UIFont systemFontOfSize:12]];
    
    [self.bottomView addSubview:self.currentTimeLabel];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(15*SINGLE_LINE_WIDTH);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(@13);
        make.width.mas_equalTo(@(size.width));
    }];
    //总时间
    self.totalTimeLabel = [UILabel new];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12];
    self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
    self.totalTimeLabel.text = @"--:--";
    [self.bottomView addSubview:self.totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-15*SINGLE_LINE_WIDTH);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(@13);
        make.width.mas_equalTo(@(size.width));
    }];
    //下载进度条
    self.downLoadProgress = [UIProgressView new];
    self.downLoadProgress.trackTintColor = [UIColor lightGrayColor];
    self.downLoadProgress.progressTintColor = [UIColor colorWithWhite:1 alpha:0.6];
    CGPoint center = self.downLoadProgress.center;
    center.y = self.bottomView.bounds.size.height/2;
    self.downLoadProgress.center = center;
    [self.bottomView addSubview:self.downLoadProgress];
    [self.downLoadProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(15*SINGLE_LINE_WIDTH);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
        make.height.mas_equalTo(@(2*SINGLE_LINE_WIDTH));
    }];
    //播放滑动条
    self.videoSlider = [UISlider new];
    self.videoSlider.maximumTrackTintColor = [UIColor clearColor];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"slider指针"] forState:UIControlStateNormal];
    self.videoSlider.maximumValue = 1;
    self.videoSlider.minimumTrackTintColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    [self.videoSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:self.videoSlider];
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(15*SINGLE_LINE_WIDTH);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
        make.height.mas_equalTo(@15);
    }];
    //底部进度条
    self.bottomPlayProgress =[UIProgressView new];
    self.bottomPlayProgress.trackTintColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.bottomPlayProgress.progressTintColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    [self addSubview:self.bottomPlayProgress];
    [self.bottomPlayProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(@(2*SINGLE_LINE_WIDTH));
    }];
    //点击控制面板
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapControl:)];
    [self addGestureRecognizer:tap];
    //自动隐藏面板
    [self autoHiddenControl];
}
#pragma mark ---触发的操作
-(void)tapControl:(UITapGestureRecognizer *)recognizer
{
    if (self.isShow) {
        if (self.playOrpause.hidden) {//没有暂停按钮
            [self.delegate xywPause];
            self.playOrpause.hidden = NO;
        }else{
            self.playOrpause.hidden = YES;
            [self.delegate xywPlay];
            [self autoHiddenControl];
        }
    }else{
        [self controlShow];
        self.playOrpause.hidden = YES;
    }
}
-(void)doNothing
{
    
}
-(void)sliderValueChange:(UISlider *)slider
{
    NSLog(@"slider value = %f",slider.value);
    [self.delegate seekToTime:slider.value completionHandler:nil];
}
-(void)autoHiddenControl
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(controlHidden) object:nil];
    [self performSelector:@selector(controlHidden) withObject:nil afterDelay:3];
}
/*
 *  重置控制面板的状态
 */
-(void)resetControl
{
    self.videoSlider.value = 0;
    self.downLoadProgress.progress = 0;
    self.bottomPlayProgress.progress = 0;
    self.playOrpause.hidden = YES;
}
/**
 *  隐藏控制面板
 */
-(void)controlHidden
{
    if (!self.playOrpause.hidden) {//正在暂停呢
        return;
    }
    self.bottomView.hidden = YES;
    self.moreBtn.hidden = YES;
    self.bottomPlayProgress.hidden = NO;
    self.isShow  = NO;
}
/**
 *  显示控制面板
 */
-(void)controlShow
{
    self.bottomView.hidden = NO;
    self.moreBtn.hidden = NO;
    self.bottomPlayProgress.hidden = YES;
    self.isShow = YES;
    [self autoHiddenControl];
}
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - release
- (void)dealloc {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self cancelAutoFadeOutControlBar];
}
@end
