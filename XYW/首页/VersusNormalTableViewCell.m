//
//  VersusNormalTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VersusNormalTableViewCell.h"
#import "UserInfoManager.h"

static NSString *const kCorverImageURLPrefix = @"http://raw.i.zuoyoupk.com/";

@interface VersusNormalTableViewCell()
@property (nonatomic,strong)UIImageView *leftWinFlagImageView;
@property (nonatomic,strong)UIImageView *rightWinFlagImageView;
@end

@implementation VersusNormalTableViewCell

- (void)defaultConfig {
    DbLog(@"配置cell");
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-kLeadingAnTringVersusNormalTableViewCell)/2;
    
    //左边遮罩
    UIBezierPath* pathL = [UIBezierPath bezierPath];
    [pathL moveToPoint:CGPointMake(0, 0)];
    [pathL addLineToPoint:CGPointMake(width+10, 0)];
    [pathL addLineToPoint:CGPointMake(width-15, width)];
    [pathL addLineToPoint:CGPointMake(0, width)];
    [pathL closePath];
    CAShapeLayer* shapeL = [CAShapeLayer layer];
    shapeL.path = pathL.CGPath;
    self.leftVideoImg.layer.mask = shapeL;
    //左边边线
    CAShapeLayer *borderLayer=[CAShapeLayer layer];
    borderLayer.path    =   pathL.CGPath;
    borderLayer.fillColor  = [UIColor clearColor].CGColor;
    borderLayer.strokeColor    = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    borderLayer.lineWidth      = 1;
    borderLayer.frame=self.leftVideoImg.bounds;
    [self.leftVideoImg.layer addSublayer:borderLayer];
    
    //    右边
    
    UIBezierPath* pathR = [UIBezierPath bezierPath];
    [pathR moveToPoint:CGPointMake(25, 0)];
    [pathR addLineToPoint:CGPointMake(width+10, 0)];
    [pathR addLineToPoint:CGPointMake(width+10, width)];
    [pathR addLineToPoint:CGPointMake(0, width)];
    [pathR closePath];
    CAShapeLayer* shapeR = [CAShapeLayer layer];
    shapeR.path = pathR.CGPath;
    
    self.rightVIdeoImg.layer.mask = shapeR;
    CAShapeLayer *borderRLayer=[CAShapeLayer layer];
    borderRLayer.path    =   pathR.CGPath;
    borderRLayer.fillColor  = [UIColor clearColor].CGColor;
    borderRLayer.strokeColor    = [UIColor colorWithHexColorString:@"03a9f3"].CGColor;
    borderRLayer.lineWidth      = 1;
    borderRLayer.frame=self.rightVIdeoImg.bounds;
    [self.rightVIdeoImg.layer addSublayer:borderRLayer];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self defaultConfig];
    self.fengexianH.constant = SINGLE_LINE_WIDTH;
}
//点击的左侧还是右侧视频
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    //get touched layer
    UIView *view = [self hitTest:point withEvent:event];
    if (view.frame.origin.x>100) {//点击了右侧的视频
        self.clickRightVideo = YES;
    }else{
        self.clickRightVideo = NO;
    }
    DbLog(@"%@",view);
}
//设置数据
-(void)setDataModel:(PKModel *)dataModel
{
    //异步处理数据，然后主线程更新UI
    __weak typeof(dataModel) wkModel = dataModel;
    __weak typeof(self) wkSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _dataModel = dataModel;
        contestantVideosModel *leftVideo = wkModel.contestantVideos.firstObject;
        CGFloat leftBens = leftVideo.praiseCnt.floatValue;
        
        contestantVideosModel *rightVideo = wkModel.contestantVideos.lastObject;
        CGFloat rightBens = rightVideo.praiseCnt.floatValue;
        //点击热区的时候取tagID和tagName
        self.tagHotArea.tag = wkModel.tagId;
        
        //设置sd图片load不缓存到内存，不解压
//        SDImageCache *cache = [SDImageCache sharedImageCache];
//        cache.shouldDecompressImages = NO;//不解压
//        cache.shouldCacheImagesInMemory = NO;//不缓存到内存
//        SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
//        downloder.shouldDecompressImages = NO;
        //设置用户信息
        [UserInfoManager  setNameLabel:wkSelf.pkLeftUserNameLabel headImageV:wkSelf.pkLeftUserIconImgV corverImageV:wkSelf.pkLeftCorverImgV with:@(leftVideo.mid)];
        [UserInfoManager setNameLabel:wkSelf.pkRightUserNameLabel headImageV:wkSelf.pkRightUserIconImgV corverImageV:wkSelf.pkRightCorverImgV with:@(rightVideo.mid)];
        
            wkSelf.leftVideoImg.tag = wkSelf.dataModel.pkID;
            wkSelf.rightVIdeoImg.tag = wkSelf.dataModel.pkID;
//        主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tagHotArea.text = wkModel.formatertagName;
                //标签名
                if (dataModel.tagActivity) {
                    wkSelf.pkTitleLabel.attributedText = [self attributedTagName:dataModel.formatertagName];
//                    wkSelf.pkTitleLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
                }else{
                    wkSelf.pkTitleLabel.text = dataModel.formatertagName;
//                    wkSelf.pkTitleLabel.textColor = [UIColor colorWithHexColorString:@"CB7EE1"];
                }
                
                //赛事点评
                wkSelf.pkSumLabel.text = dataModel.outline;
                //左边数量
                wkSelf.pkLeftUserBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)leftBens];
                //右边数量
                wkSelf.pkRightUserBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)rightBens];
                //设置pk进度条
                CGFloat total = leftBens+rightBens;
                if (total==0) {
                    wkSelf.pkprogress.percent = 0.5;
                }else{
                    if (rightBens == 0){//
                        wkSelf.pkprogress.percent = 0.98;
                    }else{
                        CGFloat percent = leftBens/total;
                        wkSelf.pkprogress.percent = percent;
                    }
                }
                //更新输赢状态
                [wkSelf updateWinType];
                //左边视频缩略图
                [self.leftVideoImg sd_setImageWithURL:[NSURL URLWithString:leftVideo.frontCover] placeholderImage:[UIImage imageNamed:@"00"]];
                //右边视频缩略图
                [self.rightVIdeoImg sd_setImageWithURL:[NSURL URLWithString:rightVideo.frontCover] placeholderImage:[UIImage imageNamed:@"00"]];
            });
        
    });
  
}
//更新界面的倒计时,
-(void)updateWinType
{
    //设置倒计时
    self.timeLabel.text = [self.dataModel currentTimeString];
    if (self.dataModel.winnerVersusContestantType&&self.dataModel.winnerVersusContestantType.length>0) {//比赛结束
        self.PKV.hidden = YES;//隐藏PK图标
        if ([self.dataModel.winnerVersusContestantType isEqualToString:@"RED"]){//红方（左边）胜利
            self.pkRightCorverImgV.image = [UIImage imageNamed:@"赛事头像corver"];
            self.pkLeftCorverImgV.image = [UIImage imageNamed:@"赛事皇冠-左"];
            self.pkLeftPKbtn.hidden = NO;
            self.leftWinFlagImageView.hidden = NO;
            self.pkRightPKbtn.hidden = YES;
            self.rightWinFlagImageView.hidden = YES;
        }else if ([self.dataModel.winnerVersusContestantType isEqualToString:@"BLUE"]){//蓝方（右边）胜利
            self.pkRightCorverImgV.image = [UIImage imageNamed:@"赛事皇冠-右"];
            self.pkLeftCorverImgV.image = [UIImage imageNamed:@"赛事头像corver"];
            self.pkLeftPKbtn.hidden = YES;
            self.leftWinFlagImageView.hidden = YES;
            self.pkRightPKbtn.hidden = NO;
            self.rightWinFlagImageView.hidden = NO;
        }
    }else{
        self.PKV.hidden = NO;//显示PK图标
        self.pkRightCorverImgV.image = [UIImage imageNamed:@"赛事头像corver"];
        self.pkLeftCorverImgV.image = [UIImage imageNamed:@"赛事头像corver"];
        self.pkLeftPKbtn.hidden = YES;
        self.pkRightPKbtn.hidden = YES;
        self.leftWinFlagImageView.hidden = YES;
        self.rightWinFlagImageView.hidden = YES;
    }
}

-(UIImage *)corverImg:(UIImage *)img
{
    @autoreleasepool {
        CGSize imgSize = img.size;
        //开启上下文
        UIGraphicsBeginImageContextWithOptions(img.size, NO, 0);
        [img drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
        UIImage *corverImg = [UIImage imageNamed:@"失败章"];
        [corverImg drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
        UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        img = nil;
        return maskedImage;
    }
    
}
/* 截取图片的话将无法描边，故仍需使用截取控件
 
////缓存之前调用的这个代理
////获取封面的时候进行裁剪
-(UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL
{
    if ([imageURL.absoluteString hasPrefix:kCorverImageURLPrefix]) {//如果是封面图
        if (imageURL.query) {//只有需要裁剪的封面图才会有“裁剪左侧”这个参数
            BOOL left = [imageURL.query isEqualToString:@"left"];
            return [self ladderImage:image isLeft:left withPersent:0.8];
        }
    }
    return image;
    
}
//裁剪这个图片
-(UIImage *)ladderImage:(UIImage *)srcImg isLeft:(BOOL)left withPersent:(CGFloat)percent
{
    //－>开始绘制图片
    UIGraphicsBeginImageContext(srcImg.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    //绘制Clip区域
    if (left) {
        CGContextMoveToPoint(gc, 0, 0);
        CGContextAddLineToPoint(gc, width, 0);
        CGContextAddLineToPoint(gc, height*percent, height);
        CGContextAddLineToPoint(gc, 0, height);
    }else{
        CGContextMoveToPoint(gc, height*(1-percent), 0);
        CGContextAddLineToPoint(gc, width, 0);
        CGContextAddLineToPoint(gc, width, height);
        CGContextAddLineToPoint(gc, 0, height);
    }
    CGContextClosePath(gc);
    CGContextClip(gc);
    
    //坐标系转换，因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
    CGContextTranslateCTM(gc, 0, height);
    CGContextScaleCTM(gc, 1, -1);
    
    //画图
    CGContextDrawImage(gc, CGRectMake(0, 0, width, height), [srcImg CGImage]);
    
    //<-结束绘画,返回图片
    UIImage *destImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();//关闭上下文
   // CGContextRelease(gc);//销毁资源
    
    return destImg;
}
*/

#pragma mark ---懒加载
-(UIImageView *)leftWinFlagImageView
{
    if (!_leftWinFlagImageView) {
        _leftWinFlagImageView = [[UIImageView alloc]init];
        _leftWinFlagImageView.image = [UIImage imageNamed:@"VersusWinFlagLeft"];
        [_leftVideoImg addSubview:_leftWinFlagImageView];
        [_leftWinFlagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(_leftVideoImg);
            make.height.with.mas_equalTo(35);
        }];
    }
    return _leftWinFlagImageView;
    
}
-(UIImageView *)rightWinFlagImageView
{
    if (!_rightWinFlagImageView) {
        _rightWinFlagImageView = [[UIImageView alloc]init];
        _rightWinFlagImageView.image = [UIImage imageNamed:@"VersusWinFlagRight"];
        [_rightVIdeoImg addSubview:_rightWinFlagImageView];
        [_rightWinFlagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_rightVIdeoImg);
            make.height.with.mas_equalTo(35);
        }];
    }
    return _rightWinFlagImageView;
    
}
-(NSAttributedString *)attributedTagName:(NSString *)tagName
{
    // 添加表情
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",tagName]];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    // 表情图片
    attch.image = [UIImage imageNamed:@"tagName活动icon"];
    // 设置图片大小
    CGSize size = attch.image.size;
    attch.bounds = CGRectMake(0, -1, (size.width/size.height)*14, 14);
    
    // 创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri appendAttributedString:string];
//    [attri addAttribute:NSForegroundColorAttributeName
//                  value:[UIColor colorWithHexColorString:@"ff4a4b"]
//                  range:NSMakeRange(0, attri.length)];
    [attri addAttributes:@{NSBaselineOffsetAttributeName:@(3),
                           NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ff4a4b"],
                           } range:NSMakeRange(0, attri.length)];
    
    return attri;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
