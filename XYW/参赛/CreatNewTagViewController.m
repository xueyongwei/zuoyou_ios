//
//  CreatNewTagViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "CreatNewTagViewController.h"
#import "CaptureViewController.h"

@interface CreatNewTagViewController ()
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UITextField *TF;
@end

@implementation CreatNewTagViewController
-(void)tfChanged:(UITextField *)tf{
    // 准备对象
//    NSString * searchStr = tf.text ;
//    NSString * regExpStr = @"[^a-zA-Z0-9\u4E00-\u9FA5_:：!！,，。.?？]";
//    NSString * replacement = @"";
//    // 创建 NSRegularExpression 对象,匹配 正则表达式
//    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regExpStr
//                                                                       options:NSRegularExpressionCaseInsensitive
//                                                                         error:nil];
//    NSString *resultStr = searchStr;
//    // 替换匹配的字符串为 searchStr
//    resultStr = [regExp stringByReplacingMatchesInString:searchStr
//                                                 options:NSMatchingReportProgress
//                                                   range:NSMakeRange(0, searchStr.length)
//                                            withTemplate:replacement];
//    NSLog(@"\\nsearchStr = %@\\nresultStr = %@",searchStr,resultStr);
    UITextRange *selectedRange = [tf markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [tf positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    NSString *noEmojiStr =[self disableEmoji:tf.text];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"～@／；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *normalStr = [noEmojiStr stringByTrimmingCharactersInSet:set];
    tf.text = normalStr;
    if (tf.text.length>14) {
        tf.text = [tf.text substringToIndex:14];
    }
    self.okBtn.enabled = tf.text.length>3;
}
//禁止输入表情
- (NSString *)disableEmoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"创建话题";
    self.okBtn.clipsToBounds = YES;
    self.okBtn.layer.cornerRadius = 5;
    [self.TF addTarget:self action:@selector(tfChanged:) forControlEvents:UIControlEventEditingChanged];
    self.TF.text = self.inputText;
    self.okBtn.enabled = self.TF.text.length>3;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)onOkClick:(UIButton *)sender {
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/tag/check",HeadUrl] parameters:@{@"name":self.TF.text} inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            CoreSVPCenterMsg(result[@"errMsg"]);
            DbLog(@"%@",result[@"errMsg"]);
        }else{
            CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
            CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
            captureViewCon.tagName = [NSString stringWithFormat:@"#%@#",self.TF.text];
            captureViewCon.challenge = @"false";
            [navCon pushViewController:captureViewCon animated:YES];
            [self.navigationController presentViewController:navCon animated:YES completion:nil];
        }
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
        CoreSVPCenterMsg(error.localizedDescription);
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
