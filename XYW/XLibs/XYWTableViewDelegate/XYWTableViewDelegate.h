//
//  XYWTableViewDelegate.h
//  testScrollInTableView
//
//  Created by xueyognwei on 17/1/22.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface XYWTableViewDelegate : NSObject
//dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
//注：如果使用iOS8的高度自动适应 ，不能重写heightForRowAtIndexPath

//Delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


@end
