//
//  ZJPKTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZJPKTableViewCell.h"

@implementation ZJPKTableViewCell
{
    CAShapeLayer *shapeLayer;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    //创建出圆形贝塞尔曲线
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(45, 45) radius:45 startAngle:(M_PI_2) * 3.0 endAngle:(M_PI_2) * 3.0 + (M_PI) * 2.0 clockwise:YES];

    //创建出底色的CAShapeLayer
    CAShapeLayer *bgshapeLayer = [CAShapeLayer layer];
    bgshapeLayer.frame = CGRectMake(0, 0, 90, 90);
    bgshapeLayer.fillColor = [UIColor clearColor].CGColor;
    //设置线条的宽度和颜色
    bgshapeLayer.lineWidth = 13.0f;
    bgshapeLayer.strokeColor = [UIColor colorWithHexColorString:@"9ccc65"].CGColor;
    //设置stroke起始点
    bgshapeLayer.strokeStart = 0;
    bgshapeLayer.strokeEnd = 1;
    //让贝塞尔曲线与CAShapeLayer产生联系
    bgshapeLayer.path = circlePath.CGPath;
    
    //添加并显示
    [self.progessView.layer addSublayer:bgshapeLayer];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(0, 0, 90, 90);
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色
    shapeLayer.lineWidth = 13.0f;
    shapeLayer.strokeColor = [UIColor colorWithHexColorString:@"ffa000"].CGColor;
    
    //设置stroke起始点
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = self.percent;
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    shapeLayer.path = circlePath.CGPath;
    
    //添加并显示
    [self.progessView.layer addSublayer:shapeLayer];
    
}
-(void)setPercent:(NSInteger)percent
{
    _percent = percent;
    if (percent==-1) {
        shapeLayer.strokeColor = [UIColor colorWithHexColorString:@"dddddd"].CGColor;
        shapeLayer.strokeEnd = 1;
        self.persentLabel.text = @"暂无\n数据";
    }else{
        shapeLayer.strokeColor = [UIColor colorWithHexColorString:@"ffa000"].CGColor;
        shapeLayer.strokeEnd = percent*0.01;
        self.persentLabel.text = [NSString stringWithFormat:@"胜率\n%ld％",(long)percent];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
