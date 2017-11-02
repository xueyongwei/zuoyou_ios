//
//  FlashModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/8/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fram_flashModel.h"
@interface FlashModel : NSObject<NSCoding>
@property (nonatomic,copy)NSString *fram_count;
@property (nonatomic,copy)NSString *flashID;
@property (nonatomic,copy)NSString *report;
@property (nonatomic,copy)NSString *vc;
@property (nonatomic,copy)NSString *rootPath;
@property (nonatomic,strong)NSArray *fram_flashs;
@end
