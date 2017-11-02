//
//  CaptureVideoNavigationController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "CaptureVideoNavigationController.h"

@interface CaptureVideoNavigationController ()

@end

@implementation CaptureVideoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.showStatusWhenDealloc) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
