//
//  VideoWithTagTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoWithTagTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videosViewWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepraHeightConst;
@property (weak, nonatomic) IBOutlet UIImageView *leftVideoImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightVIdeoImg;
@property (weak, nonatomic) IBOutlet UIButton *pkBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *userIconCorver;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;

@end
