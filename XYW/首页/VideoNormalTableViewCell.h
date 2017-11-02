//
//  VideoNormalTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoNormalTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videosViewWidthConst;
@property (weak, nonatomic) IBOutlet UIImageView *leftVideoImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightVIdeoImg;
@property (weak, nonatomic) IBOutlet UIButton *pkBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *userIcomCorver;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
