//
//  UHFansTableViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserHomeTableViewController.h"
#import "UHSocialInfoModel.h"
#import "UHCaresTableViewCell.h"
@interface UHFansTableViewController : UserHomeTableViewController<BDTableViewCellDelegate>
-(void)prepareDataWithPg:(NSInteger)page;
@end
