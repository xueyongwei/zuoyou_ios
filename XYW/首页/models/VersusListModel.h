//
//  VersusListModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYModel.h"
#import "contestantVideosModel.h"
@interface VersusListModel : ZYModel
@property (nonatomic,strong)NSArray *contestantVideos;
@property (nonatomic,assign)NSInteger createdBy;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,assign)NSInteger deadLine;
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
@property (nonatomic,copy)NSMutableAttributedString *huoshengText;
@end
