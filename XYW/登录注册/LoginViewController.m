//
//  LoginViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SchemesModel.h"
#import "PKDetailViewController.h"
#import "UserInfoManager.h"
#import "SocketManager.h"
#import "XYWAlert.h"
#import "XGPush.h"
#define SEP @"-"
@interface LoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;
@property (weak, nonatomic) IBOutlet UITextField *passWordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property(nonatomic,strong)SchemesModel *scheme;
@end

@implementation LoginViewController
{
    UIButton *clearBtn;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"手机号登录页面"];
    [self.phoneNumTF becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customTF];
//    [self customNavi];
}
-(void)checkWaitingSchemes
{
    DbLog(@"捕获了打开应用的检测，但是没有登录我不处理。");
}
-(void)schemesListen:(NSNotification *)noti
{
    DbLog(@"捕获了打开应用的通知，但是没有登录我保存在本地不做处理。");
    DbLog(@"class = %@",NSStringFromClass(self.class));
    DbLog(@"listen %@",noti);
    
    //保存起来，等登录后再发一次通知
    NSDictionary *dic = noti.object;
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:dic forKey:@"SCHEMES"];
    [usf synchronize];
}
-(void)customNavi
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 15, 30);
    btn.contentMode = UIViewContentModeLeft;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBar;
}
-(void)onBackClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth
{
//    CGRect frame = textField.bounds;
//    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, leftWidth)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}
-(void)customTF
{
    self.phoneNumTF.tag = 100;
    self.passWordTF.tag = 110;
    self.phoneNumTF.delegate = self;
    self.passWordTF.delegate = self;
    
    
    [self setTextFieldLeftPadding:self.phoneNumTF forWidth:45];
    [self setTextFieldLeftPadding:self.passWordTF forWidth:45];
    
    [self.phoneNumTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passWordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIImageView *pnImgV = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"phone"]];
    pnImgV.frame = CGRectMake(10, 13, 25, 25);
    [self.phoneNumTF.leftView addSubview:pnImgV];
    
    UIImageView *pnImgV2 = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"password"]];
    pnImgV2.frame = CGRectMake(10, 13, 25, 25);
    [self.passWordTF.leftView addSubview:pnImgV2];
    
    
    UIView *rtView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 40)];
    
    clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(0, 0, 15, 40);
    [clearBtn setImage:[UIImage loadImageNamed:@"X"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(onClearCLick:) forControlEvents:UIControlEventTouchDown];
    [rtView addSubview:clearBtn];
    clearBtn.hidden = YES;
    
    UIButton *eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeBtn.frame = CGRectMake(15, 0, 40, 40);
    [eyeBtn setImage:[UIImage loadImageNamed:@"眼睛_40X40"] forState:UIControlStateNormal];
    [eyeBtn setImage:[UIImage loadImageNamed:@"眼睛_X"] forState:UIControlStateSelected];
    eyeBtn.selected = YES;
    [eyeBtn addTarget:self action:@selector(onEyeClick:) forControlEvents:UIControlEventTouchDown];
    [rtView addSubview:eyeBtn];
    
    self.passWordTF.rightViewMode = UITextFieldViewModeAlways;
    self.passWordTF.rightView = rtView;
    
}
-(void)onClearCLick:(UIButton *)sender
{
    self.passWordTF.text = @"";
    clearBtn.hidden = YES;
    self.loginBtn.userInteractionEnabled = NO;
    self.loginBtn.backgroundColor = [UIColor lightGrayColor];
}
#pragma mark ---TF的代理
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textField:textField Selected:YES];
    if (textField.tag == 110) {
        if (textField.text.length>0) {
            clearBtn.hidden = NO;
        }
        if (self.phoneNumTF.text.length!=13) {
            
            [textField resignFirstResponder];
            [self.phoneNumTF becomeFirstResponder];
            if (self.phoneNumTF.text.length<1) {
                CoreSVPCenterMsg(@"请输入手机号码！");
            }else{
                CoreSVPCenterMsg(@"请输入正确的手机号码！");
            }
            return;
        }
    }
    
    
}
-(void)textField:(UITextField *)textField Selected:(BOOL)selected
{
    textField.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    textField.layer.cornerRadius = 5;
    if (selected) {
        textField.layer.borderWidth = 0.5f;
    }else{
        textField.layer.borderWidth = 0.0f;
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textField:textField Selected:NO];
    if (textField.tag == 110) {
        clearBtn.hidden = YES;
    }
    
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.tag == 100) {//手机号
        NSMutableString *temString = [NSMutableString stringWithString:textField.text];
        temString = (NSMutableString*)[temString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (temString.length>3) {
            [temString insertString:SEP atIndex:3];
        }
        if (temString.length>8) {
            [temString insertString:SEP atIndex:8];
        }
        if (temString.length>13) {
            temString =(NSMutableString*)[temString substringToIndex:13];
        }
        textField.text = temString;
    }
    if (textField.tag == 110) {//密码
        if (textField.text.length>0) {
            clearBtn.hidden = NO;
        }else{
            clearBtn.hidden = YES;
        }
        if (textField.text.length>18) {
            textField.text = [textField.text substringToIndex:18];
        }
        [self howMuch:textField];
    }
    
}
-(void)howMuch:(UITextField *)textField
{
    if (self.passWordTF.text.length>5) {
        self.loginBtn.userInteractionEnabled = YES;
        self.loginBtn.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    }else{
        self.loginBtn.userInteractionEnabled = NO;
        self.loginBtn.backgroundColor = [UIColor colorWithHexColorString:@"cbcbcb"];
    }
    if (self.passWordTF.text.length>0) {
        clearBtn.hidden = NO;
    }else{
        clearBtn.hidden = YES;
    }

    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)onEyeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.passWordTF.secureTextEntry = YES;
    }else{
        self.passWordTF.secureTextEntry = NO;
    }
    [self.passWordTF becomeFirstResponder];
    self.passWordTF.font = [UIFont systemFontOfSize:15];
}

- (IBAction)onLoginCLick:(UIButton *)sender {
    CoreSVPLoading(@"正在登录...", NO);
//    [self login];
    [self changeRootView];
}


-(void)login
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/login"] parameters:@{@"num":[self.phoneNumTF.text stringByReplacingOccurrencesOfString:SEP withString:@""],@"pwd":self.passWordTF.text } inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        if (result) {
            DbLog(@"%@",result);
            NSNumber *errCode = [result objectForKey:@"errCode"];
            if (errCode) {
                if (errCode.integerValue == 4007) {
                    [XYWAlert XYWAlertTitle:[result objectForKey:@"errMsg"] message:nil first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"知道了" handle:nil];
                    return ;
                }else if (errCode.integerValue == 4001){//尚未注册
                    [self.phoneNumTF resignFirstResponder];
                    [self.passWordTF resignFirstResponder];
                    UIAlertView *alV = [[UIAlertView alloc]initWithTitle:[result objectForKey:@"errMsg"] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去注册", nil];
                    alV.tag = 100;
                    [alV show];
                    return;
                }
                //吐司弹错
                CoreSVPCenter3sMsg([result objectForKey:@"errMsg"]);
                if (errCode.integerValue == 4002){
                    self.passWordTF.text = @"";
                }
                return ;
            }
            NSDictionary *userInfo = (NSDictionary *)result;
            [self refreshConnect:userInfo];
            [self changeRootView];
        }
    } failure:^(NSError *error) {
        [CoreSVP dismiss];
    }];

}
-(void)refreshConnect:(NSDictionary *)userInfo
{
    [UserInfoManager saveMyselfInfo:userInfo];
    [XYWhttpManager refreshRequestToken];
    [[SocketManager defaultManager] createWS];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"forgetSegue"]) {
        RegisterViewController *vc = segue.destinationViewController;
//        vc.phoneNbTF.text = self.phoneNumTF.text;
        vc.navigationItem.title = @"找回密码";
        vc.phone = self.phoneNumTF.text;
    }else if([segue.identifier isEqualToString:@"registerSegue"]){
        RegisterViewController *vc = segue.destinationViewController;
        vc.phone = self.phoneNumTF.text;
    }
}
#pragma mark ---alertView的代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        if (buttonIndex ==0) {
            
        }else if (buttonIndex ==1){
            [self performSegueWithIdentifier:@"registerSegue" sender:self];
        }
    }
    
}
-(void)changeRootView
{
    [CoreSVP dismiss];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RootViewController *lgvc = [RootViewController new];
    
    // 修改rootViewController
    [delegate.window addSubview:lgvc.view];
    [self.view removeFromSuperview];
    delegate.window.rootViewController =  lgvc;
   
    //移除膜拜数据
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"mobaidate"];
#pragma mark --检查受否有待处理的跳转信息
    //检查受否有待处理的跳转信息
    dispatch_queue_t concurrentQueue = dispatch_queue_create("zuoyou.data.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        //异步线程处理数据
        [self talkingDataSetAccount];
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [usf objectForKey:@"SCHEMES"];
        if (dic&&dic[@"id"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程更新界面
                DbLog(@"将通知再次传递");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SCHEMES" object:dic];
            });
        }
    });
    
}
-(void)talkingDataSetAccount
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("zuoyou.data.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        //异步线程处理数据
        MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
        
        TDGAAccount *acount =[TDGAAccount setAccount:[NSString stringWithFormat:@"%@",my.mid] ];
        [acount setAccountType:kAccountRegistered];
        
        [acount setAccountName:my.name];
        [acount setGameServer:@"iOS客户端"];
        [XGPush setAccount:[NSString stringWithFormat:@"%@",my.mid] successCallback:^{
            NSLog(@"[XGDemo] Set account success");
        } errorCallback:^{
            NSLog(@"[XGDemo] Set account error");
        }];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //主线程更新界面
//        });
        
    });
    
    
}
@end
