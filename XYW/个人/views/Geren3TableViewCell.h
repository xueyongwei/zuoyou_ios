//
//  Geren3TableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDProgressView.h"
@interface Geren3TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet LDProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *proTexTlabel;

@end
