//
//  MsgDetailTopTableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/7/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"
@interface MsgDetailTopTableViewCell : UITableViewCell<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet TimeLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contWbH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengexianH;


@property (nonatomic,copy)NSString *content;
@end
