//
//  SocketManager.m
//  testChat
//
//  Created by xueyongwei on 16/5/5.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SocketManager.h"
#import "SRWebSocket.h"
#import <MJExtension/MJExtension.h>


@implementation WSmessageModel

@end

@interface SocketManager ()<SRWebSocketDelegate>

@property (nonatomic,strong)SRWebSocket *socket;
@property (nonatomic,assign)int ReconnectCount;//重连次数
@property (nonatomic,assign)BOOL sleepForBackGround;
@property (nonatomic,assign)BOOL reConnecting;//正在重连
@end

@implementation SocketManager

+(SocketManager *)defaultManager
{
    static SocketManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        manager.reConnecting = NO;
        manager.ReconnectCount = 0;
        [manager addNoti];
    });
    return manager;
}
//创建一个新的socket链接，会重新获取token
-(void)createWS{
    DbLog(@"将要创建新的连接..");
    if (![UserInfoManager haveLogined]) {
        DbLog(@"没有登录，不能链接socket");
        return ;
    }
    if (self.socket && self.socket.readyState == SR_OPEN) {
        DbLog(@"当前socket已连接，放弃本次连接请求");
        return;
    }
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *url = KWSurl;
    NSString *parm = [NSString stringWithFormat:@"token=%@&ts=%@",[UserInfoManager mySelfInfoModel].token,ts];
    NSString *vc = [NSString stringWithFormat:@"%@%@",parm,SECUREKEY];
    DbLog(@"本次连接ws的parm:%@",parm);
  
    [self.socket close];
    self.socket.delegate = nil;
    
    DbLog(@"新的socket连接已发起..");
    SRWebSocket *socket = [[SRWebSocket alloc]initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@&vc=%@&vn=%@",url,parm,vc.md5,KAPPVERSION]]]];
    socket.delegate = self;
    [socket open];
    self.socket = socket;
}
//销毁ws，用以新建ws连接
-(void)dropWS{
    DbLog(@"socket连接已关闭。");
    [self.socket close];
    self.socket.delegate = nil;
//    self.socket = nil;
}
//防止应用失活导致的socket状态不正确，主动断开或者连接socket
-(void)addNoti
{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)appDidEnterBackground
{
    DbLog(@"应用失活，将要断开socket");
    self.sleepForBackGround = YES;
    [self dropWS];
}
-(void)appDidEnterPlayGround
{
    DbLog(@"应用被唤醒");
    if (self.sleepForBackGround) {
        DbLog(@"已因休眠断开ws，重新连接socket");
        [self createWS];
        self.sleepForBackGround = NO;
    }
}
//重新连接：先断开，再创建个新的socket
-(void)reConnectWS
{
    DbLog(@"将要重新连接..");
    if (self.reConnecting) {
        DbLog(@"正在重连，本次重连放弃。");
        return;
    }
    if (self.socket.readyState == SR_OPEN) {
        DbLog(@"socket已连接，本次连接放弃。");
        return;
    }
    //不管什么状态，都重新创建个连接
    self.reConnecting = YES;
    [self createWS];

}

//发送ws消息
-(void)sendMsg:(id)msg{//发送ws消息
    DbLog(@"准备发送消息:%@",msg);
    if (self.socket && self.socket.readyState == SR_OPEN) {//开启状态直接发送消息
        DbLog(@"消息已发送..");
        [self.socket send:msg];
    }else{
        DbLog(@"ws没有打开，重连，稍后发送..");
        [self reConnectWS];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendMsg:msg];
        });
    }
}

#pragma mark ---WS的代理方法
//ws打开成功
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.reConnecting = NO;
    self.ReconnectCount = 0;
    DbLog(@"%@ 连接成功!",webSocket);
    NSNotification *noti = [[NSNotification alloc]initWithName:@"SOCKETOPEN" object:nil userInfo:@{@"tag":@"1"}];
    [[NSNotificationCenter defaultCenter]postNotification:noti];
    
}
//出错了
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    self.reConnecting = NO;
    DbLog(@"连接出错！error:%@",error.localizedDescription);
    NSString *errMsg = [NSString stringWithFormat:@"连接消息服务失败：%@",error.localizedDescription];
    CoreSVPCenterMsg(errMsg);
    if (error.code == 50) {//没有网络  不再连接
    }else{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self reConnectWS];
//        });
    }
    NSNotification *noti = [[NSNotification alloc]initWithName:@"SOCKETERROR" object:nil userInfo:@{@"tag":@"1",@"error":error.localizedDescription}];
//    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [[NSNotificationCenter defaultCenter]postNotification:noti];
//    });
}

//ws关闭
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.reConnecting = NO;
    DbLog(@"WS 连接已关闭! reason:%@ ",reason);
}
//收到了ws消息
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    self.reConnecting = NO;
    DbLog(@"收到消息:\n%@",message);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if (![dic isKindOfClass:[NSDictionary class]]) {//不是正确的数据
        DbLog(@"❌ 错误的消息！");
        return;
    }
    NSNumber *errCode = [dic objectForKey:@"errorCode"];
    if (errCode) {//如果报错了
        return;
    }
    WSmessageModel *model = [WSmessageModel mj_objectWithKeyValues:message];
    if (model) {
        if ([model.uri isEqualToString:@"system/user/relogin"]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kShouldLogoutNoti object:nil];
            return;
        }
        [self messageHandle:model.uri model:model];
    }
}

#pragma mark ---收到WS发送的消息，对消息进行分发处理
-(void)messageHandle:(NSString *)uri model:(WSmessageModel *)model
{
    NSRange range = [uri rangeOfString:@"?"];//查找子串，找不到返回NSNotFound 找到返回location和length
    if (range.location != NSNotFound) {
        NSString * ptr1 = [uri substringToIndex:range.location];//字符串抽取 从下标0开始到4 不包括4
        
        NSString *ptr2 = [ptr1 stringByReplacingOccurrencesOfString:@"/" withString:@""];
        DbLog(@"%@ -> %@",ptr1,ptr2);
        // something
        if (model) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:ptr2 object:nil userInfo:@{@"model":model}];
//            });
        }
    }else{
        NSString *ptr2 = [uri stringByReplacingOccurrencesOfString:@"/" withString:@""];
        DbLog(@"%@ -> %@",uri,ptr2);
        // something
        if (model) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:ptr2 object:nil userInfo:@{@"model":model}];
//            });
        }
    }
}


@end
