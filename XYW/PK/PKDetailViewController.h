//
//  PKDetailViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/5/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//


#import "AppDelegate.h"
#import "BaseViewController.h"

#import "liwuGuidView.h"
#import "QiehuanGuideView.h"
#import "songliGuidView.h"
#import "fasongGuideView.h"

#import "PkdetailinfoTableViewCell.h"

#import "YYText.h"
#import "YYLabel.h"

#import "PKModel.h"

@interface PKDetailViewController : BaseViewController<UIScrollViewDelegate,UIAlertViewDelegate,QiehuanGuideViewDelegate,liwuGuidViewViewDelegate,PkdetailinfoTableViewCellDelegate>
/**IB视图**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottonPinglunFengexianH;
@property (weak, nonatomic) IBOutlet UITextField *PinglunTF;
@property (weak, nonatomic) IBOutlet UIPageControl *giftViewPageView;
@property (weak, nonatomic) IBOutlet YYLabel *gitfChongZhiLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *giftScorlView;
@property (weak, nonatomic) IBOutlet UIButton *giftSendBtn;
@property (nonatomic ,assign)       BOOL         clickRightVideo;
@property (nonatomic,copy)NSString *contestantType;
/** 视频model */

@property (nonatomic,strong) PKModel *pkModel;
@property (nonatomic,assign)NSInteger pkId;
//@property (nonatomic,strong)UIImage *leftCoverImage;
//@property (nonatomic,strong)UIImage *rightCoverImage;
@end
