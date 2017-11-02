//
//  EditSignViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseViewController.h"

@interface EditSignViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextView *TV;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UILabel *textsNubLael;
@property (nonatomic,copy)NSString *single;
@end
