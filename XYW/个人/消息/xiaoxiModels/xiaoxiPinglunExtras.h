//
//  xiaoxiPinglunExtras.h
//  HDJ
//
//  Created by xueyongwei on 16/7/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface xiaoxiPinglunExtras : NSObject
//blueMid = 30;
//mid = 49;
//nickname = dustplusplus;
//redMid = 28;
//referredMid = 0;
//referredNickname = "";
//versusId = 2;
//versusTagName = "\U4e00\U4e2a\U6897";
@property (nonatomic,copy)NSString *nickname;
@property (nonatomic,copy)NSString *referredNickname;
@property (nonatomic,copy)NSString *versusTagName;
@property (nonatomic,copy)NSString *contestantType;
@property (nonatomic,copy)NSString *referredContestantType;

@property (nonatomic,assign)NSInteger blueMid;
@property (nonatomic,assign)NSInteger redMid;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)NSInteger referredMid;
@property (nonatomic,assign)NSInteger versusId;
-(NSString *)formaterVersusTagName;
@end
