//
//  RegisterViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/2.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "RegisterViewController.h"
#import "CoreBtn.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SchemesModel.h"
#import "UserInfoManager.h"
#import "SocketManager.h"
#import "XYWAlert.h"
#import "XGPush.h"
#define SEP @"-"
@interface RegisterViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)SchemesModel *scheme;
@end

@implementation RegisterViewController
{
    UIButton *clearBtn;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"注册／找回密码页面"];
    [self.phoneNbTF becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customTF];
    [self customNavi];
    [self customView];
    // Do any additional setup after loading the view.
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
    [super customNavi];
    self.phoneNbTF.text = self.phone;
    if (![self.navigationItem.title isEqualToString:@"注册"]) {
        [self.doneBtn setTitle:@"确定" forState:UIControlStateNormal];;
    }
}
-(void)onBackClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth
{
//    CGRect frame = textField.frame;
//    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, leftWidth)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}
-(void)customTF
{
    self.phoneNbTF.tag = 100;
    self.smsYzmTF.tag = 110;
    self.passWdTF.tag = 120;
    
    self.phoneNbTF.delegate = self;
    self.passWdTF.delegate = self;
    self.smsYzmTF.delegate = self;
    [self.phoneNbTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passWdTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.smsYzmTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self setTextFieldLeftPadding:self.phoneNbTF forWidth:45];
    [self setTextFieldLeftPadding:self.passWdTF forWidth:45];
    [self setTextFieldLeftPadding:self.smsYzmTF forWidth:45];
    UIImageView *pnImgV = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"phone"]];
    pnImgV.frame = CGRectMake(10, 13, 25, 25);
    [self.phoneNbTF.leftView addSubview:pnImgV];
    
    UIImageView *pnImgV2 = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"password"]];
    pnImgV2.frame = CGRectMake(10, 13, 25, 25);
    [self.passWdTF.leftView addSubview:pnImgV2];
    
    UIImageView *smImgV = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"验证码"]];
    smImgV.frame = CGRectMake(10, 13, 25, 25);
    [self.smsYzmTF.leftView addSubview:smImgV];
    
    UIView *rtView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 40)];
    
    clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(0, 0, 15, 40);
    [clearBtn setImage:[UIImage loadImageNamed:@"X"] forState:UIControlStateNormal];
    //    clearBtn.backgroundColor = [UIColor redColor];
    [clearBtn addTarget:self action:@selector(onClearCLick:) forControlEvents:UIControlEventTouchDown];
    [rtView addSubview:clearBtn];
    clearBtn.hidden = YES;
    
    UIButton *eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeBtn.frame = CGRectMake(15, 0, 40, 40);
    [eyeBtn setImage:[UIImage loadImageNamed:@"眼睛_40X40"] forState:UIControlStateNormal];
    [eyeBtn setImage:[UIImage loadImageNamed:@"眼睛_X"] forState:UIControlStateSelected];
    [eyeBtn addTarget:self action:@selector(onEyeClick:) forControlEvents:UIControlEventTouchDown];
    eyeBtn.selected = YES;
    [rtView addSubview:eyeBtn];
    
    self.passWdTF.rightViewMode = UITextFieldViewModeAlways;
    self.passWdTF.rightView = rtView;
    if (self.phone.length ==11) {//11位来自上一级，可以激活获取验证码按钮
        self.huoquyanzhengmaBtn.enabled = YES;
        [self.huoquyanzhengmaBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
        self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    }
    
}
-(void)customView
{
    self.huoquyanzhengmaBtn.layer.cornerRadius = 5;
    self.huoquyanzhengmaBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
    self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"c1c1c1"].CGColor;
    
    self.doneBtn.msg = @"请稍等...";
    self.doneBtn.shutOffZoomAnim = YES;
    self.doneBtn.backgroundColorForNormal= [UIColor colorWithHexColorString:@"cbcbcb"];
    self.doneBtn.backgroundColorForHighlighted=[UIColor colorWithHexColorString:@"cbcbcb"];
    self.doneBtn.backgroundColorForSelected=[UIColor colorWithHexColorString:@"cbcbcb"];
    
}
-(void)onClearCLick:(UIButton *)sender
{
    self.passWdTF.text = @"";
    clearBtn.hidden = YES;
    self.doneBtn.userInteractionEnabled = NO;
    self.doneBtn.backgroundColor = [UIColor colorWithHexColorString:@"cbcbcb"];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textField:textField Selected:YES];
    if (textField.tag == 110) {
        
        if (self.phoneNbTF.text.length!=13) {
            
            [textField resignFirstResponder];
            [self.phoneNbTF becomeFirstResponder];
            if (self.phoneNbTF.text.length<1) {
                CoreSVPCenterMsg(@"请输入手机号码！");
            }else{
                CoreSVPCenterMsg(@"请输入正确的手机号码！");
            }
            return;
        }else{
            
        }
    }else if (textField.tag == 120){
        if (self.phoneNbTF.text.length!=13) {
            
            [textField resignFirstResponder];
            [self.phoneNbTF becomeFirstResponder];
            if (self.phoneNbTF.text.length<1) {
                CoreSVPCenterMsg(@"请输入手机号码！");
            }else{
                CoreSVPCenterMsg(@"请输入正确的手机号码！");
            }
            return;
        }
        /*
        if (self.smsYzmTF.text.length !=6) {
            [textField resignFirstResponder];
            [self.smsYzmTF becomeFirstResponder];
            if (self.smsYzmTF.text.length<1) {
                CoreSVPCenterMsg(@"请输入短信验证码！");
            }else{
                CoreSVPCenterMsg(@"请输入正确的短信验证码！");
            }
            return;
        }*/
    }else if (textField.tag == 100){
        if (textField.text.length ==13 && self.huoquyanzhengmaBtn.status != CoreCountBtnStatusCounting) {
            self.huoquyanzhengmaBtn.enabled = YES;
            [self.huoquyanzhengmaBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
        }else{
            self.huoquyanzhengmaBtn.enabled = NO;
            [self.huoquyanzhengmaBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"c1c1c1"].CGColor;
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
    if (textField == self.phoneNbTF) {
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
        
        if (textField.text.length ==13 && self.huoquyanzhengmaBtn.status != CoreCountBtnStatusCounting) {
            self.huoquyanzhengmaBtn.enabled = YES;
            [self.huoquyanzhengmaBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
        }else{
            self.huoquyanzhengmaBtn.enabled = NO;
            [self.huoquyanzhengmaBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.huoquyanzhengmaBtn.layer.borderColor = [UIColor colorWithHexColorString:@"c1c1c1"].CGColor;
        }
    }
    if (textField == self.smsYzmTF) {
        if (textField.text.length>6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }
    if (textField == self.passWdTF) {
        if (textField.text.length>18) {
            textField.text = [textField.text substringToIndex:18];
        }
        if (textField.text.length>5){
            self.doneBtn.userInteractionEnabled = YES;
            self.doneBtn.backgroundColorForNormal = [UIColor colorWithHexColorString:@"ff4a4b"];
        }else{
            self.doneBtn.userInteractionEnabled = NO;
            self.doneBtn.backgroundColorForNormal = [UIColor lightGrayColor];
        }
        if (self.passWdTF.text.length>0) {
            clearBtn.hidden = NO;
        }else{
            clearBtn.hidden = YES;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark ---按钮的点击事件
- (void)onEyeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSString *tmpStr = self.passWdTF.text;
    if (sender.selected) {
        self.passWdTF.secureTextEntry = YES;
    }else{
        self.passWdTF.secureTextEntry = NO;
    }
    self.passWdTF.text = @"";
    self.passWdTF.text = tmpStr;
}
- (IBAction)onHuoquYzmClick:(CoreCountBtn *)sender {
    
    sender.status = CoreCountBtnStatusCounting;
    [self sendSMS];
}

- (IBAction)onRegisterClik:(CoreStatusBtn *)sender {
    sender.status=CoreStatusBtnStatusProgress;
    if ([self.navigationItem.title isEqualToString:@"注册"]) {
        [self RegisterAndLogin];
    }else{
        [self DoneTochangePwd];
    }
    
}
#pragma mark ---发起网络请求
-(void)sendSMS
{
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    //    md6(exists=&num=&ts=key)
    NSString *phoneNub = [self.phoneNbTF.text stringByReplacingOccurrencesOfString:SEP withString:@""];
    NSString *exts = [self.navigationItem.title isEqualToString:@"注册"]?@"false":@"true";
    NSString *vc = [NSString stringWithFormat:@"exists=%@&num=%@&ts=%@%@",exts,phoneNub,ts,SECUREKEY];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/authenticateCode"]  parameters:@{@"num":phoneNub,@"ts":ts,@"exists":exts,@"vc":vc.md5} inView:nil sucess:^(id result) {
        if (result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"errCode"]) {
                if ([[result objectForKey:@"errCode"] isEqualToString:@"1013"]) {
                    UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"该手机号已被注册，请前往登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
                    [alv show];
                    [self.huoquyanzhengmaBtn unUse];
                }else{
                    CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                }
                return ;
            }
            if ([result objectForKey:@"code"]) {
                CoreSVPCenterMsg([result objectForKey:@"msg"]);
                NSDictionary *extras = [result objectForKey:@"extras"];
                NSString *nextTime = [extras objectForKey:@"afterMinutes"];
                //设置下次发送验证码的时间
                NSNumber *code =(NSNumber *)[result objectForKey:@"code"];
                if (code.integerValue == 1007) {
                    [self.huoquyanzhengmaBtn unUse];
                    [self.huoquyanzhengmaBtn setTitle:@"明日再试" forState:UIControlStateNormal];
                    return;
                }
                self.huoquyanzhengmaBtn.countNum = nextTime.integerValue*60;
            }
        }

    } failure:^(NSError *error) {
        
    }];
}
-(void)RegisterAndLogin
{
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    //    md6(exists=&num=&ts=key)/v1/users/reg?num=&code=&pwd=&ts=&vc=
    //    md5(code=&num=&pwd=&ts=key)
    NSString *phoneNub = [self.phoneNbTF.text stringByReplacingOccurrencesOfString:SEP withString:@""];
    NSString *vc = [NSString stringWithFormat:@"code=%@&num=%@&pwd=%@&ts=%@%@",self.smsYzmTF.text,phoneNub,self.passWdTF.text,ts,SECUREKEY];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/reg"] parameters:@{@"num":phoneNub,@"code":self.smsYzmTF.text,@"pwd":self.passWdTF.text,@"ts":ts,@"vc":vc.md5} inView:nil sucess:^(id result) {
        if (result) {
            self.doneBtn.status = CoreStatusBtnStatusSuccess;
            DbLog(@"%@",result);
            NSNumber *errCode = [result objectForKey:@"errCode"];
            if (errCode) {
                if (errCode.integerValue == 4007) {
                    [XYWAlert XYWAlertTitle:[result objectForKey:@"errMsg"] message:nil first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"知道了" handle:nil];
                    return ;
                }
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                return;
            }
            
            NSDictionary *userInfo = (NSDictionary *)result;
            [self refreshConnect:userInfo];
            [self changeRootView];
        }
    } failure:^(NSError *error) {
        self.doneBtn.status = CoreStatusBtnStatusFalse;
    }];
    
}
///v1/users/resetPwd?num=&code=&newPwd=
-(void)DoneTochangePwd
{
    if (self.phoneNbTF.text.length!=13) {
        CoreSVPCenterMsg(@"请输入正确的手机号");
        self.doneBtn.status = CoreStatusBtnStatusFalse;
        return;
    }
    if (self.smsYzmTF.text.length<6) {
        CoreSVPCenterMsg(@"请输入正确的验证码");
        self.doneBtn.status = CoreStatusBtnStatusFalse;
        return;
    }
    NSString *phoneNub = [self.phoneNbTF.text stringByReplacingOccurrencesOfString:SEP withString:@""];
    NSDictionary *param = @{@"num":phoneNub,@"code":self.smsYzmTF.text,@"newPwd":self.passWdTF.text};
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/resetPwd"] parameters:param inView:nil sucess:^(id result) {
        if (result) {
            self.doneBtn.status = CoreStatusBtnStatusSuccess;
            DbLog(@"%@",result);
            if ([result objectForKey:@"errCode"]) {
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                return ;
            }
            NSDictionary *userInfo = (NSDictionary *)result;
            [self refreshConnect:userInfo];
            [self changeRootView];
        }

    } failure:^(NSError *error) {
        self.doneBtn.status = CoreStatusBtnStatusFalse;
    }];
}
-(void)refreshConnect:(NSDictionary *)userInfo
{
    [UserInfoManager saveMyselfInfo:userInfo];
    [XYWhttpManager refreshRequestToken];
    [[SocketManager defaultManager] createWS];
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
    
#pragma mark --检查受否有待处理的跳转信息
    //检查受否有待处理的跳转信息
    id __weak weakSelf = self;
    dispatch_queue_t concurrentQueue = dispatch_queue_create("zuoyou.data.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        //异步线程处理数据
        [weakSelf talkingDataSetAccount];
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
    });
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
