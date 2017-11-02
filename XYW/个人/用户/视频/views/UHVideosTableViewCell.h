//
//  UHVideosTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UHVideosTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *statusFLag;
@property (weak, nonatomic) IBOutlet UILabel *tagName;
@property (weak, nonatomic) IBOutlet UIImageView *leftUser;
@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;

@property (weak, nonatomic) IBOutlet UIImageView *rightUser;
@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;

@end
