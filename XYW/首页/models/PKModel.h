//
//  PKModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "contestantVideosModel.h"

@interface PraiseInfoModel : NSObject
@property (nonatomic,assign) NSInteger praiseColdDownSec;//冷却时间
@property (nonatomic,strong) NSNumber *versusContestantId;//被点赞视频的赛事ID
@end

@interface PKModel : NSObject
@property (nonatomic,strong)NSArray *contestantVideos;
@property (nonatomic,assign)NSInteger createdBy;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,copy)NSString *deadLine;
@property (nonatomic,assign)NSInteger editBy;
@property (nonatomic,assign)NSInteger pkID;
@property (nonatomic,copy)NSString *notes;
@property (nonatomic,copy)NSString *publishDate;
@property (nonatomic,assign)float royaltyRate;
@property (nonatomic,assign)NSInteger tagId;
@property (nonatomic,copy)NSString *tagName;

@property (nonatomic,copy)NSString *outline;
@property (nonatomic,copy)NSString *versusType;
@property (nonatomic,assign)NSInteger winBonus;
@property (nonatomic,copy)NSString *winnerVersusContestantType;
@property (nonatomic,assign)NSInteger winnerVersusContestantId;
//@property (nonatomic,copy)NSMutableAttributedString *huoshengText;
@property (nonatomic,strong)PraiseInfoModel *praiseInfo;

@property (nonatomic,strong)NSDictionary *tagActivity;
/**
 *  计数减1(countdownTime - 1)
 */
-(void)cutDown;
/**
 *  将当前的countdownTime信息转换成字符串
 */
-(NSMutableAttributedString *)huoshengText;
- (NSString *)currentTimeString;
-(NSString *)formatertagName;
//- (NSMutableAttributedString*)currentTimeStringInPkdetail;
@end
