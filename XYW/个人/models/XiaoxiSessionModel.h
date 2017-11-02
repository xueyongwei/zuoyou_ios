//
//  XiaoxiSessionModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XiaoxiBodyModel.h"
#import "MsgPersonalModelExtra.h"

@interface msgLastMessageModel : NSObject
@property (nonatomic,strong)XiaoxiBodyModel *body;
@property (nonatomic,strong)MsgPersonalModelExtra *extras;
@property (nonatomic,copy)NSString *uri;
@property (nonatomic,copy)NSString *showSum;
@end

@interface XiaoxiSessionModel : NSObject
@property (nonatomic,copy)NSString *messageSessionKey;
@property (nonatomic,assign)NSInteger unreadCount;
@property (nonatomic,strong)msgLastMessageModel *lastMessage;

//支持的消息
-(BOOL)isSuppotrType;
@end
