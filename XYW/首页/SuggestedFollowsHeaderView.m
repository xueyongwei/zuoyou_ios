//
//  SuggestedFollowsHeaderView.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "SuggestedFollowsHeaderView.h"

@implementation SuggestedFollowsHeaderView
- (IBAction)onCareClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(onCareClick)]) {
        [self.delegate onCareClick];
    }
}

- (IBAction)onCloseClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(removeTableViewHeaderView)]) {
        [self.delegate removeTableViewHeaderView];
    }
}


@end
