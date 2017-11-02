//
//  SuggestedFollowsCollectionViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/27.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SuggestedFollowsCollectionViewCellDelegate <NSObject> // 代理传值方法
- (void)onUserIconTap:(UITapGestureRecognizer *)recognizer;
@end

@interface SuggestedFollowsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectStatusBtn;
@property (nonatomic,weak) id <SuggestedFollowsCollectionViewCellDelegate> delegate;
@end
