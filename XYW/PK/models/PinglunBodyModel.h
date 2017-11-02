//
//  PinglunBodyModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinglunBodyModel : NSObject
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,assign)NSInteger pinglunID;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)double timeAgo;
-(NSString *)howLongStr;
@end
