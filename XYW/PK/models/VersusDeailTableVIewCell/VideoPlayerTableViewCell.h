//
//  VideoPlayerTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYPlayer.h"
@interface VideoPlayerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ZYPlayerView *playerView;

@end
