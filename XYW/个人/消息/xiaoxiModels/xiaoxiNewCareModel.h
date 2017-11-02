//
//  xiaoxiNewCareModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XiaoxiBodyModel.h"
#import "xiaoxiNewCareExtras.h"
@interface xiaoxiNewCareModel : NSObject
@property (nonatomic,strong)XiaoxiBodyModel *body;
@property (nonatomic,strong)xiaoxiNewCareExtras *extras;
@end
