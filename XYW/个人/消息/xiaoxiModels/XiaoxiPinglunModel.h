//
//  XiaoxiPinglunModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XiaoxiBodyModel.h"
#import "xiaoxiPinglunExtras.h"
@interface XiaoxiPinglunModel : NSObject

@property (nonatomic,strong)XiaoxiBodyModel *body;
@property (nonatomic,strong)xiaoxiPinglunExtras *extras;
@end
