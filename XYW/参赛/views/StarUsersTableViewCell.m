//
//  StarUsersTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "StarUsersTableViewCell.h"
@implementation StarUsersCollectionLayout
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}
@end
@implementation StarUsersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
