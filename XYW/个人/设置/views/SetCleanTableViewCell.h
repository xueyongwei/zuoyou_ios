//
//  SetCleanTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetCleanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengeConst;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitView;

@end
