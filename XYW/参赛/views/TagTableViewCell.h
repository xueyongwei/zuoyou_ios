//
//  TagTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IconConstH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeightconst;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idxLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepreatConstH;
@property (nonatomic,assign) BOOL hiddenIcon;
@end
