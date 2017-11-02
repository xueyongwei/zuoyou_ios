//
//  PkdetailinfoTableViewCell.h
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    versusPraiseStateNormal = 1<<0,
    versusPraiseStateEnd = 1<<1,
    versusPraiseStateCoolingLeft = 1<<2,
    versusPraiseStateCoolingRight = 1<<3,
    versusPraiseStateCooled = 1<<4,
} versusPraiseBtnState;

@protocol PkdetailinfoTableViewCellDelegate <NSObject>
- (void)onLeftGiftsClick;
- (void)onRightGiftsClick;
//-(void)gotoFnasVC;
@end
@interface PkdetailinfoTableViewCell : UITableViewCell
@property (nonatomic,weak) id<PkdetailinfoTableViewCellDelegate> delegate;

//@property (weak, nonatomic) IBOutlet UIView *fansView;
@property (weak, nonatomic) IBOutlet UILabel *pinglunShuLael;
@property (weak, nonatomic) IBOutlet UIButton *rightGiftBtn;
@property (nonatomic,assign)versusPraiseBtnState praiseBtnState;
//@property (nonatomic,assign)BOOL PraiseBtnLight;
-(void)setL:(NSInteger)lbeans andR:(NSInteger)rbeans;
//-(void)setFansIconWithFans:(NSArray *)fans;
@end
