//
//  Geren2TableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Geren2TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *botH;
@property (weak, nonatomic) IBOutlet UIImageView *itmIconV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numbLabelHeghtConst;
@property (weak, nonatomic) IBOutlet UILabel *itmNaleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numbLH;
@property (weak, nonatomic) IBOutlet UILabel *numbLVB;


@end
