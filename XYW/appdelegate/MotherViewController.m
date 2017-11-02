//
//  MotherViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MotherViewController.h"
#import "SchemesModel.h"
#import "PKDetailViewController.h"
#import "AppDelegate.h"
#import "HowLoginViewController.h"
@interface MotherViewController ()

@end

@implementation MotherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self prepareSchemes];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeSchemeNoti];
}
-(void)removeSchemeNoti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCHEMES" object:nil];
}
-(void)prepareSchemes
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(schemesListen:) name:@"SCHEMES" object:nil];
}

-(void)schemesListen:(NSNotification *)noti
{
    DbLog(@"class = %@",NSStringFromClass(self.class));
    DbLog(@"listen %@",noti);
    NSDictionary *dic = noti.object;
    SchemesModel *model = [SchemesModel mj_objectWithKeyValues:dic];
    if (model.pkID&&model.pkID>0) {
        PKDetailViewController *dvc = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
        dvc.pkId = model.pkID;
        
        [self.navigationController pushViewController:dvc animated:YES];
//        UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//        [rootVC pushViewController:dvc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
