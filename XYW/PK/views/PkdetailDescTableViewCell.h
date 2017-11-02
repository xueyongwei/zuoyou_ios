//
//  PkdetailDescTableViewCell.h
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PkdetailDescTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic,assign)BOOL selectedRight;
@end
