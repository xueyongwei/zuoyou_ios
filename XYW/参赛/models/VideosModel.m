//
//  VideosModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/10.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VideosModel.h"

@implementation VideosModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"VideoId":@"id",
             @"videoDescription":@"description"
             };
}
-(NSString *)formatertagName
{
    return [NSString stringWithFormat:@"#%@#",_tagName];
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
