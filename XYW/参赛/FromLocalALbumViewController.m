//
//  FromLocalALbumViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "FromLocalALbumViewController.h"
#import "MyvideosCollectionViewCell.h"
#import "MyVideoModel.h"
#import "ReviewMovieViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import "XYWCompressionVideo.h"
@implementation XassetModel
@end

@interface FromLocalALbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)NSInteger selecteIndex;

@property (nonatomic,strong)NSMutableArray *groups;
@property (nonatomic,strong) NSMutableArray *assetModels;
@property (nonatomic,strong) NSMutableArray *assetDataSource;
@property (nonatomic,strong)ALAssetsGroup *photoGroup;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation FromLocalALbumViewController
-(NSMutableArray *)assetDataSource
{
    if (!_assetDataSource) {
        _assetDataSource = [NSMutableArray new];
    }
    return _assetDataSource;
}
- (ALAssetsLibrary *)assetsLibrary{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}
-(NSMutableArray *)assetModels
{
    if (!_assetModels) {
        _assetModels = [[NSMutableArray alloc]init];
    }
    return _assetModels;
}
-(NSMutableArray *)groups
{
    if (_groups == nil) {
        _groups = [NSMutableArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group){
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"我的照片流"]) {
                        return ;
                    }
                    [self->_groups addObject:group];
                    [self setPhotoGroup:self->_groups.lastObject];
                }
            } failureBlock:^(NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"访问相册失败！" message:@"爱水印权限访问您的照片,请前往系统设置开启照片权限。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置",nil];
                alertView.delegate = self;
                [alertView show];
            }];
        });
    }
    return _groups;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选取视频";
    [self customCollections];
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkAlbum];
}
//检查相册
-(BOOL)checkAlbum
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    switch (author) {
        case ALAuthorizationStatusNotDetermined:{
            NSString *tips = @"请允许本App可以访问相册";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存到相册需要授权" message:tips delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置",nil];
            alert.delegate = self;
            [alert show];
            break;
        }
            
        case ALAuthorizationStatusRestricted:{
            NSString *tips = @"你的权限受限";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取相册需要授权" message:tips delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置",nil];
            alert.delegate = self;
            [alert show];
            return NO;
            break;
        }
            
        case ALAuthorizationStatusDenied:{
            NSString *tips = @"爱水印没有权限使用照片！请前往系统设置开启照片权限。";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无权限读取相册！" message:tips delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置",nil];
            alert.delegate = self;
            [alert show];
            return NO;
            break;
        }
            
        case ALAuthorizationStatusAuthorized:
        {
            [self setPhotoGroup:[[self groups] lastObject]];
        }
            break;
            
        default:
            break;
    }
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DbLog(@"%ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        [self openSetPage];
    }
}
-(void)openSetPage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@",[NSBundle mainBundle].bundleIdentifier]];
    DbLog(@"%@",url);
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}
#pragma mark ---🔌数据相关

-(void)setPhotoGroup:(ALAssetsGroup *)photoGroup
{
    //防止每次指向累积添加
    [self.assetModels removeAllObjects];
    
    [photoGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil){
            if (self.assetModels) {
                self.assetModels = (NSMutableArray *)[[self.assetModels reverseObjectEnumerator] allObjects];
            }
            return ;
        }
        if (![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {//不是视频
            return;
        }
        [self.assetDataSource addObject:asset];
        XassetModel *model = [[XassetModel alloc] init];
        model.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        model.imageURL = asset.defaultRepresentation.url;
        [self.assetModels addObject:model];
        [self.collectionView reloadData];
    }];
}

-(void)customCollections
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyvideosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MyvideosCollectionViewCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (SCREEN_W-15)/4;
    
    return (CGSize){width,width};
}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(5, 5, 5, 5);
//}

//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModels.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){SCREEN_W,5};
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyvideosCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MyvideosCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    ALAsset *asset = self.assetDataSource[indexPath.row];
    
    cell.corverImgV.image = [UIImage imageWithCGImage:asset.thumbnail];
    DbLog(@"%@",[asset valueForProperty:ALAssetPropertyDuration]);
    NSNumber *duration = [asset valueForProperty:ALAssetPropertyDuration];
    cell.timeLabel.text = [self timeStrWithDuration:duration.integerValue];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark ---- UICollectionViewDelegate


// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.selecteIndex = indexPath.row;
    ALAsset *model = self.assetDataSource[indexPath.item];
    NSNumber *duration = [model valueForProperty:ALAssetPropertyDuration];
    if (duration.integerValue<15||duration.integerValue>180) {
        CoreSVPCenterMsg(@"请选择15秒~3分钟的视频参与PK");
        return;
    }
    //name是另存为的文件名
    [self videoWithAsset:model withFileName:@"aa.mov"];
}
-(void)pushToReviewWithlocalPath:(NSString *)localPath
{
    ALAsset *asset = self.assetDataSource[self.selecteIndex];
    ReviewMovieViewController *reVC = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
    reVC.corverImage = [UIImage imageWithCGImage:asset.thumbnail];
    ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
    NSString *uti = [defaultRepresentation UTI];
    NSURL  *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
    reVC.moviePath = localPath;
    reVC.ReferenceURL = videoURL;
    reVC.challenge = @"true";
    reVC.uploadTagId = self.uploadTagId;
    reVC.uploadTagName = self.uploadTagName;
    reVC.contestantVideoId = self.contestantVideoId;
    
    AVAsset *VideoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:localPath]];
    NSArray *tracks = [VideoAsset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        NSLog(@"=====hello  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);//宽高
        reVC.movieSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    }
    [self.navigationController pushViewController:reVC animated:YES];
}
// 将原始视频的URL转化为NSData数据,写入沙盒
- (void)videoWithAsset:(ALAsset *)asset withFileName:(NSString *)fileName
{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    CoreSVPLoading(@"处理中...", NO);
    ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
    NSString *uti = [defaultRepresentation UTI];
    NSURL *url = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
            
                NSString * videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
                char const *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 11024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    //计算文件的MD5
                    CC_MD5_CTX md5;
                    CC_MD5_Init(&md5);
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                            CC_MD5_Update(&md5, buffer, bufferSize);
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    //生成MD5
                    unsigned char digest[CC_MD5_DIGEST_LENGTH];
                    CC_MD5_Final(digest, &md5);
                    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                   digest[0], digest[1],
                                   digest[2], digest[3],
                                   digest[4], digest[5],
                                   digest[6], digest[7],
                                   digest[8], digest[9],
                                   digest[10], digest[11],
                                   digest[12], digest[13],  
                                   digest[14], digest[15]];
                    
                    DbLog(@"%@",s);
                    NSString *uriStr = [NSString stringWithFormat:@"%@/upload/videotoken?challenge=%@&key=%@&widthPX=%@&hightPX=%@",HeadUrl,@"false",@"aa",@(100),@(100)];
                    //发送请求获取token
                    [XYWhttpManager XYWpost:uriStr parameters:nil inView:nil sucess:^(id result) {
                        if ([result isKindOfClass:[NSDictionary class]]) {
                            NSString *token = [result objectForKey:@"uploadToken"];
                                if (token && token.length>0) {
                                    [XYWCompressionVideo compressedVideoOtherMethodWithURL:url compressionType:AVAssetExportPresetHighestQuality compressionResultPath:^(NSString *resultPath, float memorySize) {
                                        if (resultPath) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [CoreSVP dismiss];
                                            [self pushToReviewWithlocalPath:resultPath];
                                            });
                                        }
                                    }];
                                }else{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [CoreSVP dismiss];
                                        CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
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
            } failureBlock:nil];
        }
    });
}

-(NSString *)timeStrWithDuration:(NSInteger)duration
{
    int m = (int)duration/60;
    int s = duration%60;
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}

@end
