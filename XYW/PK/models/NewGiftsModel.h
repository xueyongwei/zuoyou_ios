//
//  NewGiftsModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewGiftsModel : NSObject
//@property (nonatomic,copy)NSString *
//@property (nonatomic,assign)NSInteger
@property (nonatomic,assign)NSInteger contestantId;
@property (nonatomic,copy)NSString * contestantType;
@property (nonatomic,assign)NSInteger itemId;
@property (nonatomic,copy)NSString * itemName;
@property (nonatomic,assign)NSInteger itemPrice;
@property (nonatomic,assign)NSInteger itemVal;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)NSInteger versusId;
@end
