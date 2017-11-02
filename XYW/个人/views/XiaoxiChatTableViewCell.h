//
//  XiaoxiChatTableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XiaoxiChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidthConst;

@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UILabel *FlagLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSPH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSPH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSPLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flagH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flagheightConst;

@end
