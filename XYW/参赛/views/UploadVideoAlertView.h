//
//  UploadVideoAlertView.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadVideoAlertView : UIView
@property (weak, nonatomic) IBOutlet UIButton *selecteFromPhotos;
@property (weak, nonatomic) IBOutlet UIButton *selecteFromPersonalPage;

-(void)show;
-(void)disMiss;
@end
