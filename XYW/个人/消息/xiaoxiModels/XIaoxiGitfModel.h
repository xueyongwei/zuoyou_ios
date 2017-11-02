//
//  XIaoxiGitfModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/22.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XiaoxiBodyModel.h"
#import "xiaoxiGiftExtras.h"
@interface XIaoxiGitfModel : NSObject
@property (nonatomic,strong)XiaoxiBodyModel *body;
@property (nonatomic,strong)xiaoxiGiftExtras *extras;
@property (nonatomic,copy)NSString *uri;
@end
