//
//  YijianfankuiViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/8/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseViewController.h"

@interface YijianfankuiViewController : BaseViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *TF;
@property (weak, nonatomic) IBOutlet UILabel *TVPlaceHolder;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UITextField *contactsTF;

@end
