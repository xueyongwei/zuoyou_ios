//
//  XuseCoreBtn.h
//  CoreBtn
//
//  Created by 薛永伟 on 15/11/23.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#ifndef CoreBtn_XuseCoreBtn_h
#define CoreBtn_XuseCoreBtn_h
/*
 
 //代码
 
 CoreStatusBtn *btn=[[CoreStatusBtn alloc] initWithFrame:CGRectMake(50, 110, 160, 40)];
 btn.msg=@"登陆中";
 btn.shutOffZoomAnim = YES;
 btn.shutOffColorLoadingAnim = YES;
 //设置文字
 [btn setTitle:@"我是按钮" forState:UIControlStateNormal];
 
 btn.backgroundColorForNormal=[UIColor brownColor];
 btn.backgroundColorForHighlighted=[UIColor redColor];
 btn.backgroundColorForSelected=[UIColor yellowColor];
 self.btn=btn;
 
 //添加事件
 [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
 
 [self.view addSubview:btn];
 
 
 //nib
 self.myBtn.backgroundColorForNormal=rgb(121, 36, 98);
 self.myBtn.shutOffColorLoadingAnim = YES;
 self.myBtn.shutOffZoomAnim = YES;
 self.countBtn.backgroundColorForNormal=rgb(167, 132, 27);
 self.countBtn.countNum=60;
 
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
 self.countBtn.status=CoreCountBtnStatusNormal;
 });
 
 
 CoreBtn *btn2 = [[CoreBtn alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
 btn2.backgroundColorForNormal = [UIColor redColor];
 [self.view addSubview:btn2];
 [btn2 Click:UIControlEventTouchDown ClickBlock:^{
 NSLog(@"点击");
 }];
 }
 
 
 -(IBAction)btnClick:(CoreStatusBtn *)btn{
 
 btn.status=CoreStatusBtnStatusProgress;
 
 //子线程测试
 dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
 btn.status=CoreStatusBtnStatusFalse;
 });
 }
 
 
 - (IBAction)getVerify:(CoreCountBtn *)countBtn{
 countBtn.countNum = 10;
 countBtn.status=CoreCountBtnStatusCounting;
 
 
 }

 
 
 */

#endif
