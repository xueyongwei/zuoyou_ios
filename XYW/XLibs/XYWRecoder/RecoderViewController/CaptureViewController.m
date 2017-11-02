//
//  CaptureViewController.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-12.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "CaptureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ProgressBar.h"
#import "SBCaptureToolKit.h"
#import "SBVideoRecorder.h"
#import "DeleteButton.h"
#import "PlayViewController.h"
#import "MBProgressHUD.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SimpleVideoFileFilterViewController.h"

#import "ReviewMovieViewController.h"
#import "XYWAlert.h"
#import "UIImage+Color.h"
#import "MarqueeLabel.h"

#include <sys/param.h>
#include <sys/mount.h>

#define TIMER_INTERVAL 0.05f

#define TAG_ALERTVIEW_CLOSE_CONTROLLER 10086

@interface CaptureViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) SBVideoRecorder *recorder;
@property (strong,nonatomic) UIImageView *redPoint;
@property (strong,nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) ProgressBar *progressBar;

@property (strong, nonatomic) DeleteButton *deleteButton;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *importVideoBtn;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) MarqueeLabel *tagNameLabel;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *flashButton;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (assign, nonatomic) BOOL initalized;
@property (assign, nonatomic) BOOL isProcessingData;

@property (strong, nonatomic) UIView *preview;
@property (strong, nonatomic) UIImageView *focusRectView;

@end

@implementation CaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    //删除本次拍摄的所有视频
    [self dropTheVideo];
    //删除缓存路径
//    [self cleanCachesAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
//    //删除路径下所有视频
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *videosPath = [documentPath stringByAppendingPathComponent:@"videos"];
//    [self cleanCachesAtPath:videosPath];
}
// 根据路径删除文件
- (void)cleanCachesAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];
    self.view.backgroundColor = [UIColor whiteColor];
    [self capInitalize];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}
-(void)appDidEnterBackground
{
    if (self.recordButton.selected) {//正在录制，触发点击
        [self pressRecoderBtn];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //如果有状态栏，需要隐藏
    if (![UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_initalized) {
        return;
    }
    [self initRecorder];
    self.initalized = YES;
}
-(void)capInitalize
{
    [self initPreview];
    
    //创建视频暂存文件夹
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self initProgressBar];
    [self initRecordButton];
    [self initTimeLabel];
    [self initDeleteButton];
    [self initOKButton];
    [self initImportVideoBtn];
    [self initNavigationItem];
    
}
#pragma mark ---定制控件
//视频预览控件
- (void)initPreview
{
    self.preview = [[UIView alloc] init];
//                    WithFrame:CGRectMake(0, 44, DEVICE_SIZE.width, DEVICE_SIZE.width)];
    _preview.clipsToBounds = YES;
    _preview.backgroundColor = [UIColor blackColor];
    //    [self.view insertSubview:_preview belowSubview:_maskView];
    [self.view addSubview:_preview];
    [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(44);
        make.top.right.left.equalTo(self.view);
        make.height.equalTo(_preview.mas_width);
    }];
}
//录像机
- (void)initRecorder
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus authSounStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限
        authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问
    {
        [self dismissViewControllerAnimated:YES completion:^{
            // 无权限 引导去开启
            [XYWAlert XYWAlertTitle:@"左右无法使用相机" message:@"请前往“设置”开启左右访问设备的权限" first:@"去允许" firstHandle:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            } second:nil Secondhandle:nil cancle:@"取消" handle:^{
                
            }];
        }];
        return;
    }
    if (authSounStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的麦克风数据。可能是家长控制权限
        authSounStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了
    {
        [self dismissViewControllerAnimated:YES completion:^{
            // 无权限 引导去开启
            [XYWAlert XYWAlertTitle:@"左右无法使用麦克风" message:@"请前往“设置”开启左右访问设备的权限" first:@"去允许" firstHandle:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            } second:nil Secondhandle:nil cancle:@"取消" handle:^{
                
            }];
        }];
        return;
    }
    self.recorder = [[SBVideoRecorder alloc] init];
    _recorder.delegate = self;
    _recorder.preViewLayer.frame = CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.width);
    [self.preview.layer addSublayer:_recorder.preViewLayer];
    //focus rect view 对焦
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(_preview.center.x, _preview.center.y, 50, 50)];
    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
    _focusRectView.alpha = 0;
    [self.preview addSubview:_focusRectView];
}
//录制进度条
- (void)initProgressBar
{
    self.progressBar = [ProgressBar getInstance];
    
    [SBCaptureToolKit setView:_progressBar toOriginY:DEVICE_SIZE.width];
    //    [self.view insertSubview:_progressBar belowSubview:_maskView];
    [self.view addSubview:_progressBar];
  
    [_progressBar startShining];
}
//录制按钮
- (void)initRecordButton
{
//    CGFloat buttonW = 111.0f;
    CGFloat buttonW = SCREEN_W/3;
    CGFloat bottomToolViewCenterY =( DEVICE_SIZE.height-(_progressBar.frame.origin.y + _progressBar.frame.size.height) )/2 + (_progressBar.frame.origin.y + _progressBar.frame.size.height) ;
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_SIZE.width - buttonW) / 2.0,bottomToolViewCenterY-buttonW/2, buttonW, buttonW)];
    [_recordButton setImage:[UIImage imageNamed:@"录制btn"] forState:UIControlStateNormal];
    _recordButton.adjustsImageWhenHighlighted = NO;
    
    UIImage *recoding = [UIImage imageNamed:@"录制中btn"];
    UIImage *recoding1 = [UIImage imageNamed:@"录制中btn1"];
    UIImage *recoding2 = [UIImage imageNamed:@"录制中btn2"];
    NSArray *animages = @[recoding,recoding1,recoding2,recoding1];
    _recordButton.imageView.animationImages = animages;
    _recordButton.imageView.animationRepeatCount = 0;
    _recordButton.imageView.animationDuration = 1.0f;
    
    //    [self.view insertSubview:_recordButton belowSubview:_maskView];
    [self.view addSubview:_recordButton];
    
    [_recordButton addTarget:self action:@selector(pressRecoderBtn) forControlEvents:UIControlEventTouchUpInside];
    
}

//删除按钮
- (void)initDeleteButton
{
    if (_isProcessingData) {
        return;
    }
    
    self.deleteButton = [DeleteButton getInstance];
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    [SBCaptureToolKit setView:_deleteButton toOrigin:CGPointMake(30, self.view.frame.size.height - _deleteButton.frame.size.height - 10)];
    [_deleteButton addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _deleteButton.center;
    center.y = _recordButton.center.y;
    _deleteButton.center = center;
    
    //    [self.view insertSubview:_deleteButton belowSubview:_maskView];
    [self.view addSubview:_deleteButton];
    
}
//时间按钮
-(void)initTimeLabel
{
    //    CGSize labelSize = CGSizeMake(100.0f, 13.0f);
    //    CGFloat centX = _recordButton.center.x;
    //    CGFloat centY = _recordButton.frame.origin.y-4-labelSize.height/2;
    //
    self.timeLabel = [UILabel new];
    //    [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    //    self.timeLabel.center = CGPointMake(centX, centY);
    
    self.timeLabel.font = [UIFont systemFontOfSize:13];
    self.timeLabel.text = @"0:0";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    //    [self.view insertSubview:_timeLabel belowSubview:_maskView];
    [self.view addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_recordButton);
        make.bottom.equalTo(_recordButton.mas_top).offset(-4);
        make.height.mas_equalTo(13);
    }];
    
    self.timeLabel.hidden = YES;
    
    self.redPoint = [UIImageView new];
    _redPoint.image = [UIImage new];
    {
        UIImage *emptyImg = [UIImage imageFromContextWithColor:[UIColor clearColor]];
        UIImage *redPointImg = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"ff4a4b"]];
        _redPoint.animationImages = @[emptyImg,redPointImg];
        _redPoint.animationDuration = 0.5;
    }
    
    _redPoint.layer.cornerRadius = 3;
    _redPoint.clipsToBounds = YES;
    [self.view addSubview:_redPoint];
    [_redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_timeLabel);
        make.right.equalTo(_timeLabel.mas_left).offset(-5);
        make.width.height.mas_equalTo(6);
    }];
    
}

//导入视频按钮
-(void)initImportVideoBtn
{
    self.importVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _importVideoBtn.hidden = NO;
    
    [_importVideoBtn setImage:[UIImage loadImageNamed:@"视频btn"] forState:UIControlStateNormal];
    [_importVideoBtn setImage:[UIImage loadImageNamed:@"视频btn-click"] forState:UIControlStateHighlighted];
    
    [_importVideoBtn addTarget:self action:@selector(pressImpotrBtn) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _importVideoBtn.center;
    center.y = _recordButton.center.y;
    _importVideoBtn.center = center;
    
    //    [self.view insertSubview:_importVideoBtn belowSubview:_maskView];
    [self.view addSubview:_importVideoBtn];
    [_importVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_recordButton);
        make.right.equalTo(self.view).offset(-30);
        make.width.height.equalTo(_deleteButton);
    }];
}
//OK按钮
- (void)initOKButton
{
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [[UIButton alloc] initWithFrame:CGRectMake(0, 0, okButtonW, okButtonW)];
    _okButton.hidden = YES;
    
    [_okButton setImage:[UIImage loadImageNamed:@"对号btn-click"] forState:UIControlStateHighlighted];
    
    [_okButton setImage:[UIImage loadImageNamed:@"对号btn"] forState:UIControlStateNormal];
    
    //    [SBCaptureToolKit setView:_okButton toOrigin:CGPointMake(self.view.frame.size.width - 30, self.view.frame.size.height - 10)];
    
    [_okButton addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _okButton.center;
    center.y = _recordButton.center.y;
    _okButton.center = center;
    
    //    [self.view insertSubview:_okButton belowSubview:_maskView];
    [self.view addSubview:_okButton];
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_recordButton);
        make.right.equalTo(self.view).offset(-30);
        make.width.height.equalTo(_deleteButton);
    }];
}
//顶部控制条
- (void)initNavigationItem
{
    CGFloat buttonW = 44.0f;
    
    //关闭
//    self.closeButton = [[UIButton alloc] init];
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonW, buttonW)];
    [_closeButton setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateNormal];
    // [_closeButton setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateDisabled];
    //[_closeButton setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateSelected];
    //[_closeButton setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view insertSubview:_closeButton belowSubview:_maskView];
    UIBarButtonItem *backItm = [[UIBarButtonItem alloc]initWithCustomView:_closeButton];
    UIBarButtonItem *negativeSpacerL = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacerL.width = -15;//修正左侧间隙
    UIBarButtonItem *emptyItm = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    emptyItm.width = buttonW;//左右对称，让title居中
    self.navigationItem.leftBarButtonItems = @[negativeSpacerL,backItm,emptyItm];
//    [self.view addSubview:_closeButton];
    
    //标题栏目
    MarqueeLabel *label = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.marqueeType = MLLeftRight;
    label.rate = 60.0f;
    label.fadeLength = 10.0f;
    label.leadingBuffer = 0.0f;
    label.trailingBuffer = 44;
    label.textAlignment = NSTextAlignmentCenter;
    
    self.tagNameLabel = label;
    
    //    self.tagNameLabel.center = CGPointMake(self.view.center.x, 22);
    self.tagNameLabel.font = [UIFont systemFontOfSize:16];
    self.tagNameLabel.text = self.tagName;
    self.tagNameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    self.tagNameLabel.textAlignment = NSTextAlignmentCenter;
    self.tagNameLabel.hidden = YES;
    self.navigationItem.titleView = self.tagNameLabel;
    
    //    [self.view insertSubview:_tagNameLabel belowSubview:_maskView];
//    [self.view addSubview:_tagNameLabel];
//    [_tagNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.centerY.equalTo(_closeButton.mas_centerY);
//        make.height.mas_equalTo(17);
//        make.width.mas_lessThanOrEqualTo(SCREEN_W-20);
//    }];
    
    //前后摄像头转换
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonW, buttonW)];
//                         initWithFrame:CGRectMake(self.view.frame.size.width , 0, buttonW, buttonW)];
    [_switchButton setImage:[UIImage imageNamed:@"镜头切换btn"] forState:UIControlStateNormal];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
    [_switchButton setImage:[UIImage imageNamed:@"镜头切换btn"] forState:UIControlStateSelected];
    [_switchButton setImage:[UIImage imageNamed:@"镜头切换btn-click"] forState:UIControlStateHighlighted];
    [_switchButton setImage:[UIImage imageNamed:@"镜头切换btn-click"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_switchButton addTarget:self action:@selector(pressSwitchButton) forControlEvents:UIControlEventTouchUpInside];
    //    _switchButton.enabled = [_recorder isFrontCameraSupported];
    //    [self.view insertSubview:_switchButton belowSubview:_maskView];
//    [self.view addSubview:_switchButton];
    
    
    //闪光灯
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonW, buttonW)];
//                        initWithFrame:CGRectMake(self.view.frame.size.width - buttonW
//                                                                  , 0, buttonW, buttonW)];
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关btn"] forState:UIControlStateNormal];
    //    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关btn"] forState:UIControlStateDisabled];
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-开btn-click"] forState:UIControlStateHighlighted];
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关btn-click"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-开btn"] forState:UIControlStateSelected];
    //如果是后置摄像头，根据是否支持判断：_recorder.isTorchSupported
    _flashButton.enabled = NO;
    _flashButton.hidden = YES;
    [_flashButton addTarget:self action:@selector(pressFlashButton) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view insertSubview:_flashButton belowSubview:_maskView];
//    [self.view addSubview:_flashButton];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer1.width = -15;//修正间隙
    UIBarButtonItem *swchItm = [[UIBarButtonItem alloc]initWithCustomView:_switchButton];
    UIBarButtonItem *flashItm = [[UIBarButtonItem alloc]initWithCustomView:_flashButton];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer1,swchItm,flashItm];
    
    
}
#pragma mark --- 点击触发的事件
-(void)pressRecoderBtn
{
    if ([self freeDiskSpaceInBytes]<100) {
        [XYWAlert XYWAlertTitle:@"设备存储空间不足！" message:@"可能导致您无法正常拍摄/上传视频,请在系统设置中清理" first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"" handle:nil];
        return;
    }
    if (_isProcessingData) {
        return;
    }
    _recordButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _recordButton.userInteractionEnabled = YES;
    });
    [self touchesBegan:[NSSet set] withEvent:nil];//触发一下点击屏幕事件
    _recordButton.selected = !_recordButton.selected;
    
    if (_recordButton.selected) {
        [_recordButton.imageView startAnimating];
    }else{
        [_recordButton.imageView stopAnimating];
    }
    if (_recordButton.selected) {//开始录制
        NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
        [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
        [_redPoint startAnimating];
    }else{
        //停止录像
        [_recorder stopCurrentVideoRecording];
        [_redPoint stopAnimating];
    }
}
//点击了关闭按钮
- (void)pressCloseButton
{
    if ([_recorder getVideoCount] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"放弃这个视频么?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        alertView.tag = TAG_ALERTVIEW_CLOSE_CONTROLLER;
        [alertView show];
    } else {
        [self dropTheVideo];
    }
}
//点击了切换摄像头
- (void)pressSwitchButton
{
    _switchButton.selected = !_switchButton.selected;
    if (!_switchButton.selected) {//换后置摄像头
        if (_flashButton.selected) {
            [_recorder openTorch:NO];
            _flashButton.selected = NO;
            _flashButton.enabled = NO;
            _flashButton.hidden = YES;
        } else {
            _flashButton.enabled = NO;
            _flashButton.hidden = YES;
        }
    } else {
        _flashButton.enabled = [_recorder isFrontCameraSupported];
        _flashButton.hidden = NO;
    }
    
    [_recorder switchCamera];
}
//点击了闪光灯
- (void)pressFlashButton
{
    _flashButton.selected = !_flashButton.selected;
    [_recorder openTorch:_flashButton.selected];
}
//点击删除
- (void)pressDeleteButton
{
    if (_deleteButton.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
    } else if (_deleteButton.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        
        if ([_recorder getVideoCount] > 0) {
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        } else {//视频删除完了，恢复初始状态
            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
            //初始化到最初的
            _timeLabel.hidden = YES;
            _redPoint.hidden = YES;
            _importVideoBtn.hidden = NO;
        }
    }
}
//点击OK按钮
- (void)pressOKButton
{
    if (_isProcessingData) {
        return;
    }
    if (_recordButton.selected) {//正在录制，则结束录制
        [self pressRecoderBtn];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self begigMerge];
        });
    }else{
        [self begigMerge];
    }
}
-(void)begigMerge
{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = @"努力处理中";
    }
    [_hud show:YES];
    [self.view addSubview:_hud];
    
    [_recorder mergeVideoFiles];
    self.isProcessingData = YES;
}
//点击导入视频按钮
-(void)pressImpotrBtn
{
    ALAuthorizationStatus authorPhotoStatus = [ALAssetsLibrary authorizationStatus];
    if (authorPhotoStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问
        authorPhotoStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了
    {
        // 无权限 引导去开启
        [XYWAlert XYWAlertTitle:@"左右无法使用相册" message:@"请前往“设置”开启左右访问设备的权限" inWkVC:self first:@"去允许" firstHandle:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        } second:nil Secondhandle:nil cancle:@"取消" handle:^{
            
        }];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.view.backgroundColor = [UIColor orangeColor];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.sourceType = sourcheType;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*) kUTTypeMovie, (NSString*) kUTTypeVideo, nil];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@",info);
    NSURL *MediaURL = [info objectForKey:@"UIImagePickerControllerMediaURL"];
    NSURL *referenceURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:referenceURL options:nil];
    float second = asset.duration.value/asset.duration.timescale;
    if (second<15 || second>180) {
        UIAlertView *shotrVideoalv = [[UIAlertView alloc]initWithTitle:@"请选择15秒~3分钟的视频参与PK" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [shotrVideoalv show];
        [picker popViewControllerAnimated:YES];
        return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
        rvc.moviePath = MediaURL.absoluteString;
        rvc.ReferenceURL = referenceURL;
        rvc.movieUrl = MediaURL;
        rvc.contestantVideoId = self.contestantVideoId;
        rvc.uploadTagId = self.tagId;
        rvc.uploadTagName = self.tagName;
        rvc.challenge = self.challenge;
        [self.navigationController pushViewController:rvc animated:YES];
    }];
    
    
}
//放弃本次视频，并且关闭页面
- (void)dropTheVideo
{
    [_recorder deleteAllVideo];
    //防止出现红色navigationBar
    [_recorder.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//删除最后一段视频
- (void)deleteLastVideo
{
    if ([_recorder getVideoCount] > 0) {
        [_recorder deleteLastVideo];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//聚焦
- (void)showFocusRectAtPoint:(CGPoint)point
{
    _focusRectView.alpha = 1.0f;
    _focusRectView.center = point;
    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [_focusRectView.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                _focusRectView.alpha = 0;
            }];
        });
    }];
}

#pragma mark - SBVideoRecorderDelegate
//开始录制一段视频
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
    
    [self.progressBar addProgressView];
    [_progressBar stopShining];
    
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    _okButton.hidden = YES;
    _importVideoBtn.hidden = YES;
    _closeButton.hidden = YES;
    _flashButton.hidden = YES;
    _switchButton.hidden = YES;
    _tagNameLabel.hidden = NO;
    _timeLabel.hidden = NO;
}
//录制一段视频完毕
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"录制视频错误:%@", error);
    } else {
        NSLog(@"录制视频完成: %@", outputFileURL);
    }
    AVAsset *asset = [AVAsset assetWithURL:outputFileURL];
    if (asset.tracks.count<2) {
        DbLog(@"轨道不够！%@",asset.tracks);
    } ;
    [_progressBar startShining];
    
    if (totalDur >= MAX_VIDEO_DUR) {
        [self pressOKButton];
    }
    if (totalDur >= MIN_VIDEO_DUR) {
        _okButton.hidden = NO;
    }
    [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
    _closeButton.hidden = NO;
    if (_switchButton.selected) {
        _flashButton.hidden = NO;
    }
    _switchButton.hidden = NO;
    _tagNameLabel.hidden = YES;
}
//删除视频断
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    } else {
        NSLog(@"删除了视频: %@", fileURL);
        NSLog(@"现在视频长度: %f", totalDur);
    }
    
    if ([_recorder getVideoCount] > 0) {
        [_deleteButton setStyle:DeleteButtonStyleNormal];
    } else {
        [_deleteButton setStyle:DeleteButtonStyleDisable];
    }
    _okButton.hidden = !(totalDur >= MIN_VIDEO_DUR);
    self.timeLabel.text = [self currentTimeStringWithSec:totalDur];
}
//录制回调
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];
    _okButton.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
    self.timeLabel.text = [self currentTimeStringWithSec:videoDuration + totalDur];
    if (videoDuration + totalDur > 15) {
        self.okButton.hidden = NO;
    }
}

/**
 达到最大值

 @param videoRecorder 录制器
 @param outputFileURL 输出路径
 */
-(void)videoRecorder:(SBVideoRecorder *)videoRecorder didCompleteMaxTimeToOutPutFileAtURL:(NSURL *)outputFileURL
{
    _recordButton.selected = NO;
    [_recordButton.imageView stopAnimating];
    [_redPoint stopAnimating];
}
//合并视频完毕
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    [_hud hide:YES];
    self.isProcessingData = NO;
    
    ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
    rvc.moviePath = outputFileURL.path;
    rvc.ReferenceURL = outputFileURL;
    rvc.movieUrl = outputFileURL;
    
    rvc.uploadTagId = self.tagId;
    rvc.uploadTagName = self.tagName;
    rvc.challenge = self.challenge;
    rvc.contestantVideoId = self.contestantVideoId;
    rvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rvc animated:YES];
    
    //    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
    //                                completionBlock:^(NSURL *assetURL, NSError *error) {
    //                                    if (error) {
    //                                        NSLog(@"Save video fail:%@",error);
    //
    //                                    } else {
    //                                        NSLog(@"Save video succeed.");
    //                                        SimpleVideoFileFilterViewController *play = [[SimpleVideoFileFilterViewController alloc]initWithNibName:@"SimpleVideoFileFilterViewController" bundle:nil];
    //                                        play.videoURL = outputFileURL;
    //
    //                                        ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
    //                                        rvc.moviePath = outputFileURL.path;
    //                                        rvc.ReferenceURL = assetURL;
    //                                        rvc.movieUrl = outputFileURL;
    //
    //                                        rvc.uploadTagId = self.tagId;
    //                                        rvc.uploadTagName = self.title;
    //                                        rvc.challenge = @"false";
    //                                        rvc.hidesBottomBarWhenPushed = YES;
    //                                        [self.navigationController pushViewController:rvc animated:YES];
    //                                    }
    //                                }];
    //
    
    //    SimpleVideoFileFilterViewController *play = [[SimpleVideoFileFilterViewController alloc]initWithNibName:@"SimpleVideoFileFilterViewController" bundle:nil];
    //    play.videoURL = outputFileURL;
    //    [self.navigationController pushViewController:play animated:YES];
    //    return;
    
    //    PlayViewController *playCon = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil withVideoFileURL:outputFileURL];
    //    [self.navigationController pushViewController:playCon animated:YES];
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData) {
        return;
    }
    
    if (_deleteButton.style == DeleteButtonStyleDelete) {//取消删除
        [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([touch.view isEqual:self.preview]) {
        CGPoint touchPoint = [touch locationInView:self.preview.superview];
        [self showFocusRectAtPoint:touchPoint];
        [_recorder focusInPoint:touchPoint];
    }
//    CGPoint touchPoint = [touch locationInView:_recordButton.superview];
//    //如果点击的是录像机，则对焦
//    touchPoint = [touch locationInView:self.view];//previewLayer 的 superLayer所在的view
//    if (CGRectContainsPoint(_recorder.preViewLayer.frame, touchPoint)) {
//        
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData) {
        return;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERTVIEW_CLOSE_CONTROLLER:
        {
            switch (buttonIndex) {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self dropTheVideo];
                }
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
// <iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
#endif

- (NSString*)currentTimeStringWithSec:(CGFloat)seconds {
    NSInteger m = seconds/60;
    CGFloat s = seconds-m*60;
    if (m>0) {
        return [NSString stringWithFormat:@"%ld:%02.1f",(long)m,s];
    }else{
        return [NSString stringWithFormat:@"%.1f",s];
    }
    
}
- (long ) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace/1024/1024;
}

@end



















