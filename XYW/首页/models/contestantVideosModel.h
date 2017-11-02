//
//  contestantVideosModel.h
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface contestantVideosModel : NSObject
@property (nonatomic,copy)NSString *contestantRole;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,copy)NSString *videoDescription;
@property (nonatomic,assign)NSInteger durationSec;
@property (nonatomic,assign)NSInteger fileBytes;
@property (nonatomic,assign)NSInteger fPS;
@property (nonatomic,copy)NSString *frontCover;
@property (nonatomic,assign)NSInteger goldBeans;
@property (nonatomic,assign)NSInteger heightPX;
@property (nonatomic,assign)NSInteger VideoId;
@property (nonatomic,copy)NSString *lastModified;
@property (nonatomic,copy)NSString *m3u8;
@property (nonatomic,copy)NSString *m3u8SRC128K;
@property (nonatomic,copy)NSString *m3u8SRC1M;
@property (nonatomic,copy)NSString *m3u8SRC2M;
@property (nonatomic,copy)NSString *m3u8SRC5M;
@property (nonatomic,copy)NSString *sRC;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)NSInteger playTimes;
@property (nonatomic,copy)NSString *pornoDetail;
@property (nonatomic,assign)NSInteger pornoResult;
@property (nonatomic,copy)NSString *recordDate;
@property (nonatomic,copy)NSString *recordDevice;
@property (nonatomic,assign)float recordLatitude;
@property (nonatomic,assign)float recordLongitude;
@property (nonatomic,assign)NSInteger redBeans;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,assign)NSInteger tagId;
@property (nonatomic,copy)NSString *tagName;
@property (nonatomic,copy)NSString *uploadIP;
@property (nonatomic,assign)NSInteger versusContestantId;
@property (nonatomic,assign)NSInteger versusId;
@property (nonatomic,assign)NSInteger widthPX;
@property (nonatomic,copy)NSString *outline;

@property (nonatomic,strong)NSNumber *praiseCnt;
@end
