//
//  VersusDetailViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"
#import "PKModel.h"

@interface VersusDetailViewController : ZYTableViewController
@property (nonatomic,assign)NSInteger versusId;
@property (nonatomic,strong) PKModel *pkModel;
@end
