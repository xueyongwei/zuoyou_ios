//
//  VideoNormalTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VideoNormalTableViewCell.h"

@implementation VideoNormalTableViewCell

- (void)defaultConfig {
    DbLog(@"配置cell");
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-16)/2;
    self.videosViewWidthConst.constant = width*2;
    
    UIBezierPath* pathL = [UIBezierPath bezierPath];
    [pathL moveToPoint:CGPointMake(0, 0)];
    [pathL addLineToPoint:CGPointMake(width+10, 0)];
    [pathL addLineToPoint:CGPointMake(width-15, width)];
    [pathL addLineToPoint:CGPointMake(0, width)];
    [pathL closePath];
    CAShapeLayer* shapeL = [CAShapeLayer layer];
    shapeL.path = pathL.CGPath;
    self.leftVideoImg.layer.mask = shapeL;
    
    //左边边线
    CAShapeLayer *borderLayer=[CAShapeLayer layer];
    borderLayer.path    =   pathL.CGPath;
    borderLayer.fillColor  = [UIColor clearColor].CGColor;
    borderLayer.strokeColor    = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    borderLayer.lineWidth      = 1;
    borderLayer.frame=self.leftVideoImg.bounds;
    [self.leftVideoImg.layer addSublayer:borderLayer];
    
    
    
    UIBezierPath* pathR = [UIBezierPath bezierPath];
    [pathR moveToPoint:CGPointMake(25, 0)];
    [pathR addLineToPoint:CGPointMake(width+10, 0)];
    [pathR addLineToPoint:CGPointMake(width+10, width)];
    [pathR addLineToPoint:CGPointMake(0, width)];
    [pathR closePath];
    CAShapeLayer* shapeR = [CAShapeLayer layer];
    shapeR.path = pathR.CGPath;
    self.rightVIdeoImg.layer.mask = shapeR;
    
    self.rightVIdeoImg.layer.mask = shapeR;
    CAShapeLayer *borderRLayer=[CAShapeLayer layer];
    borderRLayer.path    =   pathR.CGPath;
    borderRLayer.fillColor  = [UIColor clearColor].CGColor;
    borderRLayer.strokeColor    = [UIColor colorWithHexColorString:@"03a9f3"].CGColor;
    borderRLayer.lineWidth      = 1;
    borderRLayer.frame=self.rightVIdeoImg.bounds;
    [self.rightVIdeoImg.layer addSublayer:borderRLayer];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self defaultConfig];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
