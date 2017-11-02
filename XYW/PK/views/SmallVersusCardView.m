//
//  SmallVersusCardView.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/22.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SmallVersusCardView.h"
#import "UIView+Extend.h"
#import "PKDetailViewController.h"

@interface SmallVersusCardView()
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;

@property (weak, nonatomic) IBOutlet UIImageView *leftIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;

//@property (nonatomic,copy)NSString *tagName;
@property (strong,nonatomic) NSNumber *pkId;
//@property (strong,nonatomic) NSNumber *leftUserId;
//@property (strong,nonatomic) NSNumber *rightUserId;
@end

@implementation SmallVersusCardView
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
    
}
-(void)setUp{
    UIView *cardVidw =[[[NSBundle mainBundle]loadNibNamed:@"SmallVersusCardView" owner:self options:nil]lastObject];
    [self addSubview:cardVidw];
    [cardVidw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self);
    }];
//    self.leftIcon.layer.borderWidth = 1;
//    self.rightIcon.layer.borderWidth = 1;
//    self.leftIcon.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
//    self.rightIcon.layer.borderColor = [UIColor colorWithHexColorString:@"03a9f3"].CGColor;
}
-(void)setTagName:(NSString *)tagName pkId:(NSNumber *)pkID leftUserId:(NSNumber *)leftUserID rightUserID:(NSNumber *)rightUserID
{
//    _tagName = tagName;
    _pkId = pkID;
//    _leftUserId = leftUserID;
    self.tagNameLabel.text = tagName;
    [UserInfoManager setNameLabel:nil headImageV:self.leftIcon corverImageV:self.leftCorver with:leftUserID];
    [UserInfoManager setNameLabel:nil headImageV:self.rightIcon corverImageV:self.rightCorver with:rightUserID];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    PKDetailViewController *vc = [PKDetailViewController new];
    vc.pkId = self.pkId.integerValue;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
