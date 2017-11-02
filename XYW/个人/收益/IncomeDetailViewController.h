//
//  IncomeDetailViewController.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYListViewController.h"

@interface withdrawHostoryModel:NSObject
@property (nonatomic,strong)NSNumber *amount;
@property (nonatomic,strong)NSNumber *withdrawId;
@property (nonatomic,strong)NSNumber *blueMid;
@property (nonatomic,strong)NSNumber *ownerMid;
@property (nonatomic,strong)NSNumber *redMid;;
@property (nonatomic,strong)NSNumber *createdBy;
@property (nonatomic,strong)NSNumber *versusContestantId;
@property (nonatomic,strong)NSNumber *versusId;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)NSString *tagName;
@end

@interface IncomeDetailViewController : ZYListViewController

@end
