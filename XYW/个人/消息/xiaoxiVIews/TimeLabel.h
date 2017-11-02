//
//  TimeLabel.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/2.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLabel : UILabel
// 用来决定上下左右内边距，也可以提供一个借口供外部修改，在这里就先固定写死
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@end
