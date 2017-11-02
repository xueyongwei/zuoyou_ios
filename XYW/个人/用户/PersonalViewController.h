//
//  PersonalViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"
#import "LDProgressView.h"
#import "EditGerenViewController.h"
#import "SetingViewController.h"
#import "ChongZhiViewController.h"
#import "XiaoxiViewController.h"
#import "ShouYiTableViewController.h"
#import "XiaoxiSessionModel.h"
#import "RenWuListModel.h"
//#import "ZhichiBisaiViewController.h"
#import "VersusListViewController.h"
#import "RenwuTableViewCell.h"
#import "Geren1TableViewCell.h"
#import "Geren2TableViewCell.h"
#import "Geren3TableViewCell.h"

#import "UITabBar+badge.h"

@interface PersonalViewController : ZYTableViewController<RenwuTableViewCellFrameDelegate,XiaoxiViewControllerProtocol>
-(void)setMessageItemUnreadCount:(NSInteger)unreadShowCount totalCount:(NSInteger)unreadTotalCount;
@end
