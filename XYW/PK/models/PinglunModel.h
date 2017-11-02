//
//  PinglunModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PinglunBodyModel.h"
#import "PingluExtModel.h"
@interface PinglunModel : NSObject
//@property (nonatomic,copy)NSString *
//@property (nonatomic,assign)NSInteger
@property (nonatomic,strong)PinglunBodyModel *body;
@property (nonatomic,strong)PingluExtModel *extras;

@property (nonatomic,copy)NSString *uri;

@end
