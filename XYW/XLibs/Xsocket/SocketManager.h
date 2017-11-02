//
//  SocketManager.h
//  testChat
//
//  Created by xueyongwei on 16/5/5.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSmessageModel : NSObject

@property (nonatomic,copy)NSString *uri;
@property (nonatomic,strong)NSObject *body;
@property (nonatomic,strong)NSDictionary *extras;
@property (nonatomic,strong)NSDictionary *headers;
@end

@interface SocketManager : NSObject
//默认管理器，首次使用会自动创建个连接
+(SocketManager *)defaultManager;
//创建一个新的连接
-(void)createWS;
////打开ws连接
//-(void)connectWS;
/*
 销毁ws，用以新建ws连接
 */
-(void)dropWS;
////关闭ws连接
//-(void)closeWS;
//发送消息
-(void)sendMsg:(id)msg;
@end
