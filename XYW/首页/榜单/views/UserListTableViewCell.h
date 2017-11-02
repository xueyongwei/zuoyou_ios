//
//  UserListTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

@protocol BDTableViewCellDelegate <NSObject>
-(void)reloadNewWorkDataSource;
@end

#import <UIKit/UIKit.h>
/**
 *  用户列表的cell的父类
 */
@interface UserListTableViewCell : UITableViewCell
//用户列表均需要关注操作，需要VC进行刷新列表
@property (nonatomic,weak)id<BDTableViewCellDelegate> delegate ;


//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//关注
@property (weak, nonatomic) IBOutlet UIButton *guanzhuBtn;

@end
