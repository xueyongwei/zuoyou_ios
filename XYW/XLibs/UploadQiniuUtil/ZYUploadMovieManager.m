//
//  ZYUploadMovieManager.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYUploadMovieManager.h"
#import "XYWhttpManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ShouYeViewController.h"
#import "UIWindow+TopViewController.h"
//#import "ZYUploadUtil.h"

@implementation ZYUploadMovieModel
@end


@interface ZYUploadMovieManager()
@property (nonatomic,strong)NSMutableArray *uploadTasts;
@end
@implementation ZYUploadMovieManager

-(NSMutableArray *)uploadTasts
{
    if (!_uploadTasts) {
        _uploadTasts = [NSMutableArray new];
    }
    return _uploadTasts;
}
+ (ZYUploadMovieManager *)defaultManager
{
    static ZYUploadMovieManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}
- (void)uploadCorver {
    ZYUploadMovieModel *model = self.uploadTasts.firstObject;
    NSString *corverKey = [NSString stringWithFormat:@"%@.jpg",[self keyWithFilePath:model.corverPath]];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@key=%@",HeadUrl,@"/upload/imgtoken?",corverKey];
    //发送请求获取token
    [XYWhttpManager XYWpost:urlStr parameters:nil inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"uploadToken"]) {
            NSString *token = [result objectForKey:@"uploadToken"];
            if (token) {
                [self uploadCorver:model.corverPath withToken:token andCorverKey:corverKey];
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];
}

/**
 *  上传到封面七牛
 *
 *  @param filePath  corver的路径
 *  @param aToken    token
 *  @param corverKey corver的key
 */
-(void)uploadCorver:(NSString *)filePath withToken:(NSString *)aToken andCorverKey:(NSString *)corverKey
{
    NSError *error;
    //断点续传保存进度
    QNFileRecorder *recorder = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"zuoyouMovieCache"] error:&error];
    if (error) {
        DbLog(@"file recorder %@", error);
        CoreSVPCenterMsg(@"无法创建缓存目录！");
        return;
    }
    
    //断点续传
    [QNFileRecorder fileRecorderWithFolder:@"/zuoyouMovieCache" error:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithRecorder:recorder];
    //上传参数
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        DbLog(@"%f",percent);
    } params:nil checkCrc:YES cancellationSignal:^BOOL{
        return NO;
    }];
    //上传文件
    [upManager putFile:filePath key:corverKey token:aToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        DbLog(@"%@ %@ %@",info,key,resp);
        if (info.isOK) {//封面上传完成
            //删除封面图
            //上传电影
            [self uploadMovieAndShowProgressWithCorver:key];
        }else{
            CoreSVPCenterMsg(info.error.localizedDescription);
        }
    } option:opt];
    
}
/**
 *  请求movie的token
 *
 *  @param corverKey 封面的地址
 */
-(void)uploadMovieAndShowProgressWithCorver:(NSString *)corverKey
{
    ZYUploadMovieModel *model = self.uploadTasts.firstObject;
    NSString *movieKey = [self keyWithFilePath:model.moviePath];
    
    NSString *uriStr = [NSString stringWithFormat:@"%@/upload/videotoken?challenge=%@&key=%@&widthPX=%@&hightPX=%@&md5=%@",HeadUrl,model.challenge,movieKey,@(model.movieSize.width),@(model.movieSize.height),model.movieMD5];
    //发送请求获取token
    [XYWhttpManager XYWpost:uriStr parameters:nil inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"uploadToken"]) {
            NSString *token = [result objectForKey:@"uploadToken"];
            if (token) {
                [self uploadMovie:model.moviePath withToken:token movieKey:movieKey andCorverKey:(NSString *)corverKey andVC:[result objectForKey:@"vc"]];
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];
}

-(void)uploadMovie:(NSString *)filePath withToken:(NSString *)aToken movieKey:(NSString *)movieKey andCorverKey:(NSString *)corverKey andVC:(NSString *)vc
{
    NSError *error;
//    断点续传保存进度
//    QNFileRecorder *recorder = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"zuoyouMovieCache"] error:&error];
    if (error) {
        DbLog(@"file recorder %@", error);
        CoreSVPCenterMsg(@"无法创建缓存目录！");
        return;
    }
    //断点续传
    ZYUploadMovieModel *model = self.uploadTasts.firstObject;
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:corverKey forKey:@"x:frontCover"];
    [param setObject:model.uploadDescription forKey:@"x:description"];
    [param setObject:vc forKey:@"x:vc"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)[self mySelfId]] forKey:@"x:mid"];
    [param setObject:model.contestantVideoId forKey:@"x:contestantVideoId"];
    [param setObject:model.uploadTagId forKey:@"x:tagId"];
    [param setObject:model.movieMD5 forKey:@"x:md5"];
    [param setObject:model.uploadTagName forKey:@"x:tagName"];
    
    UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    
 
    ShouYeViewController *shouye = (ShouYeViewController*)[UIWindow getViewControllerInRootViewControllerWithIndex:0];
    [shouye.uploadProgressWindow addSubview:progressView];

    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(progressView.superview);
        make.height.mas_equalTo(20);
    }];
    progressView.contentMode = UIViewContentModeScaleAspectFill;
    progressView.trackTintColor = [UIColor colorWithHexColorString:@"999999"];
    progressView.progressTintColor = [UIColor colorWithHexColorString:@"ff4a4b" alpha:1];
    
    UILabel *progressLabel = [UILabel new];
    [progressView addSubview:progressLabel];
    [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(progressView);
    }];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.font = [UIFont systemFontOfSize:11];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.text = @"视频上传中0％";
    
    [QNFileRecorder fileRecorderWithFolder:@"/zuoyouMovieCache" error:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithRecorder:nil];
    //上传参数
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        DbLog(@"%f",percent);
        dispatch_async(dispatch_get_main_queue(), ^{
            progressLabel.text = [NSString stringWithFormat:@"视频上传中%.1f％",percent*100];
            [progressView setProgress:percent animated:YES];
        });
        
    } params:param checkCrc:YES cancellationSignal:^BOOL{
        return NO;
    }];
    //上传文件
    [upManager putFile:filePath key:movieKey token:aToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        DbLog(@"%@ %@ %@",info,key,resp);
        if (info.isOK) {//movie上传完成
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressView removeFromSuperview];
                CoreSVPCenterMsg(@"已成功上传，可在个人主页查看");
            });
            [self.uploadTasts removeObjectAtIndex:0];
            if (self.uploadTasts.count>0) {
                [self uploadCorver];
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressView removeFromSuperview];
                UIView *faildview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 64)];
                faildview.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
                faildview.userInteractionEnabled = YES;
                UILabel *faildLabel = [UILabel new];
                [faildview addSubview:faildLabel];
                [faildLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.right.left.bottom.equalTo(faildview);
                }];
                faildLabel.textColor = [UIColor whiteColor];
                faildLabel.font = [UIFont systemFontOfSize:14];
                faildLabel.textAlignment = NSTextAlignmentCenter;
                faildLabel.text = @"上传失败，点击重试";
                
                UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [faildview addSubview:closeBtn];
                [closeBtn setImage:[UIImage imageNamed:@"上传进度关闭"] forState:UIControlStateNormal];
                [closeBtn addTarget:self action:@selector(onCloseUploadClick:) forControlEvents:UIControlEventTouchUpInside];
                [closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(faildview);
                    make.right.equalTo(faildview.mas_right).offset(-13);
                    make.width.height.mas_equalTo(23);
                }];
                UITapGestureRecognizer *tapRetry = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onRetryViewRecoginzer:)];
                [faildview addGestureRecognizer:tapRetry];
                [shouye.uploadProgressWindow addSubview:faildview];
            });
            
        }
    } option:opt];
}
-(void)onRetryViewRecoginzer:(UITapGestureRecognizer *)recognizer
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        CoreSVPCenterMsg(@"请检查网络连接！");
        return;
    }
    [recognizer.view removeFromSuperview];
    [self uploadCorver];
}
-(void)onCloseUploadClick:(UIButton *)sender
{
    [self.uploadTasts removeObjectAtIndex:0];
    if (self.uploadTasts.count>0) {
        [self uploadCorver];
    }
    [sender.superview removeFromSuperview];
}
-(void)addTastWithCorverPath:(NSString *)corverPath moviePath:(NSString *)moviePath movieMD5:(NSString *)md5 movieSize:(CGSize)size challenge:(NSString *)challenge tagID:(NSString *)tagID tagName:(NSString *)tagName contestantVideoId:(NSString *)contestantVideoId description:(NSString *)description
{
    ZYUploadMovieModel *model = [ZYUploadMovieModel new];
    model.corverPath = corverPath;
    model.moviePath = moviePath;
    model.movieSize = size;
    model.challenge = challenge;
    model.uploadTagId = tagID.integerValue>0?tagID:@"";
    model.uploadTagName = tagName;
    model.uploadDescription = description;
    model.contestantVideoId = contestantVideoId.integerValue>0?contestantVideoId:@"";
    model.movieMD5 = md5;
    [self.uploadTasts addObject:model];

    if (self.uploadTasts.count==1) {//只有一个的时候说明刚开始的任务
        [self uploadCorver];
    }
}
/**
 *  获取文件的key
 *
 *  @param filePath 文件路径
 *
 *  @return 如果保存过了这个key，可以断点续传，否则新生成一个key
 */
-(NSString *)keyWithFilePath:(NSString *)filePath
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYMM"];
    NSString *DateTime = [formatter stringFromDate:date];

    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    
    NSString *key = [NSString stringWithFormat:@"%@/%ld_%lld",DateTime,(long)[self mySelfId],theTime];

    return key;
}
/**
 *  我的ID
 */
-(NSInteger )mySelfId
{
    return [UserInfoManager mySelfInfoModel].mid.integerValue;
}
@end
