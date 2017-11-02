//
//  UHVideosTableView.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "YXTabItemBaseView.h"
#import "UHVideosTableHeader.h"
#import "UHVideosTableViewCell.h"

#import "PKDetailViewController.h"

#import "MyVideoModel.h"

#import "XYWPlayer.h"
#import "XYWAlert.h"

@interface UHVideosTableView : YXTabItemBaseView<XYWPlayerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UHVideosTableHeader *header;
@property (nonatomic,strong)XYWPlayer *xywPlayer;
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,assign)NSInteger currentPage;

-(void)stopPlay;
-(void)pause;
-(void)play;
@end
