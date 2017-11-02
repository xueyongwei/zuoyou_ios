//
//  ReviewMovieViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

#import "ZYPlayer.h"
#import "ZYSoundChanger.h"

#import "ReviewMovieViewController.h"
#import "AddDescViewController.h"

#import "SoundChangeCollectionViewCell.h"
#import "SoundChangeModel.h"
#import "AddBgmViewController.h"
#pragma mark ---soundChangeType

#pragma mark -- ReviewMovieViewController
@interface ReviewMovieViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet ZYPlayerView *playerView;
@property (nonatomic,assign)BOOL playing;
@property (nonatomic,weak)UIButton *nextBtnPoint;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *soundSource;
@property (nonatomic,copy)NSString *effectVideoPath;
@property (nonatomic,strong)NSMutableDictionary *changedVideoPath;
@property (nonatomic,strong)UIActivityIndicatorView *waitView;
@property (nonatomic,strong)NSIndexPath *currentSelectIndexPath;
@end
typedef enum{
    kVCPresentStylePresent = 10010,
    kVCPresentStylePush
} kVCPresentStyle;
@implementation ReviewMovieViewController
-(UIActivityIndicatorView *)waitView
{
    if (!_waitView) {
        _waitView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _waitView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.changedVideoPath = [NSMutableDictionary new];
    [self.playerView setVideoURL:self.ReferenceURL];
    [self.playerView autoPlayTheVideo];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkVideoInfo];
    });
    [self prepareSoundChangeSource];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    });
    self.currentSelectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.playerView pause];
    self.playing = YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.playing) {
        [self.playerView play];
    }
}
-(void)prepareSoundChangeSource{
    SoundChangeModel *none = [[SoundChangeModel alloc]initWithName:@"原音" imgName:@"soundChange原音" tempo:0 rate:0 pitch:0];
    SoundChangeModel *funy = [[SoundChangeModel alloc]initWithName:@"搞怪" imgName:@"soundChange搞怪" tempo:0 rate:0 pitch:11];
   SoundChangeModel *uncle = [[SoundChangeModel alloc]initWithName:@"大叔" imgName:@"soundChange大叔" tempo:0 rate:0 pitch:-6];
    SoundChangeModel *lolita = [[SoundChangeModel alloc]initWithName:@"萝莉" imgName:@"soundChange萝莉" tempo:0 rate:0 pitch:4];
    self.soundSource = @[none,funy,uncle,lolita];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SoundChangeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SoundChangeCollectionViewCell"];
    
}
//获取原始视频的MD5
-(void)checkVideoInfo
{
    if (self.ReferenceURL) {
        if ([self.ReferenceURL.scheme isEqualToString:@"file"]) {//直接获取文件的md5
            NSString *videoMD5 = [NSString getFileMD5WithPath:self.ReferenceURL.path];
            DbLog(@"videoMD5 = %@",videoMD5);
            __block typeof(self) wkself = self;
            [wkself checkVideoHaveUsedWithMD5:videoMD5 canUse:^{//可以继续使用
                AVAsset *VideoAsset = [AVAsset assetWithURL:wkself.ReferenceURL];
                NSArray *tracks = [VideoAsset tracksWithMediaType:AVMediaTypeVideo];
                if([tracks count] > 0) {
                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                    NSLog(@"=====hello  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);//宽高
                    wkself.movieSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
                    wkself.movieMD5 = videoMD5;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                     wkself.corverImage = [wkself thumbnailImageForVideo:wkself.ReferenceURL atTime:0];
                    wkself.nextBtnPoint.selected = YES;
                    self.nextBtnPoint.userInteractionEnabled = YES;
                    [self.waitView stopAnimating];
                    [self.waitView removeFromSuperview];
                });
            }];
        }else{//需要获取原始视频的md5
            ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
            __block typeof(self) wkself = self;
            [assetLibrary assetForURL:self.ReferenceURL resultBlock:^(ALAsset *asset) {
                if (!asset) {
                    DbLog(@"没有asset");
                    CoreSVPCenterMsg(@"asset empty!");
                    return ;
                }
                ALAssetRepresentation *rep = [asset defaultRepresentation];
//                UIImage *thumb = [UIImage imageWithCGImage:[rep fullResolutionImage]];
                const int bufferSize = 11024 * 1024;
                Byte *buffer = (Byte*)malloc(bufferSize);
                NSUInteger read = 0, offset = 0 ;
                NSError* err = nil;
                //计算文件的MD5
                CC_MD5_CTX md5;
                CC_MD5_Init(&md5);
                
                if (rep.size != 0)
                {
                    do {
                        read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                        offset += read;
                        CC_MD5_Update(&md5, buffer, bufferSize);
                    } while (read != 0 && !err);//没到结尾，没出错，ok继续
                }
                //生成MD5
                unsigned char digest[CC_MD5_DIGEST_LENGTH];
                CC_MD5_Final(digest, &md5);
                free(buffer);
                
                NSString* videoMD5 = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                      digest[0], digest[1],
                                      digest[2], digest[3],
                                      digest[4], digest[5],
                                      digest[6], digest[7],
                                      digest[8], digest[9],
                                      digest[10], digest[11],
                                      digest[12], digest[13],
                                      digest[14], digest[15]];
                DbLog(@"videoMD5 = %@",videoMD5);
                
                [wkself checkVideoHaveUsedWithMD5:videoMD5 canUse:^{//可以继续使用
                    AVAsset *VideoAsset = [AVAsset assetWithURL:wkself.ReferenceURL];
                    NSArray *tracks = [VideoAsset tracksWithMediaType:AVMediaTypeVideo];
                    if([tracks count] > 0) {
                        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                        DbLog(@"=====hello  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);//宽高
                        wkself.movieSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
                        wkself.movieMD5 = videoMD5;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wkself.nextBtnPoint.selected = YES;
                        self.nextBtnPoint.userInteractionEnabled = YES;
                        [self.waitView stopAnimating];
                        [self.waitView removeFromSuperview];
                        UIImage *thumb = [wkself thumbnailImageForVideo:wkself.ReferenceURL atTime:0];
                        wkself.corverImage = thumb;
                    });
                }];
            } failureBlock:^(NSError *error) {
                DbLog(@"%@",error.localizedDescription);
                CoreSVPCenterMsg(error.localizedDescription);
            }];
        }
        
    }
    
}
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        DbLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}
-(void)checkVideoHaveUsedWithMD5:(NSString *)md5 canUse:(void(^)(void))canUse
{
    DbLog(@"%@",md5);
    NSString *uriStr = [NSString stringWithFormat:@"%@/upload/videotoken?challenge=%@&key=%@&widthPX=%@&hightPX=%@&md5=%@",HeadUrl,@"false",@"aa",@(100),@(100),md5];
    //发送请求获取token
    [XYWhttpManager XYWpost:uriStr parameters:nil inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSString *token = [result objectForKey:@"uploadToken"];
            if (token && token.length>0) {
                canUse();
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CoreSVP dismiss];
                    CoreSVPCenter2sMsg([result objectForKey:@"errMsg"]);
                    [self.navigationController popViewControllerAnimated:YES];
//                    [self dismissViewControllerAnimated:YES completion:^{
//                    }];
                });
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CoreSVP dismiss];
            CoreSVPCenterMsg(error.localizedDescription);
        });
    }];
}
-(void)customNavi
{
    [super customNavi];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if (self.navigationController.childViewControllers.count>1) {//不是弹出来的，而是push进来的
        [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        btn.tag = kVCPresentStylePush;
    }else{
        [btn setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateNormal];
        btn.tag = kVCPresentStylePresent;
    }
    
    [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];
    
    UIBarButtonItem *negativeRSpacer = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeRSpacer.width = -3;
    UIButton *nxtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nxtBtn.frame = CGRectMake(0, 0, 60, 20);
    [nxtBtn setTitle:@" " forState:UIControlStateNormal];
    [nxtBtn setTitle:@"下一步" forState:UIControlStateSelected];
    self.nextBtnPoint = nxtBtn;
    self.nextBtnPoint.userInteractionEnabled = NO;
    self.waitView.frame = nxtBtn.bounds;
    [self.nextBtnPoint addSubview:self.waitView];
    [self.waitView startAnimating];
    
    nxtBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    nxtBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [nxtBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
    [nxtBtn addTarget:self action:@selector(onNxtClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[negativeRSpacer,[[UIBarButtonItem alloc]initWithCustomView:nxtBtn]];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 16)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexColorString:@"333333"];
    label.text = @"预览";
    label.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = label;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =nil;
}
-(void)onBackClick:(UIButton *)sender
{
    sender.tag == kVCPresentStylePush?[self.navigationController popViewControllerAnimated:YES]:[self dismissViewControllerAnimated:YES completion:nil];
}
-(void)onNxtClick:(UIButton *)sender
{
    AddBgmViewController *addVC = [[AddBgmViewController alloc]initWithNibName:@"AddBgmViewController" bundle:nil];
    
    /*
    AddDescViewController *addVC = [[AddDescViewController alloc]initWithNibName:@"AddDescViewController" bundle:nil];
    */
    //    addVC.moviePath = self.moviePath;
    addVC.moviePath = self.effectVideoPath.length>0?self.effectVideoPath:self.movieUrl.path;
    addVC.movieSize = self.movieSize;
    addVC.corverImage = self.corverImage;
    addVC.uploadTagId = [NSString stringWithFormat:@"%@",self.uploadTagId];
    addVC.contestantVideoId = [NSString stringWithFormat:@"%@",self.contestantVideoId];
    addVC.challenge = self.challenge;
    addVC.uploadTagName = self.uploadTagName;
    addVC.videoId = self.videoId;
    addVC.movieMD5 = self.movieMD5;
    [self.navigationController pushViewController:addVC animated:YES];
     
}

#pragma mark ---collectionView代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SoundChangeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SoundChangeCollectionViewCell" forIndexPath:indexPath];
    SoundChangeModel *type = self.soundSource[indexPath.item];
    cell.imgView.image = [UIImage imageNamed:type.imgName];
    cell.txtLabel.text = type.name;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.currentSelectIndexPath isEqual: indexPath]) {
        return;
    }
    self.currentSelectIndexPath = indexPath;
   SoundChangeModel *type = self.soundSource[indexPath.item];
    if (indexPath.item ==0) {
        [self.playerView resetToPlayNewURL];
        [self.playerView setVideoURL:self.ReferenceURL];
        [self.playerView autoPlayTheVideo];
        self.effectVideoPath = @"";
        return;
    }
    NSString *changedVideoPath =self.changedVideoPath[type.name];
    if (changedVideoPath) {
        [self.playerView resetToPlayNewURL];
        [self.playerView setVideoURL:[NSURL fileURLWithPath:changedVideoPath]];
        [self.playerView autoPlayTheVideo];
        self.effectVideoPath = changedVideoPath;
        return;
    }
    CoreSVPLoading(@"处理中..", NO);
    ZYSoundChanger *manager = [ZYSoundChanger changer]; 
    
    [manager changeVideo:self.movieUrl.path withTempo:type.effect.tempo andPitch:type.effect.pitch andRate:type.effect.rate sucess:^(NSString *videoPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CoreSVP dismiss];
            NSLog(@"视频合成完毕！ %@",videoPath);
//            CoreSVPCenterMsg(@"视频合成完毕！");
            [self.playerView resetToPlayNewURL];
            [self.playerView setVideoURL:[NSURL fileURLWithPath:videoPath]];
            [self.playerView autoPlayTheVideo];
            self.effectVideoPath = videoPath;
            if (videoPath) {
                [self.changedVideoPath setObject:videoPath forKey:type.name];
            }
            
        });
    } failure:^(NSError *error) {
        NSLog(@"视频合成出错：%@",error.localizedDescription);
        CoreSVPCenterMsg(@"视频合成出错！");
    }];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (int)(collectionView.bounds.size.width/4);
    CGSize size = CGSizeMake(width, 90) ;
    return size;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
