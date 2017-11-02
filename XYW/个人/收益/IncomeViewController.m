//
//  IncomeViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "IncomeViewController.h"
#import "IncomeDetailViewController.h"
#import "UILabel+FlickerNumber.h"
@interface IncomeViewController ()<UITextFieldDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UITextField *TF;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UILabel *ruleDescLabel;
@property (nonatomic,strong) NSNumber *minAmount;
@end

@implementation IncomeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.delegate = self;
    [self prepareDataOfRules];
    self.okBtn.layer.cornerRadius = 8;
    self.okBtn.clipsToBounds = YES;
    self.TF.delegate = self;
   
    [self.TF addTarget:self action:@selector(TFchanged:) forControlEvents:UIControlEventEditingChanged];
    
}
-(void)dealloc
{
    DbLog(@"incomeVC dealloc");
    self.navigationController.delegate = nil;
}
#pragma mark 准备数据
-(void)prepareDataOfRules
{
    __weak typeof(self) wkSelf = self;
    [UserInfoManager refreshMyselfInfoFinished:^{
        NSNumber *balance = [UserInfoManager mySelfInfoModel].profitBalance;
        [wkSelf.incomeLabel fn_setNumber:balance format:@"%.2f"];
    }];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/finance/withdrawRule",HeadUrl] parameters:nil inView:nil sucess:^(id result) {
        if ([result objectForKey:@"rule"]) {
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[[result objectForKey:@"rule"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            self.ruleDescLabel.attributedText = attrStr;
            self.TF.placeholder = [result objectForKey:@"amountNotice"];
            self.minAmount = [result objectForKey:@"amount"];
        }else{
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            DbLog(@"%@",[result objectForKey:@"errMsg"]);
        }
    } failure:^(NSError *error) {
        
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.TF resignFirstResponder];
}
#pragma mark TF的代理
-(void)TFchanged:(UITextField *)tf
{
    if (tf.text.length>6) {
        tf.text = [tf.text substringToIndex:6];
    }
    self.okBtn.enabled =tf.text.integerValue>=self.minAmount.integerValue&&tf.text.length<8;
}
#pragma mark 点击事件
- (IBAction)onBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onDetailClick:(id)sender {
    IncomeDetailViewController *detailVC = [[IncomeDetailViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (IBAction)onOkClick:(id)sender {
    if (self.TF.text.length==0) {
        CoreSVPCenterMsg(@"请输入提现金额");
        return;
    }
    CoreSVPLoading(@"正在请求", NO);
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/finance/withdraw",HeadUrl] parameters:@{@"amount":self.TF.text} inView:nil sucess:^(id result) {
        if ([result objectForKey:@"code"]) {
            CoreSVPCenterMsg([result objectForKey:@"msg"]);
            [UserInfoManager refreshMyselfInfoFinished:^{
                [CoreSVP dismiss];
                [wkSelf.incomeLabel fn_setNumber:[UserInfoManager mySelfInfoModel].profitBalance format:@"%.2f"];
            }];
        }else{
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
        }
    } failure:^(NSError *error) {
        [CoreSVP dismiss];
    }];
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
