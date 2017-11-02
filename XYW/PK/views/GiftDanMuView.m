//
//  GiftDanMuView.m
//  HDJ
//
//  Created by xueyongwei on 16/6/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "GiftDanMuView.h"
#import <CoreText/CoreText.h>
@implementation GiftDanMuView
-(void)awakeFromNib
{
    NSMutableAttributedString *attributedString =[[NSMutableAttributedString alloc]initWithString:@"X10"];
    int number = -3;//间距
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&number);
    [attributedString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[attributedString length])];
    CFRelease(num);
    [_gitfNumbLabel setAttributedText:attributedString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
