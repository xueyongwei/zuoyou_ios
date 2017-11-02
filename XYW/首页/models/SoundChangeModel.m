//
//  SoundChangeModel.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "SoundChangeModel.h"

@implementation SoundChangeModel
-(SoundChangeEffect *)effect
{
    if (!_effect) {
        _effect = [[SoundChangeEffect alloc]init];
    }
    return _effect;
}
-(id)initWithName:(NSString *)name imgName:(NSString *)imgName tempo:(int)tempo rate:(int)rate pitch:(int)pitch{
    if (self = [super init]) {
        self.name = name;
        self.imgName = imgName;
        self.effect.tempo = tempo;
        self.effect.rate = rate;
        self.effect.pitch = pitch;
    }
    return self;
}
@end
