//
//  ZYBgmSoundEditer.m
//  VideoWithSound
//
//  Created by xueyognwei on 2017/2/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "ZYBgmSoundEditer.h"
@implementation ZYSoundModel

@end

@implementation ZYBgmSoundEditer
/**
 左右：给视频添加背景音乐和音效
 
 @param bgmUrl 背景音乐URL
 @param soundModels 要添加的音效们
 @param videoUrl 视频url
 @param outputFilePath 输出到路径
 @param completionHandle 完成回调
 */
+(void)addBgmFileUrl:(NSURL *)bgmUrl soundEffetFileModels:(NSArray *)soundModels toVidelFileUrl:(NSURL *)videoUrl outPutFilePath:(NSString *)outputFilePath completion:(void (^)(NSString *outPath, BOOL isSuccess))completionHandle
{
    
    //视频路径
    NSURL   *video_inputFileUrl = videoUrl;
    NSURL   *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    //创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    //视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc]initWithURL:video_inputFileUrl options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    //视频画面采集
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack*a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange
                                     ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                      atTime:nextClipStartTime
                                       error:nil];
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    
    CGFloat videoTimeSeconds =(float)videoAsset.duration.value/(float)videoAsset.duration.timescale;
    DbLog(@"value = %lld,timescale = %d",videoAsset.duration.value,videoAsset.duration.timescale);
    //背景音乐路径
    if (bgmUrl) {
        NSURL   *audio_inputFileUrl = bgmUrl;
        //音乐声音采集
        AVURLAsset *bgmAudioAsset =[[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
        
        CGFloat bgmAudioTimeSeconds =(float)bgmAudioAsset.duration.value/(float)bgmAudioAsset.duration.timescale;
        
        if (bgmAudioTimeSeconds>videoTimeSeconds) {//背景音乐足够长
            CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
            AVMutableCompositionTrack*b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
            [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[bgmAudioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }else{//背景音乐需要重复播放
            NSInteger repeatimes = videoTimeSeconds/bgmAudioTimeSeconds;
            for (NSInteger i=0; i<repeatimes; i++) {
                NSLog(@"第%ld次添加",i+1);
                CGFloat startTime = i*videoTimeSeconds;
                CMTime start = CMTimeMakeWithSeconds(startTime, videoAsset.duration.timescale);
                CMTimeRange audio_timeRange = CMTimeRangeMake(start, videoAsset.duration);
                AVMutableCompositionTrack*b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
                [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[bgmAudioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:kCMTimeZero error:nil];
                
            }
            CGFloat stileTimeSecond= videoTimeSeconds - bgmAudioTimeSeconds *repeatimes ;
            if (stileTimeSecond>0 ) {//剩余的时间不够一首歌的时间
                NSLog(@"添加剩余的%f秒",stileTimeSecond);
                CGFloat startTime = repeatimes*videoTimeSeconds;
                CMTime start = CMTimeMakeWithSeconds(startTime, videoAsset.duration.timescale);
                CMTimeRange audio_timeRange = CMTimeRangeMake(start, videoAsset.duration);
                AVMutableCompositionTrack*b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
                [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[bgmAudioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:kCMTimeZero error:nil];
            }
        }
    }
    
    
    
    
    
    //音效声音采集
    for (ZYSoundModel *sound in soundModels) {
        AVURLAsset *effectAudioAsset =[[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:sound.soundFilePath] options:nil];
        CGFloat valueableSeconds = videoTimeSeconds - sound.startTime;
        CGFloat effectSeconds = effectAudioAsset.duration.value/effectAudioAsset.duration.timescale;
        if (valueableSeconds >effectSeconds) {//还能够放下
            AVMutableCompositionTrack*eff_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                              preferredTrackID:kCMPersistentTrackID_Invalid];
            CMTime start = CMTimeMakeWithSeconds(sound.startTime, effectAudioAsset.duration.timescale);
            CMTimeRange effect_timeRange = CMTimeRangeMake(kCMTimeZero, effectAudioAsset.duration);
            [eff_compositionAudioTrack insertTimeRange:effect_timeRange ofTrack:[[effectAudioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:start error:nil];
        }else if (valueableSeconds >0){//还有时间，但是放不下这个长度了
            DbLog(@"还有时间，但是放不下这个长度了~");
            AVMutableCompositionTrack*eff_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                              preferredTrackID:kCMPersistentTrackID_Invalid];
            CMTime start = CMTimeMakeWithSeconds(sound.startTime, effectAudioAsset.duration.timescale);
            CMTime end = CMTimeMakeWithSeconds(valueableSeconds, effectAudioAsset.duration.timescale);
            CMTimeRange effect_timeRange = CMTimeRangeMake(kCMTimeZero, end);
            [eff_compositionAudioTrack insertTimeRange:effect_timeRange ofTrack:[[effectAudioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:start error:nil];
        }else{
            DbLog(@"没时间喽，略略略~");
        }
        
    }
    
    //创建一个输出
    AVAssetExportSession* _assetExport =[[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileUrl;
    
    _assetExport.shouldOptimizeForNetworkUse= YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch ([_assetExport status]) {
             case AVAssetExportSessionStatusFailed: {
                 NSLog(@"合成失败：%@",[[_assetExport error] description]);
                 completionHandle(outputFilePath,NO);
             } break;
             case AVAssetExportSessionStatusCancelled: {
                 completionHandle(outputFilePath,NO);
             } break;
             case AVAssetExportSessionStatusCompleted: {
                 completionHandle(outputFilePath,YES);
             } break;
             default: {
                 completionHandle(outputFilePath,NO);
             } break;
         }
         
     }
     ];
    
}

@end
