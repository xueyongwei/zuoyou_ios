//
//  ShouYeViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/5/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"
#import "YijianfankuiViewController.h"

@interface UploadProgressWindow : UIWindow

@end

@interface ShouYeViewController : UIViewController<UIAlertViewDelegate>
@property (nonatomic,strong)UploadProgressWindow *uploadProgressWindow;
-(void)setTabbarUnderCount:(NSInteger)unreadCount;
@end
