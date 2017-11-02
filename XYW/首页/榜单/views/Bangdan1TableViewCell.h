//
//  Bangdan1TableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/6/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BangdanBaseTableViewCell.h"

@interface Bangdan1TableViewCell : BangdanBaseTableViewCell
//膜拜按钮
@property (weak, nonatomic) IBOutlet UIButton *mobaiBtn;
//关注按钮右侧偏移
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *guanzhuOffConst;
//是否可以膜拜
@property (nonatomic,assign)BOOL canMoBai;

@end
