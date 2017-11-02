//
//  StarUsersTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StarUsersCollectionLayout :UICollectionViewFlowLayout

@end

@interface StarUsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
