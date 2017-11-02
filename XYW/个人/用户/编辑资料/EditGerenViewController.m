//
//  EditGerenViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/5/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "EditGerenViewController.h"
#import "AppDelegate.h"

@interface EditGerenViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;
@property (weak, nonatomic) IBOutlet UIImageView *hdImgView;

@end

@implementation EditGerenViewController
{
    UIView *sexSelextView;
    UIButton *currentSexBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"编辑资料";
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self customView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"编辑资料页面"];
    [self customView];
}
-(void)customView
{
    MyselfInfoModel *myModel = [UserInfoManager mySelfInfoModel];
    
    self.nickNameTF.text = myModel.name;
    [self.hdImgView sd_setImageWithURL:[NSURL URLWithString:myModel.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
    self.sigleLabel.text = myModel.signature;
    self.nickNameTF.delegate = self;
    [self.nickNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    if (myModel.gender) {
        NSNumber *gender = myModel.gender;
        self.xingbieGo.hidden = YES;
        self.xingbieBtn.userInteractionEnabled = NO;
        self.xingbieLabel.text = gender.integerValue==0?@"女":@"男";
    }
    
}
-(void)onSaveClick:(UIButton *)sender
{
    DbLog(@"save");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onHeadImgClick:(UIButton *)sender {
    [TalkingDataGA onEvent:KBIANJITOUXIANG eventData:@{@"编辑_头像":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"编辑资料"
                                                          action:@"编辑头像"
                                                           label:nil
                                                           value:@1] build]];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册选取",@"相机拍照", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)onXingbieClick:(UIButton *)sender {
//    [self.nickNameTF resignFirstResponder];
    [TalkingDataGA onEvent:KBIANJIXINGBIE eventData:@{@"编辑_性别":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"编辑资料"
                                                          action:@"编辑性别"
                                                           label:nil
                                                           value:@1] build]];
    sexSelextView = [[[NSBundle mainBundle]loadNibNamed:@"SexSelectView" owner:self options:nil]lastObject];
    sexSelextView.alpha = 0;
    sexSelextView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    [[UIApplication sharedApplication].windows.lastObject addSubview:sexSelextView];
    [UIView animateWithDuration:0.1 animations:^{
        sexSelextView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark --上传头像
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        UIImagePickerController *photoLibraryPicker = [[UIImagePickerController alloc] init];
        photoLibraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoLibraryPicker.allowsEditing = YES;
        photoLibraryPicker.delegate = self;
        [self presentViewController:photoLibraryPicker animated:YES completion:nil];
    }else if (buttonIndex == 1)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraPicker.allowsEditing = YES;
            cameraPicker.delegate = self;
            [self presentViewController:cameraPicker animated:YES completion:nil];
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        self.hdImgView.image = image;
        [self uploadIcon:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ---点击时间的handle
- (IBAction)onCancle:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        sender.superview.alpha = 0;
        sexSelextView.alpha = 0;
        
    } completion:^(BOOL finished) {
        currentSexBtn =nil;
        self.quedingBtn.selected = NO;
        self.quedingBtn.userInteractionEnabled = NO;
        [sexSelextView removeFromSuperview];
        
    }];
}
- (IBAction)onOkCLick:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        sender.superview.alpha = 0;
        sexSelextView.alpha = 0;
    } completion:^(BOOL finished) {
        [sexSelextView removeFromSuperview];
    }];
    [self updataUserData:@{@"avatar":@"",@"name":@"",@"sign":@"",@"gender":[NSString stringWithFormat:@"%d",(int)currentSexBtn.tag-100]}];
}
- (IBAction)onSexBtnClick:(UIButton *)sender {
    currentSexBtn.selected = NO;
    sender.selected = YES;
    currentSexBtn = sender;
    DbLog(@"选择了性别:%ld",(long)sender.tag);
    self.quedingBtn.selected = YES;
    self.quedingBtn.userInteractionEnabled = YES;
}
- (IBAction)onSignClick:(UIButton *)sender {
    EditSignViewController *eds = [[EditSignViewController alloc]initWithNibName:@"EditSignViewController" bundle:nil];
    
    eds.single = [UserInfoManager mySelfInfoModel].signature;
    [self.navigationController pushViewController:eds animated:YES];
}




#pragma mark ---TF的代理
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [TalkingDataGA onEvent:kBIANJINICENG eventData:@{@"编辑_昵称":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"编辑资料"
                                                          action:@"编辑昵称"
                                                           label:nil
                                                           value:@1] build]];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    
    if (textField.text.length == 0) {
        textField.text = my.name;
    }else if(textField.text.length<2){
        CoreSVPCenterMsg(@"两个字以上的昵称才够特别哦~");
        return YES;
    }
    if ([textField.text isEqualToString:my.name]){
    }else{
        [self updataUserData:@{@"name":textField.text,@"avatar":@"",@"gender":@"",@"sign":@""}];
    }
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 16) {
        textField.text = [textField.text substringToIndex:16];
    }
}


#pragma mark ---修改资料
-(void)uploadIcon:(UIImage *)image
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyMMddHHmmss"];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    NSString *ts = [formater stringFromDate:[NSDate date]];
    //    ls+‘,’+ex+‘,’+ts+‘,’+resp+‘,’+SECRET_KEY的MD5加密后的返回值 (SECRET_KEY=zuoyoupk.net.2016)
    NSString *vc = [NSString stringWithFormat:@"10000000,png,jpg,%@,json,zuoyoupk.net.2016",ts];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
    [manager POST:KUPLOADURL parameters:@{@"resp":@"json",@"rd":@"",@"ts":ts,@"ls":@"10000000",@"ex":@"png,jpg",@"vc":vc.md5,@"wm":@"",@"rs":@"4",@"rsv":@"120,120"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"img.jpg" mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            NSDictionary *rspDic = (NSDictionary *)responseObject;
            if ([rspDic[@"statusCode"] isEqualToString:@"1"]) {
                NSArray *fileList = rspDic[@"fileList"];
                NSDictionary *file = fileList.firstObject;
                
                [self updataUserData:@{@"avatar":[file objectForKey:@"url"]}];
            }else if (rspDic[@"errCode"]){
                DbLog(@"%@",rspDic[@"errMsg"]);
                CoreSVPCenterMsg(rspDic[@"errMsg"]);
            }
        }else{
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}

/**
 * 更新资料
 *
 *  @param param 需要更新的内容，将会直接作为请求参数
 */
-(void)updataUserData:(NSDictionary *)param
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/updateInfo"] parameters:param inView:nil sucess:^(id result) {
        if (result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"code"]) {
                CoreSVPCenterMsg([result objectForKey:@"msg"]);
                [self prepareMyInfo];
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                [self.nickNameTF becomeFirstResponder];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark --- 获取最新的用户信息
-(void)prepareMyInfo
{
    [UserInfoManager refreshMyselfInfoFinished:^{
        [self customView];
    }];    
}
@end
