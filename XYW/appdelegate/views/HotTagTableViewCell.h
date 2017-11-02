//
//  HotTagTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotTagTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *TagThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepHeightConst;

@end
