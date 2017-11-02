//
//  EffectVoiceModel.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/3/6.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EffectVoiceModel : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *imgName;
@property (nonatomic,copy)NSString *voicePath;
//@property (nonatomic,assign)SystemSoundID soundID;
@end
