//
//  MyVideoModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKModel.h"

typedef enum {
    personalVideoTypeWaiting,
    personalVideoTypeFail,
    personalVideoTypeDone
}personalVideoType;

@interface MyVideoModel : NSObject
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,copy)NSString *frontCover;
@property (nonatomic,copy)NSString *m3u8SRC128K;
@property (nonatomic,copy)NSString *m3u8SRC1M;
@property (nonatomic,copy)NSString *m3u8SRC2M;
@property (nonatomic,copy)NSString *m3u8SRC5M;
@property (nonatomic,assign)NSInteger videoID;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)NSInteger playTimes;
@property (nonatomic,assign)NSInteger durationSec;
@property (nonatomic,assign)NSInteger tagId;
@property (nonatomic,copy)NSString *tagName;
@property (nonatomic,strong)NSArray *versus;
@property (nonatomic,assign)BOOL canChallenge;
@property (nonatomic,assign,readonly)personalVideoType videoType;
@property (nonatomic,copy)NSString *m3u8;
-(NSString *)formatertagName;
@end
