//
//  SoundChangeCollectionViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundChangeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *soundChangeImageViewWidthConst;

@end
