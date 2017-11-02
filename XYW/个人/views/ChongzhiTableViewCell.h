//
//  ChongzhiTableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/6/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChongzhiTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *youhuiLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengeLabelH;
@property (weak, nonatomic) IBOutlet UILabel *douziLabel;

@property (nonatomic,assign)BOOL YouHui;
@end
