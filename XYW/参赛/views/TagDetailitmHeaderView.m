//
//  itmHeaderView.m
//  testScrollInTableView
//
//  Created by xueyognwei on 17/1/22.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "TagDetailitmHeaderView.h"

@implementation TagDetailitmHeaderView
//-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithReuseIdentifier:reuseIdentifier];
//    if (self) {
////        [self customView];
//    }
//    return self;
//}
//-(void)customView{
//    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"1",@"2",nil];
//    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
//    segmentedControl.frame = CGRectMake(0, 0, 300, 50);
//    segmentedControl.selectedSegmentIndex = 2;//设置默认选择项索引
//    segmentedControl.tintColor = [UIColor clearColor];
//    
//    //定义选中状态的样式selected，类型为字典
//    NSDictionary *selected = @{NSFontAttributeName:[UIFont systemFontOfSize:20],
//                               NSForegroundColorAttributeName:[UIColor redColor]};
//    //定义未选中状态下的样式normal，类型为字典
//    NSDictionary *normal = @{NSFontAttributeName:[UIFont systemFontOfSize:10],
//                             NSForegroundColorAttributeName:[UIColor blackColor]};
//    [segmentedControl setTitleTextAttributes:normal forState:UIControlStateNormal];
//    [segmentedControl setTitleTextAttributes:selected forState:UIControlStateSelected];
//    
//    [segmentedControl addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
//    [self addSubview:segmentedControl];
//}
//-(void)valueChange:(UISegmentedControl *)segmentedControl
//{
//    NSLog(@"%ld",segmentedControl.selectedSegmentIndex);
//    if (self.delegate) {
//        [self.delegate TagDetailitmHeaderViewOnItmSelect:segmentedControl.selectedSegmentIndex];
//    }
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
