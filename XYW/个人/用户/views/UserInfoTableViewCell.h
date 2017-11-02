//
//  UserInfoTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *userRoleIconImgV;
@property (weak, nonatomic) IBOutlet UILabel *userRoleDesclabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userRoleDescLabelHeightConst;


@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImgV;
@property (weak, nonatomic) IBOutlet UILabel *userSignLabel;
@end
