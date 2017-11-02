//
//  GiftsModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/24.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftsModel : NSObject
@property (nonatomic,copy) NSString *createdDate;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *animationVersion;
@property (nonatomic,assign)NSInteger GiftsID;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign)NSInteger price;
@property (nonatomic,assign)NSInteger val;

@end
