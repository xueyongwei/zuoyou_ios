//
//  GlobalInstance.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/21.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalInstance : NSObject

/**
 这里都是强指针指向的数据，保证数据不被释放

 @return 全局变量实例
 */
+(GlobalInstance *)shareInstance;
@property (nonatomic,strong) NSMutableArray *sessionListDataSource;
@end
