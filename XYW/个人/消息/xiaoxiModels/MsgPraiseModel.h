//
//  MsgPraiseModel.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgModel.h"
//意见反馈的扩展
@interface MsgPraiseExtras : NSObject
@property (nonatomic,copy)NSString *versusTagName;
@property (nonatomic,copy)NSString *contestantType;
@property (nonatomic,strong)NSNumber *mid;
@property (nonatomic,strong)NSNumber *blueMid;
@property (nonatomic,strong)NSNumber *contestantId;
@property (nonatomic,strong)NSNumber *redMid;
@property (nonatomic,strong)NSNumber *versusId;
-(NSString *)formaterVersusTagName;
@end

@interface MsgPraiseModel : MsgModel
@property (nonatomic,strong)MsgPraiseExtras *extras;
@end
