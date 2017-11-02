//
//  VideosListTableDelegater.h
//  ZuoYou
//
//  Created by xueyognwei on 17/1/22.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "XYWTableViewDelegate.h"

@interface VideosListTableDelegater : XYWTableViewDelegate
@property (nonatomic,strong)NSNumber *tagID;
@property (nonatomic,assign)BOOL cellTypeIsWithTag;
@property (nonatomic,copy)NSString *tagName;
@property (nonatomic,strong)UITableView *tableView;
@end
