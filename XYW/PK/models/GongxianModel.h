//
//  GongxianModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GongxianModel : NSObject
//CLZ = VersusItemRankTO;
//avatar = "http://static.hongdoujiao.net/upimg/1607/f2juiqroumkg.jpg";
//beansVal = 5;
//contestantRole = RED;
//memberId = 28;
//name = yuepeng;
//@property (nonatomic,copy)NSString *avatar;
@property (nonatomic,copy)NSString *contestantRole;
//@property (nonatomic,copy)NSString *name;
@property (nonatomic,assign)NSInteger beansVal;
@property (nonatomic,assign)NSInteger mid;
@end
