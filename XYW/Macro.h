//
//  Macro.h
//  HDJ
//
//  Created by xueyongwei on 16/5/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

//常量

//屏幕尺寸
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width

#define SECUREKEY @"9r0q*72("
//用户信息
//#define KUSERINFO @"zuoyoulogineduserinfo"
//#define kUSERNAME @"name"
//#define kUSERICON @"avatar"
//#define kUSERID @"id"
//#define kUSERGENDER @"gender"
//#define kUSERSIGNATURE @"signature"
#define GLOUBOPENTIMES @"opentimes"
#define GLOUBXIACIZAISHUO @"xiacizaishuo"
//系统版本
#define KSYSTEMVERSION [[UIDevice currentDevice] systemVersion]
//机型
#define KDEVICEMODEL [UIDevice currentDevice].model
#define KAPPVERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//视频播放器相关
#define PLAYERAUTOPLAY @"playerAutoPlay"
#define PLAYINMOBLIE @"playInMobile"
//全局计时器
#define GLOBLETIMER @"globleTimer"
//一个像素的宽度
#define SINGLE_LINE_WIDTH (1 / [UIScreen mainScreen].scale)
#define GUID @"guid"
#define KFLASHJSON @"flashJson"
#define KFirstUse @"firstusezuoyou"

//统计事件的EventID
#define KDIANJIMOBAI @"40000"
#define KFENXIANGDAO @"20000"
#define KDIANJISUOLUETU @"10000"
#define KDIANJILIWUTUBIAO @"10010"
#define KDIANJIFASONGLIWU @"10020"
#define KQUCHONGZHI @"10030"
#define KSONGHONGDOU @"10040"
#define KBIANJITOUXIANG @"30000"
#define kBIANJINICENG @"30010"
#define KBIANJIXINGBIE @"30020"
#define KQIAODAO @"40010"
#define KZIDONGBOFANG @"40020"
#define KFENXIANGAPP @"40030"
#define KQINGCHUHUANCUN @"40040"
#define KTUICHUZHUANGHU @"40050"
#define KQIEHUANZHENYING @"50000"

//视频播放器
#define KGuider @"xinshouyindaolema"

#define KCOlorPKBlue @"03a9f3"
#define KCOlorPKRed @"f44236"

#define KPRODUCTEVN @"productEverment"

//个人页切换tableVIew的响应者
#define KNOTIwhoCanScroll @"whichVCsTableViewCanScrol"
#define KSUBVCSCROLL @"subViewControllersCanScroll"

#define KSUPVCSCROLL @"superViewControllerCanScroll"

//全局通知的通知名字
#define kShouldLogoutNoti @"currentUserShouldLogOut"
#define kCaptureViewControllerStopRecod @"CaptureViewControllerStopRecod"

#endif /* Macro_h */

