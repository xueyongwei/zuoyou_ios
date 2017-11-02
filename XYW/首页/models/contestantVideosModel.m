//
//  contestantVideosModel.m
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "contestantVideosModel.h"

@implementation contestantVideosModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"VideoId":@"id",
             @"videoDescription":@"description"
             };
}
-(void)setRedBeans:(NSInteger)redBeans
{
    _redBeans = redBeans;
}
-(NSString *)m3u8
{
    if (self.m3u8SRC1M) {
        return self.m3u8SRC1M;
    }else if (self.m3u8SRC2M){
        return self.m3u8SRC2M;
    }else if (self.m3u8SRC5M){
        return self.m3u8SRC5M;
    }else if (self.m3u8SRC128K){
        return self.m3u8SRC128K;
    }else{
        return nil;
    }
}
@end
