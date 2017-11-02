//
//  MsgUserContentVersusCell.m
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgUserContentVersusCell.h"

@implementation MsgUserContentVersusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.user1IconImgV.layer.borderWidth = 1;
//    self.user2IconImgV.layer.borderWidth = 1;
//    self.user1IconImgV.layer.borderColor = [UIColor colorWithHexColorString:@"f44236"].CGColor;
//    self.user2IconImgV.layer.borderColor = [UIColor colorWithHexColorString:@"03a9f3"].CGColor;
    // Initialization code
}

//-(void)setContent:(NSString *)content
//{
//    
//    NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType};
//    NSAttributedString *string = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
//    [self.ctnTextView setAttributedText:string];
//     self.ctntTextViewH.constant = [self.ctnTextView sizeThatFits:CGSizeMake(self.ctnTextView.bounds.size.width, MAXFLOAT)].height;
//    CGRect rect = self.frame;
//    rect.size.height = self.ctntTextViewH.constant+90;
//    self.frame = rect;
//}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
