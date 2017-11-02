//
//  tagModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tagModel : NSObject<NSCoding>

@property (nonatomic,strong)NSNumber *tagID;
@property (nonatomic,copy)NSString *tagName;
@property (nonatomic,copy)NSString *frontCover;
@property (nonatomic,strong)NSDictionary *activity;
-(NSString *)formatertagName;
@end
