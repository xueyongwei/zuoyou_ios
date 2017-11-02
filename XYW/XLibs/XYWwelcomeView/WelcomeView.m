//
//  WelcomeView.m
//  XYW
//
//  Created by xueyongwei on 16/8/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "WelcomeView.h"
@interface WelcomeView()
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIPageControl *pc;
@property (nonatomic,strong)UIButton *startBtn;
@property (nonatomic,strong) void(^finishBlock)(void);
@end
@implementation WelcomeView
-(id)init
{
    if (self = [super init]) {
        [self xywConfig];
    }
    return self;
}
-(void)xywConfig
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_W*115/72)];
    self.scrollView.center = CGPointMake(SCREEN_W/2, SCREEN_H/2-20);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    [self addSubview:self.scrollView];
    
    [self add1];
    [self add2];
    [self add3];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(SCREEN_W *3, 0);
    
    self.pc = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 200, 85)];
    self.pc.center = CGPointMake(SCREEN_W/2, SCREEN_H-60);
    self.pc.numberOfPages = 3;
    self.pc.currentPage = 0;
    self.pc.pageIndicatorTintColor = [UIColor colorWithHexColorString:@"e5e5e5"];
    self.pc.currentPageIndicatorTintColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    [self addSubview:self.pc];
    
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.frame = self.pc.frame;
    self.startBtn.contentMode = UIViewContentModeScaleAspectFit;
//    [self.startBtn setTitle:@"开启旅程" forState:UIControlStateNormal];
    
    [self.startBtn setImage:[UIImage loadImageNamed:@"startBtn"] forState:UIControlStateNormal];
//    [self.startBtn setBackgroundImage:[UIImage loadImageNamed:@"startBtn"] forState:UIControlStateNormal];
    
    
    self.startBtn.userInteractionEnabled = NO;
    self.startBtn.alpha = 0;
    [self.startBtn addTarget:self action:@selector(endWelcome) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.startBtn];
    
    
    
}
-(void)add1
{
    //添加背景图片
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W*115/72);
    CGPoint center = imageView.center;
    center.y = SCREEN_H/2;
    imageView.center = center;
    //        NSString *name = [NSString stringWithFormat:@"bg1",(long)i];
    imageView.image = [UIImage loadImageNamed:@"bg1"];
    [self.scrollView addSubview:imageView];
    //添加第一层动画
    UIImageView *imagesViewDp = [UIImageView new];
    imagesViewDp.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W*78/72);
    
    NSMutableArray *animgsDp = [NSMutableArray new];
    for (int i = 0; i<6; i++) {
        NSString *name = [NSString stringWithFormat:@"不撕不快-红豆%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animgsDp addObject:img];
    }
    for (int i = 4; i>=0; i--) {
        NSString *name = [NSString stringWithFormat:@"不撕不快-红豆%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animgsDp addObject:img];
    }
    imagesViewDp.animationImages = animgsDp;
    imagesViewDp.animationRepeatCount = 0;
    imagesViewDp.animationDuration = 1;
    [imagesViewDp startAnimating];
    [imageView addSubview:imagesViewDp];
    //添加闪烁动画
    UIImageView *imageAnisView = [UIImageView new];
    imageAnisView.frame = imagesViewDp.bounds;
    NSMutableArray *animages = [NSMutableArray new];
    for (int i =1; i<35; i++) {
        NSString *name = [NSString stringWithFormat:@"不撕不快-文字%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animages addObject:img];
    }
    imageAnisView.animationImages = animages;
    imageAnisView.animationRepeatCount = 0;
    imageAnisView.animationDuration = 2.0f;
    [imageAnisView startAnimating];
    [imageView addSubview:imageAnisView];
}
-(void)add2
{
    //添加背景图片
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(SCREEN_W, 0, SCREEN_W, SCREEN_W*115/72);
    CGPoint center = imageView.center;
    center.y = SCREEN_H/2;
    imageView.center = center;
    //        NSString *name = [NSString stringWithFormat:@"bg1",(long)i];
    imageView.image = [UIImage loadImageNamed:@"bg2"];
    [self.scrollView addSubview:imageView];
    //添加第一层动画
    UIImageView *imagesViewDp = [UIImageView new];
    imagesViewDp.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W*78/72);
    
    NSMutableArray *animgsDp = [NSMutableArray new];
    for (int i = 0; i<5; i++) {
        NSString *name = [NSString stringWithFormat:@"创意变现-红豆%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animgsDp addObject:img];
    }
//    imagesViewDp.animationImages = animgsDp;
    imagesViewDp.animationRepeatCount = 0;
    imagesViewDp.animationDuration = 2;
//    [imagesViewDp startAnimating];
    [imageView addSubview:imagesViewDp];

    
        for (int i = 5; i<10; i++) {
            NSString *name = [NSString stringWithFormat:@"创意变现-红豆%d",i];
            UIImage *img = [UIImage loadImageNamed:name];
            [animgsDp addObject:img];
        }
        for (int i = 9; i>4; i--) {
            NSString *name = [NSString stringWithFormat:@"创意变现-红豆%d",i];
            UIImage *img = [UIImage loadImageNamed:name];
            [animgsDp addObject:img];
        }
        for (int i = 16; i<21; i++) {
            NSString *name = [NSString stringWithFormat:@"创意变现-红豆%d",i];
            UIImage *img = [UIImage loadImageNamed:name];
            [animgsDp addObject:img];
        }
        for (int i = 19; i>15; i--) {
            NSString *name = [NSString stringWithFormat:@"创意变现-红豆%d",i];
            UIImage *img = [UIImage loadImageNamed:name];
            [animgsDp addObject:img];
        }
        imagesViewDp.animationImages = animgsDp;
        [imagesViewDp startAnimating];
    
    //添加金币闪烁动画
    UIImageView *imageAnisView = [UIImageView new];
    imageAnisView.frame = imagesViewDp.bounds;
    NSMutableArray *animages = [NSMutableArray new];
    for (int i = 0; i<8; i++) {
        NSString *name = [NSString stringWithFormat:@"创意变现-金币%ld",(long)i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animages addObject:img];
    }
    for (int j = 0; j<2; j++) {
        for (int i =8; i<35; i++) {
            NSString *name = [NSString stringWithFormat:@"创意变现-金币%ld",(long)i];
            UIImage *img = [UIImage loadImageNamed:name];
            [animages addObject:img];
        }
    }
    
    imageAnisView.animationImages = animages;
    imageAnisView.animationRepeatCount = 0;
    imageAnisView.animationDuration = 2.0f;
    [imageAnisView startAnimating];
    [imageView addSubview:imageAnisView];
}
-(void)add3
{
    //添加背景图片
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(SCREEN_W*2, 0, SCREEN_W, SCREEN_W*115/72);
    CGPoint center = imageView.center;
    center.y = SCREEN_H/2;
    imageView.center = center;
    //        NSString *name = [NSString stringWithFormat:@"bg1",(long)i];
    imageView.image = [UIImage loadImageNamed:@"bg3"];
    [self.scrollView addSubview:imageView];
    //添加第一层动画
    UIImageView *imagesViewDp = [UIImageView new];
    imagesViewDp.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W*78/72);
    
    NSMutableArray *animgsDp = [NSMutableArray new];
    for (int i = 0; i<11; i++) {
        NSString *name = [NSString stringWithFormat:@"左右胜负-旗帜%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animgsDp addObject:img];
    }
    for (int i = 9; i>=0; i--) {
        NSString *name = [NSString stringWithFormat:@"左右胜负-旗帜%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animgsDp addObject:img];
    }
    imagesViewDp.animationImages = animgsDp;
    imagesViewDp.animationRepeatCount = 0;
    imagesViewDp.animationDuration = 1;
    [imagesViewDp startAnimating];
    [imageView addSubview:imagesViewDp];
    //添加闪烁动画
    UIImageView *imageAnisView = [UIImageView new];
    imageAnisView.frame = imagesViewDp.bounds;
    NSMutableArray *animages = [NSMutableArray new];
    for (int i =1; i<9; i++) {
        NSString *name = [NSString stringWithFormat:@"左右胜负-眼睛%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animages addObject:img];
    }
    for (int i =7; i>0; i--) {
        NSString *name = [NSString stringWithFormat:@"左右胜负-眼睛%d",i];
        UIImage *img = [UIImage loadImageNamed:name];
        [animages addObject:img];
    }
    imageAnisView.animationImages = animages;
    imageAnisView.animationRepeatCount = 0;
    imageAnisView.animationDuration = 0.5;
    [imageAnisView startAnimating];
    [imageView addSubview:imageAnisView];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/SCREEN_W;
    self.pc.currentPage = page;
    if (page ==2) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.startBtn.alpha = 1;
        } completion:^(BOOL finished) {
            self.startBtn.userInteractionEnabled = YES;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.startBtn.alpha = 0;
        }completion:^(BOOL finished) {
            self.startBtn.userInteractionEnabled = NO;
        }];
    }
}
-(void)showStartClick:(void(^)(void))finishBlock
{
    self.finishBlock = finishBlock;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
-(void)endWelcome
{
    if (self.finishBlock) {
        self.finishBlock();
    }
}

@end
