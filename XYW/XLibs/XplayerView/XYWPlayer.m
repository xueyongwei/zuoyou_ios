//
//  XYWPlayer.m
//  XplayerView-Master
//
//  Created by 薛永伟 on 16/9/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XYWPlayer.h"
#import "XYWPlayerContrl.h"

@interface XYWPlayer()<XYWPlayerContrlDelegate>

//视频的itm
@property (nonatomic ,readonly) AVPlayerItem *item;
//视频播放器layer
@property (nonatomic ,readonly) AVPlayerLayer *playerLayer;
//视频播放器
@property (nonatomic ,readonly) AVPlayer *player;
//控制视图
@property (nonatomic,strong) XYWPlayerContrl *playerContrl;
//代理
@property (nonatomic ,weak) id <XYWPlayerDelegate> Delegate;


@property (nonatomic ,strong)  id timeObser;

@property (nonatomic ,assign) float videoLength;

@property (nonatomic ,assign) CGPoint lastPoint;

@property (nonatomic ,assign) BOOL isPauseByUser;


@end

@implementation XYWPlayer


- (id)initWithUrl:(NSString *)path frame:(CGRect)frame delegate:(id<XYWPlayerDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _playerUrl = path;
        _Delegate = delegate;
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self setUpPlayer];
        
        _playerContrl = [[XYWPlayerContrl alloc]initWithFrame:frame];
        _playerContrl.delegate = self;
        [self addSubview:_playerContrl];
        
    }
    return self;
}

- (void)setUpPlayer {
    //本地视频
    //NSURL *rul = [NSURL fileURLWithPath:_playerUrl];
    
    self.isPauseByUser = NO;
    NSURL *url = [NSURL URLWithString:_playerUrl];
    NSLog(@"%@",url);
    
    _item = [[AVPlayerItem alloc] initWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:_item];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:_playerLayer];
    
    [self addVideoKVO];
    [self addVideoTimerObserver];
    [self addVideoNotic];
    [self bringSubviewToFront:self.playerContrl];
}
-(void)resetPlayer
{
    [self.player pause];
    [self removeVideoKVO];
    [self removeVideoNotic];
    [self removeVideoTimerObserver];
    _item = nil;
    self.playerUrl = @"";
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.isPauseByUser = NO;
    [self.playerContrl resetControl];
    
    _player = nil;
    
}
-(void)changUrl:(NSString *)videoUrl
{
    [self resetPlayer];
    self.playerUrl = videoUrl;
    [self setUpPlayer];
}
/**
 *  这可是用户自己要play的
 */
-(void)xywPlay
{
    [self.player play];
    self.isPauseByUser = NO;
}
/**
 *  这可是用户自己要pause的
 */
-(void)xywPause
{
    [self.player pause];
    self.isPauseByUser = YES;
}

#pragma mark - KVO
- (void)addVideoKVO
{
    //KVO
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeVideoKVO {
    [_item removeObserver:self forKeyPath:@"status"];
    [_item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = _item.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [_player play];
                _videoLength = floor(_item.asset.duration.value * 1.0/ _item.asset.duration.timescale);
                self.playerContrl.totalTimeLabel.text = [self getVideoLengthFromTimeLength:_videoLength];
                NSLog(@"%f",_videoLength);
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"AVPlayerItemStatusFailed");
                NSLog(@"%@",_item.error);
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.item.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.playerContrl.downLoadProgress setProgress:timeInterval/totalDuration animated:YES];
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    }
}
#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - Notic
- (void)addVideoNotic {
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieJumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStalle:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backGroundPauseMoive) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}
- (void)removeVideoNotic {
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)movieToEnd:(NSNotification *)notic {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.Delegate playDidEnd:self];
}
- (void)movieJumped:(NSNotification *)notic {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)movieStalle:(NSNotification *)notic {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}
-(void)enterPlayGround
{
    if (self.isPauseByUser) {
        [self xywPause];
    }
}
- (void)backGroundPauseMoive {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.player pause];
}

#pragma mark - TimerObserver
- (void)addVideoTimerObserver {
    __weak typeof (self)self_ = self;
    _timeObser = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        float currentTimeValue = time.value*1.0/time.timescale/self_.videoLength;
        NSString *currentString = [self_ getStringFromCMTime:time];
        if (![currentString isEqualToString:@"00:00"]) {
            self_.playerContrl.currentTimeLabel.text = currentString;
            [self_.playerContrl.videoSlider setValue:currentTimeValue animated:YES];
            [self_.playerContrl.bottomPlayProgress setProgress:currentTimeValue animated:YES];
        }
    }];
}
- (void)removeVideoTimerObserver {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [_player removeTimeObserver:_timeObser];
}


#pragma mark - Utils
- (NSString *)getStringFromCMTime:(CMTime)time
{
    float currentTimeValue = (CGFloat)time.value/time.timescale;//得到当前的播放时
    
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:currentTimeValue];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:currentDate];
    
    if (currentTimeValue >= 3600 )
    {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%02ld:%02ld",components.minute,components.second];
    }
}

- (NSString *)getVideoLengthFromTimeLength:(float)timeLength
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeLength];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    if (timeLength >= 3600 )
    {
        return [NSString stringWithFormat:@"%ld:%ld:%ld",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld:%ld",components.minute,components.second];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}

- (void)seekToTime:(float)dragedSecondsPercent completionHandler:(void (^)(BOOL finished))completionHandler;
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSecondsPercent*self.videoLength, 1);
        [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            // 视频跳转回调
            if (completionHandler) {
                completionHandler(finished);
            }
            
        }];
    }
}


#pragma mark - release
- (void)dealloc {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self removeVideoTimerObserver];
    [self removeVideoNotic];
    [self removeVideoKVO];
}

@end