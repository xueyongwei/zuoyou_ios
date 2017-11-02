//
//  SuggestedFollowsHeaderView.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuggestedFollowsHeaderViewDelegate <NSObject>
-(void)removeTableViewHeaderView;
-(void)onCareClick;
@end
@interface SuggestedFollowsHeaderView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *careBtn;

@property (nonatomic,weak) id<SuggestedFollowsHeaderViewDelegate> delegate;
@end
