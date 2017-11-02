//
//  XiaoxiSessionModel.m
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XiaoxiSessionModel.h"
@implementation msgLastMessageModel

@end


@implementation XiaoxiSessionModel
-(BOOL)isSuppotrType
{
    NSString *type = self.messageSessionKey;
    if ([type hasPrefix:@"system/social/comment"]) {//评论和回复
        return YES;
    }else if ([type hasPrefix:@"system/finance/item"]){//礼物
        return YES;
    }else if ([type hasPrefix:@"system/pk/notice"]){//赛事
        return YES;
    }else if ([type hasPrefix:@"system/user/follow"]){//关注
        return YES;
    }else if ([type hasPrefix:@"system/notice"]){//小豆说
        return YES;
    }else if ([type hasPrefix:@"system/user/notice"]){//系统通知
        return YES;
    }else if ([type hasPrefix:@"system/finance/praise"]){//赞
        return YES;
    }else if ([type hasPrefix:@"private/dialog"]){//私信
        return YES;
    }
    
    return NO;
}

@end
