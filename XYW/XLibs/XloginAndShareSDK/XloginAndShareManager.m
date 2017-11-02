//
//  XloginAndShareManager.m
//  XloginAndShare
//
//  Created by xueyongwei on 16/7/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XloginAndShareManager.h"
#import "AppDelegate.h"
@interface XloginAndShareManager()
@property (nonatomic,copy)NSString *wbtoken;
@end
@implementation XloginAndShareManager
{
    TencentOAuth *_qqOAuth;
    BOOL wxHasDone;
    void(^qqLoginTmpBlock)(NSDictionary *dic);
    void(^wbLoginTmpBlock)(NSDictionary *dic);
    void(^wxLoginTmpBlock)(NSDictionary *dic);
    
    void(^wxShareTmpBlock)(NSDictionary *dic);
    void(^wbShareTmpBlock)(NSDictionary *dic);
    void(^qqShareTmpBlock)(NSDictionary *dic);
}
+(XloginAndShareManager *)defaultManager
{
    static XloginAndShareManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[XloginAndShareManager alloc] init];
    });
    return sharedAccountManagerInstance;
}
+(BOOL)HandleOpenURL:(NSURL *)url
{
    if ([TencentOAuth HandleOpenURL:url]) {
        return  [TencentOAuth HandleOpenURL:url];
    }else if ([WeiboSDK handleOpenURL:url delegate:[XloginAndShareManager defaultManager]]){
        return [WeiboSDK handleOpenURL:url delegate:[XloginAndShareManager defaultManager]];
    }else if ([WXApi handleOpenURL:url delegate:[XloginAndShareManager defaultManager]]){
        return [WXApi handleOpenURL:url delegate:[XloginAndShareManager defaultManager]];
    }else if ([QQApiInterface handleOpenURL:url delegate:[XloginAndShareManager defaultManager]]){
        return [QQApiInterface handleOpenURL:url delegate:[XloginAndShareManager defaultManager]];
    }else{
        return NO;
    }
}
+(void)XregisterApp
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kWeiboAppKey];
    
    [WXApi registerApp:kWeixinAppId];
}
-(id)init
{
    if (self = [super init]) {
        _qqOAuth = [[TencentOAuth alloc]initWithAppId:kTencentAppID andDelegate:self];
        wxHasDone = NO;
    }
    return self;
}
#pragma mark ---三种登录方式
-(void)loginWithQQ:(void (^)(NSDictionary *))infoBlock
{
    [_qqOAuth authorize:[NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,kOPEN_PERMISSION_ADD_SHARE, nil] inSafari:NO];
    
    qqLoginTmpBlock = infoBlock;
}
-(void)loginWithWB:(void(^)(NSDictionary *userInfo))infoBlock
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURI;
    request.shouldShowWebViewForAuthIfCannotSSO = YES;
    request.scope = @"follow_app_official_microblog";
    [WeiboSDK sendRequest:request];
    wbLoginTmpBlock = infoBlock;
}
-(void)loginWithWX:(void(^)(NSDictionary *userInfo))infoBlock
{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"App";
    [WXApi sendReq:req];
    wxLoginTmpBlock = infoBlock;
}

#pragma mark ----👪分享到三方
-(void)shareToQQ:(NSDictionary *)param result:(void (^)(NSDictionary *))infoBlock
{
    qqShareTmpBlock = infoBlock;
    QQApiNewsObject *newsObj;
    if (self.shareData[@"shareImg"]) {
        newsObj = [QQApiNewsObject objectWithURL: [NSURL URLWithString:self.shareData[@"shareUrl"]] title:self.shareData[@"shareTitle"] description:self.shareData[@"shareDesc"] previewImageURL: [NSURL URLWithString:self.shareData[@"shareImgUrl"]]];
    }else if (self.shareData[@"shareImgUrl"]){
        newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.shareData[@"shareUrl"]] title:self.shareData[@"shareTitle"] description:self.shareData[@"shareDesc"] previewImageData:self.shareData[@"shareImgUrl"]];
    }
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if ([param[@"to"] isEqualToString:@"qq"]) {
        [QQApiInterface sendReq:req];
    }else{
        [QQApiInterface SendReqToQZone:req];
    }
    
}
-(void)shareToWx:(NSDictionary *)param result:(void (^)(NSDictionary *))infoBlock
{
    wxShareTmpBlock = infoBlock;
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = [param[@"to"] isEqualToString:@"wx"]?0:1;
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    NSDictionary *shareData = [self shareData];
    urlMessage.title = shareData[@"shareTitle"];//分享标题
    urlMessage.description = shareData[@"shareDesc"];//分享描述
    UIImage *img = [shareData[@"shareImg"] imageByScalingAndCroppingForSize:CGSizeMake(120, 120)];
//    urlMessage.thumbData = shareData[@"shareImg"];
    [urlMessage setThumbImage:img];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = shareData[@"shareUrl"];//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

-(void)shareToWb:(NSDictionary *)param result:(void (^)(NSDictionary *))infoBlock
{
    wbShareTmpBlock = infoBlock;
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    
    authRequest.redirectURI = kWeiboRedirectURI;
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    
    NSDictionary *shareData = [self shareData];
    
    WBWebpageObject *webObj = [WBWebpageObject object];
    webObj.objectID = @"haveno";
    
    webObj.title =shareData[@"shareTitle"];
    webObj.description = shareData[@"shareDesc"];
    webObj.scheme =shareData[@"shareUrl"];
    webObj.webpageUrl = shareData[@"shareUrl"];
    UIImage *img = [shareData[@"shareImg"] imageByScalingAndCroppingForSize:CGSizeMake(120, 120)];
//    webObj.thumbnailData = UIImagePNGRepresentation([shareData[@"shareImg"] imageByScalingAndCroppingForSize:CGSizeMake(120, 120)]);
    
    webObj.thumbnailData = UIImageJPEGRepresentation(img, 1);
    webObj.webpageUrl = shareData[@"shareUrl"];//分享链接
//    message.mediaObject = webObj;
    message.text = [NSString stringWithFormat:@"%@%@ by 左右视频 %@（@左右视频APP http://zuoyoupk.com）",shareData[@"shareDesc"],shareData[@"shareTitle"],shareData[@"shareUrl"]];
    WBImageObject *imageObj = [[WBImageObject alloc]init];
    imageObj.imageData = UIImageJPEGRepresentation(img, 0.9);
    message.imageObject = imageObj;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
    [WeiboSDK sendRequest:request];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = NSLocalizedString(@"左右", nil);
    webpage.description = [NSString stringWithFormat:NSLocalizedString(@"分享网页内容简介-%.0f", nil), [[NSDate date] timeIntervalSince1970]];
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"]];
    webpage.webpageUrl = @"http://www.xyw.pub";
    message.mediaObject = webpage;
    
    return message;
}












#pragma mark ---tencentSessionDelegate
-(void)tencentDidLogin
{
    [_qqOAuth getUserInfo];
}
-(void)tencentDidLogout
{
    
}
-(void)tencentDidNotNetWork
{
    
}
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    CoreSVPCenterMsg(@"授权失败");
}
-(void)getUserInfoResponse:(APIResponse *)response
{
    DbLog(@"%@",response.jsonResponse);
    NSString *imgUrl = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
    NSString *nickName = [response.jsonResponse objectForKey:@"nickname"];
    
    DbLog(@"%@ %@",imgUrl,nickName);
    qqLoginTmpBlock(@{@"userName":nickName?nickName:@"",@"userImg":imgUrl?imgUrl:@"",@"openID":_qqOAuth.getUserOpenID});
    
}
#pragma mark ---微博的代理方法
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if (response.statusCode==WeiboSDKResponseStatusCodeSuccess) {
            wbShareTmpBlock(@{@"shareState":@"sucess"});
        }else{
            CoreSVPCenterMsg(@"授权失败");
            wbShareTmpBlock(@{@"shareState":@"fail"});
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        //        https://api.weibo.com/2/users/show.json
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        if (self.wbtoken) {
            NSDictionary *dic=@{@"access_token":[(WBAuthorizeResponse *)response accessToken],@"uid":[(WBAuthorizeResponse *)response userID]};
            [WBHttpRequest requestWithURL:@"https://api.weibo.com/2/users/show.json" httpMethod:@"GET" params:dic delegate:self withTag:@"me"];
        }else{
            CoreSVPCenterMsg(@"授权失败");
        }
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {//支付
    }
    else if([response isKindOfClass:WBSDKAppRecommendResponse.class])
    {//邀请
    }else if([response isKindOfClass:WBShareMessageToContactResponse.class])
    {
    }
}
-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSData *data=[result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];                //打印接收到的数据，可以根据需要而从字典里取出来
    DbLog(@"%@",dic);
    if ([dic objectForKey:@"error"]) {
        CoreSVPCenterMsg([dic objectForKey:@"error"]);
        return;
    }
    NSString *userName = dic[@"name"];
    NSString *userID = [NSString stringWithFormat:@"%@",dic[@"id"]];
    NSString *userImg = dic[@"avatar_large"];
    wbLoginTmpBlock(@{@"userName":userName,@"openID":userID,@"userImg":userImg});
}
#pragma mark --微信的代理回调方法
-(void)onReq:(BaseReq *)req
{
    DbLog(@"aaa %@",req);
}
-(void)onResp:(BaseResp *)resp
{
    DbLog(@"!!!! %@",resp);
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (wxHasDone) {//防止微信两次回调导致应用崩溃
            return;
        }
        SendAuthResp *temp = (SendAuthResp *)resp;
        if (!temp.code) {
            CoreSVPCenterMsg(@"授权失败");
            return;
        }
        
        NSString *accessUrlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kWeixinAppId, kWeixinAppKey, temp.code];
        [XYWhttpManager XYWpost:accessUrlStr parameters:nil inView:nil sucess:^(id result) {
            if (result&&![result objectForKey:@"errcode"]) {
                NSDictionary *accessDict = [NSDictionary dictionaryWithDictionary:result];
                DbLog(@" 11 %@",accessDict);
                
                [self wechatLoginByRequestForUserInfo:accessDict];
            }
        } failure:^(NSError *error) {
            DbLog(@"获取access_token时出错 = %@", error);
        }];
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        if (resp.errCode) {
            wxShareTmpBlock(@{@"shareState":@"fail"});
            return;
        }else{
            wxShareTmpBlock(@{@"shareState":@"sucess"});
        }
    }
    //以下是QQ的回调
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *qqresp = (SendMessageToQQResp*)resp;
        DbLog(@"%@  %@",qqresp.result,qqresp.errorDescription);
        if (qqresp.errorDescription.length<1) {
             qqShareTmpBlock(@{@"shareState":@"sucess"});
        }else{
            qqShareTmpBlock(@{@"shareState":@"fail"});
        }
    }
}
- (void)wechatLoginByRequestForUserInfo:(NSDictionary *)accessDic {
    wxHasDone = YES;
    
    NSString *accessToken = accessDic[@"access_token"];
    NSString *openID = accessDic[@"openid"];
    NSString *userUrlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openID];
    // 请求用户数据
    [XYWhttpManager XYWpost:userUrlStr parameters:nil inView:nil sucess:^(id result) {
        if (result) {
            if ([result objectForKey:@"errcode"]) {
                NSString *msg = [NSString stringWithFormat:@"%@%@",[result objectForKey:@"errcode"],[result objectForKey:@"errmsg"]];
                CoreSVPCenterMsg(msg);
                return ;
            }
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:result];
            DbLog(@" 22 %@",dic);
            NSString *userName = dic[@"nickname"];
            NSString *userID = [NSString stringWithFormat:@"%@",dic[@"openid"]];
            NSString *userImg = dic[@"headimgurl"];
            wxLoginTmpBlock(@{@"userName":userName,@"openID":userID,@"userImg":userImg});
            wxHasDone = NO;
        }

    } failure:^(NSError *error) {
        DbLog(@"获取access_token时出错 = %@", error);
    }];
}
///**
// 处理来至QQ的响应
// */
//-(void)onResp:(QQBaseResp *)resp
//{
//    DbLog(@"qq 回调");
//}
-(void)isOnlineResponse:(NSDictionary *)response
{
    DbLog(@"online %@",response);
}

@end
