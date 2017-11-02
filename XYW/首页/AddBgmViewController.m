//
//  AddBgmViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "AddBgmViewController.h"
#import "AddDescViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ZYPlayer.h"
#import "EffectSoundEditView.h"

#import "SoundChangeCollectionViewCell.h"
#import "VideoFramesCollectionViewCell.h"
#import "BgmListTableViewCell.h"
#import "BgmListFirstTableViewCell.h"

#import "XYWSandBox.h"
#import "ZYBgmSoundEditer.h"

#import "EffectVoiceModel.h"
#import "BackgroundMusicModel.h"

@interface AddBgmVideoFramesModel : NSObject
@property (nonatomic,copy)NSString *imagePath;
@property (nonatomic,strong)NSIndexPath *effectVoiceIndexPath;
@end
@implementation AddBgmVideoFramesModel

@end

@interface AddBgmViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *bgmBtn;
@property (weak, nonatomic) IBOutlet UIButton *effectVoiceBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet ZYPlayerView *player;
@property (nonatomic,strong) AVAudioPlayer  *bgmPlayer;
@property (nonatomic,strong)UIButton * nextBtnPoint;

@property (nonatomic,strong) EffectSoundEditView *effectEditView;
@property (nonatomic,strong) UITableView *bgmTableView;

@property (nonatomic,strong)NSMutableArray *bgmSource;
@property (nonatomic,strong)NSMutableArray *videoFrameSource;
@property (nonatomic,strong)NSMutableArray *effectVoiceSource;
@property (nonatomic,strong)NSMutableArray *effectVoiceModels;

@property (nonatomic,strong)NSMutableArray *effectVoicePlayers;

@property (nonatomic,weak) UIView *currentConntView;//当前的view是哪个

@property (nonatomic,strong) NSIndexPath *currenVideoFrameIndexPath;
@property (nonatomic,strong) UIActivityIndicatorView *waitActivity;

@property (nonatomic,assign)BOOL videoPlayerCanControl;
@property (nonatomic,assign)BOOL obserVideoPlayerProgress;

@property (nonatomic,assign)CGFloat videoDuraionTime;
@property (nonatomic,strong)NSIndexPath *currentBgnIndexPath;
@end

@implementation AddBgmViewController
-(UIActivityIndicatorView *)waitActivity
{
    if (!_waitActivity) {
        _waitActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _waitActivity;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self dataSourceInit];
    [self customToolView];
    
    [self.player setVideoURL:[NSURL fileURLWithPath:self.moviePath]];
    [self.player autoPlayTheVideo];
    [self.player pause];
    
}
-(void)customNavi
{
    [super customNavi];
    UIBarButtonItem *negativeRSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeRSpacer.width = -3;
    UIButton *nxtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nxtBtn.frame = CGRectMake(0, 0, 44, 44);
    [nxtBtn setTitle:@"下一步" forState:UIControlStateNormal];
    self.nextBtnPoint = nxtBtn;
//    self.nextBtnPoint.hidden = YES;
    nxtBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    nxtBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [nxtBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
    [nxtBtn addTarget:self action:@selector(onNxtClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[negativeRSpacer,[[UIBarButtonItem alloc]initWithCustomView:nxtBtn]];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 16)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexColorString:@"333333"];
    label.text = self.uploadTagName;
    label.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = label;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =nil;
}
-(void)dataSourceInit{
    self.bgmSource = [NSMutableArray new];
    self.videoFrameSource = [NSMutableArray new];
    self.effectVoiceSource = [NSMutableArray new];
}
-(void)customToolView{
    //effectView
    EffectSoundEditView *effectView = [[[NSBundle mainBundle]loadNibNamed:@"EffectSoundEditView" owner:self options:nil]lastObject];
    self.effectEditView = effectView;
    self.effectEditView.videoFramesCollectionView.delegate = self;
    self.effectEditView.videoFramesCollectionView.dataSource = self;
    [self.effectEditView.videoFramesCollectionView registerNib:[UINib nibWithNibName:@"VideoFramesCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoFramesCollectionViewCell"];
    self.effectEditView.videoFramesCollectionView.allowsMultipleSelection = YES;
    
    self.effectEditView.effectVoiceCollectionView.delegate = self;
    self.effectEditView.effectVoiceCollectionView.dataSource = self;
    [self.effectEditView.effectVoiceCollectionView registerNib:[UINib nibWithNibName:@"SoundChangeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SoundChangeCollectionViewCell"];
//    self.effectEditView.effectVoiceCollectionView.allowsMultipleSelection = YES;
    //bgmTableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.bgmTableView = tableView;
    
    //默认使用bgm的view
    [self.contentView addSubview:self.bgmTableView];
    __weak typeof(self) wkSelf = self;
    [self.bgmTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(wkSelf.contentView);
    }];
    
    [self.effectEditView.playBtn addTarget:self action:@selector(onPlayBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
    //默认是第一个,不能处罚setter方法
    _currenVideoFrameIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.currentConntView = _bgmTableView;
    //加载背景音乐
    [self loadBgmList];
    [self loadEffectVoiceList];
    
}
#pragma mark -加载背景音乐列表
-(void)loadBgmList{
    NSArray *names = @[@"无音乐",@"甜蜜",@"可爱",@"振奋",@"调皮",@"舞动",@"悲伤",@"跳跃",@"古风",@"大气"];
    //刷新列表，并默认选中第一行
    for (unsigned i = 0; i<names.count; i++) {
        NSString *name = names[i];
        NSString *musicPath = [[NSBundle mainBundle]pathForResource:name ofType:@"aac"];
        BackgroundMusicModel *model = [[BackgroundMusicModel alloc]init];
        model.name = name;
        model.muiscPath = musicPath;
        [self.bgmSource addObject:model];
    }
    [self addNotiCenter];
    [self.bgmTableView reloadData];
    [self.bgmTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}
#pragma mark -加载音效列表
-(void)loadEffectVoiceList{
    NSArray *names = @[@"惊悚",@"掌声",@"欢呼",@"大笑",@"五杀"];
    for (unsigned i = 0; i<names.count; i++) {
        NSString *name = names[i];
        NSString *effectPath = [[NSBundle mainBundle]pathForResource:name ofType:@"aac"];
        //    NSString *str = [[NSBundle mainBundle] pathForResource:@"48s" ofType:@"mp3"];
//        NSURL *url = [NSURL fileURLWithPath:effectPath];
        
        EffectVoiceModel *model = [[EffectVoiceModel alloc]init];
        model.name = name;
        model.voicePath = effectPath;
        model.imgName = [NSString stringWithFormat:@"effect%@icon",name];
        [self.effectVoiceSource addObject:model];
    }
//    for (NSString *name in names) {
//        NSString *effectPath = [[NSBundle mainBundle]pathForResource:name ofType:@"aac"];
//        NSString *str = [[NSBundle mainBundle] pathForResource:@"五杀" ofType:@"aac"];
//        //    NSString *str = [[NSBundle mainBundle] pathForResource:@"48s" ofType:@"mp3"];
//        NSURL *url = [NSURL fileURLWithPath:str];
//        SystemSoundID soundID = name;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
//        
//        EffectVoiceModel *model = [[EffectVoiceModel alloc]init];
//        model.name = name;
//        model.voicePath = effectPath;
//        model.imgName = @"";
//        [self.effectVoiceSource addObject:model];
//    }
    self.effectVoicePlayers = [NSMutableArray new];
    [self.effectEditView.effectVoiceCollectionView reloadData];
    
//    [self.bgmTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}
#pragma mark -异步获取帧图片，可以一次获取多帧图片
// 异步获取帧图片，可以一次获取多帧图片
- (void)centerFrameImageWithVideoURL:(NSURL *)videoURL completion:(void (^)(NSMutableArray *imagePathArr))completion {
    // AVAssetImageGenerator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calculate the midpoint time of video
    Float64 duration = CMTimeGetSeconds([asset duration]);
    self.videoDuraionTime = duration;
    // 取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
    // 通常来说，600是一个常用的公共参数，苹果有说明:
    // 24 frames per second (fps) for film, 30 fps for NTSC (used for TV in North America and
    // Japan), and 25 fps for  PAL (used for TV in Europe).
    // Using a timescale of 600, you can exactly represent any number of frames in these systems
    NSMutableArray *timeArr = [NSMutableArray new];
    for (NSInteger i = 0; i<duration; i++) {
        CMTime midpoint = CMTimeMakeWithSeconds(i, 600);
        NSValue *midTime = [NSValue valueWithCMTime:midpoint];
        [timeArr addObject:midTime];
    }
    __block NSInteger i = 0;
    __block NSMutableArray *imagePathArr = [NSMutableArray new];
    
    NSString *videoThumbsDir = [XYWSandBox cachePathAutoCreateIfNotExistWithComponent:@"videoThumbs"];
    [XYWSandBox clearCachesFromDirectoryPath:videoThumbsDir];//清理下之前的文件
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image != NULL) {
            UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
            
            //设置一个图片的存储路径
            
            NSString *imagePath = [videoThumbsDir stringByAppendingFormat:@"/%ld.png",i];
            
            //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
            [UIImageJPEGRepresentation(centerFrameImage, 0.5) writeToFile:imagePath atomically:YES];
            //            [UIImagePNGRepresentation(centerFrameImage) writeToFile:imagePath atomically:YES];
            AddBgmVideoFramesModel *model = [[AddBgmVideoFramesModel alloc]init];
            model.imagePath = imagePath;
            model.effectVoiceIndexPath = nil;
            [imagePathArr addObject:model];
            i++;
            DbLog(@"%ld induration %f",i,duration);
            if (i >= (int)duration) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(imagePathArr);
                    [self waitActivityShouleHidden:YES];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                }
            });
        }
    }];
}
#pragma mark -设置当前videoFrame的下标
-(void)setVideoPlayerCanControl:(BOOL)videoPlayerCanControl
{
    _videoPlayerCanControl = videoPlayerCanControl;
    if (videoPlayerCanControl) {
        self.player.controlView.hidden = NO;
        self.player.userInteractionEnabled = YES;
    }else{
        self.player.controlView.hidden = YES;
        self.player.userInteractionEnabled = NO;
    }
}
-(void)setCurrenVideoFrameIndexPath:(NSIndexPath *)currenVideoFrameIndexPath
{
    if (currenVideoFrameIndexPath == _currenVideoFrameIndexPath) {
        return;
    }
    if (self.videoFrameSource.count==0) {
        return;
    }
    _currenVideoFrameIndexPath = currenVideoFrameIndexPath;
    self.effectEditView.currentTimeLabel.text = [self timeStrWIthTime:currenVideoFrameIndexPath.item];
    AddBgmVideoFramesModel *model = self.videoFrameSource[currenVideoFrameIndexPath.item];
    if (model.effectVoiceIndexPath) {
        [self.effectEditView.effectVoiceCollectionView selectItemAtIndexPath:model.effectVoiceIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        EffectVoiceModel *effectVoice = self.effectVoiceSource[model.effectVoiceIndexPath.item];
        [self playEffect:effectVoice.voicePath];
    }else{
        [self.effectEditView.effectVoiceCollectionView deselectItemAtIndexPath:self.effectEditView.effectVoiceCollectionView.indexPathsForSelectedItems.firstObject animated:YES];
    }
    
    
    if (!self.obserVideoPlayerProgress) {
//        CGFloat percent = self.effectEditView scrollView.contentOffset.x/scrollView.contentSize.width;
        
        [self.player seekToTime:currenVideoFrameIndexPath.item];
    }
}
-(NSString *)timeStrWIthTime:(NSInteger)sec
{
    if (sec>60) {
        NSInteger m = sec/60;
        NSInteger s = sec%60;
        return [NSString stringWithFormat:@"%ld:%02ld",(long)m,s];
    }else{
        return [NSString stringWithFormat:@"%d:%02ld",0,(long)sec];
    }
}
#pragma mark -处理方法action
-(void)playEffect:(NSString *)voicePath
{
    /*
    //播放下这个音效
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:voicePath]), &soundID);
    // 播放短频音效
    AudioServicesPlayAlertSound(soundID);
    */
    NSURL *url = [NSURL fileURLWithPath:voicePath];
    __strong AVAudioPlayer  *avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    avAudioPlayer.delegate = self;
    
    [avAudioPlayer prepareToPlay];
    [avAudioPlayer play];
    [self.effectVoicePlayers addObject:avAudioPlayer];//保证其生命周期到播放完毕音乐
     
}
-(void)playbgm:(NSString *)musicPath
{
    //播放下这个音效
    DbLog(@"播放：%@",musicPath);
    if (!musicPath) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:musicPath];
    self.bgmPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    [self.bgmPlayer prepareToPlay];
    self.bgmPlayer.delegate = self;
    self.bgmPlayer.numberOfLoops = -1;
//    self.bgmPlayer = avAudioPlayer;//保证其生命周期到播放完毕音乐
    
    [self.bgmPlayer play];
    DbLog(@"播放：%@",musicPath);
}

#pragma mark -点击事件
-(void)onPlayBtnCLick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.player.controlView.videoSlider.value/self.player.controlView.videoSlider.maximumValue>=0.99) {
            [self.player repeatPlay:nil];
//            [self.player seekToTime:0.0];
//            [self.player play];
        }else{
            [self.player play];
        }
        self.obserVideoPlayerProgress = YES;
    }else{
        [self.player pause];
        self.obserVideoPlayerProgress = NO;
    }
}
- (IBAction)onBgmClick:(UIButton *)sender {
    if (self.currentConntView == self.bgmTableView) {
        return;
    }
    [self.player.controlView.videoSlider removeObserver:self forKeyPath:@"value"];
    for (AVAudioPlayer *player in self.effectVoicePlayers) {
        [player stop];
        player.delegate = nil;
    }
    [self.effectVoicePlayers removeAllObjects];
    sender.selected = YES;
    self.videoPlayerCanControl = YES;
    if (self.effectVoiceBtn.selected) {
        self.effectVoiceBtn.selected = NO;
    }
    
    self.effectEditView.playBtn.selected = NO;
    [self.effectEditView removeFromSuperview];
    [self.contentView addSubview:self.bgmTableView];
    self.currentConntView = self.bgmTableView;
    __weak typeof(self) wkSelf = self;
    [self.bgmTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(wkSelf.contentView);
    }];
    [self resetPlayer];
}
-(void)resetPlayer{
    
    [self.bgmPlayer stop];
    
    [self.player resetToPlayNewURL];
    [self.player setVideoURL:[NSURL fileURLWithPath:self.moviePath]];
    [self.player autoPlayTheVideo];
    [self.player pause];
}
- (IBAction)onEffectVoiceClick:(UIButton *)sender {
    if (self.currentConntView == self.effectEditView) {
        return;
    }
    [self.player.controlView.videoSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    self.videoPlayerCanControl = NO;
    sender.selected = YES;
    if (self.bgmBtn.selected) {
        self.bgmBtn.selected = NO;
    }
    [self.bgmTableView removeFromSuperview];
    [self.contentView addSubview:self.effectEditView];
    self.currentConntView = self.effectEditView;
    __weak typeof(self) wkSelf = self;
    [self.effectEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(wkSelf.contentView);
    }];
    
    if (self.videoFrameSource.count<1) {
        [self waitActivityShouleHidden:NO];
        NSURL *videoUrl =[NSURL fileURLWithPath:self.moviePath];
        [self centerFrameImageWithVideoURL:videoUrl completion:^(NSMutableArray *imagePathArr) {
            DbLog(@"imagePathArr = %@",imagePathArr);
            wkSelf.videoFrameSource = imagePathArr;
            [self.effectEditView.videoFramesCollectionView reloadData];
        }];
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
        self.effectEditView.totalTimeLabel.text = [self timeStrWIthTime:asset.duration.value/asset.duration.timescale];
    }
    [self resetPlayer];
}
-(void)waitActivityShouleHidden:(BOOL)hidden{
    if (hidden) {
        self.effectEditView.pointerView.hidden = NO;
        [self.waitActivity stopAnimating];
        [self.waitActivity removeFromSuperview];
    }else{
        [self.effectEditView addSubview:self.waitActivity];
        [self.waitActivity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.effectEditView.pointerView);
        }];
        self.effectEditView.pointerView.hidden = YES;
        [self.waitActivity startAnimating];
    }
}
-(void)mergeEffectBgmToVideo
{
    NSMutableArray *effsArr = [NSMutableArray new];
    for (NSInteger i =0; i<self.videoFrameSource.count; i++) {
        AddBgmVideoFramesModel *model = self.videoFrameSource[i];
        if (model.effectVoiceIndexPath) {
            EffectVoiceModel *effVoice = self.effectVoiceSource[model.effectVoiceIndexPath.item];
            ZYSoundModel *soundModel = [[ZYSoundModel alloc]init];
            soundModel.startTime = i;
            soundModel.soundFilePath = effVoice.voicePath;
            [effsArr addObject:soundModel];
        }
    }
    NSIndexPath *selectBgmIndexPath = self.bgmTableView.indexPathForSelectedRow;
    NSURL *bgmUrl = nil;
    if (selectBgmIndexPath && selectBgmIndexPath.row!=0) {
        BackgroundMusicModel *bgm = self.bgmSource[selectBgmIndexPath.row];
        bgmUrl = [NSURL fileURLWithPath:bgm.muiscPath];
    }
    NSString *outPutPath = [[XYWSandBox cachePathAutoCreateIfNotExistWithComponent:@"effectVideo"] stringByAppendingPathComponent:@"video.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath]) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:outPutPath error:&error] == NO) {
        }
    }
    
    __weak typeof(self) wkSelf = self;
    if (!bgmUrl && effsArr.count<1) {//没有添加任何音效和背景音乐
        
        [self nextoAddDesc];
    }else{
        CoreSVPLoading(@"处理中...", NO);
        [ZYBgmSoundEditer addBgmFileUrl:bgmUrl soundEffetFileModels:effsArr toVidelFileUrl:[NSURL fileURLWithPath:self.moviePath] outPutFilePath:outPutPath completion:^(NSString *outPath, BOOL isSuccess) {
            if (isSuccess) {
                DbLog(@"音效视频合成成功！ %@",outPath);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CoreSVP dismiss];
                    AddDescViewController *addVC = [[AddDescViewController alloc]initWithNibName:@"AddDescViewController" bundle:nil];
                    addVC.moviePath = outPath;
                    addVC.movieSize = wkSelf.movieSize;
                    addVC.corverImage = wkSelf.corverImage;
                    addVC.uploadTagId = wkSelf.uploadTagId;
                    addVC.contestantVideoId = wkSelf.contestantVideoId;
                    addVC.challenge = wkSelf.challenge;
                    addVC.uploadTagName = wkSelf.uploadTagName;
                    addVC.videoId = wkSelf.videoId;
                    addVC.movieMD5 = wkSelf.movieMD5;
                    [wkSelf.navigationController pushViewController:addVC animated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CoreSVP dismiss];
                });
                CoreSVPCenterMsg(@"处理失败！");
            }
        }];
    }
    
}
-(void)nextoAddDesc{
    AddDescViewController *addVC = [[AddDescViewController alloc]initWithNibName:@"AddDescViewController" bundle:nil];
    
    //    addVC.moviePath = self.moviePath;
    addVC.moviePath = self.moviePath;
    addVC.movieSize = self.movieSize;
    addVC.corverImage = self.corverImage;
    addVC.uploadTagId = self.uploadTagId;
    addVC.contestantVideoId = self.contestantVideoId;
    addVC.challenge = self.challenge;
    addVC.uploadTagName = self.uploadTagName;
    addVC.videoId = self.videoId;
    addVC.movieMD5 = self.movieMD5;
    [self.navigationController pushViewController:addVC animated:YES];
}
-(void)onNxtClick:(UIButton *)sender
{
    
    [self mergeEffectBgmToVideo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - bgm的tableView的delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.bgmSource.count;
//    return 20;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BackgroundMusicModel *bgm = self.bgmSource[indexPath.row];

    if (indexPath.row == 0) {
        BgmListFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BgmListFirstTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"BgmListFirstTableViewCell" owner:self options:nil]lastObject];
        }
        cell.nameLabel.text =  bgm.name;
        return cell;
        
    }else{
        BgmListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BgmListTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"BgmListTableViewCell" owner:self options:nil]lastObject];
        }
        cell.nameLabel.text =  bgm.name;
        cell.flagLabel.text = [NSString stringWithFormat:@"%02ld",(long)indexPath.row];
        return cell;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.currentBgnIndexPath isEqual: indexPath]) {
        return;
    }
    
    if (indexPath.row ==0) {
        [self.bgmPlayer stop];
    }else{
//        BackgroundMusicModel *bgm = self.bgmSource[indexPath.row];
//        [self playbgm:bgm.muiscPath];
        [self.player repeatPlay:nil];
    }
    self.currentBgnIndexPath = indexPath;
}
#pragma mark -UICollection的delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.effectEditView.videoFramesCollectionView) {
        return self.videoFrameSource.count;
    }else{
        return self.effectVoiceSource.count;
    }
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.effectEditView.videoFramesCollectionView) {
        
        VideoFramesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoFramesCollectionViewCell" forIndexPath:indexPath];
        //        cell.imgView.image = [UIImage imageNamed:@"00"];
        AddBgmVideoFramesModel *model = self.videoFrameSource[indexPath.item];
        
        UIImage *img = [UIImage imageWithContentsOfFile:model.imagePath];
        cell.imgView.image = img;
        if (model.effectVoiceIndexPath) {
            cell.selected = YES;
        }else{
            cell.selected = NO;
        }
        return cell;
    }else{
        SoundChangeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SoundChangeCollectionViewCell" forIndexPath:indexPath];
        EffectVoiceModel *effVoice = self.effectVoiceSource[indexPath.item];
        
        cell.imgView.image = [UIImage imageNamed:effVoice.imgName];
        cell.txtLabel.text = effVoice.name;
        if (self.videoFrameSource.count>0 && self.currenVideoFrameIndexPath) {
            AddBgmVideoFramesModel *model = self.videoFrameSource[self.currenVideoFrameIndexPath.item];
            if (model.effectVoiceIndexPath && model.effectVoiceIndexPath == indexPath) {
                cell.selected = YES;
            }else{
                cell.selected = NO;
            }
        }
        
        return cell;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.effectEditView.videoFramesCollectionView) {
        DbLog(@"选中了%@",indexPath);
        
    }else if (collectionView == self.effectEditView.effectVoiceCollectionView){
        
        AddBgmVideoFramesModel *model = self.videoFrameSource[self.currenVideoFrameIndexPath.item];
        if (model.effectVoiceIndexPath) {
            model.effectVoiceIndexPath = nil;
            [self.effectEditView.videoFramesCollectionView deselectItemAtIndexPath:self.currenVideoFrameIndexPath animated:YES];
            [self.effectEditView.effectVoiceCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        }else{
            model.effectVoiceIndexPath = indexPath;
            
            [self.effectEditView.videoFramesCollectionView selectItemAtIndexPath:self.currenVideoFrameIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            EffectVoiceModel *effectVoice = self.effectVoiceSource[indexPath.item];
            [self playEffect:effectVoice.voicePath];
        }
    }
    
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.effectEditView.videoFramesCollectionView) {
        DbLog(@"取消选中了%@",indexPath);
        
    }else if (collectionView == self.effectEditView.effectVoiceCollectionView){
        AddBgmVideoFramesModel *model = self.videoFrameSource[self.currenVideoFrameIndexPath.item];
        model.effectVoiceIndexPath = nil;//取消音效
        [self.effectEditView.videoFramesCollectionView deselectItemAtIndexPath:self.currenVideoFrameIndexPath animated:YES];
    }
}
-(void)ShowEffectsOfFrameIndex:(NSIndexPath *)indexPath{
    AddBgmVideoFramesModel *model = self.videoFrameSource[indexPath.item];
    if (model.effectVoiceIndexPath) {
        [self.effectEditView.videoFramesCollectionView selectItemAtIndexPath:model.effectVoiceIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.effectEditView.videoFramesCollectionView) {
        CGSize size = CGSizeMake(40, 40) ;
        return size;
    }else{
//        NSInteger width = (int)(collectionView.bounds.size.width/5);
        if ([UIScreen mainScreen].bounds.size.width<350) {
            CGSize size = CGSizeMake(collectionView.bounds.size.height*16.0/17, collectionView.bounds.size.height) ;
            return size;
        }else{
            NSInteger width = (int)(collectionView.bounds.size.width/5);
            CGSize size = CGSizeMake(width, 90) ;
            return size;
        }
        
    }
    
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.1f;
//    if (collectionView == self.effectEditView.videoFramesCollectionView) {
//        return 0.1f;
//    }else{
//       return 10.0f;
//    }
}
#pragma  mark -scrollView 代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DbLog(@"%f",scrollView.contentOffset.x);
    if (scrollView == self.effectEditView.videoFramesCollectionView) {
        CGPoint pInView = [self.effectEditView convertPoint:self.effectEditView.pointerView.center toView:self.effectEditView.videoFramesCollectionView];
        NSIndexPath *indexPathNow = [self.effectEditView.videoFramesCollectionView indexPathForItemAtPoint:pInView];
        if (!indexPathNow) {//超出滑动范围
            if (scrollView.contentOffset.x<1) {
                self.currenVideoFrameIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            }else{
                self.currenVideoFrameIndexPath = [NSIndexPath indexPathForItem:self.videoFrameSource.count-1 inSection:0];
            }
        }else{
            self.currenVideoFrameIndexPath = indexPathNow;
        }
//        if (scrollView.contentOffset.x >= scrollView.contentSize.width) {
//            NSIndexPath *indexPathNow = [NSIndexPath indexPathForItem:self.videoFrameSource.count-1 inSection:0];
//            self.currenVideoFrameIndexPath = indexPathNow;
//        }else{
//            NSIndexPath *indexPathNow = [self.effectEditView.videoFramesCollectionView indexPathForItemAtPoint:pInView];
//            // 赋值给记录当前坐标的变量
//            DbLog(@"%@",indexPathNow);
//            self.currenVideoFrameIndexPath = indexPathNow;
//        }
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.effectEditView.videoFramesCollectionView) {
        if (self.effectEditView.playBtn.selected) {
            [self onPlayBtnCLick:self.effectEditView.playBtn];
        }
        self.obserVideoPlayerProgress = NO;
        self.effectEditView.playBtn.userInteractionEnabled = NO;
    }
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"fff");
}
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    
//}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.effectEditView.videoFramesCollectionView) {
        if (decelerate) {
            //        self.obserVideoPlayerProgress = NO;
        }else{
            //        self.obserVideoPlayerProgress = YES;
            [self fixContentOffSet];
            self.effectEditView.playBtn.userInteractionEnabled = YES;
        }
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.effectEditView.videoFramesCollectionView) {
        [self fixContentOffSet];
        self.effectEditView.playBtn.userInteractionEnabled = YES;
    }
}
-(void)fixContentOffSet{
    CGFloat percent = self.effectEditView.videoFramesCollectionView.contentOffset.x/(self.effectEditView.videoFramesCollectionView.contentSize.width - self.effectEditView.videoFramesCollectionView.frame.size.width);
    CGFloat currentTime = self.player.controlView.videoSlider.maximumValue*percent;
    DbLog(@"percent = %f  currentTime = %f",percent,currentTime);
    [self.player seekToTime:currentTime];
    self.player.controlView.videoSlider.value = currentTime;
//    self.obserVideoPlayerProgress = YES;
}
#pragma mark -AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.effectVoicePlayers removeObject: player];
}
#pragma mark -通知中心
-(void)addNotiCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:kZYPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidPlay:) name:kZYPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidPause:) name:kZYPauseNotification object:nil];
    
}
-(void)moviePlayDidPlay:(NSNotification *)noti
{
    DbLog(@"moviePlayDidPlay");
    NSIndexPath *selectBgmIndexPath = [self.bgmTableView indexPathForSelectedRow];
    
    if (selectBgmIndexPath && selectBgmIndexPath.row != 0) {
        BackgroundMusicModel *bgm = self.bgmSource[selectBgmIndexPath.row];
        DbLog(@"有背景音乐，开始放");
        [self playbgm:bgm.muiscPath];
        self.bgmPlayer.currentTime = self.player.controlView.videoSlider.value;
    }
}
-(void)moviePlayDidPause:(NSNotification *)noti
{
    DbLog(@"moviePlayDidPause");
    [self.bgmPlayer stop];
}
-(void)moviePlayDidEnd:(NSNotification *)noti
{
    DbLog(@"moviePlayDidEnd");
    [self.bgmPlayer stop];
}
#pragma mark -KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.currentConntView == self.effectEditView) {
        if (object == self.player.controlView.videoSlider) {
            DbLog(@"value = %f",self.player.controlView.videoSlider.value);
            UISlider *silder = object;
            CGFloat percent = silder.value/silder.maximumValue;
            if (percent>=0.999) {
                if (self.effectEditView.playBtn.selected) {
                    [self onPlayBtnCLick:self.effectEditView.playBtn];
                }
                return;
            }
            if (self.obserVideoPlayerProgress) {
                CGPoint point = CGPointMake(percent*(self.effectEditView.videoFramesCollectionView.contentSize.width - self.effectEditView.videoFramesCollectionView.frame.size.width), 0);
                [self.effectEditView.videoFramesCollectionView setContentOffset:point];
            }else{
                
            }
        };

    }else if (self.currentConntView == self.bgmTableView){
        if (object == self.player.controlView.videoSlider) {
            DbLog(@"value = %f",self.player.controlView.videoSlider.value);
            UISlider *silder = object;
            CGFloat percent = silder.value/silder.maximumValue;
            NSIndexPath *selectBgmIndexPath = self.bgmTableView.indexPathForSelectedRow;
            if ((percent >0 &&percent <0.2 ) && selectBgmIndexPath && selectBgmIndexPath!=0 ) {
                BackgroundMusicModel *bgm = self.bgmSource[selectBgmIndexPath.row];
                DbLog(@"observeValueForKeyPath playbgm");
                [self playbgm:bgm.muiscPath];
            }
        };
    }
    
}
-(void)dealloc{
    @try {
        [self.player.controlView.videoSlider removeObserver:self forKeyPath:@"value"];
    } @catch (NSException *exception) {
        DbLog(@"已经取消过了监听！");
    } @finally {
        DbLog(@"removeObserver 未捕获异常");
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
