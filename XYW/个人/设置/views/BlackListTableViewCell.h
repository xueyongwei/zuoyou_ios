//
//  BlackListTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/10.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BlackListTableViewCellDelegate // 代理传值方法
- (void)onActionBtnClick:(UITableViewCell *)cell;
@end
@interface BlackListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepheightConst;
@property (nonatomic,weak) id<BlackListTableViewCellDelegate> delegate;
@end
