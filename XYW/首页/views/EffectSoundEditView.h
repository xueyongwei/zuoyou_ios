//
//  EffectSoundEditView.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EffectSoundEditView : UIView
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *videoFramesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *effectVoiceCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *pointerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *effectScrolViewHeightConst;

@end
