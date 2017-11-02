//
//  XiaoxiBodyModel.h
//  HDJ
//
//  Created by xueyongwei on 16/7/22.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XiaoxiBodyModel : NSObject
//content = "*512016-07-21 14:15:27\U9001\U51fa\U80a5\U7682";
//createdDate = "2016-07-21 14:15:27";
//id = 3;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSMutableAttributedString *contenText;
@property (nonatomic,copy)NSString *createdDate;
@property (nonatomic,assign)NSInteger xiaoxiID;
@property (nonatomic,assign)double timeAgo;
@property (nonatomic,copy)NSString *howLongStr;
@property (nonatomic,copy)NSString *listTimeStr;
//-(NSString *)howLongStr;
@end
