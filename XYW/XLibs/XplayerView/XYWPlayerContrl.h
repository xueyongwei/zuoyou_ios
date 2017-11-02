//
//  XYWPlayerContrl.h
//  XplayerView-Master
//
//  Created by 薛永伟 on 16/9/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XYWPlayerContrlDelegate <NSObject>
//-(void)onceClick;
-(void)xywPlay;
-(void)xywPause;
- (void)seekToTime:(float)dragedSecondsPercent completionHandler:(void (^)(BOOL finished))completionHandler;
@end
@interface XYWPlayerContrl : UIView
@property (nonatomic,weak)id <XYWPlayerContrlDelegate>delegate;
@property (nonatomic,strong)UIButton *moreBtn;
@property (nonatomic,strong)UIImageView *playOrpause;
@property (nonatomic,strong)UILabel *currentTimeLabel;
@property (nonatomic,strong)UILabel *totalTimeLabel;
@property (nonatomic,strong)UIProgressView *downLoadProgress;
@property (nonatomic,strong)UIProgressView *bottomPlayProgress;
@property (nonatomic,strong)UISlider *videoSlider;
@property (nonatomic,assign,readonly)BOOL isShow;
-(void)resetControl;
-(void)controlHidden;
-(void)controlShow;
@end
