//
//  UHVideosTableHeader.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyVideoModel.h"
@interface UHVideosTableHeader : UIView
//@property (strong, nonatomic) UIImageView *corverImgV;
@property (weak, nonatomic) IBOutlet UIImageView *corverImgV;

//@property (strong, nonatomic) UIImageView *playImgV;
@property (weak, nonatomic) IBOutlet UIImageView *playImgV;

@property (weak, nonatomic) IBOutlet UIView *stateView;
@property (weak, nonatomic) IBOutlet UILabel *watiStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *failStateBtn;


@property (nonatomic,copy)NSString *videoUrl;
@property (nonatomic,assign)BOOL autoPlay;
@property (nonatomic,assign)NSInteger currentSection;
@property (nonatomic,assign)personalVideoType videoState;
@end
