//
//  XloginAndShareManager.h
//  XloginAndShare
//
//  Created by xueyongwei on 16/7/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
/*
 需要导入的库有
 QuartzCore
 CoreText
 UIKit
 libicucore
 Foundation
 CFNetwork
 MediaPlayer
 ImageIO
 libz
 libstdc++
 CoreTelephony
 libsqlite3
 CoreGraphics
 SystemConfiguration
 libiconv
 Security
 另需要在project － info － URL types 中添加各个appid等
 */
#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/sdkdef.h>
#import "WeiboSDK.h"
#import "WXApi.h"

#pragma mark --各种key和ID设置在这里 ⇣⇣☟
#define kTencentAppID @"1105521627"
#define kTencentAppKey @"gxcTxb1jAyHzSJlh"

#define kWeiboAppKey @"2873434969"
#define kWeiboRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kWeiboAppSecret @"25c80233f9b4fed0f8e14733fa4c00c8"

#define kWeixinAppId @"wx45773649b8a1c03d"
#define kWeixinAppKey @"1ade54d1ccdb45423fcd3ebeba65414c"
#pragma mark --各种key和ID设置在这里⇡⇡☝︎
@interface XloginAndShareManager : NSObject<TencentSessionDelegate,WBHttpRequestDelegate,WXApiDelegate,WeiboSDKDelegate,QQApiInterfaceDelegate>
@property (nonatomic,strong)NSDictionary *shareData;
+(XloginAndShareManager *)defaultManager;
+(void)XregisterApp;
+(BOOL)HandleOpenURL:(NSURL *)url;
-(void)loginWithQQ:(void(^)(NSDictionary *userInfo))infoBlock;
-(void)loginWithWB:(void(^)(NSDictionary *userInfo))infoBlock;
-(void)loginWithWX:(void(^)(NSDictionary *userInfo))infoBlock;

-(void)shareToWx:(NSDictionary *)param result:(void(^)(NSDictionary *userInfo))infoBlock;
-(void)shareToWb:(NSDictionary *)param result:(void(^)(NSDictionary *userInfo))infoBlock;
-(void)shareToQQ:(NSDictionary *)param result:(void(^)(NSDictionary *userInfo))infoBlock;

@end
