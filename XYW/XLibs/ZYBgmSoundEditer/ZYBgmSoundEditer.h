//
//  ZYBgmSoundEditer.h
//  VideoWithSound
//
//  Created by xueyognwei on 2017/2/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface ZYSoundModel : NSObject
@property (nonatomic,assign)CGFloat startTime;
@property (nonatomic,copy)NSString *soundFilePath;
@end

@interface ZYBgmSoundEditer : NSObject

/**
 左右：给视频添加背景音乐和音效

 @param bgmUrl 背景音乐URL
 @param soundModels 要添加的音效们
 @param videoUrl 视频url
 @param outputFilePath 输出到路径
 @param completionHandle 完成回调
 */
+(void)addBgmFileUrl:(NSURL *)bgmUrl soundEffetFileModels:(NSArray *)soundModels toVidelFileUrl:(NSURL *)videoUrl outPutFilePath:(NSString *)outputFilePath completion:(void (^)(NSString *outPath, BOOL isSuccess))completionHandle;

@end
