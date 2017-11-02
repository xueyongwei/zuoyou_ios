//
//  ZJPKTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJPKTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *progessView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UILabel *loseLabel;
@property (weak, nonatomic) IBOutlet UILabel *persentLabel;
@property (weak, nonatomic) IBOutlet UILabel *itmTitleLabel;


@property (nonatomic,assign)NSInteger percent;
@end
