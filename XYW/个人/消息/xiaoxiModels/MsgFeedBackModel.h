//
//  xiaoxiFeedBackModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgModel.h"

//意见反馈的扩展
@interface MsgFeedBackExtras : NSObject
@property (nonatomic,strong) NSNumber *contacts;
@property (nonatomic,strong) NSNumber *mid;
@property (nonatomic,copy)NSString *nickname;
@end

//意见反馈
@interface MsgFeedBackModel : MsgModel
@property (nonatomic,strong)MsgFeedBackExtras *extras;
@end
