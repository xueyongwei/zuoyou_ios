//
//  MsgModel.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MsgModelBody : NSObject
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSMutableAttributedString *contenText;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,strong)NSNumber *MsgId;
@property (nonatomic,assign)double timeAgo;
-(NSString *)howLongStr;
@end

@interface MsgModel : NSObject
@property (nonatomic,strong)MsgModelBody *body;
@property (nonatomic,copy)NSString *uri;
@end
