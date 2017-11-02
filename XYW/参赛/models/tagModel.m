//
//  tagModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "tagModel.h"

@implementation tagModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"tagID":@"id",
             @"tagName":@"name",
             };
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.tagID = [coder decodeObjectForKey:@"tagID"];
        self.tagName = [coder decodeObjectForKey:@"tagName"];
        self.frontCover = [coder decodeObjectForKey:@"frontCover"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.tagName forKey:@"tagName"];
    [coder encodeObject:self.tagID forKey:@"tagID"];
    [coder encodeObject:self.frontCover forKey:@"frontCover"];
}
-(NSString *)formatertagName
{
    return [NSString stringWithFormat:@"#%@#",_tagName];
}
@end
