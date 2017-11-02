//
//  AppDelegate.m
//  XYW
//
//  Created by xueyongwei on 16/3/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "HowLoginViewController.h"
#import "NotiView.h"
#import "TalkingData.h"
#import "TalkingDataGA.h"
#import "SchemesModel.h"
#import <SSZipArchive.h>
#import <Google/Analytics.h>
#import "XYWAlert.h"
#import "XYWdispatcher.h"
#import "UserInfoManager.h"
#import "XYWClearCacheTool.h"
#import "ZYUserDefaultsManager.h"
#import "HtmlViewController.h"
#import "ZYConfigManager.h"
#import "SocketManager.h"
#import "XGPush.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
typedef enum{
    networkStateWIFI=1,//默认为0
    networkStateMobile,
    networkStateNone,
}NetworkState;
static AFHTTPSessionManager *manager ;
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic,assign)NetworkState networkState;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册第三方登录分享
    [XloginAndShareManager XregisterApp];
    
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    //在rootVC设置之前就执行的操作,不能包含UI操作
    [self OpreaWithoutUIBeforeRootVCSeted];
    if ([UserInfoManager haveLogined]) {//本地有用户信息,到数据页
        RootViewController *rootVC = [RootViewController new];
        self.window.rootViewController = rootVC;
    }else{//本地没有用户信息,到登陆注册页面
        HowLoginViewController *lgVC = [[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"HowLoginViewController"];
        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:lgVC];
    }
    
    [self.window makeKeyAndVisible];
    [XGPush startApp:2200252634 appKey:@"IS969VV9SJ2K"];
    //启动后，UI相关初始化
    [self initUIOpera];
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {//程序是通过点击通知进来的
        CoreSVPCenterMsg(@"UIApplicationLaunchOptionsRemoteNotificationKey");
        DbLog(@"launchOptions");
//        [self remoteNotificationHandle:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    return YES;
}
-(void)OpreaWithoutUIBeforeRootVCSeted
{
    //异步操作
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        //清除上次保存的是否在移动网络播放视频
        [usf removeObjectForKey:PLAYINMOBLIE];
        
        //清楚上次保存的是否生产环境信息
        [usf removeObjectForKey:KPRODUCTEVN];
        [self checkEnvironment];
        //记录app打开次数
        if (![usf objectForKey:GUID]) {
            NSString *str = [NSString stringWithUUID];
            DbLog(@"新生成一个guid = %@",str);
            [usf setObject:str forKey:GUID];
        }
        NSNumber *openTimes = [usf objectForKey:GLOUBOPENTIMES];
        if (openTimes&&openTimes.integerValue>=0) {
            NSInteger time = openTimes.integerValue;
            time++;
            [usf setObject:@(time) forKey:GLOUBOPENTIMES];
        }else{
            [usf setObject:@(1) forKey:GLOUBOPENTIMES];
        }
        [usf synchronize];
        
        
        
        

        
        //检查更新
        [self checkUpdata];
        //清除老版本数据
        [self clearOldData];
        
        //配置远程推送
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            //iOS10特有
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            // 必须写代理，不然无法监听通知的接收与点击
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    // 点击允许
                    NSLog(@"注册成功");
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    //检查授权状态
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        NSLog(@"%@", settings);
                    }];
                } else {
                    // 点击不允许
                    [XYWAlert XYWAlertTitle:@"为及时收到PK结果及赛事信息，建议您到设置里开启通知权限" message:nil first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"知道了" handle:nil];
                    NSLog(@"注册失败");
                }
            }];
        }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
            //iOS8 - iOS9
            UIUserNotificationSettings *set = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
            //2 将配置添加进远程托送的设置中
            [[UIApplication sharedApplication]registerUserNotificationSettings:set];
            //3 注册远程推送
            [[UIApplication sharedApplication]registerForRemoteNotifications];
        }
        //检查token是否过期
        if ([UserInfoManager haveLogined]) {//已经登录了，需要检查是否过期
            [self checkTokenExpire];
            //设置af的token
            [XYWhttpManager refreshRequestToken];
            [[SocketManager defaultManager]createWS];
            
        }
    });
    
    //注册第talkingData
//    [TalkingData sessionStarted:@"D105225C598BDB279A7AC02BEF75DA1B" withChannelId:kChanalOfAnalysis];
    [TalkingDataGA onStart:@"0A5CA1E766736246703F0A706D6AB385" withChannelId:kChanalOfAnalysis];
//    [TalkingData setExceptionReportEnabled:YES];
    //注册谷歌统计
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}

/**
 UI主线程操作
 */
-(void)initUIOpera
{
    if ([ZYUserDefaultsManager zyLabchAD]) {//本地有闪屏数据，加载闪屏
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        imageView.backgroundColor = [UIColor whiteColor];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[ZYUserDefaultsManager zyLabchAD].imageUrl]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onADclick:)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.window.rootViewController.view addSubview:imageView];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imageView removeFromSuperview];
        });
    }
    //网路状态监控回调
    __block typeof(self)wkSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                CoreSVPCenterMsg(@"网络似乎已断开");
                wkSelf.networkState = networkStateNone;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                if (wkSelf.networkState == networkStateWIFI) {
                    CoreSVPCenterMsg(@"wifi已断开,正在使用2G/3G/4G流量");
                }else if (wkSelf.networkState == networkStateNone) {
                    CoreSVPCenterMsg(@"移动网络已连接");
                }
                wkSelf.networkState = networkStateMobile;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                if (wkSelf.networkState == networkStateMobile||wkSelf.networkState ==networkStateNone) {
                    CoreSVPCenterMsg(@"wifi已连接");
                }
                wkSelf.networkState = networkStateWIFI;
            }
                break;
            default:
                break;
        }
        DbLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    //开始监测网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //注册通知
    [self addNoti];
    //添加全局计时器
    [self creatTimer];
    
}
//点击了闪屏广告页
-(void)onADclick:(UITapGestureRecognizer *)recognizer
{
    HtmlViewController *htmlVC = [HtmlViewController new];
    htmlVC.url = [ZYUserDefaultsManager zyLabchAD].linkUrl;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateNormal];
    [btn addTarget:htmlVC action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    htmlVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:htmlVC];
    [recognizer.view removeFromSuperview];
    [self.window.rootViewController presentViewController:navi animated:YES completion:^{
        
    }];
    
}
//清除之前版本的数据
-(void)clearOldData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //清除1.2之前的本地保存的用户信息
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"zuoyoulogineduserinfo"];
        //1.2改动：去掉动画，此处清理已存在的动画包
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        [XYWClearCacheTool clearCacheWithFilePath:[NSString stringWithFormat:@"%@/flash",path]];
    });
    
}
#pragma mark ---推送相关
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSString *deviceTokenStr = [XGPush registerDevice:deviceToken
                                              account:nil
                                      successCallback:^{
                                          DbLog(@"[XGPush Demo] register push success");
                                      } errorCallback:^{
                                          DbLog(@"[XGPush Demo] register push error");
                                      }];
    NSString *acount =[NSString stringWithFormat:@"%@",[UserInfoManager mySelfInfoModel].mid];
    [XGPush setAccount:acount successCallback:^{
        NSLog(@"[XGDemo] Set account success");
    } errorCallback:^{
        NSLog(@"[XGDemo] Set account error");
    }];
    NSString *deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    DbLog(@"My dvsToken is %@",deviceTokenString);
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/notice/register",HeadUrl] parameters:@{@"deviceToken":deviceTokenString} inView:nil sucess:^(id result) {
        DbLog(@"token 上传成功 %@",deviceTokenString);
    } failure:^(NSError *error) {
        DbLog(@"token 上传失败！ %@",error.localizedDescription);
    }];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //向APNS注册失败，返回错误信息error
    DbLog(@"registe push error :%@",error.localizedDescription);
}
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    DbLog(@"receive notification : %@",userInfo);
//}
//iOS8-9收到推送
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //收到远程推送通知消息
    DbLog(@"receive notification : %@",userInfo);
    NSDictionary *aps = userInfo[@"aps"];
    NSNumber *badge = aps[@"badge"];
    
    if (application.applicationState == UIApplicationStateActive) {
        
    }else{
         [XYWBadgeManager setBadge:badge.integerValue];
        [self remoteNotificationHandle:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}
//iOS10点击通知进入
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    DbLog(@"%@",response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    DbLog(@"userInfo = %@",userInfo);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
    }else{
        [self remoteNotificationHandle:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}
//对推送内容的处理（跳转）
-(void)remoteNotificationHandle:(NSDictionary *)userInfo{
    NSData *jsonData = [userInfo[@"query"] dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                             
                                                            options:NSJSONReadingMutableContainers
                             
                                                              error:nil];
        [XYWdispatcher jumpToHost:userInfo[@"host"] param:dic];
    }
    
}
/*
-(void)unZipTemple{
    //解压自带的模板到doc目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    DbLog(@"解压路径：%@",path);
    //1.2改动：去掉动画，此处清理已存在的动画包
    [XYWClearCacheTool clearCacheWithFilePath:[NSString stringWithFormat:@"%@/flash",path]];
    
    [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"flash" ofType:@"zip"] toDestination:path];
    
    [self flashResolver:[NSString stringWithFormat:@"%@/flash",path]];

}
 */
/*
-(void)flashResolver:(NSString *)path
{
    DbLog(@"目录的路径%@",path);
    DbLog(@"NSThread %@",[NSThread currentThread]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *flashList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (!error) {
        NSMutableDictionary *flashDic = [NSMutableDictionary new];
        for (NSString *dir in flashList) {
            BOOL isDir = NO;
            if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",path,dir] isDirectory:&isDir]) {
                if (isDir) {//是个动画目录
                    NSString *animJsonPath = [NSString stringWithFormat:@"%@/%@/anim.json",path,dir];
                    NSString *jsonStr = [NSString stringWithContentsOfFile:animJsonPath encoding:NSUTF8StringEncoding error:nil];
                    if (jsonStr) {
                        FlashModel *model = [FlashModel mj_objectWithKeyValues:jsonStr];
                        model.rootPath = [NSString stringWithFormat:@"flash/%@",dir];
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
                        [flashDic setObject:data forKey:model.flashID];
                    }
                }else
                {
                }
            }
        }
        [[NSUserDefaults standardUserDefaults]setObject:flashDic forKey:KFLASHJSON];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
 */
#pragma mark ---全局计时器
//创建全局计时器
-(void)creatTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
//每秒发送一个全局消息
-(void)timerHandle
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLOBLETIMER object:nil];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [XloginAndShareManager HandleOpenURL:url];
    if (result == FALSE) {
        //第三方登录应用没有接手，转交给其他人
        [self handleSchemes:url];
    }
    return result;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options
{
    BOOL result = [XloginAndShareManager HandleOpenURL:url];
    if (result == FALSE) {
        //第三方登录应用没有接手，转交给其他人
        [self handleSchemes:url];
    }
    return result;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [XloginAndShareManager HandleOpenURL:url];
    if (result == FALSE) {
        //第三方登录应用没有接手，转交给其他人
        [self handleSchemes:url];
    }
    return result;
}
/**
 *  捕获来自uri打开app的操作
 *
 *  @param url schemes的url
 */
-(void)handleSchemes:(NSURL *)url
{
    [XYWdispatcher HandleOpenURL:url withScheme:@"zuoyoupk"];
//    NSString *host = [url host];
//    NSString *query = [url query];
//    NSArray *itms = [query componentsSeparatedByString:@"&"];
////    UIViewController *vc = [self viewControllerWithClassName:host];
////    for (NSString *itm in itms) {
////        NSArray *keyvalues = [itm componentsSeparatedByString:@"="];
////        [vc setValue:keyvalues.lastObject forKey:keyvalues.firstObject];
////    }
////    [self pushToVC:vc];
////    DbLog(@"%@",vc);
//    
//    if ([host isEqualToString:@"pkdetail"]) {//pk详情页
//        NSMutableDictionary *dic = [NSMutableDictionary new];
//        for (NSString *itm in itms) {
//            NSArray *keyvalues = [itm componentsSeparatedByString:@"="];
//            [dic setObject:keyvalues.lastObject forKey:keyvalues.firstObject];
//        }
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCHEMES" object:dic];
//        
//    }else if ([host isEqualToString:@"userdetail"]){//用户详情页
//        
//    }
    
    
}
-(UIViewController *)viewControllerWithClassName:(NSString *)className
{
    Class c = NSClassFromString(className);
    UIViewController *vc = [[c alloc] init];
    return vc;
}
-(void)pushToVC:(UIViewController *)vc
{
    UIViewController *currentVC = [self getCurrentVC];
    if (currentVC.navigationController) {
//        navc = currentVC.navigationController;
        [currentVC.navigationController pushViewController:vc animated:YES];
    }else{//应用没有打开或者只在主页
        UITabBarController *tbrVC = (UITabBarController *)currentVC;
        UINavigationController *navc = tbrVC.childViewControllers.firstObject;
        [navc pushViewController:vc animated:YES];
//        CoreSVPCenterMsg(@"无法打开页面！");
    }
    
}
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //清空角标
    [XYWBadgeManager setBadge:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
/**
 *  检查更新
 */
-(void)checkUpdata{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/version/info"] parameters:@{@"client":@"ios"} inView:nil sucess:^(id result) {
        ZYLanchADModel *model = [ZYLanchADModel new];
        if ([result objectForKey:@"splashImage"]) {
            model.linkUrl = [result objectForKey:@"splashLink"];
            model.imageUrl = [result objectForKey:@"splashImage"];
            //缓存一下图片
            [[UIImageView new]sd_setImageWithURL:[NSURL URLWithString:model.imageUrl]];
            [model save];
        }else {
            [ZYLanchADModel clear];
        }
        
        NSString *miniNumSupport = [result objectForKey:@"miniNumSupport"];
        
        NSInteger currentVerson = [ZYConfigManager thisVersonForUpdata];
        
        NSString  *num = [result objectForKey:@"num"];
        if (miniNumSupport.integerValue-currentVerson>0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
            alertController.title =  [result objectForKey:@"name"];
            alertController.message = [result objectForKey:@"memo"];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication].windows.lastObject.rootViewController presentViewController:alertController animated:YES completion:nil];
                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",1144064169];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }];
            //添加action
            [alertController addAction:cancelAction];
            [[UIApplication sharedApplication].windows.lastObject.rootViewController presentViewController:alertController animated:YES completion:nil];
           
        }else if (num.integerValue-currentVerson>0){
            NSString *title = [NSString stringWithFormat:@"%@",[result objectForKey:@"name"]];
            NSString *msg = [NSString stringWithFormat:@"%@",[result objectForKey:@"memo"]];
            
            [XYWAlert XYWAlertTitle:title message:msg first:@"立即更新" firstHandle:^{
                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",1144064169];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            } second:nil Secondhandle:nil cancle:@"取消" handle:^{
                
            }];
        }else{
            
        }

    } failure:^(NSError *error) {
        
    }];
}
-(void)checkTokenExpire{//检查token是否过期
    MyselfInfoModel *selfModel = [UserInfoManager mySelfInfoModel];
    if (selfModel) {
        NSString *exporeDateStr = selfModel.tokenExpireAt;
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formater setLocale:local];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *expDate = [formater dateFromString:exporeDateStr];
        NSDate *NowDate = [NSDate date];
        NSDateComponents *compnt = [NSDate dateComponents:NSCalendarUnitDay fromDate:NowDate toDate:expDate];
        if (compnt.day<10 && compnt.date>0) {
            [self refreshToken];
        }else if (compnt.date<0){
//            [self loginAnthoer];
        }
    }
}
-(void)checkEnvironment
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/version/environment"] parameters:nil inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            DbLog(@"%@",[result objectForKey:@"errMsg"]);
            return ;
        }
        NSString *env = [NSString stringWithFormat:@"%@",result[@"IS_PRODUCT_ENV"]];
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        [usf setObject:env forKey:KPRODUCTEVN];
        [usf synchronize];
    } failure:^(NSError *error) {
        
    }];
}
-(void)refreshToken{//续约token
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/refreshToken"] parameters:nil inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            DbLog(@"%@",[result objectForKey:@"errMsg"]);
            return ;
        }
        MyselfInfoModel *selfModel = [UserInfoManager mySelfInfoModel];
        if (result&&selfModel) {
            if ([result objectForKey:@"token"]) {
                selfModel.refreshedToken = [result objectForKey:@"token"];//有了新的token，但是本次不用，下次启动用
                selfModel.tokenExpireAt =  [result objectForKey:@"tokenExpireAt"];
                
                [UserInfoManager synchronizeMyselfInfoModel:selfModel];
                //本次启动请求还是用老的token请求
//                [XYWhttpManager refreshRequestToken];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ---通知中心
-(void)addNoti
{
    //消息服务的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TastFineshed:) name:@"systemmissionfinish" object:nil];//收到任务完成的消息通知
}
//显示吐司展示任务完成提示
-(void)TastFineshed:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    WSmessageModel *model = noti.userInfo[@"model"];
    NSDictionary *body = (NSDictionary *)model.body;
    DbLog(@"%@",body[@"content"]);
    CoreSVPCenter3sMsg(body[@"content"]);
}
-(void)loginAnthoer
{
    if ([self.window.rootViewController isKindOfClass:[RootViewController class]]) {
        RootViewController *rvc = (RootViewController*)self.window.rootViewController;
        [rvc onLogOut];
    }
}

@end
