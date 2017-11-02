//
//  fram_flashModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "fram_flashModel.h"

@implementation fram_flashModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.hold_time forKey:@"hold_time"];
    [aCoder encodeObject:self.path forKey:@"path"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.hold_time = [aDecoder decodeObjectForKey:@"hold_time"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
    }
    return self;
}
@end
