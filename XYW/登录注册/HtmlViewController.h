//
//  HtmlViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"

@interface HtmlViewController : ZYViewController
@property (nonatomic,copy)NSString *webTitle;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,copy)NSString *fileName;
-(void)onClose:(UIButton *)sender;
@end
