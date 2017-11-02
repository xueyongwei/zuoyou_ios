//
//  GerenTableViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/6/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDProgressView.h"
#import "EditGerenViewController.h"
#import "SettingViewController.h"
#import "ChongZhiViewController.h"
#import "XiaoxiViewController.h"
#import "ShouYiTableViewController.h"
@interface GerenTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FGCH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FGXH1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FGXH2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FGXH3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FGXH4;

@end
