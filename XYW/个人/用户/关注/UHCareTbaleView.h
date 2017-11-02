//
//  UHCareTbaleView.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "YXTabItemBaseView.h"
#import "UHSocialInfoModel.h"
#import "UHCaresTableViewCell.h"
@interface UHCareTbaleView : YXTabItemBaseView<BDTableViewCellDelegate>
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)UILabel *noDataLabel;

@end
