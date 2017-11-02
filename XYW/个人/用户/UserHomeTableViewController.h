//
//  UserHomeTableViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseTableViewController.h"
#import "XYWControlTableView.h"
@interface UserHomeTableViewController : BaseTableViewController
@property (weak, nonatomic) NSLayoutConstraint *TopConst;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,assign)CGPoint xywOffSize;
@property (nonatomic,assign)CGFloat TopSpaceHeight;

-(void)ChildrenVCstartScrol:(void(^)(void))finishBlock;
@end
