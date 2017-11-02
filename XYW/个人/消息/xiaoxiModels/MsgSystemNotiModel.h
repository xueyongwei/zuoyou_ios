//
//  MsgSystemNotiModel.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgModel.h"
//系统通知的扩展
@interface MsgSystemNotiModelExtra : NSObject;
@property (nonatomic,copy)NSString *versusTagName;
@property (nonatomic,copy)NSString *contestantType;
@property (nonatomic,strong)NSNumber *mid;
@property (nonatomic,strong)NSNumber *blueMid;
@property (nonatomic,strong)NSNumber *contestantId;
@property (nonatomic,strong)NSNumber *redMid;
@property (nonatomic,strong)NSNumber *versusId;
-(NSString *)formaterVersusTagName;
@end
//系统通知
@interface MsgSystemNotiModel : MsgModel

@property (nonatomic,strong)MsgSystemNotiModelExtra *extras;

@end
