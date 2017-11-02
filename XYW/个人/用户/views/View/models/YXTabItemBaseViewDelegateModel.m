//
//  YXTabItemBaseViewDelegateModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "YXTabItemBaseViewDelegateModel.h"

@implementation YXTabItemBaseViewDelegateModel
//容错
-(void)setNumber:(CGFloat)number
{
    if (number<0) {
        _number = 0;
    }else if (number>100){
        _number = 100;
    }else{
        _number = number;
    }
}
@end
