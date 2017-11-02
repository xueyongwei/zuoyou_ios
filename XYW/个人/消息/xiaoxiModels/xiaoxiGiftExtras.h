//
//  xiaoxiGiftExtras.h
//  HDJ
//
//  Created by xueyongwei on 16/7/22.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xiaoxiGiftExtras : NSObject
/*
contestantBlueMid = 138379;
contestantId = 21;
contestantRedMid = 18;
contestantType = RED;
itemId = 11;
itemName = "\U80a5\U7682";
itemPrice = 30;
itemVal = 30;
versusId = 1;
versusTagName = winter;
 contestantType
 */
@property (nonatomic,copy)NSString *contestantType;
@property (nonatomic,copy)NSString *itemName;
@property (nonatomic,copy)NSString *versusTagName;
@property (nonatomic,assign)NSInteger blueMid;
@property (nonatomic,assign)NSInteger contestantId;
@property (nonatomic,assign)NSInteger redMid;
@property (nonatomic,assign)NSInteger itemId;
@property (nonatomic,assign)NSInteger itemPrice;
@property (nonatomic,assign)NSInteger itemVal;
@property (nonatomic,assign)NSInteger versusId;
@property (nonatomic,assign)NSInteger mid;
-(NSString *)formaterVersusTagName;
@end
