//
//  LoginView.m
//  HDJ
//
//  Created by xueyongwei on 16/5/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "HowLoginView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <UMengSocial/UMSocial.h>
#import <WXApi.h>
#import <WeiboSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface HowLoginView()
@property(nonatomic,strong)MPMoviePlayerController *moviePlayer;
@property(nonatomic ,strong)AVAudioSession *avaudioSession;
@end
@implementation HowLoginView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self prepareMovie];
    }
    return self;
}
-(void)awakeFromNib
{
    [self prepareMovie];
}
-(void)prepareMovie
{
    self.avaudioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [self.avaudioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
    
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"1.mp4" ofType:nil];
    
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
    //    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    [_moviePlayer play];
    
    [self addSubview:_moviePlayer.view];
    [_moviePlayer.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self).offset(0);
    }];
    
    _moviePlayer.shouldAutoplay = YES;
    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
    [_moviePlayer setFullscreen:YES];
    
    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:_moviePlayer];
    [self sendSubviewToBack:_moviePlayer.view];
    //绘制登录的按钮界面
    [self custonLoginView];
}
-(void)playbackStateChanged{
    //取得目前状态
    MPMoviePlaybackState playbackState = [_moviePlayer playbackState];
    
    //状态类型
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
            NSLog(@"播放停止");
            [_moviePlayer play];
            break;
            
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放中");
            break;
            
        case MPMoviePlaybackStatePaused:
            NSLog(@"播放暂停");
            [_moviePlayer play];
            break;
            
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"播放被中断");
            break;
            
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"往前快转");
            break;
            
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"往后快转");
            break;
            
        default:
            NSLog(@"无法辨识的状态");
            break;
    }
}

-(void)custonLoginView
{
//    UIImageView *SprImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LoginLine"]];
//    SprImageView.frame = CGRectMake(20, SCREEN_H-120, SCREEN_W-40, 10);
//    [self addSubview:SprImageView];
   
    int i = 0;
    UIView *btnSView = [UIView new];
    btnSView.frame = CGRectMake(0, SCREEN_H-120, SCREEN_W, 60);
    [self addSubview:btnSView];
    
    //微博
    UIButton *btnWB = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWB.titleLabel.textColor = [UIColor redColor];
    
    btnWB.frame = CGRectMake(i*(SCREEN_W-60)/4, 0, (SCREEN_W-60)/4, 60);
    [btnWB setImage:[UIImage imageNamed:@"分享到微博"] forState:UIControlStateNormal];
    btnWB.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnWB addTarget:self action:@selector(onshareToWeibo:) forControlEvents:UIControlEventTouchUpInside];
    [btnSView addSubview:btnWB];
    i++;
    //微信
    
    if ([WXApi isWXAppInstalled]) {
        UIButton *btnWX = [UIButton buttonWithType:UIButtonTypeCustom];
        btnWX.titleLabel.textColor = [UIColor redColor];
        [btnWX setImage:[UIImage imageNamed:@"分享到微信"] forState:UIControlStateNormal];
        btnWX.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnWX.frame = CGRectMake(i*(SCREEN_W-60)/4, 0, (SCREEN_W-60)/4, 60);
        [btnWX addTarget:self action:@selector(onshareToWX) forControlEvents:UIControlEventTouchUpInside];
        [btnSView addSubview:btnWX];
        i++;
    }
    
    if ([QQApiInterface isQQInstalled]) {
        UIButton *btnQQ = [UIButton buttonWithType:UIButtonTypeCustom];
        btnQQ.titleLabel.textColor = [UIColor redColor];
        [btnQQ setImage:[UIImage imageNamed:@"分享到QQ" ] forState:UIControlStateNormal];
        btnQQ.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnQQ.frame = CGRectMake(i*((SCREEN_W-60))/4, 0, (SCREEN_W-60)/4, 60);
        [btnQQ addTarget:self action:@selector(onshareToQQ) forControlEvents:UIControlEventTouchUpInside];
        [btnSView addSubview:btnQQ];
        i++;
    }
    
    UIButton *btnDX = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDX.titleLabel.textColor = [UIColor redColor];
    [btnDX setImage:[UIImage imageNamed:@"分享到短信"] forState:UIControlStateNormal];
    btnDX.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    btnDX.frame = CGRectMake(i*((SCREEN_W-60))/4,0, (SCREEN_W-60)/4, 60);
    [btnDX addTarget:self action:@selector(onshareToSMS) forControlEvents:UIControlEventTouchUpInside];
    [btnSView addSubview:btnDX];
    i++;
    CGRect rect = btnSView.frame;
    CGPoint center = btnSView.center;
    if (i==2) {
        rect.size.width = ((SCREEN_W-60))/4*2;
    }else if (i==3){
        rect.size.width = ((SCREEN_W-60))/4*3;
    }else if (i==4){
        rect.size.width = ((SCREEN_W-60))/4*4;
    }
    
    btnSView.frame = rect;
    btnSView.center = center;
    //协议
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"注册/登录即同意红豆角服务协议和隐私条款"];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(11, [str length]-11)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[str length])];
    UIButton *xieyiBtn = [UIButton new];
    [xieyiBtn setAttributedTitle:str forState:UIControlStateNormal];
    xieyiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    xieyiBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [xieyiBtn addTarget:self action:@selector(onXieyiTiaokuanClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:xieyiBtn];
    [xieyiBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX).with.offset(0);
        make.width.equalTo(self.mas_width).with.offset(10);
        make.height.mas_equalTo(80);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
}
-(void)onXieyiTiaokuanClick:(UIButton *)sender
{
    XieyiController *xyVC = [[XieyiController alloc]initWithNibName:@"XieyiViewController" bundle:nil];
    [self.vc.navigationController pushViewController:xyVC animated:YES];
//    [self.vc presentViewController:xyVC animated:YES completion:nil];
}

- (void)onshareToWeibo:(UIButton *)sender {
    DbLog(@"微博");
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://www.sina.com";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];

}
-(void)onshareToWX
{
    DbLog(@"微信");
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler([[[UIApplication sharedApplication] delegate] window].rootViewController,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        [self dismiss];
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            NSLog(@"\nusername = %@,\n usid = %@,\n token = %@ iconUrl = %@,\n unionId = %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL, snsAccount.unionId);
            
        }
        
    });
}
-(void)onshareToSMS
{
    DbLog(@"短信！");
//    [self removeFromSuperview];
    [self dismiss];
}
-(void)onshareToQQ
{
    DbLog(@"QQ！");
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler([[[UIApplication sharedApplication] delegate] window].rootViewController,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
            NSLog(@"\nusername = %@,\n usid = %@,\n token = %@ iconUrl = %@,\n unionId = %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL, snsAccount.unionId);
            
        }});
}
-(void)dismiss
{
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0.0f;
        self.transform = CGAffineTransformScale(self.transform, 3.0, 3.0);
    } completion:^(BOOL finished) {
        for (UIView *v in self.subviews) {
            [v removeFromSuperview];
        }
        _moviePlayer = nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self removeFromSuperview];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
