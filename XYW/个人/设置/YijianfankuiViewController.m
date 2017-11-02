//
//  YijianfankuiViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "YijianfankuiViewController.h"
#import "AppDelegate.h"
@interface YijianfankuiViewController ()

@end

@implementation YijianfankuiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"意见反馈";
    self.TF.delegate = self;
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"意见反馈页面"];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.text.length<1) {
        self.TVPlaceHolder.hidden = YES;
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length<1) {
        self.TVPlaceHolder.hidden = NO;
    }
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length<1) {
//        self.TVPlaceHolder.hidden = NO;
        self.doneBtn.backgroundColor = [UIColor colorWithHexColorString:@"cdcdcd"];
        self.doneBtn.userInteractionEnabled = NO;
    }else{
        self.TVPlaceHolder.hidden = YES;
        self.doneBtn.userInteractionEnabled = YES;
        self.doneBtn.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    }
}
- (IBAction)onYijianFankuiClick:(UIButton *)sender {
    CoreSVPLoading(@"提交中...", YES);
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/feedback"] parameters:@{@"content":self.TF.text,@"contacts":self.contactsTF.text} inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        if (result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"code"]) {
                CoreSVPSuccess([result objectForKey:@"msg"]);
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
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
