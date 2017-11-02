//
//  FlashModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "FlashModel.h"

@implementation FlashModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"flashID":@"id",
             };
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"fram_flashs" : @"fram_flashModel",
             };
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fram_count forKey:@"fram_count"];
    [aCoder encodeObject:self.flashID forKey:@"flashID"];
    [aCoder encodeObject:self.vc forKey:@"vc"];
    [aCoder encodeObject:self.fram_flashs forKey:@"fram_flashs"];
    [aCoder encodeObject:self.rootPath forKey:@"rootPath"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.fram_count = [aDecoder decodeObjectForKey:@"fram_count"];
        self.flashID = [aDecoder decodeObjectForKey:@"flashID"];
        self.vc = [aDecoder decodeObjectForKey:@"vc"];
        self.fram_flashs = [aDecoder decodeObjectForKey:@"fram_flashs"];
        self.rootPath = [aDecoder decodeObjectForKey:@"rootPath"];
    }
    return self;
}
@end
