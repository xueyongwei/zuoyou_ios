//
//  MsgDetailTopTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/7/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgDetailTopTableViewCell.h"

@implementation MsgDetailTopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentWebView.layer.borderWidth = SINGLE_LINE_WIDTH;
    self.fengexianH.constant = SINGLE_LINE_WIDTH;
    self.contentWebView.layer.borderColor = [UIColor colorWithHexColorString:@"dddddd"].CGColor;
    // Initialization code
}
-(void)setContent:(NSString *)content
{
    self.contentWebView.scrollView.scrollEnabled = NO;
    self.contentWebView.delegate = self;
    [self.contentWebView loadHTMLString:content baseURL:nil];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize fittingSize = [self.contentWebView sizeThatFits:CGSizeZero];
    self.contWbH.constant = fittingSize.height;
    CGRect rect = self.frame;
    rect.size.height = fittingSize.height+55;
    self.frame = rect;
//    //    self.contentWbView.frame = CGRectMake(0, 0, fittingSize.width, fittingSize.height);
//    
//    // 用通知发送加载完成后的高度
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WEBVIEW_HEIGHT" object:self userInfo:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
