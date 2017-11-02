//
//  PingluExtModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PingluExtModel : NSObject
@property (nonatomic,copy)NSString *action;
@property (nonatomic,copy)NSString *contestantType;
@property (nonatomic,assign)NSInteger referredMid;
@property (nonatomic,assign)NSInteger versusId;
@property (nonatomic,copy)NSString *referredNickname;
@property (nonatomic,copy)NSString *referredContestantType;
@end
