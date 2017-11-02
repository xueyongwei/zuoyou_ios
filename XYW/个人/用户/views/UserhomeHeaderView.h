//
//  userhomeHeaderView.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserhomeHeaderView : UIView
//菜单视图
@property (weak, nonatomic) IBOutlet UIView *explTab;
@property (weak, nonatomic) IBOutlet UIView *videoTab;
@property (weak, nonatomic) IBOutlet UIView *careTab;
@property (weak, nonatomic) IBOutlet UIView *fansTab;
@property (weak, nonatomic) IBOutlet UIView *ZhishiqiView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zhishiqiConst;

@property (weak, nonatomic) IBOutlet UILabel *expNubLabel;
@property (weak, nonatomic) IBOutlet UILabel *videosNubLabel;
@property (weak, nonatomic) IBOutlet UILabel *caresNubLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNubLabel;

@end
