//
//  PKCardView.m
//  PKCardView
//
//  Created by xueyongwei on 2016/11/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PKCardView.h"
static CGFloat deatPad = 5 ;
static CGFloat shapeLevel = 20 ;
@interface PKCardView()
{
    CAShapeLayer      *_contentLayerL;
    CAShapeLayer      *_contentLayerR;
    
}
@end
@implementation PKCardView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat width = self.bounds.size.width/2;
    {
        UIBezierPath* pathL = [UIBezierPath bezierPath];
        [pathL moveToPoint:CGPointMake(0, 0)];
        [pathL addLineToPoint:CGPointMake(width+shapeLevel, 0)];
        [pathL addLineToPoint:CGPointMake(width-shapeLevel-deatPad, width)];
        [pathL addLineToPoint:CGPointMake(0, width)];
        [pathL closePath];
        
        CAShapeLayer *maskLayerL = [CAShapeLayer layer];
        maskLayerL.path = pathL.CGPath;
        maskLayerL.frame = CGRectMake(0, 0, width+shapeLevel, width);
        
        _contentLayerL = [CAShapeLayer layer];
        _contentLayerL.path = pathL.CGPath;
        _contentLayerL.fillColor = [UIColor clearColor].CGColor;
        _contentLayerL.strokeColor = [UIColor redColor].CGColor;
        _contentLayerL.frame = CGRectMake(0, 0, width+shapeLevel, width);
        
        _contentLayerL.mask = maskLayerL;
        _contentLayerL.contentsScale = [UIScreen mainScreen].scale;
        _contentLayerL.contentsGravity = @"resizeAspectFill";
        [self.layer addSublayer:_contentLayerL];
    }
    {
        UIBezierPath* pathR = [UIBezierPath bezierPath];
        [pathR moveToPoint:CGPointMake( shapeLevel*2 + deatPad, 0)];
        [pathR addLineToPoint:CGPointMake(width+shapeLevel, 0)];
        [pathR addLineToPoint:CGPointMake(width+shapeLevel, width)];
        [pathR addLineToPoint:CGPointMake(0, width)];
        [pathR closePath];
        
        CAShapeLayer *maskLayerR = [CAShapeLayer layer];
        maskLayerR.path = pathR.CGPath;
        maskLayerR.frame = CGRectMake(0, 0, width+shapeLevel, width);
        
        _contentLayerR = [CAShapeLayer layer];
        _contentLayerR.path = pathR.CGPath;
        _contentLayerR.fillColor = [UIColor clearColor].CGColor;
        _contentLayerR.strokeColor = [UIColor redColor].CGColor;
        _contentLayerR.frame = CGRectMake(width-shapeLevel , 0, width+shapeLevel, width);
        _contentLayerR.mask = maskLayerR;
        _contentLayerR.contentsScale = [UIScreen mainScreen].scale;
        _contentLayerR.contentsGravity = @"resizeAspectFill";
        [self.layer addSublayer:_contentLayerR];
    }
    
}

-(void)sd_setLeftImage:(NSString *)leftImgUrl rightImage:(NSString *)rightImgUrl
{
    _contentLayerL.contents = (id)([UIImage imageNamed:@"0.jpg"].CGImage);
    _contentLayerR.contents = (id)([UIImage imageNamed:@"00.jpg"].CGImage);
}
@end
