//
//  HtmlViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "HtmlViewController.h"

@interface HtmlViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *webView;
@end

@implementation HtmlViewController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.url) {
        NSURL *url = [NSURL URLWithString:self.url];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }else if (self.fileName){
        NSURL *url = [[NSBundle mainBundle] URLForResource:self.fileName withExtension:nil];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}
-(void)onClose:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.webTitle;
    self.webView = [UIWebView new];
    self.webView.delegate  = self;
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取网页title
    NSString *htmlTitle = @"document.title";
    NSString *titleHtmlInfo = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    self.navigationItem.title = titleHtmlInfo;
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
