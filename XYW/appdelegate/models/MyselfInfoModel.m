//
//  MyselfInfoModel.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/24.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MyselfInfoModel.h"

@implementation MyselfInfoModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"mid":@"id",
             };
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.mid = [coder decodeObjectForKey:@"mid"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.avatar = [coder decodeObjectForKey:@"avatar"];
        self.gender = [coder decodeObjectForKey:@"gender"];
        self.signature = [coder decodeObjectForKey:@"signature"];
        self.balance = [coder decodeObjectForKey:@"balance"];
        self.permissionDeny = [coder decodeObjectForKey:@"permissionDeny"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.refreshedToken = [coder decodeObjectForKey:@"refreshedToken"];
        self.tokenExpireAt = [coder decodeObjectForKey:@"tokenExpireAt"];
        self.memberRoles = [coder decodeObjectForKey:@"memberRoles"];
        self.profitBalance = [coder decodeObjectForKey:@"profitBalance"];
        self.createdDate = [coder decodeObjectForKey:@"createdDate"];
        
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.mid forKey:@"mid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.avatar forKey:@"avatar"];
    [coder encodeObject:self.gender forKey:@"gender"];
    [coder encodeObject:self.signature forKey:@"signature"];
    [coder encodeObject:self.balance forKey:@"balance"];
    [coder encodeObject:self.permissionDeny forKey:@"permissionDeny"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.refreshedToken forKey:@"refreshedToken"];
    [coder encodeObject:self.tokenExpireAt forKey:@"tokenExpireAt"];
    [coder encodeObject:self.memberRoles forKey:@"memberRoles"];
    [coder encodeObject:self.profitBalance forKey:@"profitBalance"];
    [coder encodeObject:self.createdDate forKey:@"createdDate"];
    
}
-(UIImage *)memberRoleIcon
{
    switch (_memberRoles.integerValue) {
        case 6:{
            return [UIImage imageNamed:@"userProfileRolesIconV"];
        }
            break;
        case 16:{
            return [UIImage loadImageNamed:@"userProfileRolesIcon1V"];
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}
-(NSString *)memberRolesDesc
{
    switch (_memberRoles.integerValue) {
        case 6:{
            return @"认证PK主";
        }
            break;
        case 16:{
            return @"特级PK主";
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}
@end
