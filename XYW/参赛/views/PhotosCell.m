//
//  PhotosCell.m
//  XYW
//
//  Created by xueyongwei on 16/3/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PhotosCell.h"
@interface PhotosCell()
@property (weak, nonatomic) IBOutlet UIView *corverV;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end
@implementation PhotosCell
-(void)setImage:(UIImage *)image
{
    
    self.imgView.image = image;
}
-(void)setCorver:(BOOL)corver
{
    if (corver) {
        _corverV.alpha = 0.5;
    }else{
        _corverV.alpha = 0;
    }
}
@end
