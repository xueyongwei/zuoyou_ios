//
//  XYWPlayer.h
//  XplayerView-Master
//
//  Created by 薛永伟 on 16/9/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol XYWPlayerDelegate <NSObject>
//播放完成，代理移除本player
-(void)playDidEnd:(UIView *)player;
@end

@interface XYWPlayer : UIView
//播放视频地址
@property (nonatomic ,copy) NSString *playerUrl;
//创建方法
- (id)initWithUrl:(NSString *)path frame:(CGRect)frame delegate:(id<XYWPlayerDelegate>)delegate;
//播放另一个视频
-(void)changUrl:(NSString *)videoUrl;
//重置播放器
-(void)resetPlayer;
-(void)xywPause;
-(void)xywPlay;
//- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler;
@end
