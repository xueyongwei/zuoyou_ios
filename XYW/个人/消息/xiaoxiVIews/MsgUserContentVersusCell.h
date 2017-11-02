//
//  MsgUserContentVersusCell.h
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVersusCardView.h"

@interface MsgUserContentVersusCell : UITableViewCell<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *iconCorver;

@property (weak, nonatomic) IBOutlet UILabel *userNaleLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ctntLabel;

@property (weak, nonatomic) IBOutlet SmallVersusCardView *versusView;

////@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
//@property (weak, nonatomic) IBOutlet UILabel *xiaoxiPkTagNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *user1IconImgV;
//@property (weak, nonatomic) IBOutlet UIImageView *user2IconImgV;
//@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;
//@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;

@property (nonatomic,copy)NSString *content;
@end
