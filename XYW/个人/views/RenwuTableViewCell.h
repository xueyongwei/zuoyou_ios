//
//  RenwuTableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import "YYText.h"
#import "YYLabel.h"
#import <UIKit/UIKit.h>
#import "RenWuListModel.h"
@protocol RenwuTableViewCellFrameDelegate <NSObject>
-(void)prepareRenwuList;
@end
@interface RenwuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *renwuIconImgV;
@property (weak, nonatomic) IBOutlet UILabel *renwuNameLabl;
@property (weak, nonatomic) IBOutlet YYLabel *renwuContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *renwuActionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengexianH;

@property (nonatomic,strong)RenWuListModel *model;

//delegate
@property (nonatomic,weak) id<RenwuTableViewCellFrameDelegate> delegate;
@end
