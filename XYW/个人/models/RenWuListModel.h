//
//  RenWuListModel.h
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RenWuListModel : NSObject
@property (nonatomic,copy)NSString *appAction;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,copy)NSString *renwuDescription;
@property (nonatomic,copy)NSString *endDate;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *icon;
@property (nonatomic,copy)NSString *startDate;
@property (nonatomic,copy)NSString *statusType;
@property (nonatomic,copy)NSString *type;

@property (nonatomic,assign)NSInteger renwuID;
@property (nonatomic,assign)NSInteger repeatablePeriodDay;
@property (nonatomic,assign)NSInteger rewardGoldBeans;
@property (nonatomic,assign)NSInteger rewardRedBeans;

@end
