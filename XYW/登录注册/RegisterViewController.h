//
//  RegisterViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/6/2.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreCountBtn.h"
#import "CoreStatusBtn.h"
#import "BaseViewController.h"
@interface RegisterViewController :BaseViewController
@property (weak, nonatomic) IBOutlet CoreCountBtn *huoquyanzhengmaBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneNbTF;
@property (weak, nonatomic) IBOutlet UITextField *smsYzmTF;
@property (weak, nonatomic) IBOutlet UITextField *passWdTF;
@property (weak, nonatomic) IBOutlet CoreStatusBtn *doneBtn;

@property (nonatomic,copy)NSString *phone;
@property (nonatomic,assign)BOOL zhaohui;
@end
