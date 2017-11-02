//
//  AddDescViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/31.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "AddDescViewController.h"
#import "XYWTimesLimitManager.h"
#import "ZYUploadMovieManager.h"
static NSInteger maxInputNuber = 70;
@interface AddDescViewController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *corverImageView;
@property (weak, nonatomic) IBOutlet UITextView *descTV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tfViewBottonConst;
@property (weak, nonatomic) IBOutlet UILabel *lenOfTF;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editCorverBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naviBottomConst;


@end

@implementation AddDescViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self customView];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)setCorverImage:(UIImage *)corverImage
{
    _corverImage = corverImage;
    self.bgImageView.image = corverImage;
    self.corverImageView.image = corverImage;
}
-(void)customView
{
    self.descTV.delegate = self;
    self.bgImageView.image = self.corverImage;
    self.corverImageView.image = self.corverImage;
    self.tagNameLabel.text = self.uploadTagName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    if (self.videoId>0) {//从个人主页选择的视频
        self.editCorverBtn.hidden = YES;
    }else{
        self.editCorverBtn.hidden = NO;
    }
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    
    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    self.tfViewBottonConst.constant = CGRectGetHeight(keyboardF)>216?CGRectGetHeight(keyboardF):216;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardWillHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 修改为以前的约束（距下边距200）
    self.tfViewBottonConst.constant = 200;
    // 更新约束
    [UIView animateWithDuration:keyboardDuration animations:^{
        
        [self.view layoutIfNeeded];
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.descTV resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        if (offsetRange.location < maxInputNuber) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = maxInputNuber - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.lenOfTF.text = @"0";
        }
        return NO;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > maxInputNuber)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:maxInputNuber];
        
        [textView setText:s];
    }
    
    //不让显示负数,
    self.lenOfTF.text = [NSString stringWithFormat:@"%ld",MAX(0,maxInputNuber - existTextNum)];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"点击添加描述"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length<1) {
        textView.text = @"点击添加描述";
        textView.textColor = [UIColor colorWithHexColorString:@"808080"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSetCorverClick:(UIButton *)sender {
    UIImagePickerController *photoLibraryPicker = [[UIImagePickerController alloc] init];
    photoLibraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoLibraryPicker.allowsEditing = YES;
    photoLibraryPicker.delegate = self;
    [self presentViewController:photoLibraryPicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        self.corverImage = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onBackClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onJoinPkClick:(UIButton *)sender {
    
    if ([self.moviePath hasSuffix:@"m3u8"]) {
        //        contestantVideoId=&videoId=&description=
        NSString *url = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/versus/challenge"];
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:self.uploadTagId forKey:@"tagId"];
        [param setObject:self.contestantVideoId forKey:@"contestantVideoId"];
        [param setObject:self.videoId forKey:@"videoId"];
        [param setObject:[self.descTV.text isEqualToString:@"点击添加描述"]?@"":self.descTV.text forKey:@"description"];
        [XYWhttpManager XYWpost:url parameters:param inView:nil sucess:^(id result) {
            if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"errCode"]) {
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                return ;
            }
            self.navigationController.navigationBarHidden = NO ;
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -4)] animated:YES];
            CoreSVPCenterMsg([result objectForKey:@"msg"]);
        } failure:^(NSError *error) {
            CoreSVPCenterMsg(error.localizedDescription);
        }];
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"corver.jpg"]];   // 保存文件的名称
        BOOL result = [UIImageJPEGRepresentation(self.corverImage, 1) writeToFile:filePath atomically:YES];
        if (result) {
            ZYUploadMovieManager *manager = [ZYUploadMovieManager defaultManager];
            NSString *desc = [self.descTV.text isEqualToString:@"点击添加描述"]?@"":self.descTV.text;
            [manager addTastWithCorverPath:filePath moviePath:self.moviePath movieMD5:self.movieMD5 movieSize:self.movieSize challenge:self.challenge tagID:self.uploadTagId tagName:[self.uploadTagName stringByReplacingOccurrencesOfString:@"#" withString:@""] contestantVideoId:self.contestantVideoId description:desc];
            
//            UIViewController *vc = self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-4];
//            [self.navigationController setNavigationBarHidden:NO animated:NO];
//            [self.navigationController popToViewController:vc animated:YES];
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kCaptureViewControllerStopRecod object:nil];
            }];
        }else{
            CoreSVPCenterMsg(@"读取封面失败！");
        }

    }
    
    
}

@end
