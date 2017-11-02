//
//  SearchUsersTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userCorverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepHeightConst;

@end
