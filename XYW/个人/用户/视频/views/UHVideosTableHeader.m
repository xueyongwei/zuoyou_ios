//
//  UHVideosTableHeader.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHVideosTableHeader.h"

@implementation UHVideosTableHeader


-(void)setVideoState:(personalVideoType)videoState
{
    if (videoState == personalVideoTypeDone) {
        self.stateView .hidden = YES;
        self.playImgV.hidden = NO;
    }else{
        self.stateView .hidden = NO;
        self.playImgV.hidden = YES;
        if (videoState == personalVideoTypeWaiting) {
            self.watiStateLabel.hidden = NO;
            self.failStateBtn.hidden = YES;
        }else{
            self.watiStateLabel.hidden = YES;
            self.failStateBtn.hidden = NO;
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
