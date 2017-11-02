//
//  EditSignViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "EditSignViewController.h"

@interface EditSignViewController ()<UITextViewDelegate>

@end

@implementation EditSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.TV.delegate = self;
    self.navigationItem.title = @"个性签名";
    self.TV.text = self.single;
    [self textViewDidChange:self.TV];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.TV becomeFirstResponder];
    
}
- (IBAction)onOkbtnClick:(UIButton *)sender {
//    avatar=&name=&gender=&sign=
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/updateInfo"] parameters:@{@"avatar":@"",@"name":@"",@"gender":@"",@"signature":[self zuoyouString:self.TV.text] } inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSDictionary class]]) {
            if ([result objectForKey:@"code"]) {
                CoreSVPCenterMsg(@"已保存");
                [self prepareMyInfo];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }
    } failure:^(NSError *error) {
        NSString *errMsg = error.localizedDescription;
        DbLog(@"%@",errMsg);
        CoreSVPCenterMsg(errMsg)
    }];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    DbLog(@"%ld",textView.text.length);

    if (textView.text.length>30){
        textView.text = [textView.text substringToIndex:30];
    }
    self.textsNubLael.text = [NSString stringWithFormat:@"%lu", 30 - (unsigned long)textView.text.length] ;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

#pragma mark --- 获取最新的用户信息
-(void)prepareMyInfo
{
    [UserInfoManager refreshMyselfInfoFinished:^{
        
    }];
}
-(NSString *)zuoyouString:(NSString *)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return  str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
